function [runAvg] = mRunningAvg(inVect,winSize)
%
%
% Computes & returns running average of inVect. Average values are
% calculated on windows of winSize points. 
%
%


halfWinSize = floor(winSize/2);
jogSize = 1; % how many points to advance between points
i = 1;
runAvg = zeros(1,ceil(length(inVect)/jogSize));
for i=1+halfWinSize:jogSize:length(runAvg)-halfWinSize;
    runAvg(i) = mean(inVect(i-halfWinSize:i+halfWinSize));    
end;

% handle edge effects
 for i=1:jogSize:halfWinSize;
    runAvg(i) = mean(inVect(i:i+halfWinSize));
 end;

 for i=(length(runAvg)-halfWinSize+1):jogSize:length(runAvg);
     %runAvg(i) = mean(inVect(i-halfWinSize):i);
     runAvg(i) = mean(inVect(i-halfWinSize:i));
 end;