[filename dirname]=UIgetfile('*.rec');

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
            goodstops=[goodstops crap(1)];
            i=i+1;
        catch
        end;
    end;

    stops=goodstops;
    
end;

[sound Fs,ChanNo]=ReadOKrankData(dirname,filename,1);
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
%     data=data-ref;

    
    Fs=Fs/40;
    data=decimate(data,40);
    
    
    data=data-mean(data);
% 
%     [a b]=butter(8,[(50/(Fs/2)) (70/(Fs/2))],'stop');
%     data=filtfilt(b,a,data);
    
    [S,F,T,P]=Spectrogram(data,128,120,128,Fs);
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

    


