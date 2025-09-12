import datetime as dt
import os
from airflow.models.dag import DAG
from airflow.models import Variable
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.sensors.time_delta import TimeDeltaSensor
from airflow.utils.task_group import TaskGroup
from docker.types import Mount
from dags.scripts.lib.emulator2.method_createDesign_Script import t_duration, acceleration

try:
    host_path = Variable.get("host_path", deserialize_json=True)
except:
    print("Host path has not been addded to the airflow UI variables or it has not been done correctly!")
    host_path = ""

remote_path = os.environ.get("AIRFLOW_REMOTE_PATH")

def base_docker_node(task_id, command, retries=3, retry_delay=dt.timedelta(minutes=2), 
                     execution_timeout=dt.timedelta(minutes=10), trigger_rule='all_success'):
    
    return DockerOperator(
        task_id=task_id,
        image="emulator2",
        auto_remove="force",
        working_dir=f"{remote_path}/scripts/lib/emulator2",
        environment=os.environ,
        command=command,
        mounts=[Mount(source=host_path, target=remote_path, type='bind')],
        mount_tmp_dir=False,
        network_mode="bridge",
        retries=retries,
        retry_delay=retry_delay,
        execution_timeout=execution_timeout,
        trigger_rule=trigger_rule 
    )


with DAG(
        dag_id="Emulator_2.0_DAG",
        description="Kiwi experiment emulator.",
        start_date=dt.datetime.now(),
        schedule_interval=None,
        catchup=False,
        is_paused_upon_creation=True
) as dag:
    
    clean_db = base_docker_node(
        task_id=f"clean_db",
        command=["python", "-c", "from database_connector import delete_data; delete_data(623)"]
    )  

    start_emu = base_docker_node(
        task_id=f"start_emu",
        command=["python", "-c", "from Node_start_emulator import start_emu; start_emu()"],
    )

    save_start_time = base_docker_node(
        task_id=f"save_start_time",
        command=["python", "-c", "from database_connector import save_start_time; save_start_time()"],
    )

    clean_db >> start_emu >> save_start_time
    last_node = save_start_time

    # iterations every hour to group tasks
    for hours in range(int(t_duration)):

        with TaskGroup(group_id=f"{hours + 1}_hour{'s' if hours+1 > 1 else ''}_tasks"):
        
            # iteration every 5 minutes (65 to include the last bound) or 1 iteration of 1 minute if acceleration is 60
            for minutes in range(5, 65, 5) if acceleration == 1 else [1]:

                time = int(hours * 60 / acceleration) + minutes

                wait = TimeDeltaSensor(
                    task_id=f"wait_{time}_min", 
                    poke_interval=30, trigger_rule='all_done', 
                    delta=dt.timedelta(minutes=time)
                )

                get_feeds = base_docker_node(
                    task_id=f"get_feeds_{time}",
                    command=["python", "-c", "from database_connector import get_feeds; get_feeds()"],
                )

                run_emu = base_docker_node(
                    task_id=f"run_emu_{time}",
                    command=["python", "-c", "from Node_run_emulator import run_emu; run_emu()"],
                )

                save_db_emu = base_docker_node(
                    task_id=f"save_db_{time}",
                    command=["python", "-c", "from database_connector import save_measurements; save_measurements()"],
                )

                last_node >> wait >> get_feeds >> run_emu >> save_db_emu
                last_node = save_db_emu
    