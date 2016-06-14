### gnuplot script to create a line-plot of a 1D NetPBM image

# plot for [col=1:3] : http://stackoverflow.com/questions/16073232/gnuplot-plotting-a-file-with-4-columns-all-on-y-axis
# plot "<cat" : http://stackoverflow.com/questions/17543386/pipe-plot-data-to-gnuplot-script


if (!exists("datafiles")) datafiles='default1.dat default2.dat' # http://gnuplot.sourceforge.net/docs_4.2/node60.html
if (!exists("outfile")) outfile='line-plot_1D-img.svg' # use ARG0."svg" for gp-5:  http://stackoverflow.com/questions/12328603/how-to-pass-command-line-argument-to-gnuplot#31815067

df1= word(datafiles,1)
df2= word(datafiles,2)

set terminal svg enhanced font "arial,10" size 800,800 #with enhanced don't use: courier
set output outfile


set title "line-plots of orig. data and RGB overlay"
set xlabel "pixel index"
set ylabel "pixel value"


stats df1 u 1 nooutput # sets e.g. STATS_records

set xrange [0:STATS_records-1]
set yrange [STATS_min-10:255]

set key opaque

set style line 1 lt rgb "red"
set style line 2 lt rgb "green"
set style line 3 lt rgb "blue"

set style fill solid
#set style fill transparent pattern 4 bo

plot df2 u 0:(255 * !(int($1) && int($2) && int($3))) w fillsteps lt rgb "black" t "tissue", \
for [i=3:1:-1] df2 u i w fillsteps ls i t columnheader, \
df1 w steps lt rgb "#ffffff" lw 3 t "orig", \
"" u ($0+0.5):1 smooth cspline lt rgb "#888888" lw 2 t " smooth"
