import json
import numpy as np
import matplotlib.pyplot as plt

for run_id in range(1, 401):
    with open(f'dags/results/{run_id}/db/db_output.json') as f:
        data = json.load(f)

    for exp_id in data:
        x = np.linspace(0, 16, len(data[exp_id]["measurements_aggregated"]["DOT"]["DOT"]))
        plt.plot(x, list(data[exp_id]["measurements_aggregated"]["DOT"]["DOT"].values()))


plt.xlabel('Time [h]')
plt.ylabel('DOT [%]')
plt.legend()
plt.grid(True)
plt.show()