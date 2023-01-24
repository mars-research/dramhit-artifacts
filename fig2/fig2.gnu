reset
set term postscript enhanced color eps 20 solid
set output "fig2.eps"

set xlabel "Skew value" font ",19"
set ylabel "Cycles per operation" font ",19"

set logscale y 10

set xrange [0.2:1.1]
set key font ",19" top left
set datafile separator ","

set loadpath '../plot-common'
load 'xyborder.cfg'

set size 1, 0.8

plot "fig2_32mb.csv" using 1:2 title "spinlock 32mb" \
		with lp ls 1 lc rgb blue lw 5, \
		'' using 1:3 title "atomic inc 32mb" \
		with lp ls 2 lc rgb blue lw 5, \
	"fig2_1gb.csv" using 1:2 title "spinlock 1gb" \
		with lp ls 1 lc rgb dblue lw 5, \
		'' using 1:3 title "atomic inc 1gb" \
		with lp ls 2 lc rgb dblue lw 5
