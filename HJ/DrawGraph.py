import csv
import ctypes
import os
import sys
import math
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image, ImageChops
import mpld3


# read csv file then draw graph for each
def draw_graph(option_data, time_data, diff_data, result_path):
    
    X = []
    Y = []
    Z = []
            
    for a in time_data:
        
        a = a.strip(" (s)")
        print(a)
        temp1 = float(a.split(" : ")[0])
        temp2 = float(a.split(" : ")[1])
        temp = temp1 * 60 + temp2
        X.append(temp)
        
    for b in diff_data:
        
        temp = float(b)
        Y.append(temp)
    
    fig, ax = plt.subplots(subplot_kw=dict(axisbg='#EEEEEE'))
    
    scatter = ax.scatter(X, Y, color = 'k', s=5)
    plt.xlabel("Time")
    plt.ylabel("Color Difference")    
    ax.set_title("Scatter Plot for Time-Color Difference", size=20)
    
    for c in option_data:
        
        temp = labeling(c)
        Z.append(temp)
    
    tooltip = mpld3.plugins.PointLabelTooltip(scatter, labels=Z, location='top right')
    mpld3.plugins.connect(fig, tooltip)
    
    mpld3.save_html(fig, result_path)
    
    return True


# labeling for tooltips
def labeling(ops):
    
    result = []
    
    result.append(str(ops[0]))
    result.append("R " + str(ops[1]))
    result.append("S " + str(ops[2]))
    result.append("T " + str(ops[3]))
    result.append("D " + str(ops[4]))
    result.append("G " + str(ops[5]))
    result.append("F " + str(ops[6]))
    
    return result



option_table = [['CPU', '100', '10', '32', '2', '2', '1'], ['CPU', '100', '10', '32', '2', '4', '1'], ['CPU', '100', '10', '32', '2', '8', '1'], ['CPU', '100', '10', '32', '2', '16', '1']]
time_table = ["1 : 20.837083", "1 : 21.121812", "1 : 21.210286", "1 : 21.20286"]
diff_table = ["0.4", "0.11", ".08", "0.19"]

draw_graph(option_table, time_table, diff_table, "Render/scatter_graph.html")

