reset
set term postscript enhanced color eps 20 solid
set output "rw-skewed.eps"

set xlabel "Read probability" font ",19"
set ylabel "Throughput (Mops)" font ",19"

set ytics 500
#set key above  width -3 horizontal font ",16" maxrows 1
set key left width -2 top font ",16"
set datafile separator ","

set title "{/:Bold Figure:} p-read vs throughput"

set loadpath '../plot-common'
load 'xyborder.cfg'

plot "skewed.csv" using 1:2 title "Folklore" \
		with lp ls 1 lw 5, \
		'' using 1:3 title "DRAMHiT" \
		with lp ls 2 lw 5, \
		'' using 1:4 title "DRAMHiT-P" with lp ls 3 lw 5
