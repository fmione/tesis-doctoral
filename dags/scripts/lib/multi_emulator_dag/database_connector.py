import sqlalchemy
import datetime
import json
import pytz
import pandas as pd
import numpy as np
import os
import sys
import uuid

def get_connection_url():
    host = os.environ.get("MYSQL_HOST")
    port = os.environ.get("MYSQL_PORT")
    user = os.environ.get("MYSQL_USER")
    password = os.environ.get("MYSQL_PASSWORD")
    database = os.environ.get("MYSQL_DATABASE")

    return f'mysql+mysqlconnector://{user}:{password}@{host}:{port}/{database}'

# Timezone definition:
local_tz = pytz.timezone('Europe/Amsterdam')

db = get_connection_url()
engine = sqlalchemy.create_engine(db, echo=False)


# **********************************************************************************
#                       MEASUREMENTS functions
# **********************************************************************************


def save_start_time(run_id):
    """
    Saves the start time of the simulation
    """

    # get time start absolute from EMULATOR_design
    with open('EMULATOR_design.json', "r") as file:
        design_file = json.load(file) 

    sql_query = " UPDATE runs SET start_time = '{}' WHERE run_id = '{}' ".format(
        datetime.datetime.fromtimestamp(design_file["time_start_absolute"], tz=local_tz).strftime('%Y-%m-%d %H:%M:%S'), run_id)

    conn = engine.connect()
    conn.execute(sqlalchemy.text(sql_query))
    conn.close()


def get_measuring_setup_id(conn, variable_type, run_id):
    """
    Get variable_setup_id from a variable_type parameter
    """

    # get measuring setup id (from variable type)   
    sql_query = f"""
        SELECT measuring_setup_id FROM measuring_setup 
        WHERE run_id = '{run_id}' AND variable_type_id = 
            (SELECT variable_type_id FROM variable_types WHERE canonical_name = '{variable_type}' );
    """
    res_msetup = conn.execute(sqlalchemy.text(sql_query)).mappings().all()  

    return res_msetup[0]["measuring_setup_id"]



def delete_measuring_setup_id_data(conn, experiment_id, measuring_setup_id):
    """
    Delete all the measurements for a particular measuring_setup_id and experiment_id
    """

    # delete all the measurements from an specific measuring setup id and exp_id
    sql_query = f"""
        DELETE FROM measurements_experiments WHERE measuring_setup_id = '{measuring_setup_id}' 
                    AND experiment_id = '{experiment_id}' AND label= 'dummy';
    """

    conn.execute(sqlalchemy.text(sql_query))
    


def send_data_to_ilab(conn, experiment_id, measuring_setup_id, start_time, measurements):
    """
    Saves measurements in iLab DB
    """

    # concatenates all the values for an specific exp_id and measurement, to insert in one query
    query_all = ""
    for measurement_time, value in measurements:
        timestamp = (start_time + datetime.timedelta(seconds=measurement_time)).strftime('%Y-%m-%d %H:%M:%S')
        query_all += f"""({measuring_setup_id}, {experiment_id}, "{timestamp}", 1, 1, {value}, 1, NULL, 'dummy'),"""

    if query_all != "":
        sql_query = f"""
            INSERT INTO measurements_experiments (measuring_setup_id, experiment_id, measurement_time, dilution_factor, valid, measured_value, checksum, sampling_id, label) 
            VALUES {query_all[:-1]};
        """
            
        conn.execute(sqlalchemy.text(sql_query))


def save_measurements(run_id):
    """
    Save all the measurements for all the MBRs. Deletes the current measurements and saves the new ones.
    """

    # get start time from design file
    with open('EMULATOR_design.json', "r") as file:
        design_file = json.load(file) 
        file.close()

    start_time = datetime.datetime.fromtimestamp(design_file["time_start_absolute"], tz=local_tz)

    # get all the measurements from file
    with open('db_emulator.json', "r") as file:
        mbrs_measurements = json.load(file) 
        file.close()

    # TODO: check measurement harcoded array  
    measurement_types = ["OD600", "DOT", "Acetate", "Glucose", "Fluo_RFP", "Volume", "Temperature", "Flow_Air", "StirringSpeed", "Acid", "Base", 
                    "Cumulated_feed_volume_glucose", "Cumulated_feed_volume_medium", "Fluo_CFP", "Fluo_RFP", "Probe_Volume", "Volume_evaporated", "pH"]
    
    conn = engine.connect() 

    # set isolation level to SERIALIZABLE
    conn.execution_options(isolation_level='SERIALIZABLE')

     # begin a transaction
    with conn.begin():
        for exp_id in mbrs_measurements:
            
            # TODO: get all measurement_setup_id in one query
            for measurement in measurement_types:
                try:
                    measurement_list = mbrs_measurements[exp_id]["measurements_aggregated"][measurement]
                    # get measuring_setup_id once for measurement canonical name
                    measuring_setup_id = get_measuring_setup_id(conn, measurement, run_id)

                    # delete all values from type of measurement
                    delete_measuring_setup_id_data(conn, exp_id, measuring_setup_id)

                    # save all the data
                    send_data_to_ilab(conn, exp_id, measuring_setup_id, start_time, zip(measurement_list["measurement_time"].values(), measurement_list[measurement].values()))
                
                except Exception as e:
                    print(f"Error on {exp_id} - {measurement}")
                    pass


def get_feeds():
    """
    Get feeds profile for all the MBRs
    """
    
    conn = engine.connect() 

    # get all the measurements from file
    with open('db_emulator.json', "r") as file:
        mbrs_measurements = json.load(file) 
        file.close()

    profile_ids = [mbrs_measurements[exp_id]["metadata"]["profile_id"]["0"] for exp_id in mbrs_measurements]

    sql_query = f"""SELECT setpoint_id, profile_id, cultivation_age, setpoint_value AS 'Feed_glc_cum_setpoints' 
                    FROM setpoints WHERE profile_id IN {tuple(profile_ids)} AND variable_type_id=99"""

    new_setpoints = pd.read_sql(sql_query, conn)
    conn.close()

    # TODO: check if there are 11 extra data in setpoints into every exp_id (start from 11th value)
    for idx, exp_id in enumerate(mbrs_measurements):

        setpoints_df = pd.DataFrame.from_dict(mbrs_measurements[exp_id]["setpoints"]).replace(np.nan, None)
        setpoints_df.index = setpoints_df.index.astype("int") 
        setpoints_df.sort_index(inplace=True)

        # concatenates first 11 values from other setpoint data with new profile setpoints
        updated_setpoints_df = pd.concat([setpoints_df[:11], new_setpoints[new_setpoints["profile_id"] == int(profile_ids[idx])][["setpoint_id","cultivation_age","Feed_glc_cum_setpoints"]]], ignore_index=True).replace(np.nan, None)
        updated_setpoints_df.index = updated_setpoints_df.index.astype("string")
        mbrs_measurements[exp_id]["setpoints"].update(updated_setpoints_df.to_dict())
    
    with open('db_emulator.json', "w") as file:
        json.dump(mbrs_measurements, file) 
        file.close()


def create_feed_json(filename_db, filename_feed):
    """
    Creates the feed.json file with the correct format
    """

    with open(filename_feed) as json_file:   
        feed_dict = json.load(json_file)

    new_profile = {}
    
    for i1 in feed_dict:
        # try catch to avoid extra fields in the json file than exp_ids
        try:
            f_pulse_new=np.array(list(feed_dict[str(i1)]['Pulse_profile']['Feed_pulse']))    
            tf_new=np.array(list(feed_dict[str(i1)]['Pulse_profile']['time_pulse']))*3600                        
            
            new_profile[str(i1)] = {}
            new_profile[str(i1)]['measurement_time']=tf_new.astype(int).tolist()
            new_profile[str(i1)]['setpoint_value']=np.cumsum(f_pulse_new).tolist()
        except:
            pass
        
    if not os.path.isdir(os.path.dirname(filename_db)):
        os.makedirs(os.path.dirname(filename_db))

    with open(filename_db, "w") as file:
        json.dump(new_profile, file)
        file.close()


# **********************************************************************************
#          GET measurements, metadata, setpoints FROM query and save file
# **********************************************************************************

def get_metadata(run_id):
    """
    Get metadata for a run_id from the database
    """

    # TODO: just start_time by now
    sql_metadata = f""" 
        SELECT start_time FROM runs WHERE run_id = '{run_id}' 
    """
    conn = engine.connect()
    res = conn.execute(sqlalchemy.text(sql_metadata))
    conn.close()
    return pd.DataFrame(res)


def get_measurements(run_id):
    """
    Get all the measurements for a run_id from the database. Grouped by (exp_id, measurement)
    """
    
    sql_measurements = f"""
        SELECT exp.experiment_id, vt.canonical_name, m_exp.measurement_time, m_exp.measured_value 
        FROM bioreactors bio
        LEFT JOIN runs ON bio.run_id = runs.run_id 
        LEFT JOIN experiments exp ON bio.bioreactor_id = exp.bioreactor_id
        INNER JOIN measurements_experiments m_exp ON m_exp.experiment_id = exp.experiment_id
        INNER JOIN measuring_setup m_set ON m_exp.measuring_setup_id = m_set.measuring_setup_id
        INNER JOIN variable_types vt ON vt.variable_type_id = m_set.variable_type_id
        WHERE runs.run_id = {run_id}
    """
    conn = engine.connect()
    res = conn.execute(sqlalchemy.text(sql_measurements))
    conn.close()

    res_df = pd.DataFrame(res)
    return res_df.groupby(["experiment_id", "canonical_name"]) if res_df.shape[0] else res_df


def get_setpoints(run_id):
    """
    Get all the setpoints for a run_id from the database. Grouped by (exp_id, setpoints)
    """

    sql_setpoints = f"""
        SELECT exp.experiment_id, vt.canonical_name, sp.cultivation_age, sp.setpoint_value 
        FROM bioreactors bio
        INNER JOIN runs ON bio.run_id = runs.run_id 
        INNER JOIN experiments exp ON bio.bioreactor_id = exp.bioreactor_id
        INNER JOIN setpoints sp ON sp.profile_id = exp.profile_id
        INNER JOIN variable_types vt ON vt.variable_type_id = sp.variable_type_id
        WHERE runs.run_id = {run_id}
    """
    conn = engine.connect()
    res = conn.execute(sqlalchemy.text(sql_setpoints))
    conn.close()
    
    res_df = pd.DataFrame(res)
    return res_df.groupby(["experiment_id", "canonical_name"]) if res_df.shape[0] else res_df


def read_run(run_id):
    """
    creates a json file with metadata, setpoints and measurements for an specific run_id
    """
    
    # initial data
    json_data = {}
    
    # get metadata
    metadata_df = get_metadata(run_id)
    # metadata_df["start_time"]

    # get setpoints
    setpoints_groups_df = get_setpoints(run_id)
     
    # get measurements
    measurements_groups_df = get_measurements(run_id)

    # iterate setpoints groups
    for (exp_id, variable), group in setpoints_groups_df:
        # rename column by variable type
        group.rename(columns={"setpoint_value": variable}, inplace=True)

        # init template for each exp id. Add setpoint as json with 11 null values. 
        # Reset index: to start from 0 for each measurement count of the original dataframe
        json_data[exp_id] = {
            "metadata": {}, 
            "setpoints": json.loads(group.reset_index()[["cultivation_age", variable]].shift(periods=11).to_json()), 
            "measurements_aggregated": {}}
        
    # iterate measurements groups
    for (exp_id, variable), group in measurements_groups_df:
        # rename column by variable type
        group.rename(columns={"measured_value": variable}, inplace=True)
        group["time"] = group["measurement_time"]

        # calculate relative time (measurement_time - experiment start time)
        def calculate_sample_time(measurement):
            return pd.Timedelta(measurement[["time"]][0] - metadata_df["start_time"][0]).total_seconds()
        group["measurement_time"] = group.apply(calculate_sample_time , axis=1)

        # add measurements for each exp id. 
        # Reset index: to start from 0 for each measurement count of the original dataframe
        json_data[exp_id]["measurements_aggregated"][variable] = json.loads(group.reset_index()[["measurement_time", variable]].to_json()) 

    return json_data


def query_and_save(run_id, filepath):
    """
    Get all the information from a run_id
    """

    rootdir = os.getcwd()

    db_json = read_run(run_id)


    # save JSON file for historical monitoring
    if not os.path.isdir(os.path.dirname(f"{rootdir}/{filepath}")):
        os.makedirs(os.path.dirname(f"{rootdir}/{filepath}"))

    pd.DataFrame(db_json).to_json(f"{rootdir}/{filepath}")


# **********************************************************************************
#                   FEEDS functions FROM save actions file
# **********************************************************************************


def get_profile_ids(connection, run_id):
    """
    Returns the profile ids and name for a given run_id

    Parameters
    ----------
    connection: sqlalchemy.engine.Connection
        Connection to mysql db using sqlalchemy.
    run_id: int
        Identification number for a experiment.
    """
    query = sqlalchemy.text(f"SELECT profiles.profile_id, profiles.profile_name, experiments.experiment_id "
                            f"FROM profiles "
                            f"INNER JOIN experiments ON profiles.profile_id=experiments.profile_id "
                            f"WHERE run_id = {run_id};"
                            )

    return pd.read_sql(query, connection)


def delete_setpoints(connection, run_id, exp_id, from_time = 0, type_id = 99):
    """
    Deletes setpoints from a given run_id and bioreactor, from a given time on.

    Parameters
    ----------
    connection: sqlalchemy.engine.Connection
        Connection to mysql db using sqlalchemy.
    run_id: int
        Identification number for a experiment.
    exp_id: int
        The exp_id value for the MBR in the current run_id.
    from_time: int/float
        The time (in seconds) from which the setpoints want to be deleted.
    type_id: int
        Which setpoint want to be changed. In the database, this would be the 'variable_type_id' column.

    """
    print(
        f"Attention! This will delete the setpoint data for run {run_id} and bioreactor exp_id {exp_id} after experiment"
        f"time {from_time}s. Press enter to continue and q to quit.")

    profiles = get_profile_ids(connection, run_id)
    profile_id = profiles.loc[profiles['experiment_id'] == exp_id]['profile_id'].iloc[0]
    query = f" DELETE FROM setpoints " \
            f" WHERE profile_id = {profile_id} AND variable_type_id = {type_id} AND cultivation_age > {from_time}; "
    

    connection.execute(sqlalchemy.text(query))


def add_setpoints(connection, run_id, exp_id, setpoint_df, type_id = 99):
    """
    Adds setpoints to a given experiment (run_id) in a specific position (profile_name).

    Parameters
    ----------
    connection: sqlalchemy.engine.Connection
        Connection to mysql db using sqlalchemy.
    run_id: int
        Identification number for a experiment.
    exp_id: int
        The exp_id value for the MBR in the current run_id.
    setpoint_df: pandas.DataFrame
        A dataframe with two columns measurement_time and setpoint_value
    type_id: int
        Which setpoint want to be changed. In the database, this would be the 'variable_type_id' column.

    """
    profiles = get_profile_ids(connection, run_id)
    profile_id = profiles.loc[profiles['experiment_id'] == exp_id]['profile_id'].iloc[0]
    setpoint_df.rename(columns={'measurement_time': 'cultivation_age'}, inplace=True)
    setpoint_df['profile_id'] = profile_id
    setpoint_df['variable_type_id'] = type_id
    setpoint_df['scope'] = 'e'
    setpoint_df['checksum'] = 1  # IDK what is this
    setpoint_df.to_sql('setpoints', con=connection, if_exists='append', index=False, method="multi")



def save_actions(run_id, file_path):
    """
    Main function to save all feeding profiles for MBRs for a run_id and a file containing the feeds.
    """

    with open(file_path, "r") as file:
        feed = json.load(file)
        file.close()

    setpoints_df = dict()
    for exp_id in feed:
        setpoints_df[exp_id] = pd.DataFrame.from_dict(feed[exp_id])

    # delete setpoint and add new values for each exp_id (mbr)
    with engine.connect() as connection:
        with connection.begin():
            for exp_id in setpoints_df:
                delete_setpoints(connection, run_id, int(exp_id))
                add_setpoints(connection, run_id, int(exp_id), setpoints_df[exp_id])


# **********************************************************************************
#                CLEAN experiment functions FROM delete data file
# **********************************************************************************


def get_exp_ids (run_id, engine):
    """
    Get experiments IDs for a run_id
    """

    sql_query = f"""
        SELECT experiment_id FROM experiments exp 
        INNER JOIN bioreactors bio ON exp.bioreactor_id = bio.bioreactor_id
        WHERE bio.run_id = {run_id} ORDER BY container_number ASC"""
    df = pd.read_sql(sql_query, engine)
    min_value= df["experiment_id"].min()
    max_value = df["experiment_id"].max()

    return min_value,max_value


def deleteMeasurements (min_exp, max_exp, engine):
    """
    Delete all the measurements for a range of experiments IDs
    """
    sql_query = f"""
        DELETE FROM measurements_experiments 
        WHERE label = 'dummy' AND  experiment_id BETWEEN {min_exp} AND {max_exp} """
    engine.execute(sql_query)


def delete_data(run_id):
    """
    Delete all the information for an specific run_id
    """
    min_exp, max_exp = get_exp_ids(run_id, engine)
    deleteMeasurements(min_exp, max_exp, engine)
    
    # TODO: delete setpoints



# **********************************************************************************
#                CREATE new experiment tables for MULTI SIMULATION
# **********************************************************************************

def create_new_experiment_tables():

    # create RUN
    sql_query = f"""
        INSERT INTO runs (run_id,run_name,folder_id,pms_id,status_id,start_time,end_time,description,conclusion,container_label,is_template) 
        VALUES (NULL,'KIWI_dummydata_{uuid.uuid4}',103,2,2,NOW(),NULL,NULL,NULL,NULL,0);
    """
    res_run = engine.execute(sqlalchemy.text(sql_query))

    # create BIOREACTOR
    sql_query = f"""
        INSERT INTO bioreactors (bioreactor_id,run_id,bioreactor_number,bioreactor_type_id,description) 
        VALUES (NULL,{res_run.lastrowid},1,6,NULL);

    """
    res_bioreactor = engine.execute(sqlalchemy.text(sql_query))

    # create PROFILES
    position = ['A2', 'A3', 'A4', 'B2', 'B3', 'B4', 'C2', 'C3', 'C4', 'D2', 'D3', 'D4', 'E2', 'E3', 'E4', 'F2', 'F3', 'F4', 'G2', 'G3', 'G4', 'H2', 'H3', 'H4']
    values = ",\n".join(
        f"(NULL, '{position[i]}', NULL, 6, 58, 5, NULL, {res_run.lastrowid})" for i in range(24)
    )

    sql_query = f"""
        INSERT INTO profiles (profile_id, profile_name, folder_id, organism_id, plasmid_id, medium_id, description, run_id)
        VALUES {values};
    """

    res_profile = engine.execute(sqlalchemy.text(sql_query))

    # create EXPERIMENTS
    values = ",\n".join(
        f"(NULL, {res_bioreactor.lastrowid}, 19, {res_profile.lastrowid + i}, NULL, NULL,'dummy',NULL)" for i in range(24)
    )

    sql_query = f"""
        INSERT INTO experiments (experiment_id, bioreactor_id, container_number, profile_id, starter_culture_id, inactivation_method_id, description, color)
        VALUES {values};
    """

    res_experiments = engine.execute(sqlalchemy.text(sql_query))
    
    # create MEASURING SETUP
    variable_type = [(8, "OD600"), (18, "Glucose"), (28, "DOT"), (40, "Acetate"), (64, "Fluo_RFP")]
    values = ",\n".join(
        f"(NULL, {res_run.lastrowid}, 'e', {vt_id}, NULL, NULL)" for vt_id, _ in variable_type
    )

    sql_query = f"""
        INSERT INTO measuring_setup (measuring_setup_id, run_id, `scope`, variable_type_id, device_id, analysis_method_id)
        VALUES {values};
     """

    res_measuring_setup = engine.execute(sqlalchemy.text(sql_query))

    return res_run.lastrowid, res_bioreactor.lastrowid, res_profile.lastrowid, res_experiments.lastrowid, res_measuring_setup.lastrowid

