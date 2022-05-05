#!/usr/bin/env python3

import numpy as np
import sys
import os

from sys import argv

INFILE=argv[1]
THRESHOLD=int(argv[2])
TAIL = int(argv[3]) if len(argv) == 4 else None
FREQ = float(os.environ["FREQ"]) if "FREQ" in os.environ else None

data = []
rejected = 0

with open(INFILE, 'r') as f:
    for line in f.readlines():
        if "fast: " in line:
            rejected = int(line.split()[1])

        else:
            data.append(int(line.strip()))

data += [THRESHOLD] * rejected

if FREQ is not None:
    data = [d * FREQ / 1000. for d in data]

def generate_points(tail):
    if tail is not None:
        ps = np.arange(101) * TAIL / 100
        ps = np.array(list(map(lambda n: 100. - 10. ** (2. - n), ps)))
        return ps

    else:
        return np.arange(101)

ps = generate_points(TAIL)
percentiles = np.percentile(data, ps)

print("none(%d)" % len(data), " ".join(map(lambda p: str(p), percentiles)))
