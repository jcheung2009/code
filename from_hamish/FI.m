clear;
[name path]=uigetfile('','Multiselect','on');
data=load([path name]);

figure;
plot(data.output.times,data.output.membvolt);

figure;
title([path name]);

hold on;


for i=1:size(data.output.stimwave,2)
    [Times{i} ISI{i}]=SpikeTimes(data.output.membvolt(1000:6000,i),0.1,1);
    MeanV(i)=Mean(data.output.membvolt(1000:6000,i));
    AvgFreq(i)=mean(ISI{i});

    if ~isempty(ISI{i})
        plot(ISI{i});
    end;        
end;

figure;
title([path name]);
hold on;
plot(data.output.I,AvgFreq);