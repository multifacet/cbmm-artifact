#!/usr/bin/env python3

import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import matplotlib.transforms as transforms
from matplotlib.patches import Patch
import numpy as np

import re
import itertools
import random
import csv
import copy
from collections import OrderedDict
from cycler import cycler
from textwrap import fill

from sys import argv, exit
from os import environ

from paperstyle import FIGSIZE, IS_PDF, OUTFNAME, SMALL_PLOT

INFILE=argv[1]

TOTALBARWIDTH = 0.65

WORKLOAD_ORDER=["mcf", "xz", "canneal", "thp-ubmk", "memcached", "mongodb", "dc-mix", "geomean"]
COLORS = {"Linux": "lightyellow", "CBMM": "lightblue", "HawkEye": "pink", "Linux4.3": "black",
    "CBMM With Only Huge Pages": "pink", "CBMM With Only Huge Pages and Async Prezeroing": "lightgreen",
    "CBMM-tuned": "orange"}
SERIES = {"Linux": 0, "Linux4.3": 1, "HawkEye": 2, "CBMM": 3, "CBMM-tuned": 4}

YMAX = 2.0

control = {}
data = {}

wklds = []
series = []

class Point:
    def __init__(self, mean, stdev, median, maxi, mini):
        self.mean = mean
        self.stdev = stdev
        self.median = median
        self.maxi = maxi
        self.mini = mini

    def normalize(self, control):
        self.mean = self.mean / control.mean
        self.median = self.median / control.median
        self.maxi = self.maxi / control.maxi
        self.mini = self.mini / control.mini

    def __repr__(self):
        return "mean=%f stdev=%f median=%f max=%f min=%f" % \
            (self.mean, self.stdev, self.median, self.maxi, self.mini)

# Read data
with open(INFILE, 'r') as f:
    reader = csv.DictReader(f)

    for row in reader:
        mean = float(row["Mean"])
        stdev = float(row["Std"].replace("%", "")) / 100.
        median = float(row["Median"])
        maxi = float(row["Max"])
        mini = float(row["Min"])

        point = Point(mean, stdev, median, maxi, mini)

        wkld = row["workload"]
        kernel = row["kernel"]
        frag = row["fragmentation"] == "true"

        if wkld == "mix":
            wkld = "dc-mix"
        if wkld == "thp-ubmk":
            continue

        #if not frag:
        #    continue
        #else:
        #    frag = False

        if kernel == "Linux":
            control[(wkld, frag)] = copy.deepcopy(point)

        data[(kernel, wkld, frag)] = point
        series.append((kernel, frag))

        wklds.append(wkld)

# Normalize against unfragmented Linux
for k, point in data.items():
    kernel, wkld, frag = k
    #point.normalize(control[(wkld, frag)])
    point.normalize(control[(wkld, False)])
    #print(kernel, wkld, frag, point)

# Add geomean
def geomean(vals):
    # using the log here avoids overflow...
    # credit: https://stackoverflow.com/questions/43099542/python-easy-way-to-do-geometric-mean-in-python
    logs = np.log(vals)
    gm = np.exp(logs.mean())

    return gm

    # arithmetic mean
    #return float(sum(vals)) / len(vals)

def geomean_all(points):
    means = [x.mean for x in points]
    stdevs = [x.stdev for x in points]
    medians = [x.median for x in points]
    maxis = [x.maxi for x in points]
    minis = [x.mini for x in points]

    #print("geomean(%s) = %f" % (medians, geomean(medians)))

    return Point(
            geomean(means),
            geomean(stdevs),
            geomean(medians),
            geomean(maxis),
            geomean(minis),
            )

for kernel, frag in series:
    points = [p for (k, w, f), p in data.items() if k == kernel and f == frag]
    if kernel == "CBMM-tuned":
        for w in set(wklds):
            if ("CBMM-tuned", w, frag) not in data:
                points.append(data["CBMM", w, frag])
    data[(kernel, "geomean", frag)] = geomean_all(points)

wklds.append("geomean")

wklds = sorted(list(set(wklds)), key = lambda w: WORKLOAD_ORDER.index(w))
wklds = {w : i for i, w in enumerate(wklds)}
series = list(sorted(set(series), key=lambda s: (s[1], SERIES[s[0]])))

nseries = len(series)
barwidth = TOTALBARWIDTH / nseries

fig = plt.figure(figsize=FIGSIZE)

print(wklds)
print(series)
for k,v in data.items():
    print(k,v)

# horizontal dotted line at 1
horizontalxs = np.arange(len(wklds) + 2 * TOTALBARWIDTH) - TOTALBARWIDTH
horizontalys = np.array([1] * len(horizontalxs))
plt.plot(horizontalxs, horizontalys, color="black", lw=0.5, ls=":")

for i, (kernel, frag) in enumerate(series):
    ys = list(filter(lambda d: d[0] == kernel and d[2] == frag, data))

    xs = np.array(list(map(lambda d: wklds[d[1]], ys))) \
            - TOTALBARWIDTH / 2 + i * TOTALBARWIDTH / nseries \
            + TOTALBARWIDTH / nseries / 2

    ys = list(map(lambda d: data[d].median, ys))

    #if frag:
    #    ys = [0 for y in ys]

    plt.bar(xs, ys,
            width=TOTALBARWIDTH / nseries,
            label="%s%s" % (kernel, ", fragmented" if frag else ""),
            color=COLORS[kernel],
            hatch="///" if frag else None,
            edgecolor="black", linewidth=.5)

    too_tall = [(x, y) for (x, y) in zip(xs, ys) if y > YMAX]
    for x, y in too_tall:
        plt.text(x + 0.1, YMAX - 0.2, "%.1f" % y)


plt.ylabel("Normalized Runtime")
plt.ylim((0, YMAX))

plt.xlim((0.5, len(wklds) - 0.5))
ticklabels = sorted(wklds, key=wklds.get)
plt.xticks(np.arange(len(wklds)) - 0.5, ticklabels,
        ha="center", rotation=45.)
ticklabeltrans = transforms.ScaledTranslation(0.2, 0., fig.dpi_scale_trans)
for label in plt.gca().xaxis.get_majorticklabels():
    label.set_transform(label.get_transform() + ticklabeltrans)

if environ.get("NOLEGEND") is None:
    legend_elements = []
    for kernel, frag in series:
        if not frag:
            legend_elements.append(Patch(facecolor=COLORS[kernel], edgecolor="k", label=kernel))

    legend_elements.append(Patch(facecolor="white", edgecolor="k", hatch="///", label="Fragmented"))

    plt.legend(handles=legend_elements, bbox_to_anchor=(0.5, 1), loc="lower center", ncol=3)
    #plt.legend(bbox_to_anchor=(0.5, 1), loc="lower center", ncol=2)


plt.grid(True)

plt.tight_layout()

plt.savefig("/tmp/%s.%s" % (OUTFNAME, "pdf" if IS_PDF else "png"), bbox_inches="tight")
#plt.show()

