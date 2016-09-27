function funLoadUltimaXML(mainDir,channels,timeCorr,xRan)
% funLoadUltimaXML (v6) (suitable for all known Ultima software versions)
% 12/09/2016
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
%      Copyright (C) 2016 Technische Universiteit Delft, 
%          Koen Hilgersom
%          K.P.Hilgersom@tudelft.nl (correspondence)
% 
%---------------------------------------------------------------------------  
tmpFN = {'Sto','ASto','Temp'}; %temporary file names for Temperature, Stokes and anti-Stokes data
for f = 1 : length(tmpFN); if exist([char(tmpFN(f)) '.tmpMF'],'file'); delete([char(tmpFN(f)) '.tmpMF']); end; end
%
strListD  = {'logs','log','logData','data'};                        nodeNrD  = NaN(size(strListD));
strListT  = {'logs','log','DateTimeIndex'};                         nodeNrT  = NaN(size(strListT));
strListP1 = {'logs','log','customData','probe1Temperature'};        nodeNrP1 = NaN(size(strListP1));
strListP2 = {'logs','log','customData','probe2Temperature'};        nodeNrP2 = NaN(size(strListP2));
tstNaN    = false;
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
    Dist  = [];
    Data  = NaN(cntMax,0,3);
    %
    h2 = waitbar(0,['Progress on current channel (Channel ' num2str(z) ')'],'Position',get(h1,'Position')-[0 80 0 0]);
    %
    tic
    for k=1:len
        XRead = xmlread([mainDir filesep 'channel ' num2str(z) filesep files(k).name]);
        if tstNaN == false;                                   
            nodeNrD = testNodeNumbersNaN(strListD ,nodeNrD ,XRead);      nodeNrT = testNodeNumbersNaN(strListT ,nodeNrT ,XRead);
            nodeNrP1= testNodeNumbersNaN(strListP1,nodeNrP1,XRead);      nodeNrP2= testNodeNumbersNaN(strListP2,nodeNrP2,XRead);
            tstNaN  = true;
        end                       
        [nodeNrD] = testNodeNumbersChange(strListD, nodeNrD, XRead); % check for changed node numbers for Dist/T/Sto/aSto data
        child           = XRead.getChildNodes.item(nodeNrD(1)).item(nodeNrD(2)).item(nodeNrD(3));
        childNodes      = child.getChildNodes;
        numChildNodes   = (childNodes.getLength-nodeNrD(4))/2;
        nEnd            = min(nMax,numChildNodes);
        for n=nMin:min([length(Dist),nEnd])
            Read                 = sscanf(char(child.item(2*(n-1)+nodeNrD(4)).item(0).getData),'%f,%f,%f,%f');
            Data(cnt,n-nMin+1,:) = Read(2:4);    
        end        
        if length(Dist)<nEnd
            nSt     = length(Dist)+1;
            DataTmp = NaN(nEnd-size(Data,2),3);
            distAdd = NaN(nEnd-length(Dist),1);
            for n=1:(nEnd-nSt+1)
                Read         = sscanf(char(child.item(2*(n-1)+nodeNrD(4)).item(0).getData),'%f,%f,%f,%f');
                if Read(1)>xR(2); nMax = nSt + n - 2; nEnd = nMax; break; end                
                distAdd(n)   = Read(1);
                DataTmp(n,:) = Read(2:4);
            end
            Dist = [Dist; distAdd(~isnan(distAdd))];
            if k==1;    nMin = max([nMin,find(Dist<=xR(1),1,'last' )+1]); end
                        nMax = min([nMax,find(Dist>=xR(2),1,'first')-1]);
            Data = cat(2,Data,NaN(cntMax,(nEnd-nMin+1)-size(Data,2),3));
            Data(cnt,(max(nSt,nMin):min(nEnd,nMax))-max(nSt,nMin)+nSt,:) = DataTmp(max(nSt,nMin):min(nEnd,nMax)-nSt+1,:);
            clear DataTmp distAdd
        end
        if cnt == cntMax
            for f = 1 : length(tmpFN); dlmwrite([char(tmpFN(f)) '.tmpMF'],Data(:,:,f),'-append'); end;
            cntMax = min(50,len-genCnt*50); DatSiz = size(Data,2); clear Data
            Data   = NaN(cntMax,DatSiz,3);
            cnt    = 0;                                                         genCnt = genCnt+1;
        end
        cnt = cnt+1;
        [nodeNrT] = testNodeNumbersChange(strListT,nodeNrT, XRead); % check for changed node numbers for time data
        A               = char(XRead.item(nodeNrT(1)).item(nodeNrT(2)).item(nodeNrT(3)).item(0).getData);
        time(k)         = datenum([A(1:4) '/' A(6:7) '/' A(9:10) ' ' A(12:13) ':' A(15:16) ':' A(18:19)]);
        % check for changed node numbers for PT100 data
        [nodeNrP1] = testNodeNumbersChange(strListP1, nodeNrP1, XRead);         [nodeNrP2] = testNodeNumbersChange(strListP2, nodeNrP2, XRead);
        PT100(k,:)      = [str2double(XRead.item(nodeNrP1(1)).item(nodeNrP1(2)).item(nodeNrP1(3)).item(nodeNrP1(4)).item(0).getData),...
                               str2double(XRead.item(nodeNrP2(1)).item(nodeNrP2(2)).item(nodeNrP2(3)).item(nodeNrP2(4)).item(0).getData)];
        clear Read XRead nodes child childNodes
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
    Dist = Dist(nMin:min([nMax,length(Dist)]));
    %
    for f = 1 : length(tmpFN); eval([char(tmpFN(f)) '=dlmread(''' char(tmpFN(f)) '.tmpMF'');']); end
    for f = 1 : length(tmpFN); delete([char(tmpFN(f)) '.tmpMF']); end
    save([mainDir filesep 'channel ' num2str(z) '.mat'],'Temp','Sto','ASto','time','Dist','PT100')
    disp(' '); disp(['Data for Channel ' num2str(z) ' was stored to:']); disp([mainDir filesep 'channel ' num2str(z) '.mat']); disp(' ');
    %
    waitbar((chCnt+0.99*k/len)/lenCh,h1);
end
delete(h1)
%
end

function [nodeNr] = testNodeNumbersNaN(strList,nodeNr,nodes)
    if any(isnan(nodeNr)); 	nodeNr = getNodeNumbers(strList,nodeNr,nodes);  end
end

function [nodeNr] = testNodeNumbersChange(strList,nodeNr,nodes)
    cmp = false;     node = nodes;
    for n = 1 : length(nodeNr)
        keyword = char(strList(n));
        node = node.getChildNodes.item(nodeNr(n)); nodeName = char(node.getNodeName);
        cmp = ~strcmpi(nodeName(max(1,end-length(keyword)+1):end),keyword);        
        if cmp == true
            nodeNr = getNodeNumbers(strList,nodeNr,nodes);  warning('XML file format was changed');
            break
        end        
    end
end

function [nodeNr] = getNodeNumbers(strList,nodeNr,nodes)
    nodeCh = nodes.getFirstChild;
    nodeName = char(nodeCh.getNodeName);
    for n = 1:length(strList);
        keyword = char(strList(n));
        for k = 0 : nodes.getLength - 1
            if strcmpi(nodeName(max(1,end-length(keyword)+1):end),keyword)
                nodeNr(n)= k;                           nodes    = nodes.item(k).getChildNodes;
                nodeCh   = nodes.getFirstChild;         nodeName = char(nodeCh.getNodeName);
                % right node found -> break loop and continue with finding string on child level
                break
            else
                % right node not found -> try next node on this level
                nodeCh   = nodeCh.getNextSibling;       nodeName = char(nodeCh.getNodeName);
            end
            if k==nodes.getLength-1; warning('XML format unknown.');
                error('Please investigate the XML structure for the right node names or contact this script''s author to solve the problem.');
            end
        end
    end
end
