load ChanList;

Fs=32000;

% ChanList=[30 1];

MainPlot=figure;
set(MainPlot,'Toolbar','figure')
hand=subplot(length(ChanList)+1,1,1); 
SubPlotIDX=0;

start=80000;
stop=100000;

for i=1:length(ChanList);
    
    SubPlotIDX=SubPlotIDX+1;
    
    data=load(['AllSongsChan' num2str(ChanList(i,1))]);
    data=data.data;
%     chunkdata{i}=bandpass(data(end-50000:end),32000,600,9000);    
    chunkdata{i}=bandpass(data(start:stop),32000,900,12000)*2;    

    hand=subplot(length(ChanList)+1,1,SubPlotIDX); 

    plot(chunkdata{i}); 
    set(gca,'xtick',[],'ytick',[])
    hold on;
     
    WavClus=load(['times_AllSongsChan' num2str(ChanList(i,1))]);
    
    
    for j=1:ChanList(i,2)
        temp=zeros(length(data),1);
        [a b]=find(WavClus.cluster_class(:,1)==j);
        idx=WavClus.cluster_class(a,2)*Fs/1000;
        temp(idx)=1;        
        chunkspikes=temp(start:stop);
        colorm=[0 0 0]
        colorm(j)=1;
        plot(chunkspikes,'color',colorm); 
        ylabel(num2str(ChanList(i,1)));
    end;
    
    
    
%     SubplotIDX=SubplotIDX+1;
    
%     for j=1:ChanList(i,2)
%         
% %         ChanTimes=find(WavClus.cluster_class==(k));
% %         ChanTimes=WavClus.cluster_class(ChanTimes,2);
% %         hand=subplot(SubPlotNum,5,[1:4]+((SubplotIDX)*5));

end;