reset
set term postscript enhanced color eps 20 solid
set output "pollutions-get.eps"

set xlabel "# pollutions / op" font ",19"
set ylabel "Throughput (Mops)" font ",19"

set xrange [0:40]
set yrange [0:1000]
set ytics 250
set key right top font ",19"
set datafile separator ","

unset key
#set size ratio 0.3
#set size 1, 0.7

set loadpath '../plot-common'
load 'xyborder.cfg'

plot "pollutions.csv" using 1:7 title "Folklore" \
		with lp ls 1 lw 5, \
	'' using 1:5 title "DRAMHiT" \
		with lp ls 2 lw 5, \
	'' using 1:3 title "DRAMHiT-P" \
		with lp ls 3 lw 5
