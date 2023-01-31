import os
import os.path
import shutil
import pathlib
import subprocess
from collections import defaultdict

def run(cmd):
    result = subprocess.run(cmd)
    assert result.returncode == 0

def latency_run(args, label):
    os.mkdir('latencies')
    run(['./kvstore'] + args)
    interleave('./latencies/', label)
    shutil.rmtree('latencies')

def interleave(path, label):
    datasets = defaultdict(lambda : [])
    for name in os.listdir(path):
        prefix = label + '-' + name.split('.')[0].split('_')[0]
        datasets[prefix].append(name)

    print(datasets)

    for prefix, sources in datasets.items():
        file = open(f'{prefix}.dat', 'w')
        for source in sources:
            latencies = open(f'{path}{source}', 'r')
            for line in latencies.readlines():
                print(line, end='', file=file)

BQ_ARGS = '--ht-fill=75 --mode=8 --ht-type=1 --ncons=32 --nprod=32 --skew=0.01'.split()
CASHTPP_ARGS = '--ht-fill=75 --mode=11 --ht-type=3 --num-threads=64 --numa-split=1 --skew=0.01'.split()
CASHT_ARGS = '--ht-fill=75 --mode=11 --ht-type=3 --num-threads=64 --numa-split=1 --skew=0.01 --no-prefetch=1'.split()

if __name__ == '__main__':
    os.chdir('/opt/kvstore')
    if os.path.exists('build'):
        shutil.rmtree(pathlib.Path('build'))
    
    os.mkdir('build')
    run(['nix-shell', '--command', 'cd build && cmake ../ -G Ninja -DLATENCY_COLLECTION=ON -DBQ_ZIPFIAN=ON && cmake --build .'])
    os.chdir('build')
    latency_run(BQ_ARGS, 'bq')
    latency_run(CASHTPP_ARGS, 'chtpp')
    latency_run(CASHT_ARGS, 'cht')
