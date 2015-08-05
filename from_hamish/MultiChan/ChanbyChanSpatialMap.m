
clear Result;

noteinfo=load('AllSongsSongChan.not.mat')
[rawsong Fs]=read_filt('AllSongs.filt');

  load('ChanMap');
  load('ChanList');
  Result(1).ChanList=ChanList;
% Result(1).ChanList=[10 3];
% ChanList=[10 3];
 suffix='.mat';
%  SubPlotNum=sum(ChanList(:,2))+2; % # of Clusters, + 
% SubPlotNum=3;
% Chanlist=[10 2]

filelist=dir('times*')

motif='a';
Result(1).motif=motif;
       
    [starts stops]=regexp(noteinfo.labels,motif);
    
    starttimes=noteinfo.onsets(starts)-50; %Song Chunk w/ 50 ms Buffer
    endtimes=noteinfo.offsets(stops)+50; % w/50ms buffer.
    
     
    endidx=endtimes*(Fs/1000);
    startidx=starttimes*(Fs/1000);
%             keyboard;

    ScaleFactor=(endtimes(1)-starttimes(1))./(endtimes-starttimes);

    numtrials=length(endidx);
%     figure;
    
    for i=1:length(ChanList)

            song{i}=rawsong(startidx(i):endidx(i));    
%             subplot(length(endidx),1,i);
            [S,F,T,P] = spectrogram(song{i},256,250,256,32000);
%             T=T*1000*ScaleFactor(i); %ms
            T=T*1000;
            Result(i).song=song{i};
%             surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
%             view(0,90);    
%             ylim([0 8000]);
        
    end;
        
    clear rawsong;        

    
    
    MainPlot=figure;
    set(MainPlot,'Toolbar','figure')
    hand=subplot(Matrix(1),Matrix(2),1); 
%     set(gca,'xtick',[]); %,'ytick',[])

    
    
    dt=1/Fs;
    dt=dt*1000;
        
%     SongSampleTime=1:length(rawsong)*dt;
    
    [S,F,T,P] = spectrogram(song{1},256,250,256,32000);
    T=T*1000; %ms
    surf(T,F,log10(P),'edgecolor','none'); axis tight; 
    ylim([0 8000]);
    xlim([10 max(T)]);
    view(0,90);

    SubplotIDX=1;
    
        
%     MainPlot=figure;
%     hold on;
    
%     set(MainPlot,'Toolbar','figure')
%     hand=subplot(SubPlotNum,5,[1:4]); 
    hold on;
    set(gca,'xtick',[]); %,'ytick',[])
    
    [S,F,T,P] = spectrogram(song{1},256,250,256,32000);    
    T=T*1000;
    surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
 
    ylim([0 8000]);
    view(0,90);
    
    gaussFilter = gausswin(15)
    gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
% 
     SubplotIDX=1;
    
    for i=1:size(ChanList,1)
        disp(i);
            for k=1:ChanList(i,2) % How many Channels we at? 
               
                    SubplotIDX=SubplotIDX+1;    
                    subplot(Matrix(1),Matrix(2),ChanList(i,1));              
                    hold on;
                    set(gca,'xtick',[],'ytick',[])
                                        
                    temp=zeros((round(max(T))+900),1); %reset the PSTH w/ a buffer. 
                    numtrials=length(endidx);
                        
                    for j=1:numtrials                     
                        SpkIdx=round(Result(SubplotIDX).WarpedSpikeTimes{j})+1; % get spk times in ms.       
                        temp(SpkIdx)=temp(SpkIdx)+1; % + sum them across their indices (in ms). 

                    end;

                    
                    PSTH=conv(temp,gaussFilter)*1000/(numtrials); %Convolve w/ Gaussian + Correct for 1 ms bin size.
                    Result(SubplotIDX).PSTH=PSTH;
                    subplot(SubPlotNum,5,[1:4]+((SubplotIDX)*5));                        
                    hold on;
                    plot(PSTH,'r')
% 
                    xlim([0 max(T)]);
                    ylabel([num2str(ChanList(i,1)) ' : ' num2str(k)]);

            end;
    end;
        
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
    save('ResultFile','Result');