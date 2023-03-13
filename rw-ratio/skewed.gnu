#set size 1, 0.7

set loadpath '../plot-common'
load 'xyborder.cfg'

plot "skewed.csv" using 1:2 title "Folklore" \
		with lp ls 1 lw 5, \
		'' using 1:3 title "DRAMHiT" \
		with lp ls 2 lw 5, \
		'' using 1:4 title "DRAMHiT-P" with lp ls 3 lw 5
