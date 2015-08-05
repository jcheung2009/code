
load ResultFile;
Fs=30000;
load ChanList;
suffix='.mat';
%     title(currdir);
%     set(gca,'xtick',[]); %,'ytick',[])


     SubPlotNum=Result(1).numtrials; %sum(ChanList(:,2))+2; % # of Clusters, + 
     [S,F,T,P] = spectrogram(Result(1).song,256,250,256,32000);
     cm=make_map(-50,10,1.2);
%      keyboard
     T=T*1000; %ms
     
     for i=1:ceil(SubPlotNum/8)         
        MainPlot(i)=figure;    
        currdir=cd;
        title([currdir(8:end) '     Pt:' num2str(i)]);
        set(MainPlot(i),'Toolbar','figure')
        set(MainPlot(i),'Color',[1 1 1]);

%         SubPlotNum=length(endidx)+2; 
        hand=subplot(9,1,1); 
        
        surf(T,F,log10(P),'edgecolor','none'); axis tight; 
        colormap(cm);
        ylim([0 8000]);
        xlim([10 max(T)]);
        view(0,90);      
        
     end;
    
 
    dt=1/Fs;
    dt=dt*1000;  

    ResultIdx=1;
%     SubPlotIDX=1;
    
    for i=1:size(ChanList,1); %length(ChanList,1);
                    
             WavClus=load(['times_AllSongsChan' num2str(ChanList(i,1)) suffix]);
%             keyboard
                
            for k=1:ChanList(i,2) % How many Channels we at? 
                
                    ResultIdx=ResultIdx+1;
                   
                    ChanIdx=find(WavClus.cluster_class==(k));
                    ChanTimes=WavClus.cluster_class(ChanIdx,2);
                    
                   
%                      set(hand,'ytick'
                    hold on;

                    for j=1:Result(1).numtrials;
                        
                        
                        SubplotIDX=j+1;

                        FigIdx=ceil(SubplotIDX/8);
                        SubplotIDX=(mod(SubplotIDX,8))+1;  ;
                        
                         if SubplotIDX==1
                             SubplotIDX=8;
                         end;
                        
       
                        
                        figure(MainPlot(FigIdx));
                         
                        subplot(9,1,SubplotIDX);
                        hold on;
                        set(gca,'xtick',[],'ytick',[]);
%                         ylabel([num2str(ChanList(i,1)) ' : ' num2str(k)],'FontSize',8); 

                        TickTimes=round(Result(ResultIdx).WarpedSpikeTimes{j}');
                        RowVector=[ones(size(TickTimes))*ResultIdx*1;ones(size(TickTimes))*(ResultIdx*1-1)];    
                        plot([TickTimes;TickTimes],RowVector,'-k','LineWidth',0.5);  
                        ylabel(num2str(j));
                                            
                    xlim([10 max(T)]);
                    ylim([0 (ResultIdx)*1]);
%     keyboard
                    end;
                    
                 
                    xlim([10 max(T)]);
                    ylim([0 (ResultIdx)*1]);
                    set(gca,'ytick',[1 Result(1).numtrials;],'FontSize',8);

%                     WaveForms=WavClus.spikes(ChanIdx,:)
%                     [AvgWave WaveSEM]=grpstats(WaveForms);
%                     hand=subplot(SubPlotNum,5,[5]+((SubplotIDX)*5));    
%                     gca;
%                     
%                     waveformtime=(1:length(AvgWave))./(Fs/1000);
% %                     keyboard;              
%                     if ~isempty(AvgWave)
%                         fig=plotyy(hand,waveformtime,AvgWave,waveformtime,AvgWave);
% %                     fig=plotyy(waveformtime,AvgWave,waveformtime,AvgWave);
%                         xlim(fig(1),[0 waveformtime(end)])
%                         xlim(fig(2),[0 waveformtime(end)])
%                     
%                         set(fig(1),'xtick',[],'ytick',[]);
%                         set(fig(2),'xtick',[]);
%                     
%                         hold on;
%                         if~isempty(WaveForms)
%                             plot(waveformtime,AvgWave+std(WaveForms),'r');
%                             plot(waveformtime,AvgWave-std(WaveForms),'r');
%                         end;
% %                     yax=min(AvgWave)-50:(max(AvgWave+50)-(min(AvgWave)-50))/3:max(AvgWave+50);
% %                      keyboard
%                         ylim(fig(2),[min(AvgWave)-100 max(AvgWave)+100]);
%                         ylim(fig(1),[min(AvgWave)-100 max(AvgWave)+100]);                    
%                     
%                         set(fig(2),'YTick',[min(AvgWave) max(AvgWave)],'FontSize',8);
%                     
%                         set(fig(1),'xtick',[],'ytick',[]);
%                         ylabel(fig(1),'uV','FontSize',8)
%                     end;


                    
             
            end;
           
    end;
%      set(fig(2),'xtick',[0:1:waveformtime(end)],'FontSize',8);
%      xlabel(fig(1),'ms','FontSize',8);
%      hand=subplot(SubPlotNum,5,[5]+((SubplotIDX)*5));    
%      set(hand,'xtick',[0:100:max(T)]);
     
       
%     currdir=cd;
%     suptitle(currdir(8:end),8);
%     save Result;
%     savefig('MultiChanRastfig');
%         keyboard;