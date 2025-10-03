import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

valores = np.random.rand(8, 3) 
df = pd.DataFrame(valores, index=list('ABCDEFGH'), columns=[2, 3, 4])

plt.figure(figsize=(6,8))
color = sns.color_palette("crest", as_cmap=True)
sns.heatmap(df, annot=True, fmt=".2f", cmap=color, cbar=True)

plt.xlabel("Columna", fontweight='bold', fontsize=11)
plt.ylabel("Fila", fontweight='bold', fontsize=11)

plt.tight_layout()
plt.show()
