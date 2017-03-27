function runAvg = jc_runninghit(invect,winSize)
%invect = [hit esc] in 1 and 0's, [1 0; 0 1;...]
%invect = [hit/esc] with 1 = hit, 0 = esc [1,0,0,1...]

    halfWinSize = floor(winSize/2);
    jogSize = 1; % how many points to advance between points
    
if size(invect,2) == 2 %invect = [hit esc] in 1 and 0's

    runAvg = zeros(1,ceil(length(invect)/jogSize));
    for i=1+halfWinSize:jogSize:length(runAvg)-halfWinSize;
        runAvg(i) = sum(invect(i-halfWinSize:i+halfWinSize,1))/(sum(invect(i-halfWinSize:i+halfWinSize,1))+sum(invect(i-halfWinSize:i+halfWinSize,2)));  
    end;

    % handle edge effects
     for i=1:jogSize:halfWinSize;
        runAvg(i) = sum(invect(i:i+halfWinSize,1))/(sum(invect(i:i+halfWinSize,1))+sum(invect(i:i+halfWinSize,2)));
     end;

     for i=(length(runAvg)-halfWinSize+1):jogSize:length(runAvg);
         runAvg(i) = sum(invect(i-halfWinSize:i,1))/(sum(invect(i-halfWinSize:i,1))+sum(invect(i-halfWinSize:i,2)));
     end;
     
elseif size(invect,2) == 1 %invect = [hit/esc] in 1 and 0's 
    
    runAvg = zeros(1,ceil(length(invect)/jogSize));
    for i=1+halfWinSize:jogSize:length(runAvg)-halfWinSize;
        runAvg(i) = mean(invect(i-halfWinSize:i+halfWinSize));
    end;

    % handle edge effects
     for i=1:jogSize:halfWinSize;
        runAvg(i) = mean(invect(i:i+halfWinSize));
     end;

     for i=(length(runAvg)-halfWinSize+1):jogSize:length(runAvg);
         runAvg(i) = mean(invect(i-halfWinSize:i));
     end;
end