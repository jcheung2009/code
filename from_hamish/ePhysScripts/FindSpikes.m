function [Freq ISIs Times Events SpkWave]=FindSpikes(RawData,Fs,StdThresh, debug);

% Fs=20000;
% RawData=Data-mean(Data);
dt=(1/Fs)*1000; %in ms; 
pad=ones(1,15)*mean(RawData);
RawData=[pad RawData' pad]';

FirstStd=std(RawData);

UpperThreshold=FirstStd*StdThresh;;
LowerThreshold=1*FirstStd;
WindowSize=15; %in samples; 

[Events]=find(RawData>UpperThreshold);
b=diff(Events);
c=find(b<10);
Events(c)=[];


KillIdx=[];
LowEvts=zeros(Events,1);
HighEvts=zeros(Events,1); 



for i=1:length(Events);
% try    
     LowEvts(i)=min(RawData(Events(i)-5:(Events(i)+WindowSize)));
% catch
%     keyboard;
% end;
    if  (LowEvts(i) > LowerThreshold)
        KillIdx=[KillIdx i];                
    end;
    HighEvts(i)=max(RawData(Events(i)-WindowSize:(Events(i)+WindowSize)));
end;

HighEvts(KillIdx)=[];
LowEvts(KillIdx)=[];
Events(KillIdx)=[];
SpkWave=zeros(2*WindowSize+1,length(Events));


for i=1:length(Events);   
    SpkWave(:,i)=RawData(Events(i)-WindowSize:(Events(i)+WindowSize));
end

ISIs=diff(Events)*dt;
Freq=(1./ISIs)*1000;
Times=Events*dt;



debug=0;
if debug==1
    figure;plot(LowEvts,HighEvts,'b.');
    figure;plot(Times(1:end-1),Freq);
    keyboard;
end;



