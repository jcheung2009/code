


ans = input('keep plotting? (y/n):','s')


figure(7);hold on;

winSize = 100;
halfWinSize = floor(winSize/2);
jogSize = 1; % how many points to advance between points

while strcmp(ans,'y')
    subplt = input('subplot number:')
    inVect = input('input variable:')
    tm = jc_tb(inVect.fv,6,0);
    inVect = inVect.fv(:,2);
    runBS = [];
    %runBS = zeros(ceil(length(inVect)/jogSize),3);
      
    % handle edge effects
     for i=1:jogSize:halfWinSize;
        runBS = cat(1,runBS,cv(inVect(i:i+halfWinSize)));
         %[meancv hi lo] = mBootstrapCI_CV(inVect(i:i+halfWinSize),'');
        %runBS = cat(1,runBS,[meancv hi lo]);
     end
    
    
    for i=1+halfWinSize:jogSize:length(inVect)-halfWinSize;
        %[meancv hi lo] = mBootstrapCI_CV(inVect(i-halfWinSize:i+halfWinSize),'');
        runBS = cat(1,runBS,cv(inVect(i-halfWinSize:i+halfWinSize)));
    end
    %handle edge effects
     for i=(length(inVect)-halfWinSize+1):jogSize:length(inVect);
         %[meancv hi lo] = mBootstrapCI_CV(inVect(i-halfWinSize:i),'');
         runBS = cat(1,runBS,cv(inVect(i-halfWinSize:i)));
     end
     
     tmind = [1:jogSize:halfWinSize, 1+halfWinSize:jogSize:length(inVect)-halfWinSize,...
         (length(inVect)-halfWinSize+1):jogSize:length(inVect)];
     tm = tm(tmind);
     if subplt == 1
         subplot(1,2,subplt);hold on;
         plot(tm/3600,runBS,'k');hold on;
         %plot(tm/3600,runBS(:,2),'k');hold on;
         %plot(tm/3600,runBS(:,3),'k');hold on;
     else 
         subplot(1,2,subplt);hold on;
         subpltclr = input('line color:','s')
         plot(tm/3600,runBS,subpltclr);hold on;
         %plot(tm/3600,runBS(:,2),'r');hold on;
         %plot(tm/3600,runBS(:,3),'r');hold on;
     end
     
     ans = input('keep plotting? (y/n):','s')
     
end
     