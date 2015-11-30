function funLoadUltimaXML(mainDir,channels,timeCorr,xRan)
% funLoadUltimaXML (v5)
% 27/11/2015
%
% Author: Koen Hilgersom (2012)
%
% This script loads part of the data from the Ultima produced XML-files and 
% puts it into arrays called Data (distance, Stokes, anti-Stokes, and fiber-
% optic temperature data), time (time vector), and PT100 (reference 
% temperature data). The data is loaded for the specified channels. The 
% arrays are saved in the same folder containing the folders with data per
% channel.
%
% The script also corrects for possible time offsets in the machine time
% relative to the actual local time.
%
%---------------------------------------------------------------------------  
%      Copyright (C) 2012 Technische Universiteit Delft, 
%          Koen Hilgersom
%          K.P.Hilgersom@tudelft.nl (correspondence)
% 
%---------------------------------------------------------------------------  
tmpFN = {'Sto','ASto','Temp'}; %temporary file names for Temperature, Stokes and anti-Stokes data
for f = 1 : length(tmpFN); if exist([char(tmpFN(f)) '.tmpMF'],'file'); delete([char(tmpFN(f)) '.tmpMF']); end; end
%
h1 = waitbar(0,'General progress'); lenCh = length(channels(:)); chCnt = 0;
for z=(channels(:))'
    files = dir([mainDir filesep 'channel ' num2str(z) filesep '*.xml']); len = length(files);
    %
    xR    = xRan(min(z,size(xRan,1)),:);
    cnt   = 1;          cntMax = min(50,len);        if cntMax==0; continue; end;                genCnt = 1;    
    nMin  = 1; nMax = 1e9;
    PT100 = NaN(len,2);
    time  = NaN(len,1);
    dist  = [];
    Data  = NaN(cntMax,0,3);
    %
    h2 = waitbar(0,['Progress on current channel (Channel ' num2str(z) ')'],'Position',get(h1,'Position')-[0 80 0 0]);
    %
    tic
    for k=1:len
        XRead           = xmlread([mainDir filesep 'channel ' num2str(z) filesep files(k).name]);
        child           = XRead.getChildNodes.item(0).item(1).item(XRead.getChildNodes.item(0).item(1).getLength-2);
        childNodes      = child.getChildNodes;
        numChildNodes   = childNodes.getLength/2;
        nEnd            = min(nMax,numChildNodes);
        for n=nMin:min([length(dist),nEnd])
            Read                 = sscanf(char(child.item(2*(n-1)).item(0).getData),'%f,%f,%f,%f');
            Data(cnt,n-nMin+1,:) = Read(2:4);    
        end        
        if length(dist)<nEnd
            nSt     = length(dist)+1;
            DataTmp = NaN(nEnd-size(Data,2),3);
            distAdd = NaN(nEnd-length(dist),1);
            for n=1:(nEnd-nSt+1)
                Read         = sscanf(char(child.item(2*(n-1)).item(0).getData),'%f,%f,%f,%f');
                if Read(1)>xR(2); nMax = nSt + n - 2; nEnd = nMax; break; end                
                distAdd(n)   = Read(1);
                DataTmp(n,:) = Read(2:4);
            end
            dist = [dist; distAdd(~isnan(distAdd))];
            if k==1;    nMin = max([nMin,find(dist<=xR(1),1,'last' )+1]); end
                        nMax = min([nMax,find(dist>=xR(2),1,'first')-1]);
            Data = cat(2,Data,NaN(cntMax,(nEnd-nMin+1)-size(Data,2),3));
            Data(cnt,(nSt:nEnd)-nSt+1,:) = DataTmp((nSt:nEnd)-nSt+1,:);
            clear DataTmp distAdd
        end
        if cnt == cntMax
            for f = 1 : length(tmpFN); dlmwrite([char(tmpFN(f)) '.tmpMF'],Data(:,:,f),'-append'); end
            cntMax = min(50,len-genCnt*50); DatSiz = size(Data,2); clear Data
            Data   = NaN(cntMax,DatSiz,3);
            cnt    = 0;                                                         genCnt = genCnt+1;
        end
        cnt = cnt+1;
        A               = char(XRead.item(0).item(1).item(7).item(0).getData);
        time(k)         = datenum([A(1:4) '/' A(6:7) '/' A(9:10) ' ' A(12:13) ':' A(15:16) ':' A(18:19)]);
        PT100(k,:)      = [str2double(XRead.item(0).item(1).item(11).item(5).item(0).getData),...
                               str2double(XRead.item(0).item(1).item(11).item(7).item(0).getData)];
        clear Read XRead child childNodes
        %
        waitbar(k/len,h2); waitbar((chCnt+0.99*k/len)/lenCh,h1);
    end
    toc
    chCnt = chCnt + 1; k = 0; delete(h2);
    %
    if abs(timeCorr) < 1e-5
        if timeCorr ~=0
            warning('Time not corrected for offset due to insignificant offset value')
        end
    else
        time = time + timeCorr;
    end
    dist = dist(nMin:min([nMax,length(dist)]));
    %
    for f = 1 : length(tmpFN); eval([char(tmpFN(f)) '=dlmread(''' char(tmpFN(f)) '.tmpMF'');']); end
    for f = 1 : length(tmpFN); delete([char(tmpFN(f)) '.tmpMF']); end
    save([mainDir filesep 'channel ' num2str(z) '.mat'],'Temp','Sto','ASto','time','dist','PT100')
    disp(' '); disp(['Data for Channel ' num2str(z) ' was stored to:']); disp([mainDir filesep 'channel ' num2str(z) '.mat']); disp(' ');
    %
    waitbar((chCnt+0.99*k/len)/lenCh,h1);
end
delete(h1)
%
end
