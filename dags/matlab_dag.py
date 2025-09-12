import datetime as dt
from airflow.models.dag import DAG
from airflow.utils.task_group import TaskGroup
from scripts.nodes.nodes import init_workflow, time_sensor, matlab_execution, sample_preprocess, save_preprocess_data, save_db, query_db, config


with DAG(
        dag_id="Matlab_DAG",
        description="Management of workflows with Matlab nodes.",
        start_date=dt.datetime.now(),
        schedule_interval=None,
        catchup=False,
        is_paused_upon_creation=True
) as dag:

    # path to strain definition
    strains = config["experiment_ids"].keys()

    # set results folder
    results_path = f"../results/{config['runID']}"

    # initial node 
    start = init_workflow()
    last_node = start

    # for each strain (matlab replica) create initial files, execute offline design and save initial profile feed in DB
    for strain in strains:
        with TaskGroup(group_id=f"init_{strain}_0"):

            init = matlab_execution(f"init", "Node_0", strain_path=strain)
            offline_design = matlab_execution(f"offline_design", "Node_optimizer", strain_path=strain)
            save_preprocess_0 = save_preprocess_data(config["experiment_ids"][strain], f"matlab/{strain}/VBA_feed.json", 
                                                            f"{results_path}/feed/{strain}/feed_0.json")
            save_db_0 = save_db(config["runID"], config["experiment_ids"][strain], f"{results_path}/feed/{strain}/feed_0.json")
            model_predict_0 = matlab_execution(f"model_predict", "Node_predict", timeout=20, trigger_rule="all_success", strain_path=strain)
            
            # first dependencies before loop
            start >> init >> offline_design >> save_preprocess_0 >> save_db_0
            offline_design >> model_predict_0
        
    for it in range(1, config["iterations"] + 1):
        
        time_wait = config["time_first_sample"] + config["time_to_process_sample"] + config["time_bw_samples"] * (it - 1) + (config["time_bw_samples"] if it == config["iterations"] else 0)

        # wait until next query 
        wait = time_sensor(
            task_id=f"{time_wait}_min_wait_{it}", 
            delta=dt.timedelta(minutes=time_wait))
        
        # query data from database:
        get_measurements = query_db(config["runID"], f"{it}", f"{results_path}/db/db_output_{it}.json")

        # set dependencies
        last_node >> wait >> get_measurements         

        # save last node for next iteration
        last_node = wait

        # last iteration only query db
        if it != config["iterations"]:
            
            # for each strain (matlab replica) add a taskgroup workflow
            for strain in strains:
               
                with TaskGroup(group_id=f"workflow_{strain}_{it}"):
                    # preprocess the subset of exp_ids for the specific strain
                    load_preprocess = sample_preprocess(config["experiment_ids"][strain], f"{results_path}/db/db_output_{it}.json", 
                                                        f"matlab/{strain}/db_output.json")

                    # trigger computational methods
                    update_iteration = matlab_execution(f"update_iteration", "Node_beginIter", timeout=5, strain_path=strain)
                    parameter_estimation = matlab_execution(f"parameter_reestimation", "Node_param", timeout=30, strain_path=strain)
                    online_redesign = matlab_execution(f"online_redesign", "Node_optimizer", timeout=20, trigger_rule="one_success", strain_path=strain)
                    fix_pe = matlab_execution(f"fix_pe", "Node_crash", timeout=10, trigger_rule="one_failed", strain_path=strain)
                    model_predict = matlab_execution(f"model_predict", "Node_predict", timeout=10, trigger_rule="all_success", strain_path=strain)
                    
                    # preprocess and save actions in ilab db
                    save_preprocess = save_preprocess_data(config["experiment_ids"][strain], f"matlab/{strain}/VBA_feed.json", 
                                                            f"{results_path}/feed/{strain}/feed_{it}.json")
                    save_actions_db = save_db(config["runID"], config["experiment_ids"][strain], f"{results_path}/feed/{strain}/feed_{it}.json")

                    # set dependencies
                    get_measurements >> load_preprocess >> update_iteration >> parameter_estimation >> fix_pe
                    [parameter_estimation, fix_pe] >> online_redesign >> model_predict >> save_preprocess >> save_actions_db
            
        