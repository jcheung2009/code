clear;

[filename pathname]=uigetfile('*.mat','*.mat');

load([pathname filename]);
gain=1;
debug=true;
pulsewidth=7;

numtrials=size(output.HVc.signal,2);

figure(1);
clf;
hold on;

    for i=1:numtrials
        
        signal=output.HVc.signal{i}/gain;       
  
        prestim=mean(signal(1:500))
        peak=max(diff(signal));      
        crap=find(diff(signal)>(peak-500));
    
    if length(crap)>2
        [a b]=max(diff(crap));    
        temp=[crap(1) crap(b+1)];
    else
        temp=crap;
    end;       
    
    temp=temp+pulsewidth;
%     try
    [amp(1,i) index(1)]=min(signal(temp(1):temp(2)-2*pulsewidth));
    [amp(2,i) index(2)]=min(signal(temp(2):end));
    
    [base(1,i) baseindex(1)]=max(signal(temp(1):temp(1)+pulsewidth+50));
    [base(2,i) baseindex(2)]=max(signal(temp(2):temp(2)+pulsewidth+50));
    
    amp(:,i)=(base(:,i)-amp(:,i));
    
    index(1)=index(1)+temp(1);
    index(2)=index(2)+temp(2);
    
    baseindex(1)=baseindex(1)+temp(1)+pulsewidth;
    baseindex(2)=baseindex(2)+temp(2)+pulsewidth;    
    
    plot(output.time{i},signal);
    
    if debug
        plot(output.time{i}(temp),signal(temp),'rx');
        plot(output.time{i}(index(1)),signal(index(1)),'bo');
        plot(output.time{i}(index(2)),signal(index(2)),'bo');    
        
        plot(output.time{i}(baseindex(1)),signal(baseindex(1)),'go');
        plot(output.time{i}(baseindex(2)),signal(baseindex(2)),'go');          
       
   %    keyboard
    end;

    

    
   
end;

clear temp;

temp(:,1)=output.ISIs(1:numtrials)';
temp(:,2:3)=amp';
temp(:,4)=(amp(2,:)./amp(1,:))';


ratio=(amp(2,:)./amp(2,:))'
meanamp=mean(amp(1,:));

meanamp(2)=std(amp(1,:))

open('meanamp');
open('temp');
title(filename);


figure(2);
hold on;
%plot(temp(:,1),temp(:,4),'g');
plot(temp(:,1),temp(:,4),'b');
%plot(temp(:,1),temp(:,4),'r');
