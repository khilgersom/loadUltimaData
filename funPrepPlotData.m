function funPrepPlotData(mainDir,channels,q1,q2,q3)
% funPrepPlotData (v2)
% 27/11/2015
%
% Author: Koen Hilgersom (2012)
%
% This function calls the funPrepData function to fill potential gaps in 
% the measurement data in order to correctly plot them using the Matlab 
% imagesc function, in case the option to plot the data, or the option to
% save the fill dataset is selected. If desired, the data is saved 
% afterwards, or plotted afterwards by calling funPlotData.
%
%---------------------------------------------------------------------------  
%      Copyright (C) 2012 Technische Universiteit Delft, 
%          Koen Hilgersom
%          K.P.Hilgersom@tudelft.nl (correspondence)
% 
%---------------------------------------------------------------------------  

for z=(channels(:))'
    Dist = []; time = []; Temp = []; Sto = []; ASto = []; PT100 = [];
    load([mainDir filesep 'channel ' num2str(z) ]);
    funPrepData
    switch q2; case 'y'; save([mainDir filesep 'channel ' num2str(z) '_filled'],'Dist','Temp','Sto','ASto','time','PT100'); end
    switch q1; case 'y'; q4 = 'n'; while q4 ~= 'y'; funPlotData; 
                            q4 = input('Satisfied with the current plot? (y/n) ','s'); end; end
end
%
%
%% funPrepData
function funPrepData
% funPrepData (v2)
% 27/11/2015
%
% Author: Koen Hilgersom (2012)
%
% This function obtains the potentially interrupted data from the complete 
% dataset and provides the option to fill gaps in the data in order to 
% properly plot them with Matlab's imagesc function.
%
%---------------------------------------------------------------------------  
%      Copyright (C) 2012 Technische Universiteit Delft, 
%          Koen Hilgersom
%          K.P.Hilgersom@tudelft.nl (correspondence)
% 
%---------------------------------------------------------------------------  

swtch=0;
switch q2
    case {'y','p'}
        while swtch==0
            time1=[time; NaN]; time2=[NaN; time];
            [tM,tN]=max(time1-time2);
            tS=round((time1-time2)*24*3600);
            switch q3
                case 'mode'
                    tS=mode(tS)/(24*3600);
                case 'min'
                    tS=min (tS)/(24*3600);
                otherwise
                    tS=mode(tS)/(24*3600);
            end
            if tM>1.99*tS
                Temp=cat(1,Temp(1:tN-1,:),NaN(round(tM/tS)-1,size(Temp,2)),Temp(tN:end,:));
                Sto=cat(1,Sto(1:tN-1,:),NaN(round(tM/tS)-1,size(Sto,2)),Sto(tN:end,:));
                ASto=cat(1,ASto(1:tN-1,:),NaN(round(tM/tS)-1,size(ASto,2)),ASto(tN:end,:));
                PT100=[PT100(1:tN-1,:);NaN(round(tM/tS)-1,2);PT100(tN:end,:)];
                timeFill=1:round(tM/tS)-1;
                time=[time(1:tN-1); timeFill'*tS+time(tN-1); time(tN:end)];
            else
                swtch=1;
            end
        end
end
%
end
%
%
%% funPlotData
function funPlotData
% funPlotData (v2)
% 27/11/2015
%
% Author: Koen Hilgersom (2012)
%
% This function plots the Ultima data based on the desired criteria to be 
% entered by answering some questions.
%
%---------------------------------------------------------------------------  
%      Copyright (C) 2012 Technische Universiteit Delft, 
%          Koen Hilgersom
%          K.P.Hilgersom@tudelft.nl (correspondence)
% 
%---------------------------------------------------------------------------  

Trange=[min(Temp(:)) max(Temp(:))];
RanX=1:length(Dist); XRan = [min(Dist) max(Dist)];
RanT=1:length(time); TimeRan = [min(time) max(time)];

disp(['Input plotting criteria for channel ' num2str(z) ':']);
TimeRes = input('What should be the time resolution of the grid? (number of ticks per day) ');
XRes    = input('What should be the spatial resolution of the grid? (m per tick) ');
TimeInp = input('Do you want to set the time range for your plot (if not, the full time range is used)? (y/n) ','s'); 
switch TimeInp
    case 'y'
        TimeRan = input('Time range plot? (dd/mm/yyyy HH:MM dd/mm/yyyy HH:MM): ','s'); 
        TimeRan = [datenum(TimeRan(1:16),'dd/mm/yyyy HH:MM') datenum(TimeRan(18:33),'dd/mm/yyyy HH:MM')];
        RanT=find(time>TimeRan(1)&time<TimeRan(2));
end
XInp=input('Do you want to set the distance range for your plot (if not, the full distance range is used)? (y/n) ','s'); 
switch XInp
    case 'y'
        XRan = input('Distance range plot? ([X1 X2]): ');
        RanX = Dist>XRan(1)&Dist<XRan(end);
end
TempInp=input('Do you want to set the temperature range for your plot (if not, the full temperature range is used)? (y/n) ','s'); 
switch TempInp
    case 'y'
        Trange = input('Temperature range plot? ([T1 T2]): ');
end
TempReg=Temp(RanT,RanX);

%% colorplot
figure(z)
clf; fitOnScreen(gcf); colormap(jet(256));
imagesc(Dist(RanX),time(RanT),TempReg,Trange)
set(gca,'XLim',XRan);%([0 500]));
set(gca,'XTick',0:XRes:ceil(max(Dist(RanX))));
set(gca,'YLim',TimeRan);
set(gca,'YTick',ceil(TimeRes*time(1))/TimeRes:1/TimeRes:time(end));
datetick('y','HH:MM','keeplimits','keepticks');
colorbar
end
%
end
