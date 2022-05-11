#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "USAGE: ./figure-2.sh MACHINE USER"
    exit 1
fi

MACHINE=$1
USER=$2

# No frag
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 hacky_spec17 mcf
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 canneal --rand 530000000
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00012 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 thp_ubmk 150

# frag
./target/debug/runner exp00010 ${MACHINE} ${USER} --fragmentation 100 --memstats --pftrace --pftrace_threshold 10000 hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 ${MACHINE} ${USER} --fragmentation 100 --memstats --pftrace --pftrace_threshold 10000 hacky_spec17 mcf
./target/debug/runner exp00010 ${MACHINE} ${USER} --fragmentation 100 --memstats --pftrace --pftrace_threshold 10000 canneal --rand 530000000
./target/debug/runner exp00010 ${MACHINE} ${USER} --fragmentation 100 --memstats --pftrace --pftrace_threshold 10000 mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 ${MACHINE} ${USER} --fragmentation 100 --memstats --pftrace --pftrace_threshold 10000 memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00012 ${MACHINE} ${USER} --fragmentation 100 --memstats --pftrace --pftrace_threshold 10000 mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
./target/debug/runner exp00010 ${MACHINE} ${USER} --fragmentation 100 --memstats --pftrace --pftrace_threshold 10000 thp_ubmk 150
