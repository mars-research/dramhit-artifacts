import os
import sys
import re
import pathlib
from collections import defaultdict

if __name__ == '__main__':
    data = defaultdict(lambda : {})
    data['queues'] = defaultdict(lambda : {})
    mops_re = re.compile("set_mops : (\d+(?:.\d+)?), get_mops : (\d+(?:.\d+)?)")
    for filename in os.listdir(sys.argv[1]):
        chunks = filename.split('-')
        if chunks[0] != 'pollute':
            continue
        
        filepath = pathlib.Path(sys.argv[1]).joinpath(filename)
        with open(filepath) as file:
            kind, n = chunks[1:]
            n = int(n)
            for line in file.readlines():
                result = mops_re.search(line)
                if result != None:
                    if 'queues' not in kind:
                        data[kind][n] = (float(result[1]), float(result[2]))
                    else:
                        data['queues'][int(kind[len('queues'):])][n] = (float(result[1]), float(result[2]))

                    break
                
            #assert n in data[kind]

    queues = defaultdict(lambda : ([], []))
    for nc, subdata in data['queues'].items():
        for pollutes, mops in subdata.items():
            queues[pollutes][0].append(mops[0])
            queues[pollutes][1].append(mops[1])

    queues = {n: (max(d[0]), max(d[1])) for n, d in queues.items()}
    data['queues'] = queues

    finds = {kind: [(n, data[kind][n][1]) for n in data[kind]] for kind in data}
    finds = {kind: list(zip(*sorted(finds[kind], key=lambda v : v[0]))) for kind in finds}
    inserts = {kind: [(n, data[kind][n][0]) for n in data[kind]] for kind in data}
    inserts = {kind: list(zip(*sorted(inserts[kind], key=lambda v : v[0]))) for kind in inserts}

    print('pollutions, queue_set, queue_get, chtpp_set, chtpp_get, cht_set, chtpp_get')
    for i, p in enumerate(finds['queues'][0]):
        print(f"{p}, {inserts['queues'][1][i]}, {finds['queues'][1][i]}, {inserts['chtpp'][1][i]}, {finds['chtpp'][1][i]}, {inserts['cht'][1][i]}, {finds['cht'][1][i]}")
