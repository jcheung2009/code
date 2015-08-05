function [runBS] = jc_RunningBootstrap_mean(inVect,winSize)
%runBS = [runavg, hiconf loconf]
%

halfWinSize = floor(winSize/2);
jogSize = 1; % how many points to advance between points
runBS = zeros(ceil(length(inVect)/jogSize),3);
parfor i=1+halfWinSize:jogSize:length(runBS)-halfWinSize;
    runavg = mean(inVect(i-halfWinSize:i+halfWinSize));
    ci = bootci(1000,{@mean,inVect(i-halfWinSize:i+halfWinSize)},'alpha',0.05,'Options',statset('UseParallel',true));
    %[hi lo] = mBootstrapCImed(inVect(i-halfWinSize:i+halfWinSize),'');
    runBS(i,:) = [runavg ci(2) ci(1)];
end;

% handle edge effects
 parfor i=1:jogSize:halfWinSize;
    runavg = mean(inVect(i:i+halfWinSize));
    %[hi lo] = mBootstrapCImed(inVect(i:i+halfWinSize),'');
    ci = bootci(1000,{@mean,inVect(i:i+halfWinSize)},'alpha',0.05,'Options',statset('UseParallel',true));
    runBS(i,:) = [runavg ci(2) ci(1)];
 end;

 parfor i=(length(runBS)-halfWinSize+1):jogSize:length(runBS);
     %runavg(i) = median(inVect(i-halfWinSize):i);
     runavg = mean(inVect(i-halfWinSize:i));
     %[hi lo] = mBootstrapCImed(inVect(i-halfWinSize:i),'');
     ci = bootci(1000,{@mean,inVect(i-halfWinSize:i)},'alpha',0.05,'Options',statset('UseParallel',true));
     runBS(i,:) = [runavg ci(2) ci(1)];
 end;
