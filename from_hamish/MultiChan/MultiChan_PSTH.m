%     load ResultFile
%      load ChanList
    
%      clear Result.TrialByTrialPSTH;
%      clear Result.PSTH;
%      
    MainPlot=figure; %(3);
    currdir=cd;
    title(currdir(8:end));
    hold on;
    SubPlotNum=sum(ChanList(:,2))+2; % # of Clusters, + 
    
    
    set(MainPlot,'Toolbar','figure')
    set(MainPlot,'Color',[1 1 1]);
    hand=subplot(SubPlotNum,5,[1:4]); 
    hold on;
    Result(1).GaussianWindow=15; %ms;
    
%     set(gca,'xtick',[]); %,'ytick',[])
     
    [S,F,T,P] = spectrogram(Result(2).song,256,250,256,32000);    
    T=T*1000;
    surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
%     set(fig(2),'xtick',[0:100:max(T)]);
    ylim([0 8000]);
    view(0,90);
    
    gaussFilter = gausswin(Result(1).GaussianWindow);
    gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
    FastgaussFilter = gausswin(5);
    FastgaussFilter = FastgaussFilter/sum(FastgaussFilter);
    
    SubplotIDX=1;
    
    for i=1:size(ChanList,1)
        disp(i);
            for k=1:ChanList(i,2) % How many Channels we at? 
                
                    SubplotIDX=SubplotIDX+1;
                    subplot(SubPlotNum,5,[1:4]+((SubplotIDX)*5));             
                    hold on; 
                    set(gca,'xtick',[],'ytick',[])
                    buffer=900;
                    temp=zeros((round(max(T))+buffer),Result(1).numtrials); %reset the PSTH w/ a buffer. 
                    numtrials=Result(1).numtrials;
                        
                    for j=1:numtrials                     
                        SpkIdx=round(Result(SubplotIDX).WarpedSpikeTimes{j})+1; % get spk times in ms.   
                     
                        temp(SpkIdx,j)=temp(SpkIdx,j)+1; % + sum them across their indices (in ms). 
                        TrialByTrialPSTH{j}=conv(temp(:,j),gaussFilter); 
                        HighResPSTH{j}=conv(temp(:,j),FastgaussFilter);
                        Result(SubplotIDX).TrialByTrialPSTH{j}=TrialByTrialPSTH{j};
                    end;
%  keyboarda
%                     temp=(temp');
%                     Result(i).TrialByTrialPSTH{j}=TrialByTrialPSTH{j};
                    tempb=[TrialByTrialPSTH{:}];i
%                     PSTH=conv(temp,gaussFilter)*1000/(numtrials); %Convolve w/ Gaussian + Correct for 1 ms bin size.
                    PSTH=sum(tempb')*(1000/(numtrials));
                    
%                     keyboard
                     ShortConv=[HighResPSTH{:}];
                     PSTHstd=std(ShortConv')*5;
%                     keyboard;
                    Result(SubplotIDX).PSTH=PSTH;
                    ThirdPSTH(SubplotIDX,:)=PSTH;
                    Result(SubplotIDX).HighResPSTH=HighResPSTH;
%                     Result(SubplotIDX).TrialByTrialPSTH{j}=TrialByTrialPSTH{j};
                    
                    subplot(SubPlotNum,5,[1:4]+((SubplotIDX)*5));                        
                    hold on;
                    PSTHTime=1:1:length(PSTH); %binned into 1ms anyways. 
%                     keyboard
%                     figure;
                    fig=plotyy(PSTHTime,PSTH,PSTHTime,PSTH); %,'color','g');              
%                     hold on;
%                      line(PSTHTime(1:length(PSTHstd)),PSTH(1:length(PSTHstd))+PSTHstd,'color','r'); 
%                      line(PSTHTime(1:length(PSTHstd)),PSTH(1:length(PSTHstd))-PSTHstd,'color','r'); 
%        
                
                    
                    xlim(fig(1),[0 max(T)]);
                    xlim(fig(2),[0 max(T)]);
                    set(fig(1),'xtick',[]);
                    set(fig(2),'xtick',[]);
                    set(fig(1),'ytick',[])
                    set(fig(2),'ytick',[0 max(PSTH)+1],'FontSize',8);
                    ylabel(fig(1),[num2str(ChanList(i,1)) ' : ' num2str(k)],'FontSize',8);
                    ylabel(fig(2),'Hz','FontSize',8);
            end;
    end;
    xlabel('ms');
    set(fig(2),'xtick',[0:100:max(T)],'FontSize',8);
       Result(1).PSTH=PSTHTime;
           
    currdir=cd;
    suptitle(currdir(8:end),8);
    
    save('ResultFile','Result');    
%     savefig('MultiChanPSTHfig');
% 
%       MainPlot=figure;
%     set(MainPlot,'Toolbar','figure')
%     hand=subplot(SubPlotNum,5,[1:4]); 
%     set(gca,'xtick',[]); %,'ytick',[])
%     
%     [S,F,T,P] = spectrogram(song{1},256,250,256,32000);    
%     T=T*1000;
%     surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
%  
%     ylim([0 8000]);
%     xlim([10 max(T)]);
%     view(0,90);
% 
%     
%     gaussFilter = gausswin(15)
%     gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
% 
%     SubplotIDX=1;
%     result.ChanList=ChanList;
%     
%     for i=1:size(ChanList,1)
%                     
% %              WavClus=load(['times_AllSongsChan' num2str(ChanList(i,1)) suffix])            
%             
%             
%                 
%             for k=1:ChanList(i,2) % How many Channels we at? 
%                 
%                     SubplotIDX=SubplotIDX+1;
%                     hand=subplot(SubPlotNum,5,[1:4]+((SubplotIDX)*5));             
%                     set(gca,'xtick',[],'ytick',[])
%                                         
%                     temp=zeros((round(max(T))+900),1); %reset the PSTH w/ a buffer. 
%                         
%                     for j=1:length(endidx)                        
%                         SpkIdx=round(Result(SubplotIDX).WarpedSpikeTimes{j})+1; % get spk times in ms.
%                         temp=zeros((round(max(T))+900),1);
%                         temp(SpkIdx)=1;
%                         
%                         %Convolve w/ Gaussian + Correct for 1 ms bin size.
%                         Result(SubplotIDX).OneTrialConvolvedSpikeTimes{j}=conv(temp,gaussFilter)*1000;
%                         hand=subplot(SubPlotNum,5,[1:4]+((SubplotIDX)*5));                           
%                         hold on;                        
%                         plot(Result(SubplotIDX).OneTrialConvolvedSpikeTimes{j},'k');
% 
%                     end;
%                     xlim([10 max(T)]);
%                     ylabel([num2str(ChanList(i,1)) ' : ' num2str(k)]);
%                     
%                    
%                     
%           
% 
%             end;
%     end;
    
%     Result(1).gaussFilter=gaussFilter;