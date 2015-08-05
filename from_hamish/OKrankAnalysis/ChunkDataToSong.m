clear;

[filename dirname]=UIgetfile('*.rec','MultiSelect','on');

filename=filename(1:end-4);

motif='abcdefg';
ref=6;

if (exist([filename '.not.mat'])==2)
    noteinfo=load([filename '.not.mat']);
    starts=find(noteinfo.labels==motif(1));
    stops=find(noteinfo.labels==motif(end));
    goodstops=[];
    crap=0;
   [starts stops]=regexp(noteinfo.labels,'abc')

end;


for j=1:length(stops)
    
    [sound Fs,ChanNo]=ReadOKrankData(dirname,filename,1);
    
    endidx=noteinfo.offsets(stops) * (Fs/1000); 
    startidx=noteinfo.onsets(starts)* (Fs/1000); 
       
    
    song{j}=sound(startidx(j):endidx(j));
    
    figure;
    hand=subplot(ChanNo,1,1); 
    set(gca,'xtick',[],'ytick',[])

    dt=1/Fs;
    dt=dt*1000;
    
    time=0:dt:dt*length(song{j})-dt;
    plot(time,song{j});
    set(gca,'xtick',[],'ytick',[])


    for i=2:ChanNo

        [data Fs]=ReadOKrankDataFilt(dirname,filename,i,900,9000);
        
        subplot(ChanNo,1,i);

        plot(time',data(startidx(j):endidx(j)));

        set(gca,'xtick',[],'ytick',[])
        
    end;
    
    set(gca,'xtickMode', 'auto')




end