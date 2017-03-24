function [runBS] = jc_RunningBootstrap_median(inVect,winSize)
%runBS = [runMed, hiconf loconf]
%

halfWinSize = floor(winSize/2);
jogSize = 1; % how many points to advance between points
runBS = zeros(ceil(length(inVect)/jogSize),3);
parfor i=1+halfWinSize:jogSize:length(runBS)-halfWinSize;
    runMed = median(inVect(i-halfWinSize:i+halfWinSize));
    ci = bootci(1000,{@median,inVect(i-halfWinSize:i+halfWinSize)},'alpha',0.05,'Options',statset('UseParallel',true));
    %[hi lo] = mBootstrapCImed(inVect(i-halfWinSize:i+halfWinSize),'');
    runBS(i,:) = [runMed ci(2) ci(1)];
end;

% handle edge effects
 parfor i=1:jogSize:halfWinSize;
    runMed = median(inVect(i:i+halfWinSize));
    %[hi lo] = mBootstrapCImed(inVect(i:i+halfWinSize),'');
    ci = bootci(1000,{@median,inVect(i:i+halfWinSize)},'alpha',0.05,'Options',statset('UseParallel',true));
    runBS(i,:) = [runMed ci(2) ci(1)];
 end;

 parfor i=(length(runBS)-halfWinSize+1):jogSize:length(runBS);
     %runMed(i) = median(inVect(i-halfWinSize):i);
     runMed = median(inVect(i-halfWinSize:i));
     %[hi lo] = mBootstrapCImed(inVect(i-halfWinSize:i),'');
     ci = bootci(1000,{@median,inVect(i-halfWinSize:i)},'alpha',0.05,'Options',statset('UseParallel',true));
     runBS(i,:) = [runMed ci(2) ci(1)];
 end;
