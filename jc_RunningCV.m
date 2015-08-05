function runningcv = jc_RunningCV(invect,winSize)
%running cv

halfWinSize = floor(winSize/2);
jogSize = 1; % how many points to advance between points
runningcv = zeros(ceil(length(invect)/jogSize),1);
parfor i=1+halfWinSize:jogSize:length(runningcv)-halfWinSize;
    runningcv(i) = cv(invect(i-halfWinSize:i+halfWinSize));
end;

% handle edge effects
 parfor i=1:jogSize:halfWinSize;
    runningcv(i)= cv(invect(i:i+halfWinSize));
 end;

 parfor i=(length(runningcv)-halfWinSize+1):jogSize:length(runningcv);
     runningcv(i) = cv(invect(i-halfWinSize:i));
 end;
