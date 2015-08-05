function [runBS] = jc_RunningBootstrap_cv(inVect,winSize)
%runBS = [runcv, hiconf loconf]
%

halfWinSize = floor(winSize/2);
jogSize = 1; % how many points to advance between points
runBS = zeros(ceil(length(inVect)/jogSize),3);
parfor i=1+halfWinSize:jogSize:length(runBS)-halfWinSize;
     runCV = cv(inVect(i-halfWinSize:i+halfWinSize));
    %[runCV hi lo] = mBootstrapCI_CV(inVect(i-halfWinSize:i+halfWinSize),'');
    ci = bootci(1000,{@cv,inVect(i-halfWinSize:i+halfWinSize)},'alpha',0.05,'Options',statset('UseParallel',true))
    runBS(i,:) = [runCV ci(2) ci(1)];
end;

% handle edge effects
 parfor i=1:jogSize:halfWinSize;
    runCV = cv(inVect(i:i+halfWinSize));
    %[runCV hi lo] = mBootstrapCI_CV(inVect(i:i+halfWinSize),'');
    ci = bootci(1000,{@cv,inVect(i:i+halfWinSize)},'alpha',0.05,'Options',statset('UseParallel',true));
    runBS(i,:) = [runCV ci(2) ci(1)];
 end;

 parfor i=(length(runBS)-halfWinSize+1):jogSize:length(runBS);
     %runMed(i) = median(inVect(i-halfWinSize):i);
     runCV = cv(inVect(i-halfWinSize:i));
     %[runCV hi lo] = mBootstrapCI_CV(inVect(i-halfWinSize:i),'');
     ci = bootci(1000,{@cv,inVect(i-halfWinSize:i)},'alpha',0.05,'Options',statset('UseParallel',true));
     runBS(i,:) = [runCV ci(2) ci(1)];
 end;
