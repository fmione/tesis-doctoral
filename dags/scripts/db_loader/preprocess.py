import pandas as pd
import json
import os
import sys


def load_exp_ids(exp_ids, input_path, output_path):
    
    with open(f"{input_path}", "r") as file:
        file_measurements = json.load(file)
        file.close()
        
    filter_exp_ids = {exp_id: file_measurements[str(exp_id)] for exp_id in exp_ids}
    pd.DataFrame(filter_exp_ids).to_json(f"{output_path}")
    return


if __name__ == '__main__':

    exp_ids = json.loads(sys.argv[1])
    input_path = sys.argv[2]
    output_path = sys.argv[3]

    load_exp_ids(exp_ids, input_path, output_path)