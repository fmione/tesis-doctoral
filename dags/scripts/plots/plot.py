# import json
# import numpy as np
# import matplotlib.pyplot as plt
# import seaborn as sns

# sns.set_theme(style="darkgrid")

# for run_id in range(1, 401):
#     with open(f'dags/results/{run_id}/db/db_output.json') as f:
#         data = json.load(f)

#     for exp_id in data:
#         x = np.linspace(0, 16, len(data[exp_id]["measurements_aggregated"]["DOT"]["DOT"]))
#         plt.plot(x, list(data[exp_id]["measurements_aggregated"]["DOT"]["DOT"].values()))


# plt.xlabel('Time [$h$]', fontweight='bold', fontsize=11)
# plt.ylabel('DOT [$\%$]', fontweight='bold', fontsize=11)
# # plt.legend()
# plt.tight_layout()
# plt.show()




import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import json
import seaborn as sns
import os


os.environ["KMP_DUPLICATE_LIB_OK"]="TRUE"


def plot_emulator_training():
    sns.set_theme(style="darkgrid")

    for species, sp_name in enumerate(["OD600", "DOT"]):

        for run_id in range(1, 401):
            with open(f'dags/results/{run_id}/db/db_output.json') as f:
                data = json.load(f)       
            
            for idx, mbr in enumerate(data):
                df = pd.DataFrame({"time": data[mbr]["measurements_aggregated"][sp_name]["measurement_time"], "value": data[mbr]["measurements_aggregated"][sp_name][sp_name]})

                # Convert time to hours
                df["time"] = df["time"] / 3600
                
                # Convert OD600 to biomass
                if sp_name == "OD600":                
                    df["value"] = df["value"] / 2.7027

                # lines
                plt.plot(df["time"], df["value"])

        if sp_name == "DOT":
            plt.ylim(0, 105)
            plt.axhline(y=20, color="#636363", linestyle='--')
            plt.text(x=0.2, y=20 + 1.5, s="DOT constraint",   color='#636363', fontsize=10)
            plt.ylabel("DOT [$\%$]", fontweight='bold')
        else:
            plt.ylabel("Biomass [$g.l^{-1}$]", fontweight='bold')

        plt.xlabel(f"Time [$h$]", fontweight='bold')        
        plt.tight_layout()
        # plt.show()

        os.makedirs(os.path.dirname("plots/"), exist_ok=True)
        plt.savefig(f"plots/{sp_name}.png", dpi=600)
        plt.clf()

    


plot_emulator_training()