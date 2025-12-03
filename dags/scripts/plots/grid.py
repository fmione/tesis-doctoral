import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


# Experiment ID 10
# valores = np.array([[88.376, 88.512, 86.876, 86.276, 83.681, 81.074, 79.168, 75.042], [71.784, 67.188, 58.898, 49.756, 40.499, 31.738, 24.880, 18.524], [13.514, 2.934, 1.810, 0.610, 0.311, 0.249, 0.257, 0.495]]).transpose()
valores = np.array([[356.571, 430.358, 513.598, 607.505, 713.450, 832.979, 967.835, 1119.988], [1291.659, 1485.354, 1703.902, 1950.495, 2228.734, 2542.685, 2896.933, 3296.654], [3747.687, 4256.622, 4830.896, 5478.899, 6210.101, 7035.186, 7966.211, 9016.782]]).transpose()
df = pd.DataFrame(valores, index=list('ABCDEFGH'), columns=[2, 3, 4])

plt.figure(figsize=(6,8))
color = sns.color_palette("crest", as_cmap=True)

ax = sns.heatmap(df, annot=True, fmt=".2f", cmap=color, cbar=True, cbar_kws={'label': ''})

colorbar = ax.collections[0].colorbar
# colorbar.set_label('DOT min [$\%$]', fontsize=14, fontweight='bold', labelpad=15)
colorbar.set_label('Alimentación acumulada [$\mu l$]', fontsize=14, fontweight='bold', labelpad=15)
colorbar.ax.tick_params(labelsize=11)

plt.xlabel("Columna", fontweight='bold', fontsize=11)
plt.ylabel("Fila", fontweight='bold', fontsize=11)

plt.tight_layout()
plt.show()
