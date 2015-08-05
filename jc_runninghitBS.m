function runBS = jc_runninghitBS(invect,winSize)

%invect = [hit/esc] with 1 = hit, 0 = esc [1,0,0,1...]

halfWinSize = floor(winSize/2);
jogSize = 1; % how many points to advance between points
runBS = zeros(ceil(length(invect)/jogSize),3);
for i=1+halfWinSize:jogSize:length(runBS)-halfWinSize;
    runAvg = mean(invect(i-halfWinSize:i+halfWinSize));
    [hi lo] = mBootstrapCI(invect(i-halfWinSize:i+halfWinSize),'');
    runBS(i,:) = [runAvg hi lo];
end;

% handle edge effects
 for i=1:jogSize:halfWinSize;
    runAvg = mean(invect(i:i+halfWinSize));
    [hi lo] = mBootstrapCI(invect(i:i+halfWinSize),'');
    runBS(i,:) = [runAvg hi lo];
 end;

 for i=(length(runBS)-halfWinSize+1):jogSize:length(runBS);
     runAvg = mean(invect(i-halfWinSize:i));
     [hi lo] = mBootstrapCI(invect(i-halfWinSize:i),'');
     runBS(i,:) = [runAvg hi lo];
end;