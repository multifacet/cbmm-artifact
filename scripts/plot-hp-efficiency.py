#!/usr/bin/env python3

import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import matplotlib.transforms as transforms
import numpy as np

import re
import itertools
import random
import csv
from collections import OrderedDict
from cycler import cycler
from textwrap import fill

from sys import argv, exit
from os import environ

from paperstyle import FIGSIZE, IS_PDF, OUTFNAME, SMALL_PLOT

INFILE=argv[1]

TOTALBARWIDTH = 0.65

#WORKLOAD_ORDER=["mcf", "xz", "canneal", "thp-ubmk", "memcached", "mongodb", "mix"]
#WORKLOAD_ORDER=["mcf", "xz", "canneal", "memcached", "mongodb", "mix"]
KERNEL_ORDER=["Linux", "HawkEye", "CBMM"]

control = {}
data = {}

wklds = []
kernels = []
series = []

# Read data
with open(INFILE, 'r') as f:
    reader = csv.DictReader(f)

    for row in reader:
        efficiency = float(row["Efficiency"])

        wkld = row["workload"]
        kernel = row["kernel"]
        frag = row["fragmentation"].lower() == "fragmented"

        #if not frag:
        #    continue
        #else:
        #    frag = False

        data[(kernel, wkld, frag)] = efficiency * 100.0
        series.append((wkld, frag))

        wklds.append(wkld)
        kernels.append(kernel)


kernels = sorted(list(set(kernels)), key = lambda k: KERNEL_ORDER.index(k))
kernels = {k : i for i, k in enumerate(kernels)}
series = list(sorted(set(series), key=lambda s: (s[1], s[0])))

nseries = len(series) / 2
barwidth = TOTALBARWIDTH / nseries

fig, axs = plt.subplots(1, 2, figsize=FIGSIZE)

print(kernels)
print(series)

for i, (wkld, frag) in enumerate(series):
    ys = list(filter(lambda d: d[1] == wkld and d[2] == frag, data))

    if frag:
        location = i - nseries
    else:
        location = i
    xs = np.array(list(map(lambda d: kernels[d[0]], ys))) \
            - TOTALBARWIDTH / 2 + location * TOTALBARWIDTH / nseries \
            + TOTALBARWIDTH / nseries / 2

    ys = list(map(lambda d: data[d], ys))

    if wkld == "canneal":
        color = "lightblue"
    elif wkld == "mcf":
        color = "goldenrod"
    elif wkld == "memcached":
        color = "lightgreen"
    elif wkld == "mix":
        color = "pink"
        wkld = "dc-mix"
    elif wkld == "mongodb":
        color = "violet"
    else:
        color = "chocolate"

    if frag:
        axis = 1
    else:
        axis = 0

    axs[axis].bar(xs, ys,
            width=TOTALBARWIDTH / nseries,
            label="%s" % (wkld),
            color=color,
            edgecolor="black")

fig.supylabel("% Backed by Huge Pages", fontsize=9, y=0.4)

axs[0].set_title("Unfragmented", fontsize=10)
axs[1].set_title("Fragmented", fontsize=10)
axs[1].set_yticklabels([])
plt.subplots_adjust(wspace=0, hspace=0)
for ax in axs:
    ticklabels = sorted(kernels, key=kernels.get)
    ax.set_xticks(range(len(kernels)))
    ax.set_xticklabels(ticklabels)
    ax.tick_params(axis='x', labelrotation = 45)
    ax.grid()

    box = ax.get_position()
    ax.set_position([box.x0, box.y0, box.width, box.height * 0.65])

if environ.get("NOLEGEND") is None:
    handles, labels = axs[1].get_legend_handles_labels()
    fig.legend(handles, labels, loc="upper center", ncol=3)

plt.savefig("/tmp/%s.%s" % (OUTFNAME, "pdf" if IS_PDF else "png"), bbox_inches="tight")
plt.show()

