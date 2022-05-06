#!/usr/bin/env python3

import sys
import os
import re

class Range:
    start: int
    end: int
    anon: int
    anon_huge: int

    def __init__(self, start, end, anon, anon_huge):
        self.start = start
        self.end = end
        self.anon = anon
        self.anon_huge = anon_huge

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

LINE_RE = "^([0-9a-fA-F]+)-([0-9a-fA-F]+) [r-][w-][x-][p-] [0-9a-fA-F]+ [0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F] [0-9a-fA-F]+\s+(.*)"

# Read and parse
started = False
start = 0
end = 0
anon = 0
anon_huge = 0
ranges = []
for line in sys.stdin:
    matches = re.search(LINE_RE, line)

    # Handle being at the start of a new range
    if matches:
        # If this is not the first region we see, add it to the list of regions
        if started:
            overlapped_range = None
            # If this range overlaps with a previous one, merge them
            for r in ranges:
                if start >= r.start and end <= r.end:
                    overlapped_range = r
                    break
                if start < r.start and end >= r.start:
                    r.start = start
                    overlapped_range = r
                    break
                if start <= r.end and end > r.end:
                    r.end = end
                    overlapped_range = r
                    break

            # If the range overlapped, take the max values of anon and anon_huge
            if overlapped_range:
                if anon > overlapped_range.anon:
                    overlapped_range.anon = anon
                if anon_huge > overlapped_range.anon_huge:
                    overlapped_range.anon_huge = anon_huge
            else:
                ranges.append(Range(start, end, anon, anon_huge))

        # Reset the variables for the new range
        start = int("0x%s" % matches.group(1), 16)
        end = int("0x%s" % matches.group(2), 16)
        anon = 0
        anon_huge = 0
        started = True
        continue

    # Split the line for easier processing
    line = line.split()

    # Check for either the amount of Anonymous or Anonymouse Huge memory
    if line[0] == "Anonymous:":
        anon = int(line[1])
    elif line[0] == "AnonHugePages:":
        anon_huge = int(line[1])

# Sum up the total amount of anon and anon huge memory
total_anon = 0
total_anon_huge = 0
for r in ranges:
    total_anon += r.anon
    total_anon_huge += r.anon_huge

print("Anonymous memory: " + str(total_anon) + "kB")
print("Anonumous huge memory: " + str(total_anon_huge) + "kB")
print("Ratio: " + str(total_anon_huge / total_anon))
