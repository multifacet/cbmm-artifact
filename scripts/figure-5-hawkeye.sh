#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "USAGE: ./figure-1.sh MACHINE USER"
fi

MACHINE=$1
USER=$2

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
