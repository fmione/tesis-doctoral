from scripts.neodb.model import ComputationalMethod, ComputationalEnvironment, Model, Experiment, Measurement, Strain, Plasmid, FeedingConfig, InductionConfig, Bioreactor, Objective, Person, WorkflowNode, FeedingSetpoint, ModelState, ModelParameter, TIME_UNITS, WORKFLOW_NODE_STATUS, WORKFLOW_NODE_TRIGGER_RULES, MEASUREMENT_TYPES
from neomodel import db, install_all_labels
import yaml, json, datetime
import os, re
import datetime
import pandas as pd
import numpy as np

class NeomodelHelper:

    def __init__(self):
        # neomodel funtion to update models
        install_all_labels()

    def get_metadata(self):
        with open(f"{os.getcwd()}/dags/metadata.yaml", 'r') as file:
            metadata = yaml.safe_load(file)
            file.close()
        return metadata

    def extract_number(self, f):
            s = re.findall("\d+",f)
            return (int(s[0]) if s else -1,f)

    @db.transaction
    def init_experiment_metadata(self, context):
        # get metadata from file
        metadata = self.get_metadata()

        # TODO: checks if experiment exists and throws an error

        # TODO: delete this line in production MODE
        db.cypher_query("match (n) detach delete n")

        # experiment node creation with metadata content
        exp = Experiment(**{**metadata["experiment"], "start_time": datetime.datetime.now()}).save()

        # start first workflow node and add dag params in relation
        wfn = WorkflowNode(
            task_id="start", 
            trigger_rule=WORKFLOW_NODE_TRIGGER_RULES["all_success"], 
            status=WORKFLOW_NODE_STATUS["running"], 
            init_time=datetime.datetime.now()
        ).save()
        exp.workflow_node.connect(wfn, metadata["computational_workflow_definition"])
        
        # create br instances
        for group in metadata["mbrs_groups"]:
            for exp_id in metadata["mbrs_groups"][group]["exp_ids"]:
                br_node = Bioreactor(exp_id=exp_id, position="", **metadata["mbrs_config"]).save()
                exp.bioreactor.connect(br_node)

                # connect to strain node
                strain = Strain.get_or_create({"name": metadata["mbrs_groups"][group]["strain"]})
                br_node.strain.connect(strain[0])

                # connect to plasmid node
                plasmid = Plasmid.get_or_create({"name": metadata["mbrs_groups"][group]["plasmid"]})
                br_node.plasmid.connect(plasmid[0])

        # checks if person (responsible) exists, otherwise creates it
        for person in metadata["responsible"]:
            responsible = Person.get_or_create({"name": person["name"]})
            exp.person.connect(responsible[0], {"rol": person["rol"]})

        # create objective instance
        objective = Objective.get_or_create(metadata["objective"])
        exp.objective.connect(objective[0])

        # create feeding config
        feeding = FeedingConfig(**metadata["feeding_config"]).save()
        exp.feeding_config.connect(feeding)

        # create induction config
        induction = InductionConfig(**metadata["induction_config"]).save()
        exp.induction_config.connect(induction)

        print("--------- End init ---------")


    def add_measurements(self, context):
        # get metadata from file
        metadata = self.get_metadata()

        # call add workflow node status to update information and get workflow_node
        workflow_node = self.update_workflow_node_status(context)

        # get iteration number
        try:
            iter = int(context["ti"].task_id.split("_")[-1])
        except:
            print("No iteration found")

        # create measurements for each BR
        with open(f"{os.getcwd()}/dags/results/{metadata['experiment']['run_id']}/db/db_output_{iter}.json", 'r') as file:
            db_output = json.load(file)
            file.close()

        with db.transaction:
            for exp_id in db_output:

                existing, _ = db.cypher_query(
                    """
                    MATCH (br:Bioreactor {exp_id:$exp_id})<-[]-(m:Measurement)
                    RETURN m.type as type, m.time as time
                    """,
                    dict(exp_id=int(exp_id))
                )
                existing_set = {(row[0], row[1]) for row in existing}

                for measurement_type, measurement_values in db_output[exp_id]["measurements_aggregated"].items():
                    if measurement_type not in MEASUREMENT_TYPES:
                        continue

                    batch = []
                    for index, m_time in measurement_values["measurement_time"].items():
                        if (measurement_type, m_time) not in existing_set:
                            print(f"Adding measurement: BR {exp_id}, Type: {measurement_type}, Time: {m_time}")
                            batch.append({
                                "type": measurement_type,
                                "time": m_time,
                                "value": measurement_values[measurement_type][index]
                            })

                    if batch:
                        db.cypher_query(
                            """
                            UNWIND $batch as row
                            MATCH (br:Bioreactor {exp_id:$exp_id})
                            CREATE (m:Measurement {type:row.type, time:row.time, time_unit:$time_unit, value:row.value, value_unit:''})
                            CREATE (m)-[:SAMPLE_FROM]->(br)
                            WITH m
                            MATCH (wf:WorkflowNode {task_id:$workflow_task_id})
                            CREATE (wf)-[:GETS]->(m)
                            """,
                            dict(
                                exp_id=int(exp_id),
                                batch=batch,
                                time_unit=TIME_UNITS["s"],
                                workflow_task_id=context["ti"].task_id,
                            )
                        )

        print("--------- End measurement ---------")


    @db.transaction
    def create_workflow_node(self, context):
        # get metadata from file
        metadata = self.get_metadata()
        # create WorkflowNode
        wfn = WorkflowNode(task_id=context["ti"].task_id, trigger_rule=context["task"].trigger_rule, init_time=context["task"].start_date, status=WORKFLOW_NODE_STATUS["running"]).save()
        
        # create relation with all the predecessor WorkflowNodes (dependencies)
        print(context["task"].upstream_task_ids)
        for task_dep_id in context["task"].upstream_task_ids:
            results, _ = db.cypher_query("MATCH (exp:Experiment{run_id: $run_id})-[*]->(n:WorkflowNode{task_id: $task_id}) RETURN n", dict(run_id=metadata["experiment"]["run_id"], task_id=task_dep_id), resolve_objects=True)
            try:
                results[0][0].workflow_node.connect(wfn)
            except:
                print(f"No node match: {task_dep_id}")

        print("--------- End create workflow node ---------")


    @db.transaction
    def update_workflow_node_status(self, context):
        # get metadata from file
        metadata = self.get_metadata()
        
        # get WorkflowNode with task_id
        results, _ = db.cypher_query("MATCH (exp:Experiment{run_id: $run_id})-[*]->(n:WorkflowNode{task_id: $task_id}) RETURN n", dict(run_id=metadata["experiment"]["run_id"], task_id=context["ti"].task_id), resolve_objects=True)
        
        print(context["ti"].state)

        # update end_time and status
        results[0][0].end_time = datetime.datetime.now()
        results[0][0].status = context["ti"].state
        results[0][0].save()

        print("--------- End update status ---------")

        return results[0][0]
    
    
    def on_success_execution(self, context):
        # get metadata from file
        metadata = self.get_metadata()

        # call add workflow node status to update information and get workflow_node
        workflow_node = self.update_workflow_node_status(context)

        if "parameter" in context["ti"].task_id:
            self.add_parameters(context, workflow_node, metadata)
            # pass

        if "save_preprocess" in context["ti"].task_id:
            self.add_setpoints(context, workflow_node, metadata)
            # pass

        if "predict" in context["ti"].task_id:
            self.add_state_prediction(context, workflow_node, metadata)
            # pass


    # callbacks for online redesign nodes (600 secs interval)
    @db.transaction
    def add_setpoints(self, context, workflow_node, metadata): 
        # get group from taskID
        current_group = next((g for g in metadata["mbrs_groups"] if g in context["ti"].task_id), None)

        # get iteration number
        try:
            iter = int(context["ti"].task_id.split(".")[0].split("_")[-1])
        except:
            print("No iteration found")
        
        # get data        
        with open(f"{os.getcwd()}/dags/results/{metadata['experiment']['run_id']}/feed/{current_group}/feed_{iter}.json", 'r') as file:
            feeds_file = json.load(file)

        feed_records = []
        for exp_id, rows in feeds_file.items():
            feed_records.append({
                "exp_id": int(exp_id),
                "time": rows["measurement_time"],
                "value": rows["setpoint_value"]
            })

        db.cypher_query(
            """
            UNWIND $feeds AS feed
            MATCH (br:Bioreactor {exp_id:feed.exp_id})
            MATCH (wf:WorkflowNode {task_id:$workflow_task_id})
            CREATE (fs:FeedingSetpoint {
                time:feed.time,
                time_unit:$time_unit,
                value:feed.value,
                value_unit:'µL'
            })
            CREATE (fs)-[:FEEDS]->(br)
            CREATE (wf)-[:CALCULATES]->(fs)
            """,
            {
                "feeds": feed_records,
                "workflow_task_id": context["ti"].task_id,
                "time_unit": TIME_UNITS["s"]
            }
        )

        # add computational_method
        comp_method_node = ComputationalMethod.get_or_create({"name": "Setpoint"})[0]
        workflow_node.computational_method.connect(comp_method_node)

        # add computational_environment
        comp_env_node = ComputationalEnvironment(cpu="Intel i5 4570", ram="16mb", operating_system="WSL").save()
        workflow_node.computational_environment.connect(comp_env_node)


        print("--------- End feeding ---------")


    # callback for PE 
    @db.transaction
    def add_parameters(self, context, workflow_node, metadata):
        # get group from taskID
        current_group = next((g for g in metadata["mbrs_groups"] if g in context["ti"].task_id), None)

        # get iteration number
        try:
            iter = int(context["ti"].task_id.split(".")[0].split("_")[-1])
        except:
            print("No iteration found")
        
        # param list definition
        param_list = ["qs_max", "qm", "qa_p_max", "qa_c_max", "Yxs_em", "Yas_of", "Yxa", "Yos", "Yoa", "Yps", "ds_ox_p", 
              "klal_mbr_1", "klal_mbr_2", "klal_mbr_3", "klal_mbr_4", "klal_mbr_5", "klal_mbr_6", 
              "kp_mbr_1", "kp_mbr_2", "kp_mbr_3", "kp_mbr_4", "kp_mbr_5", "kp_mbr_6"]
        param_units = ["$g.g^{-1}.h^{-1}$", "$g.g^{-1}.h^{-1}$", "$g.g^{-1}.h^{-1}$", "$g.g^{-1}.h^{-1}$", "$g.g^{-1}$", "$g.g^{-1}$", 
               "$g.g^{-1}$", "$g.g^{-1}$", "$g.g^{-1}$", "$g.g^{-1}$", "-", "$h^{-1}$", "$h^{-1}$", "$h^{-1}$", "$h^{-1}$", "$h^{-1}$",
               "$h^{-1}$", "$h^{-1}$", "$h^{-1}$", "$h^{-1}$", "$h^{-1}$", "$h^{-1}$", "$h^{-1}$"]

        # get data
        with open(f"{os.getcwd()}/dags/scripts/matlab/{current_group}/VBA_log.json", 'r') as file:
            param_file = json.load(file)

        # get model
        model_node = Model.get_or_create({"name": "Anane2017", "description": "None"})[0]

        # calculate real param and std from nominal version
        param_nominal=np.array(param_file['config'][f"iter{iter}"]['inF']['TH_nominal'])
        index_th=np.array(param_file['config'][f"iter{iter}"]['inF']['index_th'])-1

        posterior_param=np.array(param_file['config'][f"iter{iter}"]['priors']['muTheta'])
        real_param=param_nominal[index_th]*posterior_param

        std_posterior_param=np.diag(np.array(param_file['config'][f"iter{iter}"]['priors']['SigmaTheta']))
        std_real_param=param_nominal[index_th]*std_posterior_param

        # create nodes
        for idx, param in enumerate(param_list):
            parameter_node = ModelParameter(name=param, unit=param_units[idx], 
                                            mean=real_param[idx], variance=std_real_param[idx]).save()
            
            # asociate node with current task in the workflow
            workflow_node.model_parameter.connect(parameter_node)
            
            # asociate with model
            parameter_node.model.connect(model_node)


        param_records = [
            {
                "name": p,
                "unit": u,
                "mean": float(real_param[i]),
                "variance": float(std_real_param[i])
            }
            for i, (p, u) in enumerate(zip(param_list, param_units))
        ]

        db.cypher_query(
            """
            UNWIND $params AS p
            MATCH (wf:WorkflowNode {task_id:$workflow_task_id})
            MATCH (m:Model {name:$model_name})
            CREATE (mp:ModelParameter {
                name:p.name,
                unit:p.unit,
                mean:p.mean,
                variance:p.variance
            })
            CREATE (wf)-[:ESTIMATES]->(mp)
            CREATE (mp)-[:PART_OF]->(m)
            """,
            {
                "params": param_records,
                "workflow_task_id": context["ti"].task_id,
                "model_name": "Anane2017"
            }
        )

        # TODO: add computational_method
        comp_method_node = ComputationalMethod.get_or_create({"name": "Parameter"})[0]
        workflow_node.computational_method.connect(comp_method_node)

        # TODO: add computational_environment
        comp_env_node = ComputationalEnvironment(cpu="Intel i5 4570", ram="16mb", operating_system="WSL").save()
        workflow_node.computational_environment.connect(comp_env_node)

        print("--------- End param ---------")

    
    # callback for model state predictions 
    @db.transaction
    def add_state_prediction(self, context, workflow_node, metadata):
        # get group from taskID
        current_group = next((g for g in metadata["mbrs_groups"] if g in context["ti"].task_id), None)

        # get iteration number
        try:
            iter = context["ti"].task_id.split(".")[0].split("_")[-1]
        except:
            print("No iteration found")

        # TODO: get species:
        species_list = {"ns1": "Biomass", "ns2": "Acetate", "ns3": "Glucose", "ns4": "Fluo_RFP", "ns5": "DOT"}
                
        # get model
        model_node = Model.get_or_create({"name": "Anane2017", "description": "None"})[0]

        # get data
        with open(f"{os.getcwd()}/dags/scripts/matlab/{current_group}/VBA_digitalTwin.json", 'r') as file:
            dtwin_file = json.load(file)

        state_records = []
        for br_index, exp_id in enumerate(metadata["mbrs_groups"][current_group]["exp_ids"], start=1):
            for m_index, measurement in species_list.items():
                # state_row [time, value]
                for time_val, value in dtwin_file[f"iter{iter}"]["x_prediction"][f"n{br_index}"][m_index]:
                    state_records.append({
                        "exp_id": int(exp_id),
                        "type": measurement,
                        "time": time_val,
                        "value": value
                    })

        db.cypher_query(
            """
            UNWIND $states AS st
            MATCH (br:Bioreactor {exp_id:st.exp_id})
            MATCH (wf:WorkflowNode {task_id:$workflow_task_id})
            MATCH (m:Model {name:$model_name})
            CREATE (ms:ModelState {
                type:st.type,
                time:st.time,
                time_unit:$time_unit,
                value:st.value,
                value_unit:'-'
            })
            CREATE (br)<-[:PREDICTION_FOR]-(ms)
            CREATE (wf)-[:PREDICTS]->(ms)
            CREATE (ms)-[:PART_OF]->(m)
            """,
            {
                "states": state_records,
                "workflow_task_id": context["ti"].task_id,
                "model_name": "Anane2017",
                "time_unit": TIME_UNITS['h']
            }
        )

        # add computational_method
        comp_method_node = ComputationalMethod.get_or_create({"name": "Prediction"})[0]
        workflow_node.computational_method.connect(comp_method_node)

        # add computational_environment
        comp_env_node = ComputationalEnvironment(cpu="Intel i5 4570", ram="16mb", operating_system="WSL").save()
        workflow_node.computational_environment.connect(comp_env_node)

        print("--------- End prediction ---------")


    # TODO: add callback for retry in tasks

