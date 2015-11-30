% loadUltimaData (v2)
% 27/11/2015
%
% Author: Koen Hilgersom (2015)
%
% This script assists running the different scripts developed to load,
% correct, and plot the data saved by the Silixa Ultima. It provides the
% option to fill holes in the dataset for plotting purposes (reason for
% this is that the imagesc function does not plot these holes and this way
% provides a misleading view on your dataset).
%
%---------------------------------------------------------------------------  
%      Copyright (C) 2015 Technische Universiteit Delft, 
%          Koen Hilgersom
%          K.P.Hilgersom@tudelft.nl (correspondence)
% 
%---------------------------------------------------------------------------  
clear;clc;format long

%% INPUT DATA!!!
mainDir  ='C:\Users\user\DTS\MeasCampaign';  %main directory (excluding the names of the channel folders)
channels = [1,2,3,4];   %select the desired channels (e.g., [1,2,3,4])
timeCorr = 0;           %time offset (days) (e.g., when -2/24, 2 hours are subtracted from the time saved by the machine)
xRan     = [-0.5 1800;...
            -0.5 1800;...
            -0.5 1800;...
            -0.5 1800]; % cable range (meters) for which you would like to load the data (1 row per channel, or 1 row with range for all channels)

%% process outline questions
q0=NaN;q1=q0;q2=q0;q3=q0;
while ~any(strcmp(q0,{'y','n'})); q0 = input('Has the data already been loaded from the XML files and stored to MAT files? (y/n) ','s'); end
while ~any(strcmp(q1,{'y','n'})); q1 = input('Plot the data? (y/n) ','s'); end
while ~any(strcmp(q2,{'y','n'})); q2 = input('Save dataset with filled gaps in order to use it for plotting in the future? (y/n) ','s'); end
switch q1; case 'y'; if q2 ~= 'y'; q2 = 'p'; end; end
switch q2
    case {'y','p'}; while ~any(strcmp(q3,{'min','mode'})); 
            q3 = input('Employ the mode (''mode'') or minimum (''min'') of all timesteps to fill the dataset gaps for plotting? ','s'); end
    otherwise; q3 = 'n';
end
    
%% load XML data and store to MAT-file(s)
switch q0; case 'n'; funLoadUltimaXML(mainDir,channels,timeCorr,xRan); end

%% fill and plot data
funPrepPlotData(mainDir,channels,q1,q2,q3);
