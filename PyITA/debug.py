import os
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt


def print_matrix(from_txt: bool, matrix: np.array = None, 
                                 txt_file: str = 'Out_soft_0.txt', 
                                 test_vector: str = 'data_S30_E30_P50_F64_H1_B0', 
                                 row: int = 128, col: int = 128):
    
    if (from_txt):
        current_dir = os.path.dirname(os.path.abspath(__file__))
        filepath = os.path.join(os.path.dirname(current_dir),
                                    'simvectors',
                                    test_vector,
                                    'standalone',
                                    txt_file)

        array = np.loadtxt(filepath)
        matrix = array.reshape(row, col)
    
    sns.set_theme()
    sns.heatmap(matrix, annot=False, linewidths=0, linecolor='white', cmap='crest', xticklabels=False, yticklabels=False)
    plt.show()

# print_matrix(from_txt=True, txt_file="A_soft_0.txt")





