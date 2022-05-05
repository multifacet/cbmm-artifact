#!/usr/bin/env python3

import sys
import os
import json
import re
import glob

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

json_data = None
for line in sys.stdin:
    json_data = json.loads(line)

if len(json_data['results']) == 0:
    # nothing to do
    print("{}")
    sys.exit(0)

print(json_data, file=sys.stderr)

data = []

COUNTERS_RE = [
        ("dtlb_load_misses.walk_active:u"          , "dtlb_load_misses.(walk_active|walk_duration):u\s"),
        ("dtlb_store_misses.walk_active:u"         , "dtlb_store_misses.(walk_active|walk_duration):u\s"),
        ("dtlb_load_misses.miss_causes_a_walk:u"   , "dtlb_load_misses.miss_causes_a_walk:u\s"),
        ("dtlb_store_misses.miss_causes_a_walk:u"  , "dtlb_store_misses.miss_causes_a_walk:u\s"),
        ("cpu_clk_unhalted.thread_any:u"           , "cpu_clk_unhalted.thread_any:u\s"),
        ("inst_retired.any:u"                      , "inst_retired.any:u\s"),
        ("faults:u"                                , "faults:u\s"),
        ("migrations:u"                            , "migrations:u\s"),
        ("cs:u"                                    , "cs:u\s"),
        ("dtlb_load_misses.walk_active:k"          , "dtlb_load_misses.(walk_active|walk_duration):k\s"),
        ("dtlb_store_misses.walk_active:k"         , "dtlb_store_misses.(walk_active|walk_duration):k\s"),
        ("dtlb_load_misses.miss_causes_a_walk:k"   , "dtlb_load_misses.miss_causes_a_walk:k\s"),
        ("dtlb_store_misses.miss_causes_a_walk:k"  , "dtlb_store_misses.miss_causes_a_walk:k\s"),
        ("cpu_clk_unhalted.thread_any:k"           , "cpu_clk_unhalted.thread_any:k\s"),
        ("inst_retired.any:k"                      , "inst_retired.any:k\s"),
        ("faults:k"                                , "faults:k\s"),
        ("migrations:k"                            , "migrations:k\s"),
        ("cs:k"                                    , "cs:k\s"),
        ("dtlb_load_misses.walk_active"            , "dtlb_load_misses.(walk_active|walk_duration)\s"),
        ("dtlb_store_misses.walk_active"           , "dtlb_store_misses.(walk_active|walk_duration)\s"),
        ("dtlb_load_misses.miss_causes_a_walk"     , "dtlb_load_misses.miss_causes_a_walk\s"),
        ("dtlb_store_misses.miss_causes_a_walk"    , "dtlb_store_misses.miss_causes_a_walk\s"),
        ("cpu_clk_unhalted.thread_any"             , "cpu_clk_unhalted.thread_any\s"),
        ("inst_retired.any"                        , "inst_retired.any\s"),
        ("faults"                                  , "faults\s"),
        ("migrations"                              , "migrations\s"),
        ("cs"                                      , "cs\s"),
        ("Runtime (s)"                             , "seconds time elapsed"),
        ]

#print("Sort,Huge page,Data filename,%s,Runtime (s)" % ",".join(COUNTERS))

def find_file(json_data):
    # first try the plain file name
    first_try = json_data['cp_results'] + "/" + os.path.basename(json_data['results']) + "mmu"
    if os.path.exists(first_try):
        return first_try

    # next try subdirectories
    second_try = glob.glob(json_data['cp_results'] + "/*/" + os.path.basename(json_data['results']) + "mmu")[0]
    if os.path.exists(second_try):
        return second_try

    raise "Cannot find results file"

mmu_fname = find_file(json_data)

"""
 1,421,575,545      dtlb_load_misses.walk_active                                     (83.36%)
11,713,746,064      dtlb_store_misses.walk_active                                     (83.38%)
    13,414,159      dtlb_load_misses.miss_causes_a_walk                                     (83.32%)
   368,539,673      dtlb_store_misses.miss_causes_a_walk                                     (83.31%)
426,918,087,667      cpu_clk_unhalted.thread_any                                     (66.64%)
258,040,656,071      inst_retired.any                                              (83.30%)
    52,434,092      faults
             0      migrations
     1,349,661      cs

 129.017929724 seconds time elapsed
"""

fdata = []
try:
    with open(mmu_fname, 'r') as f:
        for line in f.readlines():
            for (c, cre) in COUNTERS_RE:
                if re.search(cre, line) is not None:
                    v = line.split()[0].replace(",", "").strip()
                    fdata.append(v)

except Exception as e:
    print("error %s skipping %s" % (e, mmu_fname))

REGEX = "(0x[0-9a-fA-F]+) (0x[0-9a-fA-F]+)"
matches = re.search(REGEX, json_data['cmd'])
hp_start = matches.group(1)
hp_end = matches.group(2)

eprint(json_data['jid'], mmu_fname, fdata)

# Build output json
outdata = {
        "Start": hp_start,
        "End": hp_end,
        "Data filename": mmu_fname,
        }

for ((c, cre), v) in zip(COUNTERS_RE, fdata):
    outdata[c] = v

eprint(json.dumps(outdata, indent=2))
print(json.dumps(outdata))
