function [SpikeTimes Freq ISIs]=SpikeTimes(V,dt,debug)

    abovezero=find(diff(V)>3);
    idx=find(diff(abovezero)>1);
    
    if ~isempty(abovezero)

        idx=idx+1;
        idx(2:end+1)=idx;
        idx(1)=1;
    end;

    SpikeTimes=abovezero(idx)*dt;
    ISIs=diff(SpikeTimes);
    Freq=1./ISIs*1000;
    
    if debug==1
%         keyboard
        figure
        plot(dt:dt:length(V)*dt,V);
        hold on;
%        keyboard%
        plot(SpikeTimes,V(round(SpikeTimes/dt)),'rx');
        
    end;
    
%     i=1;
%     
%     while i<length(ISIs)-1
%         idx=find((SpikeTimes:SpikeTimes+1)>-30);
%         
%         if ~isempty(idx)
%             width(i)=(idx(end)-idx(1))*dt;
%         else
%             times=NaN;
%         end;
%         
%         i=i+1;
%     end;
%     
    
