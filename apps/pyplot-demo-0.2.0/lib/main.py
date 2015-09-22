#!/usr/bin/python

import matplotlib
matplotlib.use('Agg')

from matplotlib import mlab  # for csv2rec, detrend_none, window_hanning
import matplotlib.cbook as cbook
import matplotlib.pyplot as plt
from matplotlib.cbook import is_string_like, is_numlike
from pylab import figure, show, gca, savefig, draw, draw_if_interactive
import numpy as np


import os
import csv
import random
import argparse
import collections
from math import log

verbose = False

def parse_args():
    parser = argparse.ArgumentParser(prog="pyplot-demo", description="A program to plot the contents of a csv file.")

    parser.add_argument("--chart-type", dest="chartType", choices=['bar', 'line'], default='line',
                        help="The type of chart to show.")

    parser.add_argument("--x-label", dest="xlabel", type=str, nargs='?', default=None,
                        help="The x-axis label.")
    parser.add_argument("--show-x-label", dest="showXLabel", action='store_true', default=False,
                        help="If specified, the x-axis label will be shown")
    parser.add_argument("--y-label", dest="ylabel", type=str, nargs='?', default=None,
                        help="The y-axis label.")
    parser.add_argument("--show-y-label", dest="showYLabel", action='store_true', default=False,
                        help="If specified, the y-axis label will be shown")
    parser.add_argument("--show-legend", dest="showLegend", action='store_true', default=False,
                        help="If specified, a legend will be generated for each chart.")

    parser.add_argument("--width", dest="width", type=int, default=512,
                        help="The chart width.")
    parser.add_argument("--height", dest="height", type=int, default=256,
                        help="The chart height.")
    parser.add_argument("--background-color", dest="background", type=str, default=None,
                        help="The css hex color of the chart background.")

    parser.add_argument('--output-location', dest="outdir", type=str,
                        help="The output directory of the plotted dataset.")

    parser.add_argument("--file-per-series", dest="separateCharts", action='store_true', default=False,
                        help="If specified, each chart will be saved in a separate file.")

    parser.add_argument("--format", dest="format", choices=['png', 'jpg', 'gif'], default='png',
                        help="The image format of the plotted dataset.")

    parser.add_argument('-v','--verbose', action='store_true', default=False,
                        help="Enable verbose output.")

    parser.add_argument('infile', type=str,
                        help="The dataset to plot.")

    args = parser.parse_args()

    return args

def create_line_chart(infile, chartType='bar', xLabel=None, showXLabel=False, yLabel=None, showYLabel=False, showLegend=False, width=512, height=256, backgroundColor=None, imageFormat='png', outDirPath='', separateCharts=False):

  #fname = cbook.get_sample_data(infile, asfileobj=False)

  with open(infile, 'rb') as csvfile:
      res = csv.reader(csvfile, delimiter=',', doublequote=False, quotechar='', quoting=csv.QUOTE_NONE, skipinitialspace=True)
      header_row = res.next() # read header for line numbers
      csvfile.close()
      columns = list(header_row)
      header_row.pop(0)
      column_count = len(columns)

      barplot_functions = dict.fromkeys(range(1,column_count), chartType)

      if verbose:
          print header_row

      if separateCharts:
          for i in range(1,column_count):
              # plotfile(infile, (0,i), plotfuncs={i: chartType}, xLabel, showXLabel, yLabel, showYLabel, showLegend)
              plotfuncs={i: chartType}
              plotfile(infile, (0,i), plotfuncs, backgroundColor, width, height, xLabel, showXLabel, yLabel, showYLabel, showLegend, separateCharts, subplots=False, newfig=True)
              #show(block=False)
              draw()
              # name the default output file after the chart time and image format
              filename =  columns[i-1] + '-' + chartType + "." + imageFormat
              outfilePath = os.path.join(outDirPath, filename)
              if backgroundColor is None:
                  if verbose:
                    print "Setting transparent background"
                  savefig(outfilePath, format=imageFormat, edgecolor='none', transparent=True)
              else:
                  if verbose:
                    print "Setting background to " + backgroundColor
                  savefig(outfilePath, format=imageFormat, facecolor=backgroundColor)

              if verbose:
                    print "Saved chart for " + columns[i-1] + " data to " + outfilePath
      else:
#         plotfuncs = {'volume': 'semilogy'}

        plotfile(infile, filter(lambda a: a != 'Volume', columns), None, backgroundColor, width, height, xLabel, showXLabel, yLabel, showYLabel, showLegend, separateCharts, subplots=False)

        draw()
        # name the default output file after the chart time and image format
        filename = chartType + "." + imageFormat
        outfilePath = os.path.join(outDirPath, filename)
        if backgroundColor is None:
            if verbose:
                print "Setting transparent background"
            savefig(outfilePath, format=imageFormat, edgecolor='none', transparent=True)
        else:
            if verbose:
                print "Setting background to " + backgroundColor
            savefig(outfilePath, format=imageFormat, facecolor=backgroundColor)

      show()

def create_bar_chart(infile, chartType='bar', xLabel=None, showXLabel=False, yLabel=None, showYLabel=False, showLegend=False, width=512, height=256, backgroundColor=None, imageFormat='png', outDirPath='', separateCharts=False):

  #fname = cbook.get_sample_data(infile, asfileobj=False)

  with open(infile, 'rb') as csvfile:
      res = csv.reader(csvfile, delimiter=',', doublequote=False, quotechar='', quoting=csv.QUOTE_NONE, skipinitialspace=True)
      header_row = res.next() # read header for line numbers
      csvfile.close()
      columns = header_row
      header_row.pop(0)
      column_count = len(columns)

      barplot_functions = dict.fromkeys(range(1,column_count), chartType)

      if verbose:
          print header_row

      if separateCharts:
          for i in range(1,column_count):
              # plotfile(infile, (0,i), plotfuncs={i: chartType}, xLabel, showXLabel, yLabel, showYLabel, showLegend)
              plotfuncs={i: chartType}
              plotfile(infile, (0,i), plotfuncs, backgroundColor, width, height, xLabel, showXLabel, yLabel, showYLabel, showLegend, separateCharts, subplots=False, newfig=True)
              #show(block=False)
              draw()
              # name the default output file after the chart time and image format
              filename =  columns[i-1] + '-' + chartType + "." + imageFormat
              outfilePath = os.path.join(outDirPath, filename)
              if backgroundColor is None:
                  if verbose:
                    print "Setting transparent background"
                  savefig(outfilePath, format=imageFormat, edgecolor='none', transparent=True)
              else:
                  if verbose:
                    print "Setting background to " + backgroundColor
                  savefig(outfilePath, format=imageFormat, facecolor=backgroundColor)

              if verbose:
                  print "Saved chart for " + columns[i-1] + " data to " + outfilePath

          plt.show()

      else:
        with open(infile, 'rb') as csvfile:
            res = csv.reader(csvfile, delimiter=',', doublequote=False, quotechar='', quoting=csv.QUOTE_NONE, skipinitialspace=True)
            row_index = 0
            groups = {}
            ticks = []
            for row in res:
                if row_index == 0:
                    for col_id, val in enumerate(row):
                        if col_id > 0:
                            groups[col_id-1] = []
#                 if row_index == 1:
#                     for col_id, val in enumerate(row):
#                         print col_id
#                         print "Adding groups[" + columns[col_id] + "] = " + val
#
#                         if col_id == 0:
#                             ticks.append(val)
#                         else:
#                             groups[columns[col_id]] = [val]
                if row_index > 0:
                    for col_id, val in enumerate(row):
#                         print col_id
#                         print "Adding groups[" + columns[col_id-1] + "] = " + val

                        if col_id == 0:
                            ticks.append(val)
                        else:
                            groups[col_id-1].append(float(val))


                row_index += 1

            csvfile.close()

            n_groups = len(groups[0])

            fig, ax = matplotlib.pyplot.subplots(figsize=(width, height))

            index = np.arange(n_groups)
            bar_width = 0.8

            opacity = 1.0
            error_config = {'ecolor': '0.3'}
            group_id = 0
            step = 1.25 * len(columns)
            for sgroup in groups:
                print "creating bar chart for " + columns[group_id]
                print group_id
                print bar_width
                tick_step = xfrange((bar_width * group_id)+step, (step * (1+len(index))) + (bar_width * group_id), step)
                print tick_step
#                 print groups[group_id]
#                 print [bar_width] * len(groups[group_id])
#                 print opacity
#                 print columns[group_id]
                bar_color=('#%06X' % random.randint(0,256**3-1))
                print bar_color
                if columns[group_id].lower() != 'volume':
                    matplotlib.pyplot.bar(tick_step,
                        groups[group_id],
                        bar_width,
                        alpha=opacity,
                        color=bar_color,
                        label=columns[group_id])
                group_id += 1

            if showXLabel:
                matplotlib.pyplot.xlabel(xLabel)

            if showYLabel:
                matplotlib.pyplot.ylabel(yLabel)

            tick_spacing = xfrange(step, step * (1+len(index)), step)
            print tick_spacing
            matplotlib.pyplot.xticks(tick_spacing, ticks, rotation=90, size='small')

            if showLegend:
                matplotlib.pyplot.legend()

            matplotlib.pyplot.tight_layout()

            filename =  chartType + "." + imageFormat
            outfilePath = os.path.join(outDirPath, filename)

            if backgroundColor is None:
                if verbose:
                    print "Setting transparent background"
                matplotlib.pyplot.savefig(outfilePath, format=imageFormat, edgecolor='none', transparent=True)
            else:
                if verbose:
                    print "Setting background to " + backgroundColor
                matplotlib.pyplot.savefig(outfilePath, format=imageFormat, facecolor=backgroundColor)

            matplotlib.pyplot.show()


def plotfile(fname, cols=(0,), plotfuncs=None, facecolor=None, width=8, height=6,
             xLabel=None, showXLabel=False, yLabel=None, showYLabel=False, showLegend=False, separateCharts=False,
             comments='#', skiprows=0, checkrows=5, delimiter=',', names=None,
             subplots=True, newfig=True,
             **kwargs):
    """
    Plot the data in *fname*

    *cols* is a sequence of column identifiers to plot.  An identifier
    is either an int or a string.  If it is an int, it indicates the
    column number.  If it is a string, it indicates the column header.
    matplotlib will make column headers lower case, replace spaces with
    underscores, and remove all illegal characters; so ``'Adj Close*'``
    will have name ``'adj_close'``.

    - If len(*cols*) == 1, only that column will be plotted on the *y* axis.

    - If len(*cols*) > 1, the first element will be an identifier for
      data for the *x* axis and the remaining elements will be the
      column indexes for multiple subplots if *subplots* is *True*
      (the default), or for lines in a single subplot if *subplots*
      is *False*.

    *plotfuncs*, if not *None*, is a dictionary mapping identifier to
    an :class:`~matplotlib.axes.Axes` plotting function as a string.
    Default is 'plot', other choices are 'semilogy', 'fill', 'bar',
    etc.  You must use the same type of identifier in the *cols*
    vector as you use in the *plotfuncs* dictionary, eg., integer
    column numbers in both or column names in both. If *subplots*
    is *False*, then including any function such as 'semilogy'
    that changes the axis scaling will set the scaling for all
    columns.

    *comments*, *skiprows*, *checkrows*, *delimiter*, and *names*
    are all passed on to :func:`matplotlib.pylab.csv2rec` to
    load the data into a record array.

    If *newfig* is *True*, the plot always will be made in a new figure;
    if *False*, it will be made in the current figure if one exists,
    else in a new figure.

    kwargs are passed on to plotting functions.

    Example usage::

      # plot the 2nd and 4th column against the 1st in two subplots
      plotfile(fname, (0,1,3))

      # plot using column names; specify an alternate plot type for volume
      plotfile(fname, ('date', 'volume', 'adj_close'),
                                    plotfuncs={'volume': 'semilogy'})

    Note: plotfile is intended as a convenience for quickly plotting
    data from flat files; it is not intended as an alternative
    interface to general plotting with pyplot or matplotlib.
    """

    if newfig:
#         fig = figure(figsize=(width, height), dpi=100)
#         if facecolor is None:
#             fig.patch.set_facecolor('w');
#             fig.patch.set_alpha(0);
#         else:
#             fig.patch.set_facecolor(facecolor)
        fig = figure()
    else:
        fig = gcf()

    if len(cols)<1:
        raise ValueError('must have at least one column of data')

    if plotfuncs is None:
        plotfuncs = dict()
    r = mlab.csv2rec(fname, comments=comments, skiprows=skiprows,
                     checkrows=checkrows, delimiter=delimiter, names=names)

    delete = set("""~!@#$%^&*()-=+~\|]}[{';: /?.>,<""")
    delete.add('"')

    def getname_val(identifier):
        'return the name and column data for identifier'
        if is_string_like(identifier):
            print "Identifier " + identifier + " is a string"
            col_name = identifier.strip().lower().replace(' ', '_')
            col_name = ''.join([c for c in col_name if c not in delete])
            return identifier, r[col_name]
        elif is_numlike(identifier):
            name = r.dtype.names[int(identifier)]
            return name, r[name]
        else:
            raise TypeError('identifier must be a string or integer')

    xname, x = getname_val(cols[0])
    ynamelist = []

    if len(cols)==1:
        ax1 = fig.add_subplot(1,1,1)
        funcname = plotfuncs.get(cols[0], 'plot')
        func = getattr(ax1, funcname)
        func(x, **kwargs)
        if showYLabel:
            if not yLabel == None:
                if verbose:
                    print 'Setting y label to supplied value ' + yLabel
                ax1.set_ylabel(yLabel)
            else:
                if verbose:
                    print 'Setting y label to derived value ' + xname
                ax1.set_ylabel(xname)
    else:
        N = len(cols)
        for i in range(1,N):
            if subplots:
                if i==1:
                    ax = ax1 = fig.add_subplot(N-1,1,i)
                else:
                    ax = fig.add_subplot(N-1,1,i, sharex=ax1)
            elif i==1:
                ax = fig.add_subplot(1,1,1)

            ax.grid(True)


            yname, y = getname_val(cols[i])
            ynamelist.append(yname)

            funcname = plotfuncs.get(cols[i], 'plot')
            func = getattr(ax, funcname)

            func(x, y, **kwargs)

            if subplots:
#                 if not yLabel == None:
#                     if verbose:
#                         print 'Setting y label to supplied value ' + yLabel
#                     ax.set_ylabel(yLabel)
#                 elif subplots:
                if verbose:
                    print 'Setting y label to derived value ' + yname
                ax.set_ylabel(yname)
            else:
                if showYLabel:
                    if not yLabel:
                        if verbose:
                            print 'Setting y label to derived value ' + yname
                        ax.set_ylabel(yname)
                    else:
                        if verbose:
                            print 'Setting y label to supplied value ' + yLabel
                        ax.set_ylabel(yLabel)
                        
            if showXLabel:
                if ax.is_last_row():
                    if not xLabel == None:
                        if verbose:
                            print 'Setting x label to supplied value ' + xLabel
                        ax.set_xlabel(xLabel)
                    else:
                        if verbose:
                            print 'Setting x label to ' + xname
                        ax.set_xlabel(xname)
                else:
                    if verbose:
                        print 'Skipping x label until end'
                    ax.set_xlabel('')

    if showLegend: # and not subplots:
        if verbose:
            print 'Creating legend as requested'
        ax.legend(ynamelist, loc='best')

    if xname=='date':
        fig.autofmt_xdate()

    draw_if_interactive()


def main():
    global verbose
    # Set matplotlib relative data directory to pwd
    #print "data folder: " + os.path.abspath(os.path.join(os.path.join(os.path.realpath(__file__), os.pardir), os.pardir))
    #matplotlib.rcParams['examples.directory'] = os.path.abspath(os.path.join(os.path.join(os.path.realpath(__file__), os.pardir), os.pardir))

    args = parse_args()
    basename = os.path.basename(args.infile)
    verbose = args.verbose

    isCsv = basename.split(".")[-1] == 'csv'
    if not isCsv:
      raise ValueError("The dataset is not a recognized file type.")

    if not os.path.exists(args.infile):
      raise ValueError("The dataset does not exist.")

    # define the output directory. use the user defined one if it was provided
    outdir = 'output'
    if args.outdir is not None:
      outdir = args.outdir

    # create the output directory if it does not already exist
    if not os.path.exists(outdir):
        os.mkdir(outdir)

    width = args.width / 100.0
    height = args.height / 100.0

    if args.chartType == 'bar':
      if verbose:
          print "Creating bar chart"
      create_bar_chart(args.infile, 'bar', args.xlabel, args.showXLabel, args.ylabel, args.showYLabel, args.showLegend, width, height, args.background, args.format, outdir, args.separateCharts)
    elif args.chartType == 'line':
      if verbose:
          print "Creating line chart"
      create_line_chart(args.infile, 'plot', args.xlabel, args.showXLabel, args.ylabel, args.showYLabel, args.showLegend, width, height, args.background, args.format, outdir, args.separateCharts)
    else:
      raise ValueError("The chart type is not recognized. Please specify one of: bar, scatter, line, pie")

def xfrange(start, stop, step):

    old_start = start #backup this value

    digits = int(round(log(10000, 10)))+1 #get number of digits
    magnitude = 10**digits
    stop = int(magnitude * stop) #convert from
    step = int(magnitude * step) #0.1 to 10 (e.g.)

    if start == 0:
        start = 10**(digits-1)
    else:
        start = 10**(digits)*start

    data = []   #create array

    #calc number of iterations
    end_loop = int((stop-start)//step)
    if old_start == 0:
        end_loop += 1

    acc = start

    for i in xrange(0, end_loop):
        data.append(acc/magnitude)
        acc += step

    return data


if __name__ == "__main__":
    main()
