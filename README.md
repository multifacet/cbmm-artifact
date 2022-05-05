# Artifact package for CBMM paper (ATC'22)

## Overview

This artifact contains:

- `README.md`: this file.
- `paper.pdf`: the accepted version of the paper, without any modifications responding to reviewer requests.
- `cbmm/`: a git submodule containing our primary artifact, the CBMM kernel, which is a modified version of Linux 5.5.8.
- `cbmm-runner/`: a git submodule of our `runner` tool, which runs our experiments.
- `profiles/`: a set of profiles we used in our evaluation. More later.
- `scripts/`:
   - Convenience scripts for running experiments (more in "Detailed Instructions"),
   - Scripts for processing experimental output into a consumable/plottable form,
   - Scripts for plotting experimental results to generate the figures from the paper.

Since our artifact is a kernel, our evaluation uses two machines: one to drive experiments (the _driver_ machine) and one for the experiments to run on (the _test_ machine). We do it this way so that our experiments can run on bare metal without virtualization overheads to muddle the results. We use two separate machines because it makes automation and scripting easier.

The CBMM kernel runs on the _test_ machine, while the `runner` program runs on the _driver_ machine.

## Artifact Claims

Running the experiments as specified below on similar hardware to our own setup (described in Section 5.1) should allow the reviewer to generate comparable results to those in the accepted version of the paper, including tail latency, performance, huge page usage, and generality results.

TODO: Because that is extremely time consuming, we provide a screencast and intermediate results for the reviewers. This should allow generation of checkable partial results in a reasonable amount of time.

## Hardware and Software Requirements

_Driver_ machine:
- A recent Linux distro with standard utilities. We ran extensively on Ubuntu 18.04 and Ubuntu 20.04. In theory, we should support MacOS, but it's never been tested, so YMMV.
- [Rust](https://rust-lang.org) 1.31 or greater. The `runner` is written in rust.
- Needs to have _passwordless_ SSH access to the _test_ machine. This is used for automatedly running commands for the experiments.
   - The network needs to be _stable_ for long periods of time, as the SSH connection is maintained while long-running commands run.
- No significant memory, CPU, or disk requirements...
- The artifact evaluator will need access to a SPEC2017 ISO image. We don't include it because it is against the License :'(
- **The driver machine is _not_ modified by the runner or any experiments.**

_Test_ machine:
- The hardware specs of our test machine are in Section 5.1 of the paper.
   - NOTE: the machine should have close to 192GB of memory. We chose our workload sizes carefully so as not to over- or under-pressure memory but have representative results.
   - NOTE: the machine needs a fair bit of free disk space, as building and running the artifact can produce a lot of output.
- Centos 7
   - We will install the CBMM kernel in the instructions below.
- Needs to have internet access to download software packages through `yum`, `git`, `wget`, `curl`.

## Getting Started

We will clone and build the `runner` program on the _driver_ machine. The `runner` will then be used to set up the _test_ machine as needed. The `runner` can subsequently be used to run any experiments in the paper.

NOTE: We include `cbmm-runner` and `cbmm` in this repository for archival reasons, but our scripts download them anyway from github.

### Setup

**On the _driver_ machine**

1. Clone this repo.

    ```sh
    git clone https://github.com/multifacet/cbmm-artifact
    ```

2. Initialize the `runner` submodule.

   ```sh
   cd cbmm-artifact
   git submodule update --init -- cbmm-runner
   git submodule update --init -- cbmm
   ```

3. Build the `runner` using Rust's `cargo` tool. This will download dependencies and build and link the tool. It should take <10 minutes to complete on an average machine.

   ```sh
   cd cbmm-runner/runner
   cargo build
   ```

4. Use the `runner` to start setting up the _test_ machine. This should take ~1 hour. The command should produce lots of output about the commands being run and their output. The commands being run are on the _test_ machine (over SSH), not the _driver_.

   In the following commands, replace:
      - `{MACHINE}` with the `ip:port` of the _test_ machine (e.g., `foo.cs.wisc.edu:22`),
      - `{USER}` with the username on the _test_ machine (e.g., `markm`),
      - `/path/to/spec2017.iso` with the path to your ISO,
      - `--swap sdb` with the proper partition name for your swap partition.

   **Troubleshooting**
      - Copying the SPEC2017 ISO hangs or fails.
         - Make sure that SSH'ing into the _test_ machine is passwordless and requires no interaction. For example, log into the machine manually once to address any fingerprint confirmations that SSH may generate.
      - On CloudLab, root partition is only 16GB and runs out of space.
         - Pass the `--resize_root` flag, which expands the size of the main partition.
      - On my machine, `/dev/sda` may point to different devices after a reboot.
         - Pass the `--unstable_device_names` flag, which causes the runner to use device UUIDs instead.

   ```sh
   # Clones/installs/builds a bunch of dependencies and benchmarks.
   ./target/debug/runner setup00000 {MACHINE} {USER} --centos7 --jemalloc \
      --clone_wkspc --firewall --host_bmks --host_dep \
      --swap sdb \
      --spec_2017 /path/to/spec2017.iso
   ```

5. **Option A** Use the `runner` to install CBMM (our system) on the _test_ machine. This should take about ~1 hour. The command should produce lots of output about the commands being run and their output. The commands being run are on the _test_ machine (over SSH), not the _driver_.

   ```sh
   # Clones and builds the CBMM kernel at the given git commit hash.
   ./target/debug/runner setup00003 {MACHINE} {USER} \
      ffc5a23759fcbf862ed68eaad460eeb06d79431d \
      --https github.com/multifacet/cbmm \
      +CONFIG_TRANSPARENT_HUGEPAGE +CONFIG_MM_ECON -CONFIG_PAGE_TABLE_ISOLATION \
      -CONFIG_RETPOLINE +CONFIG_GDB_SCRIPTS +CONFIG_FRAME_POINTERS +CONFIG_IKHEADERS \
      +CONFIG_SLAB_FREELIST_RANDOM +CONFIG_SHUFFLE_PAGE_ALLOCATOR
   ```

   **Option B** Use the `runner` to install HawkEye (experimental comparison) on the _test_ machine. This should take about ~1 hour. The command should produce lots of output about the commands being run and their output. The commands being run are on the _test_ machine (over SSH), not the _driver_.

   ```sh
   ./target/debug/runner setup00004 {MACHINE} {USER}
   ```

6. Build the `read-pftrace` tool which is used to read the page fault latency traces in Figures 2 and 4. They are in a compressed binary format to save space.

   ```sh
   cd cbmm-artifacts/cbmm/mm/read-pftrace
   cargo build --release
   ```

7. **Congratulations!** You should now have a fully-set-up _driver_ and _test_ machine pair. We can now begin running experiments.

### Kick the tires (some small tests)

The following commands run fast (<15 minutes) test experiments. The commands should be run on _driver_, but they will cause the experiments to run on _test_. In each command,
   - `{MACHINE}` is the `ip:port` of the _test_ machine (e.g., `foo.cs.wisc.edu:22`),
   - `{USER}` is the username on the _test_ machine (e.g., `markm`),

In each case, the _test_ machine will be reboot, will have a bunch of configuration setting set (e.g., CPU scaling governor, etc), will run the given experiment, and will produce a collection of output files with the same name and different extensions in `~/vm_shared/` on the _test_ machine.

1. Run the `thp_ubmk` microbenchmark with size 10GB, collecting the contents of `/proc/[pid]/smaps` periodically.

   ```sh
   ./target/debug/runner exp00010 {MACHINE} {USER} --smaps_periodic   thp_ubmk 10
   ```

2. Run the `mix` workload with size 10GB and produce profiling information for eager paging.

   ```sh
   ./target/debug/runner exp00012 {MACHINE} {USER} --eagerprofile 60 \
      --instrument redis-server mixycsb 10 --op_count 900000 \
      --read_prop 0.50 --update_prop 0.25
   ```

3. Run the `memcached` workload with size 10GB on CBMM with the given profile and collect page fault latency information.

   ```sh
   ./target/debug/runner exp00010 {MACHINE} {USER} --memstats --pftrace \
      --pftrace_threshold 10000  --asynczero --mm_econ \
      --mm_econ_benefit_file ../../profiles/memcached.csv \
      memcachedycsb 150 --op_count 9400000 --read_prop 0.99 --update_prop 0.01
   ```

## Detailed Instructions

We provide commands for generating the data in each of the figures in the
paper and plotting them.

Generating all of the results is _very_ time consuming and resource intensive. The following table shows the time to run each workload (on our _test_ machine), as the reviewer may want to generate partial results from the paper in the interest of time.

| Workload    | Rought time estimate |
|-------------|----------------------|
| xz          | 3 hours              |
| mcf         | 20 minutes           |
| canneal     | 4 hours              |
| mongodb     | 4 hours              |
| memcached   | 30 minutes           |
| mix         | 1 hour               |
| thp\_ubmk   | 10 minutes           |

### Figure 1

**NOTE**: This figure contains the results of ~4000 experiments. It took two students one month to run all experiments on ~50 machines. We include the commands for completeness, but we also include the final results (the profiles) in `profiles/`, for your use in the remaining experiments.

To produce this figure, we must first get a sense of the address space layout of the profiled process and then carry out the profiling, as described in Section 2.1.

We give only examples here, but the full set of commands to run experiments is included in `./scripts/figure-1.sh`. (TODO) We also provide the final output profiles in `profiles/`.

1. Collect `/proc/[pid]/smaps` for each workload. This gives the address space layout for the profiled process.

   ```sh
   exp00010 {MACHINE} {USER} --smaps_periodic   hacky_spec17 xz --spec_size 76800 --input  training
   ```

2. Process the smaps output and split the address space into 100 equally-sized chunks.

   ```sh
   cat /path/to/$OUTPUT.smaps | ./scripts/process-smaps.py
   ```

   Example output:

   ```txt
   0x400000 0x435000 0 {'/users/bijan/0sim-workspace/bmks/spec2017/benchspec/CPU/657.xz_s/run/run_base_refspeed_markm-thp-m64.0000/xz_s'}
   0x634000 0x63c000 0 {'', '/users/bijan/0sim-workspace/bmks/spec2017/benchspec/CPU/657.xz_s/run/run_base_refspeed_markm-thp-m64.0000/xz_s'}
   0x7fcbefc00000 0x7fcbf3200000 27 {''}
   0x7fcbf337d000 0x7ffff6600000 106521 {''}
   0x7ffff670c000 0x7ffff7dfd000 11 {'', '/usr/lib64/libgcc_s-4.8.5-20150702.so.1', '/usr/local/lib/libjemalloc.so.2', '/usr/lib64/libpthread-2.17.so', '/usr/lib64/libdl-2.17.so', '/usr/lib64/libgomp.so.1.0.0', '/usr/lib64/libc-2.17.so', '/usr/lib64/ld-2.17.so', '/usr/lib64/libstdc++.so.6.0.19', '/usr/lib64/libm-2.17.so'}
   0x7ffff7fdd000 0x7ffff7fe6000 0 {''}
   0x7ffff7ff6000 0x7ffff7fff000 0 {'', '[vdso]', '/usr/lib64/ld-2.17.so', '[vvar]'}
   0x7ffffffde000 0x7ffffffff000 0 {'[stack]'}
   0xffffffffff600000 0xffffffffff601000 0 {'[vsyscall]'}
   ```

   Manually select ranges to profile...

   ```sh
   ./scripts/huge_range_compute.py <start> <end> <nslices> | tail -n 1
   ```

   Example output:

   ```
   0x0 0x7fcc76400000,0x7fcc76400000 0x7fccfcc00000,0x7fccfcc00000 0x7fcd83400000,0x7fcd83400000 0x7fce09c00000,0x7fce09c00000 0x7fce90400000,0x7fce90400000 0x7fcf16c00000,0x7fcf16c00000 0x7fcf9d400000,0x7fcf9d400000 0x7fd023c00000,0x7fd023c00000 0x7fd0aa400000,0x7fd0aa400000 0x7fd130c00000,0x7fd130c00000 0x7fd1b7400000,0x7fd1b7400000 0x7fd23dc00000,0x7fd23dc00000 0x7fd2c4400000,0x7fd2c4400000 0x7fd34ac00000,0x7fd34ac00000 0x7fd3d1400000,0x7fd3d1400000 0x7fd457c00000,0x7fd457c00000 0x7fd4de400000,0x7fd4de400000 0x7fd564c00000,0x7fd564c00000 0x7fd5eb400000,0x7fd5eb400000 0x7fd671c00000,0x7fd671c00000 0x7fd6f8400000,0x7fd6f8400000 0x7fd77ec00000,0x7fd77ec00000 0x7fd805400000,0x7fd805400000 0x7fd88bc00000,0x7fd88bc00000 0x7fd912400000,0x7fd912400000 0x7fd998c00000,0x7fd998c00000 0x7fda1f400000,0x7fda1f400000 0x7fdaa5c00000,0x7fdaa5c00000 0x7fdb2c400000,0x7fdb2c400000 0x7fdbb2c00000,0x7fdbb2c00000 0x7fdc39400000,0x7fdc39400000 0x7fdcbfc00000,0x7fdcbfc00000 0x7fdd46400000,0x7fdd46400000 0x7fddccc00000,0x7fddccc00000 0x7fde53400000,0x7fde53400000 0x7fded9c00000,0x7fded9c00000 0x7fdf60400000,0x7fdf60400000 0x7fdfe6c00000,0x7fdfe6c00000 0x7fe06d400000,0x7fe06d400000 0x7fe0f3c00000,0x7fe0f3c00000 0x7fe17a400000,0x7fe17a400000 0x7fe200c00000,0x7fe200c00000 0x7fe287400000,0x7fe287400000 0x7fe30dc00000,0x7fe30dc00000 0x7fe394400000,0x7fe394400000 0x7fe41ac00000,0x7fe41ac00000 0x7fe4a1400000,0x7fe4a1400000 0x7fe527c00000,0x7fe527c00000 0x7fe5ae400000,0x7fe5ae400000 0x7fe634c00000,0x7fe634c00000 0x7fe6bb400000,0x7fe6bb400000 0x7fe741c00000,0x7fe741c00000 0x7fe7c8400000,0x7fe7c8400000 0x7fe84ec00000,0x7fe84ec00000 0x7fe8d5400000,0x7fe8d5400000 0x7fe95bc00000,0x7fe95bc00000 0x7fe9e2400000,0x7fe9e2400000 0x7fea68c00000,0x7fea68c00000 0x7feaef400000,0x7feaef400000 0x7feb75c00000,0x7feb75c00000 0x7febfc400000,0x7febfc400000 0x7fec82c00000,0x7fec82c00000 0x7fed09400000,0x7fed09400000 0x7fed8fc00000,0x7fed8fc00000 0x7fee16400000,0x7fee16400000 0x7fee9cc00000,0x7fee9cc00000 0x7fef23400000,0x7fef23400000 0x7fefa9c00000,0x7fefa9c00000 0x7ff030400000,0x7ff030400000 0x7ff0b6c00000,0x7ff0b6c00000 0x7ff13d400000,0x7ff13d400000 0x7ff1c3c00000,0x7ff1c3c00000 0x7ff24a400000,0x7ff24a400000 0x7ff2d0c00000,0x7ff2d0c00000 0x7ff357400000,0x7ff357400000 0x7ff3ddc00000,0x7ff3ddc00000 0x7ff464400000,0x7ff464400000 0x7ff4eac00000,0x7ff4eac00000 0x7ff571400000,0x7ff571400000 0x7ff5f7c00000,0x7ff5f7c00000 0x7ff67e400000,0x7ff67e400000 0x7ff704c00000,0x7ff704c00000 0x7ff78b400000,0x7ff78b400000 0x7ff811c00000,0x7ff811c00000 0x7ff898400000,0x7ff898400000 0x7ff91ec00000,0x7ff91ec00000 0x7ff9a5400000,0x7ff9a5400000 0x7ffa2bc00000,0x7ffa2bc00000 0x7ffab2400000,0x7ffab2400000 0x7ffb38c00000,0x7ffb38c00000 0x7ffbbf400000,0x7ffbbf400000 0x7ffc45c00000,0x7ffc45c00000 0x7ffccc400000,0x7ffccc400000 0x7ffd52c00000,0x7ffd52c00000 0x7ffdd9400000,0x7ffdd9400000 0x7ffe5fc00000,0x7ffe5fc00000 0x7ffee6400000,0x7ffee6400000 0x7fff6cc00000,0x7fff6cc00000 0x7ffff3400000,0x7ffff3400000 0x800079c00000
   ```

   These are the address space slices we will use for our profiling.

3. For each `<start> <end>,...` in the list above, run the following command (we ran each command 5x to reduce variability):

   ```sh
   ./target/debug/runner exp00010 {MACHINE} {USER}  --thp_huge_addr_ranges {ADDR} \
      --end --mmu_overhead hacky_spec17 xz --spec_size 76800 --input  training
   ```

   where `{ADDR}` is replaced by an address range from the above list.

   We used [`jobserver`] to manage this set of experiments for us:

   ```sh
   j job matrix add -x 5 --timeout 600 --max_failures 5 exp-c220g5 "exp00010 {MACHINE} {USER}  --thp_huge_addr_ranges {ADDR} --end  --mmu_overhead    hacky_spec17 xz --spec_size 76800 --input  training" /p/multifacet/users/markm/results3/cbmm/ "ADDR=0x0 0x7fcc76400000,0x7fcc76400000 0x7fccfcc00000,0x7fccfcc00000 0x7fcd83400000,0x7fcd83400000 0x7fce09c00000,0x7fce09c00000 0x7fce90400000,0x7fce90400000 0x7fcf16c00000,0x7fcf16c00000 0x7fcf9d400000,0x7fcf9d400000 0x7fd023c00000,0x7fd023c00000 0x7fd0aa400000,0x7fd0aa400000 0x7fd130c00000,0x7fd130c00000 0x7fd1b7400000,0x7fd1b7400000 0x7fd23dc00000,0x7fd23dc00000 0x7fd2c4400000,0x7fd2c4400000 0x7fd34ac00000,0x7fd34ac00000 0x7fd3d1400000,0x7fd3d1400000 0x7fd457c00000,0x7fd457c00000 0x7fd4de400000,0x7fd4de400000 0x7fd564c00000,0x7fd564c00000 0x7fd5eb400000,0x7fd5eb400000 0x7fd671c00000,0x7fd671c00000 0x7fd6f8400000,0x7fd6f8400000 0x7fd77ec00000,0x7fd77ec00000 0x7fd805400000,0x7fd805400000 0x7fd88bc00000,0x7fd88bc00000 0x7fd912400000,0x7fd912400000 0x7fd998c00000,0x7fd998c00000 0x7fda1f400000,0x7fda1f400000 0x7fdaa5c00000,0x7fdaa5c00000 0x7fdb2c400000,0x7fdb2c400000 0x7fdbb2c00000,0x7fdbb2c00000 0x7fdc39400000,0x7fdc39400000 0x7fdcbfc00000,0x7fdcbfc00000 0x7fdd46400000,0x7fdd46400000 0x7fddccc00000,0x7fddccc00000 0x7fde53400000,0x7fde53400000 0x7fded9c00000,0x7fded9c00000 0x7fdf60400000,0x7fdf60400000 0x7fdfe6c00000,0x7fdfe6c00000 0x7fe06d400000,0x7fe06d400000 0x7fe0f3c00000,0x7fe0f3c00000 0x7fe17a400000,0x7fe17a400000 0x7fe200c00000,0x7fe200c00000 0x7fe287400000,0x7fe287400000 0x7fe30dc00000,0x7fe30dc00000 0x7fe394400000,0x7fe394400000 0x7fe41ac00000,0x7fe41ac00000 0x7fe4a1400000,0x7fe4a1400000 0x7fe527c00000,0x7fe527c00000 0x7fe5ae400000,0x7fe5ae400000 0x7fe634c00000,0x7fe634c00000 0x7fe6bb400000,0x7fe6bb400000 0x7fe741c00000,0x7fe741c00000 0x7fe7c8400000,0x7fe7c8400000 0x7fe84ec00000,0x7fe84ec00000 0x7fe8d5400000,0x7fe8d5400000 0x7fe95bc00000,0x7fe95bc00000 0x7fe9e2400000,0x7fe9e2400000 0x7fea68c00000,0x7fea68c00000 0x7feaef400000,0x7feaef400000 0x7feb75c00000,0x7feb75c00000 0x7febfc400000,0x7febfc400000 0x7fec82c00000,0x7fec82c00000 0x7fed09400000,0x7fed09400000 0x7fed8fc00000,0x7fed8fc00000 0x7fee16400000,0x7fee16400000 0x7fee9cc00000,0x7fee9cc00000 0x7fef23400000,0x7fef23400000 0x7fefa9c00000,0x7fefa9c00000 0x7ff030400000,0x7ff030400000 0x7ff0b6c00000,0x7ff0b6c00000 0x7ff13d400000,0x7ff13d400000 0x7ff1c3c00000,0x7ff1c3c00000 0x7ff24a400000,0x7ff24a400000 0x7ff2d0c00000,0x7ff2d0c00000 0x7ff357400000,0x7ff357400000 0x7ff3ddc00000,0x7ff3ddc00000 0x7ff464400000,0x7ff464400000 0x7ff4eac00000,0x7ff4eac00000 0x7ff571400000,0x7ff571400000 0x7ff5f7c00000,0x7ff5f7c00000 0x7ff67e400000,0x7ff67e400000 0x7ff704c00000,0x7ff704c00000 0x7ff78b400000,0x7ff78b400000 0x7ff811c00000,0x7ff811c00000 0x7ff898400000,0x7ff898400000 0x7ff91ec00000,0x7ff91ec00000 0x7ff9a5400000,0x7ff9a5400000 0x7ffa2bc00000,0x7ffa2bc00000 0x7ffab2400000,0x7ffab2400000 0x7ffb38c00000,0x7ffb38c00000 0x7ffbbf400000,0x7ffbbf400000 0x7ffc45c00000,0x7ffc45c00000 0x7ffccc400000,0x7ffccc400000 0x7ffd52c00000,0x7ffd52c00000 0x7ffdd9400000,0x7ffdd9400000 0x7ffe5fc00000,0x7ffe5fc00000 0x7ffee6400000,0x7ffee6400000 0x7fff6cc00000,0x7fff6cc00000 0x7ffff3400000,0x7ffff3400000 0x800079c00000"
   ```

   TODO: maybe want to provide a table here so they don't have to generate figure 5 first?

4. For each output file from the experiments above, run `./scripts/extract-ranges3.py` to extract the data from the experiment output. The data will be a collection of metadata and performance counters. We once again used [`jobserver`] to help with this:

   ```sh
   j job stat --only_done --results_path mmu --cmd --csv --jid --mapper /nobackup/scripts/extract-ranges3.py --id 59000 > /tmp/data.csv
   ```

   TODO: am I missing the control experiments?

5. We then imported the CSV to spreadsheet software and used it to produce plots and statistics.

[`jobserver`]: https://github.com/mark-i-m/jobserver

### Figure 2

These experiments measure page fault latency on Linux (v5.5.8) for each of the workloads we measured.

1. Run the experiments.

   Note that this script runs all experiments sequentially, which would take multiple days. Feel free to comment out some experiments (lines in the `figure-2.sh` script) to produce partial results.

    ```sh
    cd cbmm-runner/runner
    ../../scripts/figure-2.sh
    ```

2. Copy the results back from the _test_ machine to the _driver_ machine. We recommend `rsync` for this, as it supports compression.

   ```sh
   mkdir results/
   rsync -avzP {MACHINE}:~/vm_shared/ results/
   ```

3. Process the output to generate plots. For each workload, let `$RESULTS_PATH` be the path to the output (in the `results/` directory we just created). Then, the following command generates the subplots of Figure 2:

   ```sh
   cd cbmm-artifact
   ./scripts/cdf.py $(./cbmm/mm/read-pftrace/target/release/read-pftrace --cli-only \
      --exclude NOT_ANON --exclude SWAP --other-category 600 \
      -- $RESULTS_PATH.{pftrace,rejected} 10000)
   ```

### Figure 4

These experiments are similar to Figure 2. They collect the same data as Figure
2, but on HawkEye and CBMM, too. Additionally, we will process them differently
to generate different plots.

1. Run the experiments.

   Note that we can reuse the results from the Figure 2 experiments for Linux, so `figure-4.sh` does not run them.

   Note that this script runs all experiments sequentially, which would take multiple days. Feel free to comment out some experiments (lines in the `figure-4.sh` script) to produce partial results.

    ```sh
    cd cbmm-runner/runner
    ../../scripts/figure-4.sh
    ```

2. Copy the results back from the _test_ machine to the _driver_ machine. We recommend `rsync` for this, as it supports compression.

   ```sh
   mkdir results/
   rsync -avzP {MACHINE}:~/vm_shared/ results/
   ```

3. Process the output to compute the page fault rate for each workload.

   TODO: maybe want to provide a table here so they don't have to generate figure 5 first?

   TODO

4. Process the output to generate plots. For each workload, let
   - `$LINUX_RESULTS` be the results of the Linux experiment for this workload and fragmentation setting,
   - `$LINUX_SCALE` be the page fault rate in faults/second for this workload and fragmentation setting, as computed in the previous step,
   - `$HAWKEYE_RESULTS` be the results of the Hawkeye experiment ...
   - `$HAWKEYE_SCALE` be the page fault rate in faults/second,
   - `$CBMM_RESULTS` be the results of the CBMM experiment...
   - `$CBMM_SCALE` be the page fault rate in faults/second,

   Then, we can produce the subplot of Figure 4 representing a particular workload and fragmentation setting as follows:

   ```sh
   /nobackup/linux-mm-econ/mm/read-pftrace/target/release/read-pftrace --tail 10 --combined --cli-only --exclude NOT_ANON --exclude SWAP --  $LINUX_RESULTS.{pftrace,rejected} 10000 | sed 's|none([0-9]\+)|Linux|' > /tmp/tails.txt
   /nobackup/linux-mm-econ/mm/read-pftrace/target/release/read-pftrace --tail 10 --combined --cli-only --exclude NOT_ANON --exclude SWAP --  $CBMM_RESULTS.{pftrace,rejected} 10000 | sed 's|none([0-9]\+)|CBMM|' >> /tmp/tails.txt
   FREQ=2600 /nobackup/scripts/bpf-pftrace-percentiles.py $HAWKEYE_RESULTS.pftrace 3846 10 | sed 's|none([0-9]\+)|HawkEye|' >> /tmp/tails.txt
   OUTFNAME=tails-mix PDF=1 FREQ=2200 SCALE="$LINUX_SCALE $CBMM_SCALE $HAWKEYE_SCALE" ./scripts/tail-cdf.py 10 $(cat /tmp/tails.txt)
   ```

### Figure 5

These experiments capture the total runtime of the workloads for each kernel and fragmentation setting.

1. Run the experiments.

   ```sh
   cd cbmm-runner/runner
   ../../scripts/figure-5.sh
   ```

2. Copy the results back from the _test_ machine to the _driver_ machine. We recommend `rsync` for this, as it supports compression.

   ```sh
   mkdir results/
   rsync -avzP {MACHINE}:~/vm_shared/ results/
   ```

3. Process the output... TODO

4. TODO: scripts/plot-perf.py

### Figure 6

These experiments capture the amount of each workloads' memory usage covered by huge pages for each kernel and fragmentation setting.

1. Run the experiments.

   ```sh
   cd cbmm-runner/runner
   ./scripts/figure-6.sh
   ```

2. Copy the results back from the _test_ machine to the _driver_ machine. We recommend `rsync` for this, as it supports compression.

   ```sh
   mkdir results/
   rsync -avzP {MACHINE}:~/vm_shared/ results/
   ```

3.  Process the output... TODO

4. TODO: scripts/plot-hp-efficiency.py

### Section 5.5

TODO
