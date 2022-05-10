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
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_zlim(0, 1)
    ax.set_xlabel('CPU Workload')
    ax.set_ylabel('Memory Workload')
    ax.set_zlabel(zLabel)
    # Plot the data.
    rgb = ['r', 'g', 'b']
    marker = ['o', 'x', '+']
    i = 0
    for filename in filenames:
        data = np.loadtxt(filename)

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
    fig.savefig(schedule + '.png')
    plt.close(fig)


plot_schedule('CPU Utilisation', 'cpu_util', [
              './Outputs/Diff/CPU-MEM-Matrix-1.txt', './Outputs/Diff/CPU-MEM-Matrix-2.txt', './Outputs/Diff/CPU-MEM-Matrix-3.txt'], ['Advanced V2', 'Advanced V1', 'Round Robin'])
