% 
clear;
% clear Result;
% delete('ResultFile.mat');

noteinfo=load('AllSongsSongChan.not.mat');
[rawsong Fs]=read_filt('AllSongs.filt');

  load('ChanList_Song');
%  load('LMANChanList')
Result(1).ChanList=ChanList;


suffix='.mat';
SubPlotNum=sum(ChanList(:,2))+2; % # of Clusters, + 


filelist=dir('times*')

% load ChanMap;
load Motif;

%  motif='0abcabcabc'

%  motif=Motif;
%  Result(1).motif=motif;
        
%       [starts stops]=regexp(noteinfo.labels,'0000abc'); %abcabc');
  [starts stops]=regexp(noteinfo.labels,motif); %abcabc');
  
    [starts stops]=regexp(noteinfo.labels,motif);
   

%       starts=starts;
    
    starttimes=noteinfo.onsets(starts)-50; %Song Chunk w/ 50 ms Buffer
    endtimes=noteinfo.offsets(stops)+50; % w/50ms buffer.
    

     
    endidx=endtimes*(Fs/1000);
    startidx=starttimes*(Fs/1000);
%             keyboard;

    ScaleFactor=(endtimes(1)-starttimes(1))./(endtimes-starttimes);

    numtrials=length(endidx);
    Result(1).numtrials=numtrials;
%     figure;
    
% clear song;

    for i=1:Result(1).numtrials; %length(ChanList)

            song{i}=rawsong(startidx(i):endidx(i));    
%             subplot(length(endidx),1,i);
            [S,F,T,P] = spectrogram(song{i},256,250,256,Fs);
%             T=T*1000*ScaleFactor(i); %ms
            T=T*1000;
            Result(i).song=song{i};
%             surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
%             view(0,90);    
%             ylim([0 8000]);
        
    end;
        
    result(1).T=T;
    clear rawsong;        
    
    save('ResultFile','Result');

%     keyboard;

    MultiChan_Rasters;
    save('ResultFile','Result');
    

    MultiChan_PSTH; 
    save('ResultFile','Result');
    
   
    MapBySite_PSTH;
    save('ResultFile','Result');    
   
    MapBySite_Rasters;
    save('ResultFile','Result');
    
    % TrialbyTrialCorrelations;
%     MultiTrial_Rasters;
%     
%     MultiTrial_PSTH;
    