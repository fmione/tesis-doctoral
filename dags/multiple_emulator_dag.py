import datetime as dt
import textwrap
from airflow.models.dag import DAG
from airflow.models import Variable
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.operators.empty import EmptyOperator
from airflow.utils.task_group import TaskGroup
from airflow import AirflowException
from docker.types import Mount
import os


try:
    host_path = Variable.get("host_path", deserialize_json=True)
    number_of_experiments = Variable.get("number_of_experiments", deserialize_json=True)
    t_duration = Variable.get("experiment_duration", deserialize_json=True)
    acceleration = Variable.get("acceleration", deserialize_json=True)
except:
    print("Please, add Airflow UI variables")

remote_path = os.environ.get("AIRFLOW_REMOTE_PATH")


# Check values of acceleration
if acceleration not in [1, 2, 4, 60, 54000]:
    raise AirflowException(f"Acceleration {acceleration} is not a valid value [1, 2, 4, 60, 54000]")


def base_docker_node(task_id, command, retries=3, retry_delay=dt.timedelta(minutes=2), 
                     execution_timeout=dt.timedelta(minutes=10), trigger_rule='all_success', do_xcom_push=False, 
                     image="emulator2", working_dir="/scripts/lib/multi_emulator_dag"):
    
    return DockerOperator(
        task_id=task_id,
        image=image,
        auto_remove="force",
        working_dir=f"{remote_path}/{working_dir}",
        environment=os.environ,
        command=command,
        mounts=[Mount(source=host_path, target=remote_path, type='bind')],
        mount_tmp_dir=False,
        network_mode="bridge",
        retries=retries,
        retry_delay=retry_delay,
        execution_timeout=execution_timeout,
        trigger_rule=trigger_rule,
        do_xcom_push=do_xcom_push,
    )


with DAG(
        dag_id="MultiEmulator_2.0_DAG",
        description="Kiwi multiexperiment emulator.",
        start_date=dt.datetime.now(),
        schedule_interval=None,
        catchup=False,
        is_paused_upon_creation=True
) as dag:
    
    start = EmptyOperator(task_id="start")
    last_node = start
    
    for exp in range(1, number_of_experiments + 1):

        with TaskGroup(group_id=f"experiment_{exp}"):

            init = base_docker_node(
                task_id=f"init",
                command=["python", "-c", f"from Node_init import initialize; initialize({t_duration}, {acceleration})"],
                do_xcom_push=True
            )

            start_emu = base_docker_node(
                task_id=f"start_emu",
                command=["python", "-c", "from Node_start_emulator import start_emu; start_emu()"]
            )

            save_start_time = base_docker_node(
                task_id=f"save_start_time",
                command=["python", "-c", textwrap.dedent("""
                    from database_connector import save_start_time; 
                    run_id = '{{ ti.xcom_pull(task_ids='experiment_""" + str(exp) + """.init') }}'
                    save_start_time(run_id)""")],
            )

            create_feeds = base_docker_node(
                task_id=f"create_feeds",
                command=["python", "-c", textwrap.dedent("""
                    from database_connector import create_feed_json; 
                    run_id = '{{ ti.xcom_pull(task_ids='experiment_""" + str(exp) + """.init') }}'
                    create_feed_json(f'../../../results/{run_id}/feed/feed_0.json','EMULATOR_config.json')""")]
            ) 

            save_feeds = base_docker_node(
                task_id=f"save_feeds",
                command=["python", "-c", textwrap.dedent("""
                    from database_connector import save_actions; 
                    run_id = '{{ ti.xcom_pull(task_ids='experiment_""" + str(exp) + """.init') }}'
                    save_actions(run_id, f'../../../results/{run_id}/feed/feed_0.json')""")]
            ) 

            get_feeds = base_docker_node(
                task_id=f"get_feeds",
                command=["python", "-c", "from database_connector import get_feeds; get_feeds()"]
            )

            run_emu = base_docker_node(
                task_id=f"run_emu",
                command=["python", "-c", "from Node_run_emulator import run_emu; run_emu()"]
            )

            save_measurements = base_docker_node(
                task_id=f"save_measurements",
                command=["python", "-c", textwrap.dedent("""
                    from database_connector import save_measurements; 
                    run_id = '{{ ti.xcom_pull(task_ids='experiment_""" + str(exp) + """.init') }}'
                    save_measurements(run_id)""")]
            )

            get_measurements = base_docker_node(
                task_id=f"get_measurements",
                command=["python", "-c",  textwrap.dedent("""
                    from database_connector import query_and_save; 
                    run_id = '{{ ti.xcom_pull(task_ids='experiment_""" + str(exp) + """.init') }}'
                    query_and_save(run_id, f'../../../results/{run_id}/db/db_output.json')""")]
            )

            # save_neo4j = base_docker_node(
            #     task_id=f"save_neo4j",
            #     image="neomodel",
            #     working_dir="/scripts/neodb",
            #     command=["python", "-c",  textwrap.dedent("""
            #         from Node_neo4j import save_neo4j; 
            #         run_id = '{{ ti.xcom_pull(task_ids='experiment_""" + str(exp) + """.init') }}'
            #         save_neo4j(run_id, f'../../results/{run_id}/db/db_output.json')""")]
            # )


            # last_node >> init >> start_emu >> save_start_time >> create_feeds >> save_feeds >> get_feeds >> run_emu >> save_measurements >> get_measurements >> save_neo4j
            last_node >> init >> start_emu >> save_start_time >> create_feeds >> save_feeds >> get_feeds >> run_emu >> save_measurements >> get_measurements
            
            # last_node = save_neo4j
            last_node = get_measurements


    
    