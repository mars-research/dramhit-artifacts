reset
set term postscript enhanced color eps 20 solid
set output "fig12.eps"

set xlabel "Skew" font ",19"
set ylabel "Mops/s" font ",19"

set ytics 1200
set key left width -2 top font ",16"
set datafile separator ","

set title "{/:Bold Figure 12.} Lookups on a skewed distribution (small)"

set loadpath '../plot-common'
load 'xyborder.cfg'
#load 'ratio.cfg'

plot "small_skewed_ht.csv" using 1:6 title "Folklore-small" \
		with lp ls 1 lw 5, \
		'' using 1:11 title "KVStore-small" \
		with lp ls 2 lw 5, \
		'' using 1:16 title "KVStoreP-small"   \
		with lp ls 3 lw 5
