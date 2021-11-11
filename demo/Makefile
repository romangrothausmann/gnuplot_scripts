
all : random-points.svg

%.svg : ../data/%.txt
	gnuplot -e "datafile='$<'; outfile='$@'; bin=0.5; sigma=bin; col=2; xlabel='example values'" ../hist-ar+kd.gp
