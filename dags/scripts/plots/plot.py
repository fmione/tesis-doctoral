import json
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

sns.set_theme(style="darkgrid")

for run_id in range(1, 401):
    with open(f'dags/results/{run_id}/db/db_output.json') as f:
        data = json.load(f)

    for exp_id in data:
        x = np.linspace(0, 16, len(data[exp_id]["measurements_aggregated"]["DOT"]["DOT"]))
        plt.plot(x, list(data[exp_id]["measurements_aggregated"]["DOT"]["DOT"].values()))


plt.xlabel('Time [h]', fontweight='bold', fontsize=11)
plt.ylabel('DOT [$\%$]', fontweight='bold', fontsize=11)
# plt.legend()
plt.grid(True)
plt.show()
# plt.savefig("CS2-all-DOT.png", dpi=600)