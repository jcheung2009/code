clear;

[filename dirname]=uigetfile('*.rhd');

% filename=filename(1:end-4);

motif='abc';
% ref=6;

high_f=250; %make Filters;
low_f=1;
nyq=30000/2;
[q r]=butter(8,[low_f/nyq high_f/nyq]);
    
if (exist([filename '.not.mat'])==2)
    noteinfo=load([filename '.not.mat']);
    [starts stops]=regexp(noteinfo.labels,motif);
end;

[amplifier_data,t_amplifier,Fs,filedata,song]=IntanRHDImportAll(dirname,filename);

figure;

%           Fs=Fs/20;
          
for j=1:length(stops)
    
%     [sound Fs,ChanNo]=ReadOKrankData(dirname,filename,1);

    
    endidx=noteinfo.offsets(stops) * (Fs/1000); %.*Fs;
    startidx=noteinfo.onsets(starts) * (Fs/1000); %.*Fs;       
       
    
    sound=song(startidx(j):endidx(j));
    figure;
    
%     hand=subplot(8+1,1,1);
    hand=subplot(filedata.num_amplifier_channels+1,1,1);
    
    
%     [refsig Fs,ChanNo]=ReadOKrankData(dirname,filename,ref);
    
    dt=1/Fs;
    dt=dt*1000;
%     time=0:dt:dt*length(sound)-dt;
%     plot(time,sound);axis tight;
    [S,F,T,P] = spectrogram(sound,256,250,256,30000);
    surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
    view(0,90);
    songXLims=xlim;
    set(gca,'xtick',[],'ytick',[])


    for i=1:filedata.num_amplifier_channels

%         load(['AllSongsChan' num2str(i)]);
%         [data Fs]=ReadOKrankData(dirname,filename,i);
        data=amplifier_data(i,startidx(j):endidx(j));
%         keyboard
%         data=filtfilt(q,r,data); 
%         decimate(data,150);

           data=decimate(data,10);

        data=data-mean(data);
        
        nfft=round(Fs/10*8/1000);
        nfft = 2^nextpow2(nfft);
        spect_win = hanning(nfft);
        noverlap = round(0.9*length(spect_win)); %number of overlapping points    

%         [S,F,T,P]=spectrogram(data,spect_win,noverlap,nfft,Fs);
        [S,F,T,P]=spectrogram(data,256,250,256,3000);

    %     P=P./F;
%         subplot(8+1,1,i+1);
        subplot(filedata.num_amplifier_channels+1,1,i+1);
        
%         title(num2str(i));
    %     P=P/max(P);
        surf(T,F,P,'edgecolor','none'); axis tight; 
    %     colormap('gray');
        view(0,90);
        ylim([0 50]); 
    %     ylim([3.5 6.5]);
        set(gca,'xtick',[],'ytick',[]);

    end;
    set(gca,'xtickMode', 'auto')




end