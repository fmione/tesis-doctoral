import datetime as dt
import os
import json
from airflow.models import Variable
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.operators.empty import EmptyOperator
from airflow.sensors.time_delta import TimeDeltaSensor
from scripts.operators.matlab_operator import MatlabOperator
from docker.types import Mount
from scripts.neodb.helper import NeomodelHelper


# KIWI-exp directory paths for mounting the docker volumes. CHANGE!
try:
    host_path = Variable.get("host_path", deserialize_json=True)
except:
    print("Host path has not been addded to the airflow UI variables or it has not been done correctly!")
    host_path = ""

remote_path = os.environ.get("AIRFLOW_REMOTE_PATH")
matlab_path = os.environ.get("MATLAB_REMOTE_PATH")

try:
    config = Variable.get("matlab_dag_definition", deserialize_json=True)
except:
    config = json.load(open(remote_path + "/config_matlab.json", 'rb'))["matlab_dag_definition"]

# create helper instance to create Neo4j nodes
neohelper = NeomodelHelper()

# --------------------- BASE OPERATOR DEFINITION -----------------------

# matlab license error callback
def matlab_retry_callback(context):
    if "Licensing error" not in str(context["exception"]):
        context["ti"].set_state("failed")


def matlab_execution(task_id, file_name, timeout=20, trigger_rule='all_done', strain_path=""):
    return MatlabOperator(
        task_id=task_id,
        image="federm20/matlab-vba:v1.0.0",
        auto_remove="force",
        working_dir=f"{matlab_path}/scripts/matlab",
        user="root",
        command=f'sudo matlab -batch "strain=\'{strain_path}\'; run(\'{file_name}\')"',
        environment=os.environ,
        mounts=[Mount(source=host_path, target=matlab_path, type='bind'),
                Mount(source=os.path.dirname(host_path)+"/images/matlab/", target=os.environ.get("MATLAB_LICENSE_PATH"), type='bind')],
        mount_tmp_dir=False,
        network_mode="bridge",
        mac_address=os.environ.get('MATLAB_MAC_ADDRESS'),
        retries=4,
        retry_delay=dt.timedelta(minutes=1),
        execution_timeout=dt.timedelta(minutes=timeout),
        trigger_rule=trigger_rule,
        on_retry_callback=matlab_retry_callback,
        on_execute_callback=neohelper.create_workflow_node, 
        on_success_callback=neohelper.on_success_execution,
        on_failure_callback=neohelper.update_workflow_node_status
    )

def base_python_execution(task_id, command, retries=3, retry_delay=dt.timedelta(minutes=2), 
        execution_timeout=dt.timedelta(minutes=10), trigger_rule='all_success', on_execute_callback=neohelper.create_workflow_node, 
        on_success_callback=neohelper.on_success_execution, on_failure_callback=neohelper.update_workflow_node_status):
    
    return DockerOperator(
        task_id=task_id,
        image="emulator2",
        auto_remove="force",
        working_dir=f"{remote_path}/scripts",
        environment=os.environ,
        command=command,
        mounts=[Mount(source=host_path, target=remote_path, type='bind')],
        mount_tmp_dir=False,
        network_mode="bridge",
        retries=retries,
        retry_delay=retry_delay,
        execution_timeout=execution_timeout,
        trigger_rule=trigger_rule,
        on_execute_callback=on_execute_callback, 
        on_success_callback=on_success_callback, 
        on_failure_callback=on_failure_callback
    )

# ---------------------- PARTICULAR NODES DEFINITION ---------------------

def sample_preprocess(exp_ids, fileinput=None, fileoutput=None):
    return base_python_execution(
        task_id=f"load_preprocess",
        command=["python", "db_loader/preprocess.py", json.dumps(exp_ids), fileinput, fileoutput],
    )

def query_db(runID, iteration, filepath=None):
    return base_python_execution(
        task_id=f"get_measurements_{iteration}",
        command=["python", "db_loader/query_and_save.py", str(runID), filepath],
        on_success_callback=neohelper.add_measurements
    )

def save_preprocess_data(exp_ids, fileinput=None, fileoutput=None):
    return base_python_execution(
        task_id=f"save_preprocess",
        command=["python", "db_save/preprocess.py", json.dumps(exp_ids), fileinput, fileoutput]
    )

def save_db(runID, exp_ids, filepath=None):
    return base_python_execution(
        task_id=f"save_db",
        command=["python", "db_save/save_actions.py", str(runID), filepath, json.dumps(exp_ids)],
    )

def init_workflow():
    return EmptyOperator(
        task_id="start", 
        on_execute_callback=neohelper.init_experiment_metadata,  
        on_success_callback=neohelper.update_workflow_node_status, 
        on_failure_callback=neohelper.update_workflow_node_status
        )

def empty(task_id):
    return EmptyOperator(
        task_id=task_id, 
        on_execute_callback=neohelper.create_workflow_node, 
        on_success_callback=neohelper.update_workflow_node_status, 
        on_failure_callback=neohelper.update_workflow_node_status
    )

def time_sensor(task_id, delta):
    return TimeDeltaSensor(
        task_id=task_id, 
        poke_interval=30, 
        trigger_rule='all_done', 
        delta=delta,
        on_execute_callback=neohelper.create_workflow_node, 
        on_success_callback=neohelper.update_workflow_node_status, 
        on_failure_callback=neohelper.update_workflow_node_status
    )