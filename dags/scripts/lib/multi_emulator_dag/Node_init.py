import json
import copy
import numpy as np
from database_connector import create_new_experiment_tables
from method_create_design import create_design

def initialize(t_duration, acceleration):

    # init database
    run_id, bioreactor_id, profile_id, exp_id, _  = create_new_experiment_tables()

    exp_ids = np.arange(exp_id, exp_id + 24)
    position = ['A2', 'A3', 'A4', 'B2', 'B3', 'B4', 'C2', 'C3', 'C4', 'D2', 'D3', 'D4', 'E2', 'E3', 'E4', 'F2', 'F3', 'F4', 'G2', 'G3', 'G4', 'H2', 'H3', 'H4']

    # to return run_id as XCom in Airflow and use it in next tasks
    print(run_id)

    # create template
    mbr_template = json.load(open('mbr_template.json', 'r'))
    emu_template = {}
    for i, mbr in enumerate(exp_ids):
        emu_template[str(mbr)] = copy.deepcopy(mbr_template)
        emu_template[str(mbr)]["metadata"]["bioreactor_id"]["0"] = str(bioreactor_id)
        emu_template[str(mbr)]["metadata"]["experiment_id"]["0"] = str(mbr)
        emu_template[str(mbr)]["metadata"]["profile_id"]["0"] = str(profile_id + i)
        emu_template[str(mbr)]["metadata"]["profile_name"]["0"] = position[i]

    with open("db_emulator_template.json", 'w') as f:
        json.dump(emu_template , f)

    # create design
    create_design(exp_ids, t_duration, acceleration)
