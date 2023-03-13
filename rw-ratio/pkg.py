import sys
import os
from collections import defaultdict
import pathlib
import re

MOPS_RE = re.compile("set_mops : (\d+(?:.\d+)?), get_mops : ((?:\d+(?:.\d+)?)|inf)")


def get_mops(filepath):
    match = MOPS_RE.search(''.join(open(filepath).readlines()))
    return float(match[1]), float(match[2])

def main():
    path = pathlib.Path(sys.argv[1])
    data = {'cht': {}, 'chtpp': {}, 'queues': defaultdict(lambda : defaultdict(lambda : []))}
    for file in os.listdir(path):
        filepath = path.joinpath(file)
        chunks = file.split('-')
        kind = chunks[0]
        if kind not in data.keys():
            continue

        pread = float(chunks[1])
        if kind != 'queues':
            data[kind][pread] = get_mops(filepath)[0]
        else:
            n_cons = int(chunks[2])
            data[kind][pread][n_cons].append(get_mops(filepath)[1])

    for pread in data['queues']:
        blob = data['queues'][pread]
        best_mops = 0.0
        for n_cons in blob:
            best_mops = max((lambda l : sum(l) / len(l))(blob[n_cons]), best_mops)

        data['queues'][pread] = best_mops

    print('p-read, cht, chtpp, queues')
    for pread in data['queues']:
        print(pread, data['cht'][pread], data['chtpp'][pread], data['queues'][pread], sep=', ')

if __name__ == '__main__':
    main()
