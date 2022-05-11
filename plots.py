import math
import matplotlib.pyplot as plt
import numpy as np


def plot_schedule(zLabel, schedule, filenames, plotnames):
    """
    Plot the data from filenames in a 3D plot.
    """
    # Create the figure.
    fig = plt.figure(figsize=(8, 8))
    ax = fig.add_subplot(111, projection='3d')
    # ax.set_xlim(0, 1)
    # ax.set_ylim(0, 1)
    # ax.set_zlim(0, 1)
    ax.set_xlabel('CPU Workload')
    ax.set_ylabel('Memory Workload')
    ax.set_zlabel(zLabel)
    # Plot the data.
    rgb = ['r', 'g', 'b', 'orange', 'purple', 'yellow', 'pink', 'cyan']
    marker = ['o', 'x', '+', '^', 'v', '<', '>']
    i = 0
    for filename in filenames:
        data = np.loadtxt(filename)

        # Plot the data.
        for j in range(len(data[:, 0])):
            if j == 0:
                ax.scatter(np.linspace(0.1, 0.9, 9), [
                           (j + 1) / 10.0] * 9, data[:, j], c=rgb[i], marker=marker[i], label=plotnames[i])
            else:
                ax.scatter(np.linspace(0.1, 0.9, 9), [
                    (j + 1) / 10.0] * 9, data[:, j], c=rgb[i], marker=marker[i])

        i += 1
    ax.legend(loc="best")
    ax.view_init(20, -75)

    # Save the figure.
    fig.savefig(schedule + '.png', dpi=600)
    plt.close(fig)


plot_schedule('CPU Utilisation', 'cpu_util', [
              './Outputs/Diff/CPU-Util-Matrix-0.txt', './Outputs/Diff/CPU-Util-Matrix-1.txt', './Outputs/Diff/CPU-Util-Matrix-2.txt', './Outputs/Diff/CPU-Util-Matrix-3.txt', './Outputs/Diff/CPU-Util-Matrix-4.txt', './Outputs/Diff/CPU-Util-Matrix-4.txt'], ['Round Robin', 'Advanced V1', 'Advanced V2', 'Advanced V3', 'Advanced V4', 'Advanced V5'])
plot_schedule('Memory Utilisation', 'mem_util', [
              './Outputs/Diff/MEM-Util-Matrix-0.txt', './Outputs/Diff/MEM-Util-Matrix-1.txt', './Outputs/Diff/MEM-Util-Matrix-2.txt', './Outputs/Diff/MEM-Util-Matrix-3.txt', './Outputs/Diff/MEM-Util-Matrix-4.txt', './Outputs/Diff/MEM-Util-Matrix-5.txt'], ['Round Robin', 'Advanced V1', 'Advanced V2', 'Advanced V3', 'Advanced V4', 'Advanced V5'])

graph_names = ["Time until Memory Allocation", "Time until Execution",
               "Time until Execution after Mem Alloc", "Execution Time"]
graph_data = ["WAITMEM", "WAITCPU", "EXECMEM", "EXECTIME"]
graph_types = ["mean", "spread", "min", "max"]

for i in range(len(graph_data)):
    for j in range(len(graph_types)):
        plot_schedule(graph_names[i] + ' ' + graph_types[j], graph_data[i] + '-' + graph_types[j], ['./Outputs/Matrices/' +
                      graph_data[i] + '-' + graph_types[j] + "-Matrix-6.txt"], ["Advanced V5"])
