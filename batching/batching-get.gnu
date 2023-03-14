reset
set term postscript enhanced color eps 20 solid
set output "batching-get.eps"

set xlabel "Batch length" font ",19"
set ylabel "Finds (Mops)" font ",19"

set xrange [1:16]
set ytics 500
#set key above  width -3 horizontal font ",16" maxrows 1
set key left width -2 top font ",16"
set datafile separator ","

set title "{/:Bold Figure:} Batch length vs Lookups"

set loadpath '../plot-common'
load 'xyborder.cfg'
#load 'ratio.cfg'

plot "batching.csv" using 1:5 title "DRAMHiT" \
		with lp ls 2 lw 5, \
		'' using 1:10 title "DRAMHiT-P" \
		with lp ls 3 lw 5

