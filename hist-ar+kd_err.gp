### gnuplot script to create a histogram with abs. and rel. scale and kernel-density plot

if (!( GPVAL_VERSION >= 5.1 || ( GPVAL_VERSION == 5.0 && GPVAL_PATCHLEVEL >= 4) )) {print "This script needs at least gnuplot-5.0.4\n"; exit;}

if (!exists("datafile")) datafile='default.dat' # http://gnuplot.sourceforge.net/docs_4.2/node60.html
if (!exists("datafileL")) datafile='default_low.dat'
if (!exists("datafileU")) datafile='default_upp.dat'
if (!exists("outfile")) outfile='hist-ar+kd.svg' # use ARG0."svg" for gp-5:  http://stackoverflow.com/questions/12328603/how-to-pass-command-line-argument-to-gnuplot#31815067
if (!exists("xlabel")) xlabel='UNSPECIFIED'
if (!exists("bin")) bin=17
if (!exists("sigma")) sigma=0
if (!exists("colD")) colD='interplanarAngles' # http://stackoverflow.com/questions/16089301/how-do-i-set-axis-label-with-column-header-in-gnuplot#18309074
if (exists("sep")) set datafile separator sep

show  datafile separator

set samples 1000
set boxwidth bin # very important! see "gnuplot in action" p. 257
bin (x,s)= s* int(x/s)
binc(x,s)= s* (int(x/s) + .5)
binl(x,s)= s* ceil(x/s)
binr(x,s)= s* floor(x/s)

stats datafile u colD nooutput # sets e.g. STATS_records

###first do a dummy plot to determin chosen y-range;-)
if (exists("xmin") && exists("xmax")) set xrange [xmin:xmax]
set term dumb
plot datafile u (binc(column(colD), bin)):(1. / bin / STATS_records) smooth frequency with boxes ti sprintf("%d values (rel. freq)", STATS_records)
###y-range is now: GPVAL_Y_MAX or use GPVAL_DATA_Y_MAX
print GPVAL_Y_MAX, GPVAL_DATA_Y_MAX


## negative range for scattered points: http://www.gnuplot.info/demo/smooth.html
set yrange  [-0.0006:GPVAL_Y_MAX] # or [0:GPVAL_DATA_Y_MAX], without some small boxes might vanish!
set y2range [-0.0006 * bin * STATS_records:GPVAL_Y_MAX * bin * STATS_records] #scale yrange to make y2range graph (abs) coincide with relative

set title "relative and absolut frequency plot with error region"
set xlabel xlabel
set ylabel  "rel. frequency"
set y2label "abs. frequency"
set y2tics
set ytics nomirror

set terminal svg enhanced font "arial,10" size 800,600 #with enhanced don't use: courier
set output outfile

set style fill transparent solid .7

set style line 1 dt 4 lc rgb "#88000000" lw 2
set style line 2 dt 1 lc rgb "#000000" lw 2
set style line 3 dt 1 lc rgb "#888888"

set style circle radius 1.1 # http://stackoverflow.com/questions/34532568/gnuplot-how-to-make-scatter-plots-with-transparent-points#34533791

set table "abs_low.txt"  # single plot command avoids the need for append
plot datafileL u (binc(column(colD), bin)):(1) smooth frequency
unset table

set table "abs_upp.txt"  # single plot command avoids the need for append
plot datafileU u (binc(column(colD), bin)):(1) smooth frequency
unset table

set table "rel_low.txt"  # single plot command avoids the need for append
plot datafileL u (binc(column(colD), bin)):(1. / bin / STATS_records) smooth frequency
unset table

set table "rel_upp.txt"  # single plot command avoids the need for append
plot datafileU u (binc(column(colD), bin)):(1. / bin / STATS_records) smooth frequency
unset table

unset datafile separator # change back to white space for past input

plot \
     "< paste abs_low.txt abs_upp.txt | sed 's/[[:space:]]\+/\t/g'" u 1:2:5 with filledcurves  axes x1y2 ti sprintf("error region (%d values)", STATS_records) ls 3 , \
     "< paste rel_low.txt rel_upp.txt | sed 's/[[:space:]]\+/\t/g'" u 1:2:5 with filledcurves  fs empty  ti "" ls 1 , \
     datafile u (binc(column(colD), bin)):(1. / bin / STATS_records) smooth frequency with lines ti "frequency" ls 2
