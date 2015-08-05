function runningaverage = jc_RunningAverage(inVect,winSize)
%running average with standard error [runavg stderr]

halfWinSize = floor(winSize/2);
jogSize = 1; % how many points to advance between points
runningaverage = zeros(ceil(length(inVect)/jogSize),2);
parfor i=1+halfWinSize:jogSize:length(runningaverage)-halfWinSize;
    runavg = mean(inVect(i-halfWinSize:i+halfWinSize));
    runningaverage_stderr = stderr(inVect(i-halfWinSize:i+halfWinSize));
    %ci = bootci(5000,{@median,inVect(i-halfWinSize:i+halfWinSize)},'alpha',0.05,'Options',statset('UseParallel',true));
    %[hi lo] = mBootstrapCImed(inVect(i-halfWinSize:i+halfWinSize),'');
    runningaverage(i,:) = [runavg runningaverage_stderr];
end;

% handle edge effects
 parfor i=1:jogSize:halfWinSize;
    runavg = mean(inVect(i:i+halfWinSize));
    runningaverage_stderr = stderr(inVect(i:i+halfWinSize));
    %[hi lo] = mBootstrapCImed(inVect(i:i+halfWinSize),'');
    %ci = bootci(5000,{@median,inVect(i:i+halfWinSize)},'alpha',0.05,'Options',statset('UseParallel',true));
    runningaverage(i,:) = [runavg runningaverage_stderr];
 end;

 parfor i=(length(runningaverage)-halfWinSize+1):jogSize:length(runningaverage);
     %runMed(i) = median(inVect(i-halfWinSize):i);
     runavg = mean(inVect(i-halfWinSize:i));
     runningaverage_stderr = stderr(inVect(i-halfWinSize:i));
     %[hi lo] = mBootstrapCImed(inVect(i-halfWinSize:i),'');
     %ci = bootci(5000,{@median,inVect(i-halfWinSize:i)},'alpha',0.05,'Options',statset('UseParallel',true));
     runningaverage(i,:) = [runavg runningaverage_stderr];
 end;
