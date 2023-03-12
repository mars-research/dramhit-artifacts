reset
set term postscript enhanced color eps 20 solid
set output "latency.eps"

set key right bottom font ",12"
set datafile separator ","

#set size ratio 0.3
#set size 1, 0.7

#set yrange [0:1.2]
#set ytics 0.1

set logscale x
set xrange [10:]

set loadpath '../plot-common'
load 'xyborder.cfg'

casht_insert="/opt/kvstore/kvstore/build/cht-async.dat"
casht_find="/opt/kvstore/kvstore/build/cht-find.dat"
cashtpp_insert="/opt/kvstore/kvstore/build/chtpp-async.dat"
cashtpp_find="/opt/kvstore/kvstore/build/chtpp-find.dat"
queues_insert="/opt/kvstore/kvstore/build/bq-sync.dat"
queues_find="/opt/kvstore/kvstore/build/bq-find.dat"

stats casht_insert using 1 name "casht_insert"
stats casht_find using 1 name "casht_find"
stats cashtpp_insert using 1 name "cashtpp_insert"
stats cashtpp_find using 1 name "cashtpp_find"
stats queues_insert using 1 name "queues_insert"
stats queues_find using 1 name "queues_find"

set xlabel "Latency in Cycles" font ",19"
set ylabel "Cumulative proportion" font ",19"

set term post size 4,4

set key under

plot \
       casht_insert   using 1:(1./casht_insert_records) smooth cumulative with lines ls 1 lw 5\
                      title "Folklore insert", \
       casht_find     using 1:(1./casht_find_records) smooth cumulative with lines ls 2 lw 5\
                      title "Folklore find", \
       cashtpp_insert using 1:(1./cashtpp_insert_records) smooth cumulative with lines ls 3 lw 5\
                      title "KVstore insert", \
       cashtpp_find   using 1:(1./cashtpp_find_records) smooth cumulative with lines ls 4 lw 5\
                      title "KVstore find", \
       queues_insert  using 1:(1./queues_insert_records) smooth cumulative with lines ls 5 lw 5\
                      title "KVStoreP insert", \
       queues_find    using 1:(1./queues_find_records) smooth cumulative with lines ls 6 lw 5\
                      title "KVStoreP find"
