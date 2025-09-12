import os
import sys
import pandas as pd
from db_loader import read_run

runID = int(sys.argv[1])
filepath = sys.argv[2]
rootdir = os.getcwd()

db_json = read_run(runID)


# save JSON file for historical monitoring
if not os.path.isdir(os.path.dirname(f"{rootdir}/{filepath}")):
    os.makedirs(os.path.dirname(f"{rootdir}/{filepath}"))

pd.DataFrame(db_json).to_json(f"{rootdir}/{filepath}")