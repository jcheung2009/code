   load ResultFile;
    
    ChanList=Result(1).ChanList+1;
    load ChanMap;
    
    
    noteinfo=load('AllSongsSongChan.not.mat')
%     [rawsong Fs]=read_filt('AllSongs.filt');

    load Motif;
    load Fs;
    
    [starts stops]=regexp(noteinfo.labels,motif);


    PlotSize=[8 4];
    

    endidx=noteinfo.offsets(stops) * (Fs/1000); %.*Fs;
    startidx=noteinfo.onsets(starts) * (Fs/1000); %.*Fs;  
    
%     Fs=Fs;

    WnLow=150/(Fs/2);
    [b,d] = butter(4,WnLow,'low')
    WnHigh=2/(Fs/2);
    [e,f]=butter(4,WnHigh,'high');
    
    for j=1:1; %length(stops)
        figure;
         subplot(PlotSize(1),PlotSize(2),1);
        
    
        for i=1:32;

             [idx]=find(SiteMap==i-1)
             
             
            data=load(['AllSongsChan' num2str(i)]);
             

            data=data.data(startidx(j):endidx(j));
            data=filtfilt(b,d,data);
            data=filtfilt(e,f,data);

                    
                    v{j}=downsample(data,10);
%                 ChIdx=ChIdx+1;

             data=decimate(data,10);

%             data=data-mean(data);

            nfft=round((Fs/10)*8/1000);
            nfft = 2^nextpow2(nfft);
            spect_win = hanning(nfft);
            noverlap = round(0.9*length(spect_win)); %number of overlapping points    

    %         [S,F,T,P]=spectrogram(data,spect_win,noverlap,nfft,Fs);
            [S,F,T,P]=spectrogram(data,256,250,2028,(30000/10));
             subplot(PlotSize(1),PlotSize(2),idx);
             surf(T,F,(P),'edgecolor','none'); axis tight; 
            view(0,90);
            songXLims=xlim;
%             (num2str(i),,'FontSize',6);
            
            
             set(gca,'xtick',[]); %,'ytick',[])

    %             plot(Result(ChIdx).PSTH,'color',colorIDX{k});
%                 title(['Ch: ' num2str(ChanList(i))]);
                hold on;

%                    ylim([0 MaxFreq]);                
                   if mod(idx,PlotSize(2))~=1   
                        set(gca,'ytick',[]); %,'ytick',[]);    
%                         ylim([0 250]);                         
                   else
                         set(gca,'ytick',[0 100]);
%                          ylim([0 250]); 
%                        ylabel('rate');
                   end;
                   if idx>(PlotSize(1)*PlotSize(2)-PlotSize(1)); %e.g. last row
%                        xlim([10 max(T)]);
                   else                 
%                        xlim([10 max(T)]);
                       set(gca,'xtick',[]);
                   end;



    %             set(gca,'xtick',[],'ytick',[]);

                 ylim([0 250]);


        end;
    end;
%     savefig('MapChanPSTHfig');
    