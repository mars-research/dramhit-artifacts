reset
set term postscript enhanced color eps 20 solid
#set output "uniform-set-small.eps"
set output "fig9.eps"

set xlabel "Number of threads" font ",19"
set ylabel "Mops/s" font ",19"

set xrange [1:64]
set ytics 250
#set key above  width -3 horizontal font ",16" maxrows 1
set key left width -2 top font ",16"
set datafile separator ","

set title "{/:Bold Figure 9.} Lookups (uniform-small)"

set loadpath '../plot-common'
load 'xyborder.cfg'
#load 'ratio.cfg'

plot "small_ht.csv" using 1:5 title "Folklore-small" \
		with lp ls 1 lw 5, \
		'' using 1:10 title "KVStore-small" \
		with lp ls 2 lw 5, \
		'' using 1:15 title "KVStoreP-small"   \
		with lp ls 3 lw 5
