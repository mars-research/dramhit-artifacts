# Artifact Evaluation - EuroSys'23

Thank you for your time and picking our paper for the artifact evaluation.

This documentation contains steps necessary to reproduce the artifacts for our
paper titled **DRAMHiT: A Hash Table Architected for the Speed of DRAM**.

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
  with source code for evaluating DRAMHiT hash table.
```
https://github.com/mars-research/cloudlab-profiles
```
* Populate the name field and click `Create`

* If successful, instantiate the created profile by clicking `Instantiate`
  button on the left pane.

* **NOTE** You can select different branches on the git repository. Please select
  `dramhit-ae` branch.

* For a more descriptive explanation and its inner details, consult the
  cloudlab documentation on [repo based profiles](https://docs.cloudlab.us/creating-profiles.html#(part._repo-based-profiles)

* The `profile` git repository contains a bootstrapping script which
  automatically clones and builds the following repositories, upon a successful
  bootup of the node.
  - `/opt/dramhit/dramhit` - hashtable for running most of the benchmarks
  - `/opt/dramhit/incrementer` - for fig2

* Please allow sometime to clone and build all the source code. You can check
  the progress by tailing the log file.

* A short log is located at `/users/geniuser/dramhit-setup.log`. If the setup is
  successful, the short log should contain something similar to the one below
```
[Tue Jan 24 12:06:50 PM MST 2023] Preparing local partition ...
[Tue Jan 24 12:06:50 PM MST 2023] Creating ext4 filesystem on /dev/sda4
[Tue Jan 24 12:07:04 PM MST 2023] Begin setup!
[Tue Jan 24 12:07:04 PM MST 2023] Installing nix...
[Tue Jan 24 12:07:39 PM MST 2023] Cloning incrementer
[Tue Jan 24 12:07:40 PM MST 2023] Cloning dramhit...
[Tue Jan 24 12:08:11 PM MST 2023] Building dramhit
[Tue Jan 24 12:11:48 PM MST 2023] Done Setting up!
```

* A detailed log is available at `/users/geniuser/dramhit-verbose.log`

* The script that gets executed after startup is available
  [here](https://github.com/mars-research/cloudlab-profiles/blob/dramhit-ae/dramhit-top.sh)

* **NOTE** The automated script is executed by a different user (`geniuser`). If
  you need to manually build something under `/opt/dramhit` make sure to change
  ownership.
  ```
  pushd /opt/dramhit
  sudo chown -R <your-user-name>:<your-group> .
  ```

#### Manual setup
* If you want to set up the source repos manually for some reason,
```
mkdir /local
# make sure you have permissions or use chown
git clone https://github.com/mars-research/cloudlab-profiles.git /local/respository --branch dramhit-ae
# invoke the top level script
/local/respository/dramhit-top.sh
```

## Experiments

### Prerequisites
* The following steps assume that the experiment profile is created using the
  aforementioned steps (i.e., using the git repo for creating the profile).

* To create this setup manually,
  - Clone https://github.com/mars-research/cloudlab-profiles
  - Make sure `/opt/dramhit` is writable
  - Execute `dramhit-top.sh`

### Experiments
* All the sources should automatically be built for you. If not, refer to the
  Prerequisites subsection above to set it up manually.

* Clone the artifacts repository in your `${HOME}` directory. The scripts have
  this path hardcoded.
```
cd ${HOME}
git clone https://github.com/mars-research/dramhit-artifacts.git
```

* Chown the source code to your user name
```
sudo chown -R <your-user-name>:<your-group> /opt/dramhit
```

### Experiment 1 (Synchronization cost)

* To replicate figure 2 from the paper, please invoke this script which runs the
  benchmark, collects the results and plots the graph.
  - Time taken: 2-3 hours

 ```bash
 cd ${HOME}/dramhit-artifacts/fig2
 ./fig2.sh
 ```
 - Figure 2 is written to `fig2.pdf`

### Experiment 2 (Hash table benchmarks)

* To replicate all the hashtable benchmarks (Figures 6a, 6b, 8a, and 8b), invoke the
  script that runs all the hashtable benchmarks, captures the csv output, and
  plots the graph using gnuplot.
  - Time taken: 15 hours

 ```bash
 cd ${HOME}/dramhit-artifacts/ht-bench
 ./ht-bench.sh
 ```
 - Figures are written to `${dist}-${op}-${ht_size}.pdf`, where `dist` can be
   uniform or zipfian, `op` can be set or get, and `ht_size` can be large or
   small.

* All the figures should have three line plots. If the figures are not
  generated, the logs can possibly be corrupted due to failed or multiple
  successful runs.
  - In case of multiple successful runs, you can run the `prune-logs.sh` by
    entering the logdir

  ```
  cd /opt/dramhit/dramhit/esys-ae-${USER}
  ~/dramhit-artifacts/ht-bench/prune-logs.sh
  ```
    + Now you can re-run the `ht-bench.sh` script to generate the plots by
      commenting out the `run_ht_benchmarks` function to avoid re-running the
      data collection.

      ```
      #run_ht_benchmarks
      ```
  - In case of a failed or a partial run, you can remove or rename the log
    folder (`/opt/dramhit/dramhit/esys-ae-${USER}`) and run the `ht-bench.sh`
    script to re-run the experiments. There is a way to run only the unfinished
    experiments, but that involves editing the script files manually.

### Experiment 3 (Latency)

* To generate the latency plot (Figure 9), invoke the script that runs all
  the hashtable benchmarks, collects the latency metrics, and plots the graph
  using gnuplot.

 ```bash
 cd ${HOME}/dramhit-artifacts/latency/
 ./fig15.sh
 ```
 - Figures are written to `latency.pdf`

### Experiment 4 (Macro benchmark)

* To generate the kmer throughput graph (Figure 12), invoke the script that
  runs the kmer counting experiment with different hash tables and compare with
  one of the existing state-of-the kmer counters that uses lock-free hash
  table.

  ```bash
  cd ${HOME}/dramhit-artifacts/kmer-bench/
  ./kmer-bench.sh
  ```
  - Figures are written to `kmer-1.pdf` and `kmer-2.pdf`

## Additional experiments

### Experiment 5 (Experimen 2 on AMD architecture)

* To generate the hash table plots on AMD architecture (Figures 10, 11) follow
  the same steps as `Experiment 2` but on an AMD node.

### Experiment 6 (Cache pollution)
* Time taken: 5 human-minutes + 6 compute-hours

* Cache pollution experiments measure the impact of hash table performance when
  an application competes for the cache space (Figure 6c).

* The setup script under the `pollutions` directory builds and runs folklore, DRAMHiT,
  and DRAMHiT-P by polluting the cache after every operation to measure the
  throughput for insertions and lookups.

  ```bash
  cd ${HOME}/dramhit-artifacts/pollutions/
  ./fig.sh
  ```
  - Figures are written to `pollutions-set.pdf` and `pollutions-get.pdf`

### Experiment 7 (Mixed workloads)

* Time taken: [5 human-minutes + 8 compute-hours]

* We measure the hash table performance with a mix of insertions and lookups.
  We vary the read probability from 0.1 to 1.0, which controls the proportion
  of insert and lookup operations. The script builds and runs folklore,
  DRAMHiT, and DRAMHiT-P to plot the combined throughput for insertions and
  lookups in Figure 8c.

  ```bash
  cd ${HOME}/dramhit-artifacts/mixed-workloads/
  ./fig.sh
  ```
  - Figures are written to `rw-uniform.pdf` and `rw-skewed.pdf`

### Experiment 8 (Impact of batching)

* Time taken: [5 human-minutes + 8 compute-hours]

* We measure how the hash table performance varies when the batch size is
  varied. We vary the batch length in power-of-two increments from 1 to 16. The
  script builds and runs DRAMHiT, and DRAMHiT-P by varying the batch length and
  plots the Figure 7.

  ```bash
  cd ${HOME}/dramhit-artifacts/batching/
  ./batching.sh
  ```
  - Figures are written to `batching-set.pdf` and `batching-get.pdf`
