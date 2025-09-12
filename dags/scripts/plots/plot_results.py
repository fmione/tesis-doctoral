import json
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.colors import Normalize
import seaborn as sns

sns.set_theme(style="whitegrid", palette="deep", font_scale=1.2)

with open("dags/results/623/feed/strain4/feed_14.json") as file:
    feed = json.load(file)

allfeeds = np.array([feed[mbr]["setpoint_value"] for mbr in feed])

mean = np.round(np.mean(allfeeds, axis=0), 2)

print(", ".join(map(str,mean )))

comparativas = [0.0663, 0.0131, 0.021, 0.0356, 0.0047, 0.0053]
mbrs = [19425, 19426, 19433, 19434, 19441, 19442]


norm = Normalize(vmin=min(comparativas), vmax=max(comparativas))
cmap = cm.get_cmap('Blues')

def scaled_cmap(value, vmin=0, vmax=1, scale_min=0.3, scale_max=1.0):
    norm_val = (value - vmin) / (vmax - vmin)
    scaled_val = scale_min + norm_val * (scale_max - scale_min)
    return cmap(scaled_val)

plt.figure(figsize=(12, 6))

x = np.linspace(0, 16, len(mean))

for i, vec in enumerate(allfeeds):
    color = scaled_cmap(comparativas[i], min(comparativas), max(comparativas))
    plt.plot(x, vec, color=color, label=f'MBR {mbrs[i]} (comp={comparativas[i]:.4f})')
    plt.text(x[-1] + 0.2, vec[-1], f'{mbrs[i]}', fontsize=9, color='grey', va='center')


plt.plot(x, mean, color='black', linewidth=2, label='Reference (Mean)')
# plt.text(x[-1] + 0.2, mean[-1], f'reference', fontsize=9, color='grey', va='center')

plt.xlabel('Time [h]')
plt.ylabel('Cumulated feed volume')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()
