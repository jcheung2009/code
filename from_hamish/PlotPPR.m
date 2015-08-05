% 
% close('all');
[data path]=uigetfile('*','MultiSelect', 'on')

HVcAvg=[];
lMANAvg=[];


for i=1:length(data)
    
load([path data{i}]);



figure(1);
signal=output.HVc.signal{1}(5000:6000)-mean(output.HVc.signal{1}(1:2000));
plot(signal);
HVcout(i,1)=abs(min(signal(200:500)));
HVcout(i,2)=abs(min(signal(720:860)));

if ~isempty(HVcAvg)
    HVcAvg=HVcAvg+signal;
else
    HVcAvg=signal;
end;


hold on;

figure(2)
signal=output.lMAN.signal{1}(5000:6000)-mean(output.lMAN.signal{1}(1:2000));
plot(signal);
lMANout(i,1)=abs(min(signal(200:500)));
lMANout(i,2)=abs(min(signal(720:860)));
if ~isempty(lMANAvg)
    lMANAvg=lMANAvg+signal;
else
    lMANAvg=signal;
end;
hold on;

end;

figure(1)
plot(HVcAvg./length(data),'r');
title('HVc');
figure(2)
plot(lMANAvg./length(data),'r');
title('lMAN')