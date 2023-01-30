import os
import os.path
import shutil
import pathlib
import subprocess

def run(cmd):
    result = subprocess.run(cmd)
    assert result.returncode == 0

def latency_run(args):
    os.mkdir('latencies')
    run(['./kvstore'] + args)
    shutil.rmtree('latencies')

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
    latency_run(BQ_ARGS)
    latency_run(CASHTPP_ARGS)
    latency_run(CASHT_ARGS)
