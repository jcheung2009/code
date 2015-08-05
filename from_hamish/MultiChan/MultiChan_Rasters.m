 
    load ResultFile;

    MainPlot=figure;    
    currdir=cd;
    title(currdir(8:end));
    set(MainPlot,'Toolbar','figure')
    set(MainPlot,'Color',[1 1 1]);
    
    hand=subplot(SubPlotNum,5,[1:4]); 
        title(currdir);
%     set(gca,'xtick',[]); %,'ytick',[])

    SubPlotNum=sum(ChanList(:,2))+2; % # of Clusters, + 
    
    dt=1/Fs;
    dt=dt*1000;
        
%     SongSampleTime=1:length(rawsong)*dt;
    
    [S,F,T,P] = spectrogram(Result(1).song,256,250,256,32000);
    T=T*1000; %ms
    surf(T,F,log10(P),'edgecolor','none'); axis tight; 
    ylim([0 8000]);
    xlim([10 max(T)]);
    view(0,90);

    SubplotIDX=1;
    
    for i=1:size(ChanList,1); %length(ChanList,1);
                    
             WavClus=load(['times_AllSongsChan' num2str(ChanList(i,1)) suffix]);
%             keyboard
                
            for k=1:ChanList(i,2) % How many Channels we at? 
                
                    SubplotIDX=SubplotIDX+1;
                    ChanIdx=find(WavClus.cluster_class==(k));
                    ChanTimes=WavClus.cluster_class(ChanIdx,2);
                    
                    hand=subplot(SubPlotNum,5,[1:4]+((SubplotIDX)*5));             
%                      set(hand,'ytick'
                    hold on;

                    for j=1:length(endidx)

                        [a b]=find(ChanTimes>starttimes(j),1);
                        [c d]=find(ChanTimes>endtimes(j),1);

                        Result(SubplotIDX).MotifSpikeTimes{j}=ChanTimes(a:c-1)-starttimes(j);     
                        Result(SubplotIDX).WarpedSpikeTimes{j}=Result(SubplotIDX).MotifSpikeTimes{j}.*ScaleFactor(j);
                        
                        shit = find(Result(SubplotIDX).WarpedSpikeTimes{j} > 400);
                        
                        if ~isempty(shit)                            
%                              keyboard
                        end;
                        
                        set(gca,'xtick',[],'ytick',[]);
                        ylabel([num2str(ChanList(i,1)) ' : ' num2str(k)],'FontSize',8); 
                        TickTimes=round(Result(SubplotIDX).WarpedSpikeTimes{j}');
                        RowVector=[ones(size(TickTimes))*j*1;ones(size(TickTimes))*(j*1-1)];           
                        plot([TickTimes;TickTimes],RowVector,'-k','LineWidth',0.5);               

                    end;
                    
                    xlim([10 max(T)]);
                    ylim([0 numtrials*1]);
                    set(gca,'ytick',[1 numtrials],'FontSize',8);

                    WaveForms=WavClus.spikes(ChanIdx,:)
                    [AvgWave WaveSEM]=grpstats(WaveForms);
                    hand=subplot(SubPlotNum,5,[5]+((SubplotIDX)*5));    
                    gca;
                    
                    waveformtime=(1:length(AvgWave))./(Fs/1000);
%                     keyboard;              
                    if ~isempty(AvgWave)
                        fig=plotyy(hand,waveformtime,AvgWave,waveformtime,AvgWave);
%                     fig=plotyy(waveformtime,AvgWave,waveformtime,AvgWave);
                        xlim(fig(1),[0 waveformtime(end)])
                        xlim(fig(2),[0 waveformtime(end)])
                    
                        set(fig(1),'xtick',[],'ytick',[]);
                        set(fig(2),'xtick',[]);
                    
                        hold on;
                        if~isempty(WaveForms)
                            plot(waveformtime,AvgWave+std(WaveForms),'r');
                            plot(waveformtime,AvgWave-std(WaveForms),'r');
                        end;
%                     yax=min(AvgWave)-50:(max(AvgWave+50)-(min(AvgWave)-50))/3:max(AvgWave+50);
%                      keyboard
                        ylim(fig(2),[min(AvgWave)-100 max(AvgWave)+100]);
                        ylim(fig(1),[min(AvgWave)-100 max(AvgWave)+100]);                    
                    
                        set(fig(2),'YTick',[min(AvgWave) max(AvgWave)],'FontSize',8);
                    
                        set(fig(1),'xtick',[],'ytick',[]);
                        ylabel(fig(1),'uV','FontSize',8)
                    end;


                    
             
            end;
           
    end;
     set(fig(2),'xtick',[0:1:waveformtime(end)],'FontSize',8);
     xlabel(fig(1),'ms','FontSize',8);
     hand=subplot(SubPlotNum,5,[5]+((SubplotIDX)*5));    
     set(hand,'xtick',[0:100:max(T)]);
     
       
    currdir=cd;
    suptitle(currdir(8:end),8);
    save Result Result;
%     savefig('MultiChanRastfig');
%         keyboard;