     clear;
%   
    suffix='.mat';
    load ResultFile;
    load ChanList;
%     load Motif;
motif='abcabcabc'
[rawsong Fs]=read_filt('AllSongs.filt');


    
    noteinfo=load('AllSongsSongChan.not.mat')
    [starts stops]=regexp(noteinfo.labels,motif); %abcabc');
    numtrials=length(stops);
%     [starts stops]=regexp(noteinfo.labels,motif);
%     starts=starts+7;

    starttimes=noteinfo.onsets(starts)+100; %Song Chunk w/ 50 ms Buffer
    endtimes=noteinfo.offsets(stops)+0; % w/50ms buffer.
%     Fs=30000;
    
    endidx=endtimes*(Fs/1000);
    startidx=starttimes*(Fs/1000);
    
   clear temp;

      
    MainPlot=figure;    
    currdir=cd;
    title(currdir(8:end));
    set(MainPlot,'Toolbar','figure')
    set(MainPlot,'Color',[1 1 1]);

    SubPlotNum=length(ChanList)+1;

    hand=subplot(SubPlotNum,5,[1:20]); 
    
    title(currdir);
%     set(gca,'xtick',[]); %,'ytick',[])



    dt=1/Fs;
    dt=dt*1000;
        
    for i=1:numtrials

            song{i}=rawsong(startidx(i):endidx(i));    
%             subplot(length(endidx),1,i);
%             [S,F,T,P] = spectrogram(song{i},1024,768,1024,Fs);
% %             T=T*1000*ScaleFactor(i); %ms
%             T=T*1000;
             Result(i).song=song{i};
% %             surf(T,F,10*log10(P),'edgecoTlor','none'); axis tight; 
%             view(0,90);    
%             ylim([0 8000]);
        
    end;    
    
  
    filtsong = bandpass(Result(1).song,Fs,300,10000);
%     [S,F,T,P] = spectrogram(Result(1).song,512,500,512,Fs);
    [S,F,T,P] = spectrogram(Result(1).song,128,124,2048,Fs);
%     cm=colormap(gray) ; %make_map(-50,10,1.2);
%     cm(1:50,:)=0;
%     dtcm=1/50;
%     cm(51:100,1)=dtcm:dtcm:1;
%     cm(51:100,2)=dtcm:dtcm:1;
%     cm(51:100,3)=dtcm:dtcm:1;
%     cm(51:100,3)=exp(cm(51:100,1)-1)
%     cm(51:100,2)=exp(cm(51:100,1)-1)
%     cm(51:100,1)=exp(cm(51:100,1)-1)
%     colormap(cm)
    
   subplot(SubPlotNum,5,[1:5]); 
    T=T*1000; %ms
    surf(T,F,log10(P),'edgecolor','none'); axis tight; 
    ylim([0 8000]);
    xlim([10 max(T)]);
    view(0,90);
    hold on;
    
    clear Result;
    
%     temp=zeros(length(P,1)+300,1);
%     
    dwnsmp=20;
    
    WnLow=150/(Fs/2);
    [b,d] = butter(2,WnLow,'low')
    WnHigh=5/(Fs/2);
    [e,f]=butter(2,WnHigh,'high');
    
    numtrials=length(endidx);

    for i=1:numtrials; 
                   
            datafname=['AllSongsChan' num2str(ChanList(i,1)) '.mat'];
            load(datafname);
            
%             AvgLFP=zeros(1025,8000);
            figure; title(['Trial : ' num2str(i)]);
    
            for j=1:size(ChanList,1); 
                

                    v{j}=data(startidx(i):endidx(i));    
                    v{j}=filtfilt(b,d,v{j});
                    v{j}=filtfilt(e,d,v{j});
                    
                    v{j}=downsample(v{j},dwnsmp);
%                     v{j}=[zeros(1,1000) v{j} zeros(1,1000)];
                    
                    [S,F,T,P] = spectrogram(v{j},128,124,2048,Fs/dwnsmp);
%                     [S,F,T,P] = spectrogram(Result(1).song,Fs);
        %             T=T*1000*ScaleFactor(i); %ms
                    T=T*1000;                    
                    Result(i).lfp{j}=P;
                    Result(i).lfpT{j}=T;
                    Result(i).lfpF{j}=F;
                    

                      mtxsize=size(P);
                      
                 set(gca,'xtick',[],'ytick',[]);
%                    
                hand=subplot(SubPlotNum,5,[1:5]+((i)*5));  %numtrials subplots. 
                surf(T,F,(P),'edgecolor','none'); axis tight;                 


            end;
            
            
%             LFPlot=AvgLFP./j;
            LFPlot=LFPlot(:,1:length(T));
%             Result(i).AvgLFP=LFPlot;

                   
           set(gca,'xtick',[],'ytick',[]);
%                    
           hand=subplot(SubPlotNum,5,[1:5]+((i)*5));  %numtrials subplots. 
            surf(T,F,(LFPlot),'edgecolor','none'); axis tight; 
%             brighten(0.25);
%               cmap = contrast(LFPlot);
%             image(X); 
%               colormap(cmap);
            ylim([5 200]);
           
           
            hold on;
            ylabel(num2str(ChanList(i,1)),'FontSize',6);
%                                             
%             xlim([10 max(T)]);
           view(0,90);
% %                     ylim([0 (ResultIdx)*1]);
% 

    end;
    

    %Calculate CCs
%     
%      for i=1:Result(1).numtrials;
%          t=[CrossCellPSTH{:,i}];
%          CC=zeros(size(t,2),size(t,2));
%          for j=1:size(t,2);
%              for k=j:size(t,2);
%                 CCORR=xcorr(t(:,j),t(:,k),'Coeff');      
% %                 keyboard;
%                 CC(j,k)=CCORR(round(0.5*length(CCORR)));
%              end;
%          end;
%          
%          a=find(CC==0);
%          CC(a)=NaN;
%          a=find(CC>=1);
%          CC(a)=NaN;
%          
%           
%          TrialCC(i)=nanmean(nanmean(CC));         
%          hand=subplot(SubPlotNum,5,[1:5]+((i+4)*5));
%          ShortCC=num2str(TrialCC(i));
% %          ShortCC=ShortCC(1:5)
%          
%          text(-50,1,['CC=' ShortCC],'FontSize',8);
% %          keyboard
%          
%          hold on;
%          
%      end;
%      TrialCC=TrialCC'
%      Result(1).TrialCC=TrialCC;  
%     currdir=cd;
%     suptitle(currdir(8:end),8);
    
%     Result(1).TrialCC=TrialCC;
%      save Resultfile Result;
%     savefig('MultiChanRastfig');
%         keyboard;