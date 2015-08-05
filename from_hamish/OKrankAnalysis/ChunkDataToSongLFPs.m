clear;

[filename dirname]=UIgetfile('*.rec');

filename=filename(1:end-4);

motif='abcc';
% ref=6;
load('CM32_A1x32Map_ReMapped.mat')
   offset=-1; 
                        offset=15;
       
if (exist([filename '.not.mat'])==2)
    noteinfo=load([filename '.not.mat']);
    starts=find(noteinfo.labels==motif(1));
    stops=find(noteinfo.labels==motif(end));
    goodstops=[];
    crap=0;
   [starts stops]=regexp(noteinfo.labels,motif)

end;


for j=1:length(stops)
    
    [sound, Fs, ChanNo]=ReadOKrankData(dirname,filename,1);
    
    endidx=noteinfo.offsets(stops) * (Fs/1000); 
    startidx=noteinfo.onsets(starts)* (Fs/1000); 
       
    
    song{j}=sound(startidx(j):endidx(j));
    
    figure(j+1);
    
    set(gcf,'Units','normal')
    set(gca,'Position',[.05 .05 .9 .9])
%     title([filename ' song ' num2str(j)]);
    hold on;
    hand=subplot(33,1,1); 
    
%     dt=1/Fs;
%     dt=dt*1000;
    
    [S,F,T,P] = spectrogram(song{j},256,250,256,Fs);
    surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
    view(0,90);
    songXLims=xlim;
    set(gca,'xtick',[],'ytick',[])
    


    for i=2:ChanNo

    [RawData Fs]=ReadOKrankData(dirname,filename,i);       
%     
%         for j=1:length(endidx)
            padSpect=3000; 

            data=RawData(startidx(j)-padSpect:endidx(j)+padSpect); 
            data=decimate(data,40);
            
            ProbeSite=(ChanMatrix(i+offset,1)); %e.g. map to probe location. 
            ProbeSpace=ChanMatrix(i+offset,2);
            
            
            subplot(33,1,ProbeSite+1);  
%           set(gca,'xtick',[],'ytick',[])
            
            [S,F,T,P] = spectrogram(data,25,23,128,Fs/40); 
            T=T-padSpect/Fs;            
            surf(T,F,P,'edgecolor','none'); axis tight; 
            
            view(0,90);
             ylim([0 50]);
             xlim(songXLims);
               ylabel(num2str(ProbeSpace),'FontName','FixedWidth','FontSize',8);
%              ylabel(num2str(ChanMatrix(i+offset,1)),'FontName','FixedWidth','FontSize',8);
%              ylabel(num2str(i),'FontName','FixedWidth','FontSize',8);
            set(gca,'xtick',[]); %'FontName','FixedWidth','FontSize',8)  

%         end;
    


    end
%        subplot(32,1,32)      
%        set(gca,'xtick', 'auto')

end
% title(filename); 