clear;
dt=0.1;
gain=1;
% close('all');

[filename pathname]=uigetfile('*.mat','*.mat');

load([pathname filename]);

debug=true;
threshold=-0.45;
figure(1);
clf;
hold on;

data=(output.Vm(:,2))*(gain);
% Windows

    MedianFilterWindow=10; % samples; just to get rid of ;
    filter=0.2; % 500Hz filter, 10Khz sampling, 0.2)

    [b a]=butter(8, 0.1);

%     data=data/5;
    
    FilteredData=filtfilt(b,a,data);
    FilteredData=FilteredData-mean(FilteredData);
    
    
    figure;
    plot(FilteredData)

    [Idx]=find(diff(FilteredData(200:end))<threshold);
    Idx=Idx+200;
%     [Idx]=find(diff(data)>threshold);
    
%    NonSequentialEvents=find(diff(Idx)>1);
    
    Events=find(diff(Idx)>5);

    dt=0.1;
    killidx=[];
    AvgOut=zeros(301,1);
    
    for i=2:length(Events)-1
        figure(1)
        hold on;

        if Idx(Events(i))>201
            start=Idx(Events(i))-200;
            stop=Idx(Events(i))+100;
        else
            start=1;
            stop=Idx(Events(i))+200;
        end;
        

            stop=Idx(Events(i))+100;               
            EventData=data(start:stop);        
            EventData=EventData-max(EventData(1:20));%mean(round(EventData(1:20)));
            [peakamp(i) peakidx]=(min(EventData(150:250)));
            peakidx=peakidx+150;
            times=[(-peakidx*dt):dt:0 dt:dt:dt*(length(EventData)-peakidx-1)];

            if peakamp(i)<-5%&&(mean(diff(EventData(peakidx-10:peakidx)))<-1)
                 figure(3)
                 hold on;
                 plot(times(1:length(EventData)),EventData);    
                 AvgOut=AvgOut+EventData;                 
            else
                  killidx=[killidx i];   
                  figure(4)
                  hold on;
                  plot(times(1:length(EventData)),EventData,'r');    
                  figure(2)
                  hold on;
                  plot(diff(EventData),'r');
%                   keyboard
        end
    end;
    
    %Idx=Idx(NonSequentialEvents);

%     indices=Idx;
% 
% [Idx]=EventFinder(output.Vm(:,2),0.4);
% plot(output.Vm(:,2));
% plot(Idx,output.Vm(Idx,2),'rx');

    if ~isempty(killidx)
        peakamp(killidx)=[];
        Events(killidx)=[];
    end
    
    AllIEvI=diff(Events)*dt;

    peakamp=peakamp*-1;
    mean(peakamp)
    Frequency=length(peakamp)/(length(output.Vm)/10000)
    
    AvgOut=AvgOut/length(peakamp);
    figure(1)
    hold on;
    plot(times(1:length(AvgOut)),AvgOut,'r');

    peakamp=sort(peakamp);
    for i=1:length(peakamp)
        a=find(peakamp < peakamp(i));
        pd(i)=length(a);
    end;

    pd=pd/length(peakamp);
    figure;
    plot(sort(peakamp),pd);
    
    EventsTime=Idx(Events)*dt;
    ISI=sort((diff(EventsTime)));
    
    for i=1:length(ISI)
        a=find(ISI < ISI(i));
        pdISI(i)=length(a);
    end;

  
    pdISI=pdISI/length(ISI);
    figure;
    plot(sort(ISI)/1000,pdISI);
      
    

