function [runBS] = mRunningBootstrap(inVect,winSize)
%runBS = [runavg, hiconf loconf]
%

halfWinSize = floor(winSize/2);
jogSize = 1; % how many points to advance between points
runBS = zeros(ceil(length(inVect)/jogSize),3);
for i=1+halfWinSize:jogSize:length(runBS)-halfWinSize;
    runAvg = mean(inVect(i-halfWinSize:i+halfWinSize));
    [hi lo] = mBootstrapCI(inVect(i-halfWinSize:i+halfWinSize),'');
    runBS(i,:) = [runAvg hi lo];
end;

% handle edge effects
 for i=1:jogSize:halfWinSize;
    runAvg = mean(inVect(i:i+halfWinSize));
    [hi lo] = mBootstrapCI(inVect(i:i+halfWinSize),'');
    runBS(i,:) = [runAvg hi lo];
 end;

 for i=(length(runBS)-halfWinSize+1):jogSize:length(runBS);
     %runAvg(i) = mean(inVect(i-halfWinSize):i);
     runAvg = mean(inVect(i-halfWinSize:i));
     [hi lo] = mBootstrapCI(inVect(i-halfWinSize:i),'');
     runBS(i,:) = [runAvg hi lo];
 end;
