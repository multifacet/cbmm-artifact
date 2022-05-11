#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "USAGE: ./section-5.6.sh MACHINE USER"
    exit 1
fi

MACHINE=$1
USER=$2

###############################################################################
# Huge pages model only
###############################################################################

# Runtime
./target/debug/runner exp00010 ${MACHINE} ${USER}   --mm_econ --mm_econ_benefit_file ./profiles/xz-training-just-huge.csv hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 ${MACHINE} ${USER}  --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/xz-training-just-huge.csv hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 ${MACHINE} ${USER}   --mm_econ --mm_econ_benefit_file ./profiles/mcf-just-huge.csv hacky_spec17 mcf
./target/debug/runner exp00010 ${MACHINE} ${USER}  --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/mcf-just-huge.csv hacky_spec17 mcf
./target/debug/runner exp00010 ${MACHINE} ${USER}   --mm_econ --mm_econ_benefit_file ./profiles/canneal-just-huge.csv canneal --rand 530000000
./target/debug/runner exp00010 ${MACHINE} ${USER}  --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/canneal-just-huge.csv canneal --rand 530000000
./target/debug/runner exp00010 ${MACHINE} ${USER}   --mm_econ --mm_econ_benefit_file ./profiles/mongodb-just-huge.csv mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 ${MACHINE} ${USER}  --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/mongodb-just-huge.csv mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 ${MACHINE} ${USER}   --mm_econ --mm_econ_benefit_file ./profiles/memcached-just-huge.csv memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00010 ${MACHINE} ${USER}  --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/memcached-just-huge.csv memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00012 ${MACHINE} ${USER}   --mm_econ --mm_econ_benefits redis-server ./profiles/mix-redis-just-huge.csv mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
./target/debug/runner exp00012 ${MACHINE} ${USER}  --fragmentation 100 --mm_econ --mm_econ_benefits redis-server ./profiles/mix-redis-just-huge.csv mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25

# PF latency
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000  --mm_econ --mm_econ_benefit_file ./profiles/xz-training-just-huge.csv hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/xz-training-just-huge.csv hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000  --mm_econ --mm_econ_benefit_file ./profiles/mcf-just-huge.csv hacky_spec17 mcf
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/mcf-just-huge.csv hacky_spec17 mcf
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000  --mm_econ --mm_econ_benefit_file ./profiles/canneal-just-huge.csv canneal --rand 530000000
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/canneal-just-huge.csv canneal --rand 530000000
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000  --mm_econ --mm_econ_benefit_file ./profiles/mongodb-just-huge.csv mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/mongodb-just-huge.csv mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000  --mm_econ --mm_econ_benefit_file ./profiles/memcached-just-huge.csv memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/memcached-just-huge.csv memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00012 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000  --mm_econ --mm_econ_benefits redis-server ./profiles/mix-redis-just-huge.csv mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
./target/debug/runner exp00012 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 --fragmentation 100 --mm_econ --mm_econ_benefits redis-server ./profiles/mix-redis-just-huge.csv mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25

# SMAPS (huge page usage)
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic  --mm_econ --mm_econ_benefit_file ./profiles/xz-training-just-huge.csv hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/xz-training-just-huge.csv hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic  --mm_econ --mm_econ_benefit_file ./profiles/mcf-just-huge.csv hacky_spec17 mcf
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/mcf-just-huge.csv hacky_spec17 mcf
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic  --mm_econ --mm_econ_benefit_file ./profiles/canneal-just-huge.csv canneal --rand 530000000
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/canneal-just-huge.csv canneal --rand 530000000
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic  --mm_econ --mm_econ_benefit_file ./profiles/mongodb-just-huge.csv mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/mongodb-just-huge.csv mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic  --mm_econ --mm_econ_benefit_file ./profiles/memcached-just-huge.csv memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic --fragmentation 100 --mm_econ --mm_econ_benefit_file ./profiles/memcached-just-huge.csv memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00012 ${MACHINE} ${USER} --smaps_periodic --instrument redis-server  --mm_econ --mm_econ_benefits redis-server ./profiles/mix-redis-just-huge.csv mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
./target/debug/runner exp00012 ${MACHINE} ${USER} --smaps_periodic --instrument redis-server --fragmentation 100 --mm_econ --mm_econ_benefits redis-server ./profiles/mix-redis-just-huge.csv mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25

###############################################################################
# Huge pages model + Async Zeroing only
###############################################################################

# Runtime
./target/debug/runner exp00010 ${MACHINE} ${USER}   --asynczero --mm_econ --mm_econ_benefit_file ./profiles/xz-training-just-huge.csv hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 ${MACHINE} ${USER}  --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/xz-training-just-huge.csv hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 ${MACHINE} ${USER}   --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mcf-just-huge.csv hacky_spec17 mcf
./target/debug/runner exp00010 ${MACHINE} ${USER}  --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mcf-just-huge.csv hacky_spec17 mcf
./target/debug/runner exp00010 ${MACHINE} ${USER}   --asynczero --mm_econ --mm_econ_benefit_file ./profiles/canneal-just-huge.csv canneal --rand 530000000
./target/debug/runner exp00010 ${MACHINE} ${USER}  --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/canneal-just-huge.csv canneal --rand 530000000
./target/debug/runner exp00010 ${MACHINE} ${USER}   --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mongodb-just-huge.csv mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 ${MACHINE} ${USER}  --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mongodb-just-huge.csv mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 ${MACHINE} ${USER}   --asynczero --mm_econ --mm_econ_benefit_file ./profiles/memcached-just-huge.csv memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00010 ${MACHINE} ${USER}  --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/memcached-just-huge.csv memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00012 ${MACHINE} ${USER}   --asynczero --mm_econ --mm_econ_benefits redis-server ./profiles/mix-redis-just-huge.csv mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
./target/debug/runner exp00012 ${MACHINE} ${USER}  --fragmentation 100 --asynczero --mm_econ --mm_econ_benefits redis-server ./profiles/mix-redis-just-huge.csv mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25

# PF latency
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000  --asynczero --mm_econ --mm_econ_benefit_file ./profiles/xz-training-just-huge.csv hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/xz-training-just-huge.csv hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000  --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mcf-just-huge.csv hacky_spec17 mcf
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mcf-just-huge.csv hacky_spec17 mcf
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000  --asynczero --mm_econ --mm_econ_benefit_file ./profiles/canneal-just-huge.csv canneal --rand 530000000
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/canneal-just-huge.csv canneal --rand 530000000
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000  --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mongodb-just-huge.csv mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mongodb-just-huge.csv mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000  --asynczero --mm_econ --mm_econ_benefit_file ./profiles/memcached-just-huge.csv memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00010 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/memcached-just-huge.csv memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00012 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000  --asynczero --mm_econ --mm_econ_benefits redis-server ./profiles/mix-redis-just-huge.csv mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
./target/debug/runner exp00012 ${MACHINE} ${USER} --memstats --pftrace --pftrace_threshold 10000 --fragmentation 100 --asynczero --mm_econ --mm_econ_benefits redis-server ./profiles/mix-redis-just-huge.csv mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25

# SMAPS (huge page usage)
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic  --asynczero --mm_econ --mm_econ_benefit_file ./profiles/xz-training-just-huge.csv hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/xz-training-just-huge.csv hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic  --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mcf-just-huge.csv hacky_spec17 mcf
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mcf-just-huge.csv hacky_spec17 mcf
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic  --asynczero --mm_econ --mm_econ_benefit_file ./profiles/canneal-just-huge.csv canneal --rand 530000000
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/canneal-just-huge.csv canneal --rand 530000000
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic  --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mongodb-just-huge.csv mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mongodb-just-huge.csv mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic  --asynczero --mm_econ --mm_econ_benefit_file ./profiles/memcached-just-huge.csv memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00010 ${MACHINE} ${USER} --smaps_periodic --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/memcached-just-huge.csv memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00012 ${MACHINE} ${USER} --smaps_periodic --instrument redis-server  --asynczero --mm_econ --mm_econ_benefits redis-server ./profiles/mix-redis-just-huge.csv mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
./target/debug/runner exp00012 ${MACHINE} ${USER} --smaps_periodic --instrument redis-server --fragmentation 100 --asynczero --mm_econ --mm_econ_benefits redis-server ./profiles/mix-redis-just-huge.csv mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
