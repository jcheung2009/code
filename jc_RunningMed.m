function [runMed] = jc_RunningMed(inVect,winSize)
%running median with standard error [runmed stderr]
%



halfWinSize = floor(winSize/2);
jogSize = 1; % how many points to advance between points
i = 1;
runMed = zeros(1,ceil(length(inVect)/jogSize));
for i=1+halfWinSize:jogSize:length(runMed)-halfWinSize;
    runMed(i) = median(inVect(i-halfWinSize:i+halfWinSize));    
end;

% handle edge effects
 for i=1:jogSize:halfWinSize;
    runMed(i) = median(inVect(i:i+halfWinSize));
 end;

 for i=(length(runMed)-halfWinSize+1):jogSize:length(runMed);
     %runAvg(i) = mean(inVect(i-halfWinSize):i);
     runMed(i) = median(inVect(i-halfWinSize:i));
 end;