# loadUltimaData
Load data collected by the DTS instrument Ultima (Silixa Ltd, http://silixa.com/technology/ultima-dts/) and plot the data

This Matlab routine can be used to load data from the XML files produced by the Ultima[*] and plot them to get a first glimpse of the data quality. This can be done for the complete dataset, but also for specific time and distance ranges of interest. The data are stored in MAT files.

The routine includes four m files:
- loadUltimaData.m is the general script which calls the other Matlab functions. From line 21, one can enter some properties of the dataset as well as the distance range over which the data should be loaded per channel. When running the script, one can further specify which actions should be made by the Matlab routine.
- funLoadUltimaXML.m is optionally called by loadUltimaData.m to load the data from XML files in case this is not yet done before.
- funPrepPlotData.m is called by loadUltimaData.m to plot the temperatures using Matlab's imagesc function. To plot the dataset properly, holes in the dataset are filled with NaN-values. Optionally, this 'filled' dataset can be saved. Before plotting the data for each of the channels, the user can specify the resolution of the tick marks, as well the time, distance, and temperature ranges.
- fitOnScreen.m is called by funPrepPlotData.m to maximize the figure sizes to the user's monitor resolution.
 

[*] the Silixa Ultima is a temperature measurement device which employs Raman scattering for distributed temperature sensing along a fiber-optic cable. It is produced by Silixa Ltd. (Silixa House, 230 Centennial Park, Centennial Avenue, Elstree, Hertfordshire, WD6 3SN, UK). More information can be found on http://silixa.com/technology/ultima-dts/. The device stores the data as XML files, and this Matlab routine supports the withdrawal of data from the XML files.


This Matlab routine was written by Koen Hilgersom (https://github.com/khilgersom). On this set of scripts, the Apache 2.0 license applies (http://www.apache.org/licenses/LICENSE-2.0). References in scientific publications should include the following doi: 
[![DOI](https://zenodo.org/badge/19422/khilgersom/loadUltimaData.svg)](https://zenodo.org/badge/latestdoi/19422/khilgersom/loadUltimaData)


