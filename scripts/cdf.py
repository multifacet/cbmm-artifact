#!/usr/bin/env python3

import matplotlib.pyplot as plt
import numpy as np

import re
import itertools
from collections import OrderedDict
from cycler import cycler

from sys import argv, exit
from os import environ

from paperstyle import FIGSIZE, IS_PDF, OUTFNAME

USAGE_STR = "[FREQ=freq_mhz] ./script <label> <P0> <P1> ... <P100> <label> <P0> <P1> ... <P100> ..."
if len(argv[1:]) % 102 != 0:
    print("./Usage: %s" %  USAGE_STR)

FREQ = float(environ["FREQ"]) if "FREQ" in environ else None
NPLOTS = int(len(argv[1:]) / 102)

plt.figure(figsize=(8,8))

#CYCLER = (cycler(color=['r', 'g', 'b', 'y', 'c', 'm', 'k']) + cycler(linestyle=['-', '--', ':', '-.']))
colormap = plt.cm.nipy_spectral
colors = [colormap(i) for i in np.linspace(0, 1, NPLOTS)]
styles = itertools.cycle(['-', '--', ':', '-.'])
plt.gca().set_prop_cycle('color', colors)

for i in range(NPLOTS):
    label = argv[1+i*102]
    xs = [float(x) for x in argv[1+i*102+1:1+(i+1)*102]]
    if FREQ is not None:
        xs = [x / FREQ for x in xs]
    ys = [y for y in range(0, 101)] # 0 ..= 100
    plt.plot(xs, ys, label=label, linestyle=next(styles))

plt.xscale("symlog")
plt.xticks(rotation=90)
plt.xlabel("Latency (%s)" % ("cycles" if FREQ is None else "usec"))

plt.ylabel("Percentile")

plt.grid(True)

#plt.legend(bbox_to_anchor=(1.05, 1.0), loc='upper left')
plt.legend(bbox_to_anchor=(0, 1.05), loc='lower left')

plt.tight_layout()

plt.savefig("/tmp/%s.%s" % (OUTFNAME, ("pdf" if IS_PDF else "png")), bbox_inches="tight")
plt.show()
