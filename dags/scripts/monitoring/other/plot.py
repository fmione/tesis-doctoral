import json 
import matplotlib.pyplot as plt
import numpy as np

feeds_wf = []
for it_wf in range(8):
     f = open(f"dags/results/623/feed/strain1/feed_{it_wf}.json")
     feeds_wf.append(json.load(f))
     f.close()

feeds_dot = []
for it_wf in range(1, 51):
     f = open(f"dags/results/623/feed/strain1/dot/feed_{it_wf}.json")
     feeds_dot.append(json.load(f))
     f.close()

plt.figure()
for index, feed in enumerate(feeds_dot):
     plt.plot(np.array(feed["19419"]["measurement_time"]) / 3600,
                    feed["19419"]["setpoint_value"], label=f"it_{index}")
          
plt.legend()
plt.xlabel("Time [h]")
plt.ylabel("Concentration")
plt.title("Feeds 19419")
plt.show()

# for measure in ["Acetate", "DOT", "Glucose", "OD600", "Feed_glc_cum_setpoints"]:

#      plt.figure()
#      for exp_id in [19431, 19432, 19433, 19434]:

#           if measure == "Feed_glc_cum_setpoints":
#                plt.plot(np.array(list(results[str(exp_id)]["setpoints"]["cultivation_age"].values())) / 3600,
#                     list(results[str(exp_id)]["setpoints"][measure].values()), label=exp_id)
#           else:
#                plt.plot(np.array(list(results[str(exp_id)]["measurements_aggregated"][measure]["measurement_time"].values())) / 3600,
#                     list(results[str(exp_id)]["measurements_aggregated"][measure][measure].values()), label=exp_id)


#      plt.legend()
#      plt.xlabel("Time [h]")
#      plt.ylabel("Concentration")
#      plt.title(measure)
# plt.show()