function [LFPs]=ChunkDataToChannelSongBySongLFPs

load FilDir;
ffreq=temp;

load ChanList;
LFPband=[40 80]; % gamma

[filename dirname]=UIgetfile('*.rec');

filename=filename(1:end-4);

motif='ab';
ref=6;

if (exist([filename '.not.mat'])==2)
    noteinfo=load([filename '.not.mat']);
    starts=find(noteinfo.labels==motif(1));
    stops=find(noteinfo.labels==motif(end));
    goodstops=[];
    crap=0;
   [starts stops]=regexp(noteinfo.labels,motif);

end;

    [sound Fs,ChanNo]=ReadOKrankData(dirname,filename,1);
    
    endidx=noteinfo.offsets(stops) * (Fs/1000); 
    startidx=noteinfo.onsets(starts)* (Fs/1000); 

    endidx=endidx+1500;
    startidx=startidx-1500;
    
%     keyboard;
    
for j=1:length(endidx)


    
    song{j}=sound(startidx(j):endidx(j));
    
    MainPlot=figure;
    set(MainPlot,'Toolbar','figure')
    hand=subplot(size(ChanList,1),1,1)
    set(gca,'xtick',[],'ytick',[])
    title(['Song ' num2str(j) '    ffreq ' num2str(ffreq(j))]);        
    xlim([0 0.3]);
    
    
    dt=1/Fs;
    dt=dt*1000;
    
    [S,F,T,P] = spectrogram(song{j},256,250,256,Fs);
    surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
    view(0,90);
%     keyboard;
%     time=0:dt:dt*length(song{j})-dt;
%     plot(time,song{j});
    set(gca,'xtick',[],'ytick',[])
%     AllWaveForms=zeros(31,1);
    
    LFP=[]
    cnt=0;
    
    for i=ChanList(:,1)'
        cnt=cnt+1;
        disp(i)
%         keyboard
        [RawData Fs]=ReadOKrankData(dirname,filename,i);    
        data=RawData(startidx(j):endidx(j)); 
        data=decimate(data,40);
%         subplot((length(endidx)+2),4,([1:4]+([4].*(j))));         
        FsDec=Fs/40;
        
        time=(dt:dt:dt*length(data))';
        [S,F,T,P] = spectrogram(data,25,23,128,FsDec);
        
%         surf(T,F,P,'edgecolor','none'); axis tight; 
%         view(0,90);
                
        LFP(cnt,:)=sum((P(8:14,:)));
%         subplot(ChanNo,1,i);
%         plot(T,LFP{i,j});

        
%         ylim([0 250]);
%         xlim([0 0.25])
%           keyboard;;
%         set(gca,'xtick',[],'ytick',[])
    end;
%     keyboard;
    subplot(size(ChanList,1),1,2:size(ChanList,1))

%      keyboard
    surf(T,1:length(LFP(:,1)),LFP(1:end,:)); %,'CLim',[0 0.05])
    set(gca,'CLim',[0 0.03]);
    view(0,270);
%     keyboard
    axis('tight')    
    set(gca,'xtickMode', 'auto')
    title(['Song ' num2str(j) '    ffreq ' num2str(ffreq(j))]);        
%     colorbar;
    xlim([0.0 0.3]);
    
%     keyboard;
% %     
%     figure;
%     hold on;
%     
%     ZeroXCorr=zeros(32,32);
%     
%     title(['Song ' num2str(j) '    ffreq ' num2str(ffreq(j))]);        
%     
%     for k=2:size(LFP,1);
%         for l=k:size(LFP,1)
%         [XCorrFull lags]=xcorr(LFP(k,:),LFP(l,:),'coeff');
%         ZeroXCorr(k,l)=XCorrFull(round(length(XCorrFull)/2)); 
%         
%         end;
%     end;
%     surf((ZeroXCorr))
%     view(180,90);
%     axis('tight')
%     colorbar;
%     title(['Song ' num2str(j) '    ffreq ' num2str(ffreq(j))]);        
    
%     
%     subplot((length(endidx)+2),4,((length(endidx)+2)*4)-3);
%     plot(AllWaveForms,'k');
%     hold on;    
%     plot(mean(AllWaveForms'),'r','LineWidth',4);
%     [y]=ylim;
%     if y(2) < 1
%         ylim([-1 1]);
%     end;
%     STDRatio=mean(max(AllWaveForms))/std(data);
%     title(num2str(STDRatio));
%     
%     subplot((length(endidx)+2),4,((length(endidx)+2)*4)-2);  
%     plot(min(AllWaveForms),max(AllWaveForms),'ko');
%     [x]=xlim;
%     if x(2)<1
%         xlim([-1 0.25]);
%     end;
%     [y]=ylim;
%     if y(1) > -0.5
%         ylim([-0.25 1]);
%     end;
%        
%     hObject=uicontrol('Style', 'pushbutton','String', 'Export','Position', [450 00 100 50],'Callback', {@ButtonPressed, i, dirname, filename,startidx, endidx,T,F,P});     
%     set(hObject,'Units','Points')               % Was normalized
%     panelSizePts = get(hObject,'Position');     % Now in points
%     panelHeight = panelSizePts(4);
%     set(hObject,'Units','normalized'); 
end

function ButtonPressed(hObject,eventdata,i,dirname,filename,startidx,endidx,T,F,P)
    
    SaveFileName=[dirname filename '.SpikeData.mat'];
    if exist(SaveFileName);
        load(SaveFileName);
    end;
    
        
    AllWaveForms=[];
    
    disp(num2str(i)) % Display Channel #
    [RawData Fs]=ReadOKrankDataFilt(dirname,filename,i,600,9000);    
    
    for j=1:length(endidx)
              
        data=RawData(startidx(j):endidx(j));                        

        [Freq{i,j} ISIs{i,j} Times{i,j} Events{i,j} WaveForms{i,j} ]=FindSpikes(data,Fs,0);

        AllWaveForms=[AllWaveForms WaveForms];
        
        WarpedTimes{i,j}=Times{i,j}.*((startidx(j)-endidx(j))/(startidx(1)-endidx(1)));
        
    end;
    
    save(SaveFileName, 'Freq', 'ISIs', 'Times', 'Events', 'WaveForms', 'WarpedTimes','T','F','P');

