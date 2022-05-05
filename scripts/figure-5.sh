#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "USAGE: ./figure-1.sh MACHINE USER"
fi

MACHINE=$1
USER=$2

# **Linux, without fragmentation**

./target/debug/runner exp00010 {MACHINE} {USER}    hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 {MACHINE} {USER}    hacky_spec17 mcf
./target/debug/runner exp00010 {MACHINE} {USER}    canneal --rand 530000000
./target/debug/runner exp00010 {MACHINE} {USER}    mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 {MACHINE} {USER}    memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00012 {MACHINE} {USER}    mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
./target/debug/runner exp00010 {MACHINE} {USER}    thp_ubmk 150

# **Linux, with fragmentation**

./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100  hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100  hacky_spec17 mcf
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100  canneal --rand 530000000
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100  mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100  memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00012 {MACHINE} {USER}  --fragmentation 100  mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100  thp_ubmk 150

# **HawkEye, without fragmentation**

./target/debug/runner exp00010 {MACHINE} {USER}   --hawkeye hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 {MACHINE} {USER}   --hawkeye hacky_spec17 mcf
./target/debug/runner exp00010 {MACHINE} {USER}   --hawkeye canneal --rand 530000000
./target/debug/runner exp00010 {MACHINE} {USER}   --hawkeye mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 {MACHINE} {USER}   --hawkeye memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00012 {MACHINE} {USER}   --hawkeye --hawkeye_debloat memhog mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
./target/debug/runner exp00010 {MACHINE} {USER}   --hawkeye thp_ubmk 150

# **HawkEye, with fragmentation**

./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100 --hawkeye hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100 --hawkeye hacky_spec17 mcf
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100 --hawkeye canneal --rand 530000000
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100 --hawkeye mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100 --hawkeye memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00012 {MACHINE} {USER}  --fragmentation 100 --hawkeye --hawkeye_debloat memhog mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100 --hawkeye thp_ubmk 150

# **CBMM, without fragmentation**

./target/debug/runner exp00010 {MACHINE} {USER}   --asynczero --mm_econ --mm_econ_benefit_file ./profiles/xz-training.csv hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 {MACHINE} {USER}   --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mcf.csv hacky_spec17 mcf
./target/debug/runner exp00010 {MACHINE} {USER}   --asynczero --mm_econ --mm_econ_benefit_file ./profiles/canneal.csv canneal --rand 530000000
./target/debug/runner exp00010 {MACHINE} {USER}   --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mongodb.csv mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 {MACHINE} {USER}   --asynczero --mm_econ --mm_econ_benefit_file ./profiles/memcached.csv memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00012 {MACHINE} {USER}   --asynczero --mm_econ --mm_econ_benefits redis-server ./profiles/mix-redis.csv mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
./target/debug/runner exp00010 {MACHINE} {USER}   --asynczero --mm_econ --mm_econ_benefit_file ./profiles/thp-ubmk.csv thp_ubmk 150

# **CBMM, with fragmentation**

./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/xz-training.csv hacky_spec17 xz --spec_size 76800 --input  testing
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mcf.csv hacky_spec17 mcf
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/canneal.csv canneal --rand 530000000
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/mongodb.csv mongodb --op_count 9500000 --read_prop 0.25 --update_prop 0.375
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/memcached.csv memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
./target/debug/runner exp00012 {MACHINE} {USER}  --fragmentation 100 --asynczero --mm_econ --mm_econ_benefits redis-server ./profiles/mix-redis.csv mixycsb 150 --op_count 9400000 --read_prop 0.50 --update_prop 0.25
./target/debug/runner exp00010 {MACHINE} {USER}  --fragmentation 100 --asynczero --mm_econ --mm_econ_benefit_file ./profiles/thp-ubmk.csv thp_ubmk 150
