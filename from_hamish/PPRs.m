

function [amp PPR baseline]=PPRs(signal,pulsewidth,plotflag);

    amp=[0 0];
    base=[0 0];
    index=[0 0];
    baseindex=[0 0];
    
            
    baseline=mean(signal(1:750));
    
    signal=signal-baseline; % zero for convenience;
 
    peak=max(diff(signal));      
    crap=find(diff(signal)>(peak-(0.5*peak)));               
    
%    keyboard
   
    if length(crap)>2
        [a b]=max(diff(crap));    
        temp=[crap(1) crap(b+1)];
    else
        temp=crap;
    end;       
    
    temp=temp+pulsewidth;   
    
    try
    [amp(1) index(1)]=min(signal(temp(1):temp(2)-2*pulsewidth));
    catch
        amp(1)=NaN;
        index(1)=NaN;
    end;
    [amp(2) index(2)]=min(signal(temp(2)+pulsewidth:end));
%    amp(:)=amp(:)-base;
    
    index(1)=index(1)+temp(1);
    index(2)=index(2)+temp(2);
    
%     baseindex(1)=baseindex(1)+temp(1)+pulsewidth;
%     baseindex(2)=baseindex(2)+temp(2)+pulsewidth;    
    

    if plotflag
        figure;
        plot(signal);
        hold on;
        plot(index(1),amp(1),'rx');
        plot(index(2),amp(2),'gx');
    end;


    PPR=amp(2)/amp(1);
    amp=amp(1);