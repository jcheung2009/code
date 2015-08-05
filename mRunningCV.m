function [runCV] = mRunningCV(inVect,winSize)
%
%
% Computes & returns running average of inVect. Average values are
% calculated on windows of winSize points. 
%
%


halfWinSize = floor(winSize/2);
jogSize = 1; % how many points to advance between points
i = 1;
runCV = zeros(1,ceil(length(inVect)/jogSize));
for i=1+halfWinSize:jogSize:length(runCV)-halfWinSize;
    runCV(i) = cv(inVect(i-halfWinSize:i+halfWinSize));    
end;

% handle edge effects
 for i=1:jogSize:halfWinSize;
    runCV(i) = cv(inVect(i:i+halfWinSize));
 end;

 for i=(length(runCV)-halfWinSize+1):jogSize:length(runCV);
     %runAvg(i) = mean(inVect(i-halfWinSize):i);
     runCV(i) = cv(inVect(i-halfWinSize:i));
 end;