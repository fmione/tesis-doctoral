import json
import os
import sys

def save_formatted_file(exp_ids, input_path, output_path):

    # read feed results from Matlab files
    with open(input_path, "r") as file:
        feed = json.load(file)
        file.close()

    # creates dictionary with key: "experiment_id", value: dataframe ["measurement_time", "setpoint_value"]   
    setpoints_df = dict()
    for n, exp_id in enumerate(exp_ids, start=1):
        try:
            # create dataframe (measurement_time[seconds], setpoint_value)
            setpoints_df[exp_id] = {
                "setpoint_value": feed["NEXT"]["cum_feed_profile"][f"n{n}"], 
                "measurement_time": [int(round(m_time * 3600, 0)) for m_time in feed["NEXT"]["time_feed"][f"n{n}"]]
            }
        except:
            print(f"Setpoints creation failed for MBR: {exp_id}")

    if not os.path.isdir(os.path.dirname(output_path)):
        os.makedirs(os.path.dirname(output_path))
    with open(output_path, "w") as file:
        json.dump(setpoints_df, file)
        file.close()

# %%
if __name__ == '__main__':

    import json, os

    exp_ids = json.loads(sys.argv[1])
    input_path = sys.argv[2]
    output_path = sys.argv[3]

    # save file with the correct format. key: exp_id, value: pandas.DataFrame with (measurement_time, setpoint_value)
    save_formatted_file(exp_ids, input_path, output_path)
   