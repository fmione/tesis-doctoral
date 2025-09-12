import sys
import pandas as pd
import sqlalchemy
import json
import os

def run2ids(engine, runID):
    """
    Returns the profile ids and name for a given runID

    Parameters
    ----------
    engine: sqlalchemy.engine.Engine
        Connection to mysql db using sqlalchemy.
    runID: int
        Identification number for a experiment.
    """
    query = sqlalchemy.text(f"SELECT profiles.profile_id, profiles.profile_name, experiments.experiment_id "
                            f"FROM profiles "
                            f"INNER JOIN experiments ON profiles.profile_id=experiments.profile_id "
                            f"WHERE run_id = {runID};"
                            )

    return pd.read_sql(query, engine)


def delete_setpoints(engine, runID, exp_id, from_time = 0, type_id = 99):
    """
    Deletes setpoints from a given runID and bioreactor, from a given time on.

    Parameters
    ----------
    engine: sqlalchemy.engine.Engine
        Connection to mysql db using sqlalchemy.
    runID: int
        Identification number for a experiment.
    exp_id: int
        The exp_id value for the MBR in the current runID.
    from_time: int/float
        The time (in seconds) from which the setpoints want to be deleted.
    type_id: int
        Which setpoint want to be changed. In the database, this would be the 'variable_type_id' column.

    """
    print(
        f"Attention! This will delete the setpoint data for run {runID} and bioreactor exp_id {exp_id} after experiment"
        f"time {from_time}s. Press enter to continue and q to quit.")
    # res = input()
    # if res == "q":
    #     sys.exit()

    profiles = run2ids(engine, runID)
    profile_id = profiles.loc[profiles['experiment_id'] == exp_id]['profile_id'].iloc[0]
    query = f" DELETE FROM setpoints " \
            f" WHERE profile_id = {profile_id} AND variable_type_id = {type_id} AND cultivation_age > {from_time}; "
    
    with engine.connect() as connection:
        connection.execute(sqlalchemy.text(query))


def add_setpoints(engine, runID, exp_id, setpoint_df, type_id = 99):
    """
    Adds setpoints to a given experiment (runID) in a specific position (profile_name).

    Parameters
    ----------
    engine: sqlalchemy.engine.Engine
        Connection to mysql db using sqlalchemy.
    runID: int
        Identification number for a experiment.
    exp_id: int
        The exp_id value for the MBR in the current runID.
    setpoint_df: pandas.DataFrame
        A dataframe with two columns measurement_time and setpoint_value
    type_id: int
        Which setpoint want to be changed. In the database, this would be the 'variable_type_id' column.

    """
    profiles = run2ids(engine, runID)
    profile_id = profiles.loc[profiles['experiment_id'] == exp_id]['profile_id'].iloc[0]
    setpoint_df.rename(columns={'measurement_time': 'cultivation_age'}, inplace=True)
    setpoint_df['profile_id'] = profile_id
    setpoint_df['variable_type_id'] = type_id
    setpoint_df['scope'] = 'e'
    setpoint_df['checksum'] = 1  # IDK what is this
    setpoint_df.to_sql('setpoints', con=engine, if_exists='append', index=False, method="multi")


def get_connection_url():
    host = os.environ.get("MYSQL_HOST")
    port = os.environ.get("MYSQL_PORT")
    user = os.environ.get("MYSQL_USER")
    password = os.environ.get("MYSQL_PASSWORD")
    database = os.environ.get("MYSQL_DATABASE")

    return f'mysql+mysqlconnector://{user}:{password}@{host}:{port}/{database}'

# %%
if __name__ == '__main__':

    runID = int(sys.argv[1])
    file_path = sys.argv[2]
    exp_ids = json.loads(sys.argv[3])

    db = get_connection_url()    
    engine = sqlalchemy.create_engine(db, echo=False)

    with open(file_path, "r") as file:
        feed = json.load(file)
        file.close()

    setpoints_df = dict()
    for exp_id in feed:
        setpoints_df[exp_id] = pd.DataFrame.from_dict(feed[exp_id])

    # delete setpoint and add new values for each exp_id (mbr)
    for exp_id in setpoints_df:
        delete_setpoints(engine, runID, int(exp_id))
        add_setpoints(engine, runID, int(exp_id), setpoints_df[exp_id])
   