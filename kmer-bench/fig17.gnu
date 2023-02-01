reset
set term postscript enhanced color eps 20 solid
set output "fig17.eps"

set xlabel "K" font ",19"
set ylabel "Mops/s" font ",19"

set ytics 250
set key above  width -1.4 horizontal font ",16" maxrows 2
#set key above width -2 top font ",16"
set datafile separator ","

set loadpath '../plot-common'
load 'xyborder.cfg'
#load 'ratio.cfg'

plot "summary_kmer.csv" \
       using 1:2 title "Chtkc-o" \
       with lp ls 5 lw 5, \
       '' using 1:6 title "Folklore"   \
       with lp ls 1 lw 5, \
       '' using 1:4 title "KVStore"   \
       with lp ls 4 lw 5, \
       '' using 1:8 title "KVStoreP"   \
       with lp ls 3 lw 5
