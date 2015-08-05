%     clear;
%     
    load ResultFile;
    load ChanList;
    
    clear temp;
    Fs=30000;
    suffix='.mat';
      
    MainPlot=figure;    
    currdir=cd;
    title(currdir(8:end));
    set(MainPlot,'Toolbar','figure')
    set(MainPlot,'Color',[1 1 1]);

    SubPlotNum=Result(1).numtrials+5; 

    hand=subplot(SubPlotNum,5,[1:20]); 
    
    title(currdir);
%     set(gca,'xtick',[]); %,'ytick',[])

%     SubPlotNum=sum(ChanList(:,2))+2; % # of Clusters, + 
        
    

    dt=1/Fs;
    dt=dt*1000;
        
%     SongSampleTime=1:length(rawsong)*dt;
%     
    filtsong = bandpass(Result(1).song,Fs,300,10000);
    [S,F,T,P] = spectrogram(Result(1).song,256,250,256,Fs);
    cm=colormap(gray) ; %make_map(-50,10,1.2);
    cm(1:50,:)=0;
    dtcm=1/50;
    cm(51:100,1)=dtcm:dtcm:1;
    cm(51:100,2)=dtcm:dtcm:1;
    cm(51:100,3)=dtcm:dtcm:1;
    cm(51:100,3)=exp(cm(51:100,1)-1)
    cm(51:100,2)=exp(cm(51:100,1)-1)
    cm(51:100,1)=exp(cm(51:100,1)-1)
    colormap(cm)
    
    T=T*1000; %ms
    surf(T,F,log10(P),'edgecolor','none'); axis tight; 
    ylim([0 8000]);
    xlim([10 max(T)]);
    view(0,90);
%     keyboard;
    ColorSet = varycolor(sum(ChanList(:,2))); %e.g. get # of cells for plotting colors. 
    ResultIdx=1;
    
    %Set Windows. 
    gaussFilter = gausswin(5); %gausswin(Result(1).GaussianWindow);
    gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
%     FastgaussFilter = gausswin(5);
%     FastgaussFilter = FastgaussFilter/sum(FastgaussFilter);
    
temp=zeros(1000,Result(1).numtrials+2);
    
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
                        SubplotIDX=j+4;
                        
                        SpkIdx=round(Result(ResultIdx).WarpedSpikeTimes{j})+1; % get spk times in ms.   
                     
                        temp(SpkIdx,j)=temp(SpkIdx,j)+1; % + sum them across their indices (in ms). 
                        
                        CrossCellPSTH{ResultIdx,j}=conv(temp(:,j),gaussFilter)*2; 
%                         HighResCrossCellPSTH{j}=conv(temp(:,j),FastgaussFilter)*2;
                        

                        
                        set(gca,'xtick',[],'ytick',[]);
                   
                        hand=subplot(SubPlotNum,5,[1:5]+((SubplotIDX)*5));      
                        hold on;

                        plot(CrossCellPSTH{ResultIdx,j},'Color',ColorSet(ResultIdx-1,:));
                        
                        ylabel(num2str(j),'FontSize',6);
                                            
                    xlim([10 max(T)]);
%                     ylim([0 (ResultIdx)*1]);

                    end;
                    
                 
                    xlim([10 max(T)]);
                    ylim([0 (ResultIdx)*1]);

                    
             
            end;
           
    end;

    %Calculate CCs
    
     for i=1:Result(1).numtrials;
         t=[CrossCellPSTH{:,i}];
         CC=zeros(size(t,2),size(t,2));
         for j=1:size(t,2);
             for k=j:size(t,2);
                CCORR=xcorr(t(:,j),t(:,k),'Coeff');      
%                 keyboard;
                CC(j,k)=CCORR(round(0.5*length(CCORR)));
             end;
         end;
         
         a=find(CC==0);
         CC(a)=NaN;
         a=find(CC>=1);
         CC(a)=NaN;
         
          
         TrialCC(i)=nanmean(nanmean(CC));         
         hand=subplot(SubPlotNum,5,[1:5]+((i+4)*5));
         ShortCC=num2str(TrialCC(i));
%          ShortCC=ShortCC(1:5)
         
         text(-50,1,['CC=' ShortCC],'FontSize',8);
%          keyboard
         
         hold on;
         
     end;
     TrialCC=TrialCC'
     Result(1).TrialCC=TrialCC;  
    currdir=cd;
    suptitle(currdir(8:end),8);
    
%     Result(1).TrialCC=TrialCC;
%      save Resultfile Result;
%     savefig('MultiChanRastfig');
%         keyboard;