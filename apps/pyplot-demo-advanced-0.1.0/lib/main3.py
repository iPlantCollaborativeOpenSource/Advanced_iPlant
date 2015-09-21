RefactoringTool: Skipping implicit fixer: buffer
RefactoringTool: Skipping implicit fixer: idioms
RefactoringTool: Skipping implicit fixer: set_literal
RefactoringTool: Skipping implicit fixer: ws_comma
RefactoringTool: Refactored home/main.py
--- home/main.py	(original)
+++ home/main.py	(refactored)
@@ -69,16 +69,16 @@
 
   with open(infile, 'rb') as csvfile:
       res = csv.reader(csvfile, delimiter=',', doublequote=False, quotechar='', quoting=csv.QUOTE_NONE, skipinitialspace=True)
-      header_row = res.next() # read header for line numbers
+      header_row = next(res) # read header for line numbers
       csvfile.close()
       columns = list(header_row)
       header_row.pop(0)
       column_count = len(columns)
 
-      barplot_functions = dict.fromkeys(range(1,column_count), chartType)
+      barplot_functions = dict.fromkeys(list(range(1,column_count)), chartType)
 
       if verbose:
-          print header_row
+          print(header_row)
 
       if separateCharts:
           for i in range(1,column_count):
@@ -92,19 +92,19 @@
               outfilePath = os.path.join(outDirPath, filename)
               if backgroundColor is None:
                   if verbose:
-                    print "Setting transparent background"
+                    print("Setting transparent background")
                   savefig(outfilePath, format=imageFormat, edgecolor='none', transparent=True)
               else:
                   if verbose:
-                    print "Setting background to " + backgroundColor
+                    print("Setting background to " + backgroundColor)
                   savefig(outfilePath, format=imageFormat, facecolor=backgroundColor)
 
               if verbose:
-                    print "Saved chart for " + columns[i-1] + " data to " + outfilePath
+                    print("Saved chart for " + columns[i-1] + " data to " + outfilePath)
       else:
 #         plotfuncs = {'volume': 'semilogy'}
 
-        plotfile(infile, filter(lambda a: a != 'Volume', columns), None, backgroundColor, width, height, xLabel, showXLabel, yLabel, showYLabel, showLegend, separateCharts, subplots=False)
+        plotfile(infile, [a for a in columns if a != 'Volume'], None, backgroundColor, width, height, xLabel, showXLabel, yLabel, showYLabel, showLegend, separateCharts, subplots=False)
 
         draw()
         # name the default output file after the chart time and image format
@@ -112,11 +112,11 @@
         outfilePath = os.path.join(outDirPath, filename)
         if backgroundColor is None:
             if verbose:
-                print "Setting transparent background"
+                print("Setting transparent background")
             savefig(outfilePath, format=imageFormat, edgecolor='none', transparent=True)
         else:
             if verbose:
-                print "Setting background to " + backgroundColor
+                print("Setting background to " + backgroundColor)
             savefig(outfilePath, format=imageFormat, facecolor=backgroundColor)
 
       show()
@@ -127,16 +127,16 @@
 
   with open(infile, 'rb') as csvfile:
       res = csv.reader(csvfile, delimiter=',', doublequote=False, quotechar='', quoting=csv.QUOTE_NONE, skipinitialspace=True)
-      header_row = res.next() # read header for line numbers
+      header_row = next(res) # read header for line numbers
       csvfile.close()
       columns = header_row
       header_row.pop(0)
       column_count = len(columns)
 
-      barplot_functions = dict.fromkeys(range(1,column_count), chartType)
+      barplot_functions = dict.fromkeys(list(range(1,column_count)), chartType)
 
       if verbose:
-          print header_row
+          print(header_row)
 
       if separateCharts:
           for i in range(1,column_count):
@@ -150,15 +150,15 @@
               outfilePath = os.path.join(outDirPath, filename)
               if backgroundColor is None:
                   if verbose:
-                    print "Setting transparent background"
+                    print("Setting transparent background")
                   savefig(outfilePath, format=imageFormat, edgecolor='none', transparent=True)
               else:
                   if verbose:
-                    print "Setting background to " + backgroundColor
+                    print("Setting background to " + backgroundColor)
                   savefig(outfilePath, format=imageFormat, facecolor=backgroundColor)
 
               if verbose:
-                  print "Saved chart for " + columns[i-1] + " data to " + outfilePath
+                  print("Saved chart for " + columns[i-1] + " data to " + outfilePath)
 
           plt.show()
 
@@ -209,17 +209,17 @@
             group_id = 0
             step = 1.25 * len(columns)
             for sgroup in groups:
-                print "creating bar chart for " + columns[group_id]
-                print group_id
-                print bar_width
+                print("creating bar chart for " + columns[group_id])
+                print(group_id)
+                print(bar_width)
                 tick_step = xfrange((bar_width * group_id)+step, (step * (1+len(index))) + (bar_width * group_id), step)
-                print tick_step
+                print(tick_step)
 #                 print groups[group_id]
 #                 print [bar_width] * len(groups[group_id])
 #                 print opacity
 #                 print columns[group_id]
                 bar_color=('#%06X' % random.randint(0,256**3-1))
-                print bar_color
+                print(bar_color)
                 if columns[group_id].lower() != 'volume':
                     matplotlib.pyplot.bar(tick_step,
                         groups[group_id],
@@ -236,7 +236,7 @@
                 matplotlib.pyplot.ylabel(yLabel)
 
             tick_spacing = xfrange(step, step * (1+len(index)), step)
-            print tick_spacing
+            print(tick_spacing)
             matplotlib.pyplot.xticks(tick_spacing, ticks, rotation=90, size='small')
 
             if showLegend:
@@ -249,11 +249,11 @@
 
             if backgroundColor is None:
                 if verbose:
-                    print "Setting transparent background"
+                    print("Setting transparent background")
                 matplotlib.pyplot.savefig(outfilePath, format=imageFormat, edgecolor='none', transparent=True)
             else:
                 if verbose:
-                    print "Setting background to " + backgroundColor
+                    print("Setting background to " + backgroundColor)
                 matplotlib.pyplot.savefig(outfilePath, format=imageFormat, facecolor=backgroundColor)
 
             matplotlib.pyplot.show()
@@ -341,7 +341,7 @@
     def getname_val(identifier):
         'return the name and column data for identifier'
         if is_string_like(identifier):
-            print "Identifier " + identifier + " is a string"
+            print("Identifier " + identifier + " is a string")
             col_name = identifier.strip().lower().replace(' ', '_')
             col_name = ''.join([c for c in col_name if c not in delete])
             return identifier, r[col_name]
@@ -362,11 +362,11 @@
         if showYLabel:
             if not yLabel == None:
                 if verbose:
-                    print 'Setting y label to supplied value ' + yLabel
+                    print('Setting y label to supplied value ' + yLabel)
                 ax1.set_ylabel(yLabel)
             else:
                 if verbose:
-                    print 'Setting y label to derived value ' + xname
+                    print('Setting y label to derived value ' + xname)
                 ax1.set_ylabel(xname)
     else:
         N = len(cols)
@@ -397,37 +397,37 @@
 #                     ax.set_ylabel(yLabel)
 #                 elif subplots:
                 if verbose:
-                    print 'Setting y label to derived value ' + yname
+                    print('Setting y label to derived value ' + yname)
                 ax.set_ylabel(yname)
             else:
                 if showYLabel:
                     if not yLabel:
                         if verbose:
-                            print 'Setting y label to derived value ' + yname
+                            print('Setting y label to derived value ' + yname)
                         ax.set_ylabel(yname)
                     else:
                         if verbose:
-                            print 'Setting y label to supplied value ' + yLabel
+                            print('Setting y label to supplied value ' + yLabel)
                         ax.set_ylabel(yLabel)
                         
             if showXLabel:
                 if ax.is_last_row():
                     if not xLabel == None:
                         if verbose:
-                            print 'Setting x label to supplied value ' + xLabel
+                            print('Setting x label to supplied value ' + xLabel)
                         ax.set_xlabel(xLabel)
                     else:
                         if verbose:
-                            print 'Setting x label to ' + xname
+                            print('Setting x label to ' + xname)
                         ax.set_xlabel(xname)
                 else:
                     if verbose:
-                        print 'Skipping x label until end'
+                        print('Skipping x label until end')
                     ax.set_xlabel('')
 
     if showLegend: # and not subplots:
         if verbose:
-            print 'Creating legend as requested'
+            print('Creating legend as requested')
         ax.legend(ynamelist, loc='best')
 
     if xname=='date':
@@ -467,11 +467,11 @@
 
     if args.chartType == 'bar':
       if verbose:
-          print "Creating bar chart"
+          print("Creating bar chart")
       create_bar_chart(args.infile, 'bar', args.xlabel, args.showXLabel, args.ylabel, args.showYLabel, args.showLegend, width, height, args.background, args.format, outdir, args.separateCharts)
     elif args.chartType == 'line':
       if verbose:
-          print "Creating line chart"
+          print("Creating line chart")
       create_line_chart(args.infile, 'plot', args.xlabel, args.showXLabel, args.ylabel, args.showYLabel, args.showLegend, width, height, args.background, args.format, outdir, args.separateCharts)
     else:
       raise ValueError("The chart type is not recognized. Please specify one of: bar, scatter, line, pie")
@@ -499,7 +499,7 @@
 
     acc = start
 
-    for i in xrange(0, end_loop):
+    for i in range(0, end_loop):
         data.append(acc/magnitude)
         acc += step
 
RefactoringTool: Files that need to be modified:
RefactoringTool: home/main.py
