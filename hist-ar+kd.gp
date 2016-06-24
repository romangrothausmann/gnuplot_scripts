### gnuplot script to create a histogram with abs. and rel. scale and kernel-density plot


if (!exists("datafile")) datafile='default.dat' # http://gnuplot.sourceforge.net/docs_4.2/node60.html
if (!exists("outfile")) outfile='hist-ar+kd.svg' # use ARG0."svg" for gp-5:  http://stackoverflow.com/questions/12328603/how-to-pass-command-line-argument-to-gnuplot#31815067
if (!exists("xlabel")) xlabel='UNSPECIFIED'
if (!exists("bin")) bin=17
if (!exists("sigma")) sigma=0
if (!exists("xmin")) xmin=0
if (!exists("xmax")) xmax=180
if (!exists("col")) col=1
if (!exists("sep")) sep=whitespace

set datafile separator sep

set samples 1000
set boxwidth bin # very important! see "gnuplot in action" p. 257
bin (x,s)= s* int(x/s)
binc(x,s)= s* (int(x/s) + .5)
binl(x,s)= s* ceil(x/s)
binr(x,s)= s* floor(x/s)

stats datafile u col nooutput # sets e.g. STATS_records

###first do a dummy plot to determin chosen y-range;-)
set xrange [xmin:xmax]
set term dumb
plot datafile u (binc(column(col), bin)):(1. / bin / STATS_records) smooth frequency with boxes ti sprintf("%d values (rel. freq)", STATS_records)
###y-range is now: GPVAL_Y_MAX or use GPVAL_DATA_Y_MAX
print GPVAL_Y_MAX, GPVAL_DATA_Y_MAX


set yrange  [0:GPVAL_Y_MAX] # or [0:GPVAL_DATA_Y_MAX], without some small boxes might vanish!
set y2range [0:GPVAL_Y_MAX * bin * STATS_records] #scale yrange to make y2range graph (abs) coincide with relative

set title "kernel-density, relative and absolut frequency plot"
set xlabel xlabel
set ylabel  "rel. frequency"
set y2label "abs. frequency"
set y2tics
set ytics nomirror

set terminal svg enhanced font "arial,10" size 800,600 #with enhanced don't use: courier
set output outfile

set style fill transparent solid .7

set style line 1 lt 2 lc rgb "#000000" lw 1
set style line 2 lt 1 lc rgb "#00ff00"
set style line 3 lt 1 lc rgb "#0000ff"

## gp-4.6: kdensity with filledcurves gets accepted but does not work (http://gnuplot.sourceforge.net/demo_cvs/violinplot.html)
plot \
     "" u (binc(column(col), bin)):(1) axes x1y2 smooth frequency with boxes ti sprintf("%d values (abs. freq)", STATS_records) ls 3 , \
     "" u (binc(column(col), bin)):(1. / bin / STATS_records) smooth frequency with boxes fs pattern 4 ti sprintf("%d values (rel. freq)", STATS_records) ls 1 , \
     "" u col:(1. / STATS_records):(sigma) smooth kdensity with filledcurves above y1 fs solid ti "" ls 2 , \
     "" u col:(1. / STATS_records):(sigma) smooth kdensity ti sprintf("kdensity ({/symbol s}= %2.1f; rel. freq)", sigma) ls 2  # 3rd u-value is used but warning issued: extra columns ignored by smoothing option
