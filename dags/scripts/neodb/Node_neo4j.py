import os
import json
import datetime
from neomodel import db, install_all_labels
from model import Experiment, Measurement, Strain, Plasmid, Bioreactor, Objective, Person, TIME_UNITS, MEASUREMENT_TYPES

def save_neo4j(run_id, file):

    # set labels
    install_all_labels()
    
    # create measurements for each BR
    with open(file, 'r') as file:
        db_output = json.load(file)
        file.close()

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

