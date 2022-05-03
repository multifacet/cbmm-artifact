# Artifact package for CBMM paper (ATC'22)

## Overview

This artifact contains:

- `README.md`: this file.
- `paper.pdf`: the accepted version of the paper, without any modifications responding to reviewer requests.
- `linux-mm-econ/`: a git submodule containing our primary artifact, the CBMM kernel, which is a modified version of Linux 5.5.8.
- `runner/`: a git submodule of our `runner` tool, which runs our experiments.
- `profiles/`: a set of profiles we used in our evaluation. More later.

Since our artifact is a kernel, our evaluation uses two machines: one to drive experiments (the _driver_ machine) and one for the experiments to run on (the _test_ machine). We do it this way so that our experiments can run on bare metal without virtualization overheads to muddle the results. We use two separate machines because it makes automation and scripting easier.

The CBMM kernel runs on the _test_ machine, while the `runner` program runs on the _driver_ machine.

## Hardware and Software Requirements

_Driver_ machine:
- A recent Linux distro with standard utilities. We ran extensively on Ubuntu 18.04 and Ubuntu 20.04. In theory, we should support MacOS, but it's never been tested, so YMMV.
- Rust 1.31 or greater. The `runner` is written in rust.
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

### Steps

**On the _driver_ machine**

1. Clone this repo.

    ```sh
    git clone https://github.com/multifacet/cbmm-artifact
    ```

2. Initialize the `runner` submodule.

   ```sh
   cd cbmm-artifact
   git submodule update --init -- runner
   ```

3. Build the `runner` using Rust's `cargo` tool. This will download dependencies and build and link the tool. It should take <10 minutes to complete on an average machine.

   ```sh
   cd runner/runner
   cargo build
   ```

4. Use the `runner` to set up the _test_ machine. NOTE: make sure that SSH'ing into the _test_ machine is passwordless and requires no interaction. For example, log into the machine manually once to address any fingerprint confirmations that SSH may generate.

   In the following commands, replace `{MACHINE}` with the `ip:port` of the _test_ machine (e.g., `foo.cs.wisc.edu:22`), `{USER}` with the username on the _test_ machine (e.g., `markm`).

   ```sh
   # Clones/installs/builds a bunch of dependencies and benchmarks.
   ./target/debug/runner setup00000 {MACHINE} {USER} --centos7 --jemalloc \
      # TODO: update the path to point to the artifact?
      --clone_wkspc \
      --firewall --host_bmks --host_dep \
      # TODO: how to include these? Maybe as a troubleshooting section?
      --resize_root --swap sdb --unstable_device_names \
      # TODO: get rid of need for {TOKEN}
      --secret {TOKEN}
      # Replace this with the path to your ISO
      --spec_2017 /path/to/spec2017.iso
      # TODO: what to do about this?
      --spec_xz_input /p/scail/users/bijan/xz_input.tar.xz

   # Clones and builds the CBMM kernel.
   # TODO: have this point to the artifact?
   # TODO: replace `dev` with a specific hash?
   ./target/debug/runner setup00003 {MACHINE} {USER} dev \
      --https github.com/mark-i-m/linux-mm-econ \
      # TODO: make this unnecessary?
      --username robo-mark-i-m --secret {TOKEN} \
      +CONFIG_TRANSPARENT_HUGEPAGE +CONFIG_MM_ECON -CONFIG_PAGE_TABLE_ISOLATION -CONFIG_RETPOLINE +CONFIG_GDB_SCRIPTS +CONFIG_FRAME_POINTERS +CONFIG_IKHEADERS +CONFIG_SLAB_FREELIST_RANDOM +CONFIG_SHUFFLE_PAGE_ALLOCATOR
   ```

   These commands take ~2 hours total to run on our machines. They should produce lots of output about the commands being run and their output. The commands being run are on the _test_ machine (over SSH), not the _driver_.

**Congratulations!** You should now have a fully-set-up _driver_ and _test_ machine pair. We can now begin running experiments.

### Kick the tires (a small test)

TODO

## Detailed Instructions

TODO
