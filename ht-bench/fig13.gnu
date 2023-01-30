reset
set term postscript enhanced color eps 20 solid
set output "fig13.eps"

set xlabel "Skew" font ",19"
set ylabel "Mops/s" font ",19"

set ytics 500
set key left width -2 top font ",16"
set datafile separator ","

set title "{/:Bold Figure 13.} Insertions on a skewed distribution (large)"

set loadpath '../plot-common'
load 'xyborder.cfg'
#load 'ratio.cfg'

plot "large_skewed_ht.csv" using 1:4 title "Folklore-large" \
		with lp ls 1 lw 5, \
		'' using 1:9 title "KVStore-large" \
		with lp ls 2 lw 5, \
		'' using 1:14 title "KVStoreP-large"   \
		with lp ls 3 lw 5
