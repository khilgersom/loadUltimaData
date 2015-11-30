# loadUltimaData
Load data from Ultima XML files and plot them

This Matlab routine can be used to load data from the XML-files produced by the Ultima and plot them to get a first glimpse of the data quality. This can be done for the complete dataset, but also for specific time and distance ranges of interest. The data are stored in MAT-files.

The routine includes four m-files:
- loadUltimaData.m is the general script which calls the other Matlab functions. From line 21, one can enter some properties of the dataset as well as the distance range over which the data should be loaded per channel. When running the script, one can further specify which actions should be made by the Matlab routine.
- funLoadUltimaXML.m is optionally called by loadUltimaData.m to load the data from XML files in case this is not yet done before.
- funPrepPlotData.m is called by loadUltimaData.m to plot the temperatures using Matlab's imagesc function. To plot the dataset properly, holes in the dataset are filled with NaN-values. Optionally, this 'filled' dataset can be saved. Before plotting the data for each of the channels, the user can specify the resolution of the tick marks, as well the time, distance, and temperature ranges.
- fitOnScreen.m is called by funPrepPlotData.m to maximize the figure sizes to the user's monitor resolution.

This Matlab routine was created by Koen Hilgersom (https://github.com/khilgersom).
