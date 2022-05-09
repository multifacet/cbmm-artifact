#!/usr/bin/env python3

import sys
import os
import json
import re
import csv
from scipy import stats

HPFILE = sys.argv[1]
EAGERFILE = sys.argv[2]
OUTFILE = sys.argv[3]

data = []

SKEW_THRESHOLD = 2.0

with open(HPFILE, 'r') as f:
    reader = csv.DictReader(f)

    for row in reader:
        if row['Start'] == 'thp':
            continue

        averted = int(row['Averted user page walk cycles per huge page'])
        start = int(row['Start'], 16)
        end = int(row['End'], 16)

        if averted > 0:
            data.append(("huge", start, end, averted))

# Look at the skewness of the data. If the distribution is highly skewed, then
# there is likely one or two really important regions. Otherwise, it is likely
# just random, and we would be better off with an average.
skewness = stats.skew([a for (p, s, e, a) in data])
print("Skewness = %f" % skewness)

if skewness < SKEW_THRESHOLD:
    start = min([s for (p, s, e, a) in data])
    end = max([e for (p, s, e, a) in data])
    avg = sum([a for (p, s, e, a) in data]) / float(len(data))

    data = [("huge", start, end, int(avg))]

with open(EAGERFILE, 'r') as f:
    for line in f.readlines():
        if "Total" in line:
            continue

        if "-" in line:
            start, end = line.split("-")
            start = int(start, 16)
            end = int(end, 16)
        else:
            start = int(line, 16)
            end = start + (1 << 21)

        data.append(("eager", start, end, 1))

with open(OUTFILE, 'w') as f:
    writer = csv.writer(f, lineterminator="\n")

    #writer.writerow(['Start', 'End', 'Averted'])

    for policy, start, end, averted in data:
        length = end - start

        if length == 0:
            continue

        #for section in ["code", "data", "heap", "mmap"]:
        for section in ["heap", "mmap"]:
            #writer.writerow([section, averted, "addr", "<", hex(start+1), "len", ">", length-1])
            #writer.writerow([section, averted,
            #                "addr", ">", hex(max(0, start-(1<<21))),
            #                "addr", "<", hex(end+(1<<21))])
            #writer.writerow([section, averted,
            #                "addr", ">", hex(max(0, start-(1))),
            #                "addr", "<", hex(end+(1))])
            writer.writerow([policy, section, averted,
                            "addr", ">", hex(start),
                            "addr", "<", hex(end)])

