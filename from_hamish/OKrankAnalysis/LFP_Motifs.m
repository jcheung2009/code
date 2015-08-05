clear;

[filename dirname]UIgetfile('*.rec');

filename=filename(1:end-4);

motif='abc';
ref=6;

if (exist([filename '.not.mat'])==2)
    noteinfo=load([filename '.not.mat']);
    starts=find(noteinfo.labels==motif(1));
    stops=find(noteinfo.labels==motif(end));
    goodstops=[];
    crap=0;
    i=1;
    while ~isempty(crap)
        try
            crap=find(stops>starts(i))
            goodstops=[goodstops stops(crap(1))];
            i=i+1;
        catch
        end;
    end;

    stops=goodstops;

end;


for j=1:length(stops)
    
    [sound Fs,ChanNo]=ReadOKrankData(dirname,filename,1);
    
    endidx=noteinfo.offsets(stops) * (Fs/1000); %.*Fs;
    startidx=noteinfo.onsets(starts) * (Fs/1000); %.*Fs;       
       
    
    sound=sound(endidx(j):endidx(j));
    figure;
    hand=subplot(ChanNo,1,1);
    set(gca,'xtick',[],'ytick',[])
    ylim([3.5 6.5]);
    hold on;

    [refsig Fs,ChanNo]=ReadOKrankData(dirname,filename,ref);
    dt=1/Fs;
    dt=dt*1000;
    time=0:dt:dt*length(sound)-dt;
    plot(time,sound);axis tight;

    for i=2:ChanNo

        [data Fs]=ReadOKrankData(dirname,filename,i);

%          Fs=Fs/40;
%          data=decimate(data,40);

        data=data-mean(data);
        
        nfft=round(Fs*8/1000);
        nfft = 2^nextpow2(nfft);
        spect_win = hanning(nfft);
        noverlap = round(0.9*length(spect_win)); %number of overlapping points    

        [S,F,T,P]=Spectrogram(data,spect_win,nfft,noverlap,Fs);
        keyboard
    %     P=P./F;
        subplot(ChanNo,1,i);
        title(num2str(i));
    %     P=P/max(P);
        surf(T,F,P,'edgecolor','none'); axis tight; 
    %     colormap('gray');
        view(0,90);
        ylim([0 40]); 
    %     ylim([3.5 6.5]);
        set(gca,'xtick',[],'ytick',[])

    end;
    set(gca,'xtickMode', 'auto')




end