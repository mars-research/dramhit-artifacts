# Artifact Evaluation - EuroSys'23

Thank you for your time and picking our paper for the artifact evaluation.

This documentation contains steps necessary to reproduce the artifacts for our
paper titled **KVStore: A Hash-Table Architected for the Speed of DRAM**.

All the experiments are evaluated on a Dell PowerEdge C6420 machine on the
[Cloudlab Infrastructure](https://www.clemson.cloudlab.us/portal/show-nodetype.php?type=c6420)

## Setting up the hardware

* Create an account on [Cloudlab](https://www.cloudlab.us/) and login.

### Configuring the experiment

#### Automated setup (Recommended)
* The easiest way to setup our experiment is to use "Repository based profile".

* Create an experiment profile by selecting
  `Experiments > Create Experiment profile`

* Select `Git Repo` and use this repository. The profile comes pre-installed
  with source code for evaluating ksplit's static analysis.
```
https://github.com/mars-research/ksplit-cloudlab
```
* Populate the name field and click `Create`

* If successful, instantiate the created profile by clicking `Instantiate`
  button on the left pane.

* **NOTE** You can select different branches on the git repository. Please select
  `kvstore-ae` branch.

* For a more descriptive explanation and its inner details, consult the
  cloudlab documentation on [repo based profiles](https://docs.cloudlab.us/creating-profiles.html#(part._repo-based-profiles)

* The `profile` git repository contains a bootstrapping script which
  automatically clones and builds the following repositories, upon a successful
  bootup of the node.
  - `/opt/kvstore/kvstore` - hashtable for running most of the benchmarks
  - `/opt/kvstore/incrementer` - for fig2

* Please allow sometime to clone and build all the source code. You can check
  the progress by tailing the log file.

* A short log is located at `/users/geniuser/kvstore-setup.log`. If the setup is
  successful, the short log should contain something similar to the one below
```
[Tue Jan 24 12:06:50 PM MST 2023] Preparing local partition ...
[Tue Jan 24 12:06:50 PM MST 2023] Creating ext4 filesystem on /dev/sda4
[Tue Jan 24 12:07:04 PM MST 2023] Begin setup!
[Tue Jan 24 12:07:04 PM MST 2023] Installing nix...
[Tue Jan 24 12:07:39 PM MST 2023] Cloning incrementer
[Tue Jan 24 12:07:40 PM MST 2023] Cloning kvstore...
[Tue Jan 24 12:08:11 PM MST 2023] Building kvstore
[Tue Jan 24 12:11:48 PM MST 2023] Done Setting up!
```

* A detailed log is available at `/users/geniuser/kvstore-verbose.log`

* The script that gets executed after startup is available
  [here](https://github.com/mars-research/ksplit-cloudlab/blob/kvstore-ae/kvstore-top.sh)

* **NOTE** The automated script is executed by a different user (`geniuser`). If
  you need to manually build something under `/opt/kvstore` make sure to change
  ownership.
  ```
  pushd /opt/kvstore
  sudo chown -R <your-user-name>:<your-group> .
  ```

#### Manual setup
* If you want to set up the source repos manually for some reason,
```
mkdir /local
# make sure you have permissions or use chown
git clone https://github.com/mars-research/ksplit-cloudlab.git /local/respository --branch kvstore-ae
# invoke the top level script
/local/respository/kvstore-top.sh
```

## Experiments

### Prerequisites
* The following steps assume that the experiment profile is created using the
  aforementioned steps (i.e., using the git repo for creating the profile).

* To create this setup manually,
  - Clone https://github.com/mars-research/ksplit-cloudlab
  - Make sure `/opt/kvstore` is writable
  - Execute `kvstore-top.sh`

### Building KVStore
* The pdg sources should automatically be built for you. If not, refer to the
  Prerequisites subsection above to set it up manually.

* Clone the artifacts repository in your `${HOME}` directory. The scripts have
  this path hardcoded.
```
cd ${HOME}
git clone https://github.com/mars-research/kvstore-artifacts.git
```

### Figure 2

* To replicate figure 2 from the paper, please invoke this script which runs the
  benchmark, collects the results and plots the graph.
 ```bash
 cd ${HOME}/kvstore-artifacts/fig2
 ./fig2.sh
 ```
 - Figure 2 is written to `fig2.pdf`

### Figures 7-14

* To replicate all the hashtable benchmarks (Figures 7 to 14), invoke the
  script that runs all the hashtable benchmarks, captures the csv output, and
  plots the graph using gnuplot.

 ```bash
 cd ${HOME}/kvstore-artifacts/ht-bench
 ./ht-bench.sh
 ```
 - Figures are written to `fig${num}.pdf`

### Figure 15

* To generate the latency plot (Figures 15), invoke the script that runs all
  the hashtable benchmarks, collects the latency metrics, and plots the graph
  using gnuplot.

 ```bash
 cd ${HOME}/kvstore-artifacts/fig15/
 ./fig15.sh
 ```
 - Figures are written to `fig15.pdf`
