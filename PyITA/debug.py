import os
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt


def print_matrix(from_txt: bool,
                 cut: bool = False, 
                 matrix: np.array = None, 
                 txt_file: str = 'Qp_0.txt', 
                 test_vector: str = 'data_S32_E32_P32_F64_H1_B1', 
                 row: int = 64, col: int = 64):
    
    if (from_txt):
        current_dir = os.path.dirname(os.path.abspath(__file__))
        filepath = os.path.join(os.path.dirname(current_dir),
                                    'simvectors',
                                    test_vector,
                                    'standalone',
                                    txt_file)

        array = np.loadtxt(filepath)
        if (cut):
            array = array[:4096]
        matrix = array.reshape(row, col)
    
    sns.set_theme()
    sns.heatmap(matrix, annot=False, linewidths=0, linecolor='white', cmap='crest', xticklabels=False, yticklabels=False)
    plt.title(txt_file)
    plt.xlabel(col)
    plt.ylabel(row)
    plt.show()

# print_matrix(from_txt=True, txt_file="A_soft_0.txt")





