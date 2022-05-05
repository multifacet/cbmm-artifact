#!/usr/bin/env python3

import sys
import os
import json
import re

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

LINE_RE = "^([0-9a-fA-F]+)-([0-9a-fA-F]+) [r-][w-][x-][p-] [0-9a-fA-F]+ [0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F] [0-9a-fA-F]+\s+(.*)"

# Read and parse
smaps = []
for line in sys.stdin:
    matches = re.search(LINE_RE, line)
    
    if matches is None:
        continue

    start = int("0x%s" % matches.group(1), 16)
    end = int("0x%s" % matches.group(2), 16)
    region = matches.group(3)

    smaps.append((start, end, region))

# Sort and dedup the list
smaps.sort()
smaps = list(dict.fromkeys(smaps))
smaps = [(s,e,[r]) for s,e,r, in smaps]

# Coallesce regions that overlap
#
# At this point, the regions are sorted by their starting points. Thus, for
# each region, we look at all regions after it. If they overlap, we expand the
# first one to the end of the longer of the two.
#
# We repeat until we reach a fixed point.
#
# Afterwards, we can remove the shortest regions because they will be
# completely subsumed.

new_smaps = []
changed = True
while changed:
    changed = False

    for i in range(len(smaps)):
        new_start = smaps[i][0]
        new_end = smaps[i][1]
        new_region = smaps[i][2]

        for j in range(i+1, len(smaps)):
            if smaps[j][0] <= new_end < smaps[j][1]:
            #if smaps[j][0] < new_end < smaps[j][1]: don't coallesce adjacent
                new_end = smaps[j][1]
                new_region += smaps[j][2]
                changed = True

        new_smaps.append((new_start, new_end, new_region))

    smaps = new_smaps
    new_smaps = []

#for start,end,region in smaps:
#    print(hex(start), hex(end), (end-start)>>21, set(region))

new_smaps = []
for start, end, region in smaps:
    skip = False
    for prev_start, prev_end, prev_region in new_smaps:
        if prev_start <= start and end <= prev_end:
            skip = True

    if not skip:
        new_smaps.append((start, end, region))

smaps = new_smaps

for start,end,region in smaps:
    print(hex(start), hex(end), (end-start)>>21, set(region))
