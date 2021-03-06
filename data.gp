### gnuplot script to plot data (e.g. data already representing histogram data from e.g. ITK-CLIs hist)

if (!( GPVAL_VERSION >= 5.1 || ( GPVAL_VERSION == 5.0 && GPVAL_PATCHLEVEL >= 4) )) {print "This script needs at least gnuplot-5.0.4\n"; exit;}

if (!exists("datafile")) datafile='default.dat' # http://gnuplot.sourceforge.net/docs_4.2/node60.html
if (!exists("outfile")) outfile='hist-data.svg' # use ARG0."svg" for gp-5:  http://stackoverflow.com/questions/12328603/how-to-pass-command-line-argument-to-gnuplot#31815067
if (!exists("xlabel")) xlabel='UNSPECIFIED'
if (!exists("ylabel")) ylabel='UNSPECIFIED'
if (!exists("col")) col='UNSPECIFIED' # http://stackoverflow.com/questions/16089301/how-do-i-set-axis-label-with-column-header-in-gnuplot#18309074
if (!exists("excl")) excl=1e-9
if (exists("sep")) set datafile separator sep

show  datafile separator

###first do a dummy plot to determin chosen y-range;-)
if (exists("xmin") && exists("xmax")) set xrange [xmin+excl:xmax-excl]
set yrange [] writeback
set term dumb
plot datafile u colX:colY with fillsteps lc black # for gp-5.x
###y-range is now: GPVAL_Y_MAX or use GPVAL_DATA_Y_MAX
print GPVAL_Y_MAX, GPVAL_DATA_Y_MAX

set xlabel xlabel
set ylabel ylabel
set terminal svg enhanced font "arial,10" size 800,600 #with enhanced don't use: courier
set output outfile

set style fill transparent solid .7
set key off

if (exists("xmin") && exists("xmax")) set xrange [xmin:xmax]
set yrange restore
plot datafile u colX:colY with fillsteps lc black # for gp-5.x
