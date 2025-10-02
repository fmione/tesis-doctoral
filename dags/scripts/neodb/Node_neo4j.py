import os
import json
import datetime
from neomodel import db, install_all_labels
from model import Experiment, Measurement, Strain, Plasmid, Bioreactor, Objective, Person, TIME_UNITS, MEASUREMENT_TYPES, WORKFLOW_NODE_TRIGGER_RULES, WORKFLOW_NODE_STATUS

def save_neo4j(run_id, file):

    # set labels
    install_all_labels()
    
    # create measurements for each BR
    with open(file, 'r') as file:
        db_output = json.load(file)

    with db.transaction:

        # TODO: checks if experiment exists and throws an error

        # TODO: delete this line in production MODE
        # db.cypher_query("match (n) detach delete n")

        # experiment node creation with metadata content
        exp = Experiment(run_id=run_id, start_time=datetime.datetime.now(), horizon=16, horizon_unit=TIME_UNITS["h"]).save()

        for exp_id in db_output:
            # create br instance
            br = Bioreactor(exp_id=int(exp_id), position="A2").save()
            exp.bioreactor.connect(br)

            # iterates and creates measurements
            if br:
                for measurement_type, measurement_values in db_output[exp_id]["measurements_aggregated"].items():
                    # avoid units
                    if measurement_type in MEASUREMENT_TYPES:
                        for index, m_time in measurement_values["measurement_time"].items():                            
                            measurement = Measurement(type=measurement_type, time=m_time, time_unit=TIME_UNITS["s"], value=measurement_values[measurement_type][index], value_unit="").save()
                            measurement.bioreactor.connect(br)




def save_neo4j_2(run_id, file):

    # set labels (si usás Neomodel)
    install_all_labels()

    with open(file, 'r') as file:
        db_output = json.load(file)

    # TODO: checks if experiment exists and throws an error

    # TODO: delete this line in production MODE
    # db.cypher_query("MATCH (n) DETACH DELETE n")

    # Crear el nodo de Experiment directamente con Cypher
    db.cypher_query(
        """
        CREATE (e:Experiment {
            run_id: $run_id,
            start_time: $start_time,
            horizon: $horizon,
            horizon_unit: $horizon_unit
        })
        """,
        {
            "run_id": run_id,
            "start_time": int(datetime.datetime.now().timestamp()), #TODO: save real date
            "horizon": 16,
            "horizon_unit": TIME_UNITS["h"],
        }
    )

    # Crear bioreactores y conectarlos al experimento
    br_rows = []
    for exp_id in db_output:
        br_rows.append({"exp_id": int(exp_id), "position": "A2"})

    db.cypher_query(
        """
        UNWIND $rows AS row
        MATCH (e:Experiment {run_id: $run_id})
        CREATE (b:Bioreactor {exp_id: row.exp_id, position: row.position})
        CREATE (e)-[:INCLUDES]->(b)
        """,
        {"rows": br_rows, "run_id": run_id}
    )

    # Crear measurements en batches grandes
    meas_query = """
    UNWIND $rows AS row
    MATCH (b:Bioreactor {exp_id: row.exp_id})
    CREATE (m:Measurement {
        type: row.type,
        time: row.time,
        time_unit: row.time_unit,
        value: row.value,
        value_unit: row.value_unit
    })
    CREATE (m)-[:SAMPLE_FROM]->(b)
    """

    rows = []
    for exp_id in db_output:
        for measurement_type, measurement_values in db_output[exp_id]["measurements_aggregated"].items():
            if measurement_type in MEASUREMENT_TYPES:
                for index, m_time in measurement_values["measurement_time"].items():
                    rows.append({
                        "type": measurement_type,
                        "time": m_time,
                        "time_unit": TIME_UNITS["s"],
                        "value": measurement_values[measurement_type][index],
                        "value_unit": "",
                        "exp_id": int(exp_id)
                    })

                    # ejecutar en batches de 5000 para no explotar memoria
                    if len(rows) >= 5000:
                        db.cypher_query(meas_query, {"rows": rows})
                        rows = []

    # ejecutar lo que quedó
    if rows:
        db.cypher_query(meas_query, {"rows": rows})

    # almacenar los parametros del emulador
    save_emulator_parameters(run_id)



def save_emulator_parameters(run_id):

    with open("../lib/multi_emulator_dag/EMULATOR_config.json", 'r') as file:
        config_file = json.load(file)

    param_names = ["$q_{s,max}$", "$q_{sOx,max}$", "$q_{Ac,max}$", "$Y_{P_{leak}}$", "$Y_{xsOx}$", "$Y_{Ap}$", "$Y_{ax}$", "$Y_{P_{ind}}$", "$Y_{OA}$", "$Y_{OS}$", "$Y_{xsOf}$", "$K_S$",
                   "$K_A$", "$K_{iSA}$", "$K_{iAS}$", "$K_{O}$"] + ["$K_{lAl}_{"+str(mbr)+"}$" for mbr in range(1, 25)] + ["$K_{m}_{"+str(mbr)+"}$" for mbr in range(1, 25)]
    


    db.cypher_query(
        """
            MATCH (e:Experiment {run_id: $run_id})
            CREATE (wn:WorkflowNode {
                task_id: 'start',
                trigger_rule: $trigger_rule,
                status: $status,
                init_time: $time
            })
            CREATE (e)-[:HAS_COMPUTATIONAL_WORKFLOW]->(wn)

            WITH wn, $values AS values, $names AS names
            UNWIND range(0, size(values)-1) AS i
            CREATE (pr:ModelParameter {name: names[i], value: values[i]})
            CREATE (wn)-[:ESTIMATES]->(pr)
        """,
        {
            "values": config_file["Params"], 
            "trigger_rule": WORKFLOW_NODE_TRIGGER_RULES['all_success'], 
            "status": WORKFLOW_NODE_STATUS['success'], 
            "names": param_names,
            "run_id": run_id, 
            "time": int(datetime.datetime.now().timestamp())
        }
    )
