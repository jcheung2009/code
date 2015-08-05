 function ChunkDataToSongChannelByChannel

global threshold;
threshold=5;

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
    [starts stops]=regexp(noteinfo.labels,'ab')

end;

    [sound Fs,ChanNo]=ReadOKrankData(dirname,filename,1);
    
    endidx=noteinfo.offsets(stops) * (Fs/1000); 
    startidx=noteinfo.onsets(starts)* (Fs/1000); 

    
for i=2:ChanNo
    
    j=1
       
    
    song{j}=sound(startidx(j):endidx(j));    
    MainPlot=figure;
    set(MainPlot,'Toolbar','figure')
    hand=subplot((length(endidx)+2),4,[1:4]); 
    set(gca,'xtick',[],'ytick',[])

    dt=1/Fs;
    dt=dt*1000;
    
    [S,F,T,P] = spectrogram(song{j},256,250,256,1E3);
    surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
    view(0,90);
    
%     time=0:dt:dt*length(song{j})-dt;
%     plot(time,song{j});
    set(gca,'xtick',[],'ytick',[])
    AllWaveForms=zeros(31,1);
    [RawData Fs]=ReadOKrankDataFilt(dirname,filename,i,900,9000);       
    
    for j=1:length(endidx)
        
        
        data=RawData(startidx(j):endidx(j));
        
        subplot((length(endidx)+2),4,([1:4]+([4].*(j))));         
        
        time=(dt:dt:dt*length(data))';
        plot(data);
        hold on;
        [a b c Events WaveForms ]=FindSpikes(data,Fs,threshold,0);
        set(gca,'xtick',[],'ytick',[]);       
        if ~isempty(Events)
            plot(Events,0.5,'rx')
        end;
        AllWaveForms=[AllWaveForms WaveForms];
        
    end;
    
    set(gca,'xtickMode', 'auto')
    
    subplot((length(endidx)+2),4,((length(endidx)+2)*4)-3);
    plot(AllWaveForms,'k');
    hold on;    
    plot(mean(AllWaveForms'),'r','LineWidth',4);
    [y]=ylim;
    if y(2) < 1
        ylim([-1 1]);
    end;
    STDRatio=mean(max(AllWaveForms))/std(data);
    title(num2str(STDRatio));
    
    subplot((length(endidx)+2),4,((length(endidx)+2)*4)-2);  
    plot(min(AllWaveForms),max(AllWaveForms),'ko');
    [x]=xlim;
    if x(2)<1
        xlim([-1 0.25]);
    end;
    [y]=ylim;
    if y(1) > -0.5
        ylim([-0.25 1]);
    end;
       
    hObject=uicontrol('Style', 'pushbutton','String', 'Export','Position', [450 00 100 50],'Callback', {@ButtonPressed, i, dirname, filename,startidx, endidx,T,F,P});     
    set(hObject,'Units','Points')               % Was normalized
    panelSizePts = get(hObject,'Position');     % Now in points
    panelHeight = panelSizePts(4);
    set(hObject,'Units','normalized'); 
    
    hObject=uicontrol('Style', 'pushbutton','String', 'Recalculate','Position', [350 00 50 50],'Callback', {@Rethreshold, i, dirname, filename,startidx, endidx,T,F,P});     
    set(hObject,'Units','Points')               % Was normalized
    panelSizePts = get(hObject,'Position');     % Now in points
    panelHeight = panelSizePts(4);
    set(hObject,'Units','normalized'); 
end

function ButtonPressed(hObject,eventdata,i,dirname,filename,startidx,endidx,T,F,P)
    
    
    global threshold;
    SaveFileName=[dirname filename '.SpikeData.mat'];
    if exist(SaveFileName);
        load(SaveFileName);
    end;
    
        
    AllWaveForms=[];
    
    disp(num2str(i)); % Display Channel #
    [RawData Fs]=ReadOKrankDataFilt(dirname,filename,i,600,9000);    
    
    for j=1:length(endidx)
              
        data=RawData(startidx(j):endidx(j));                        

        [Freq{i,j} ISIs{i,j} Times{i,j} Events{i,j} WaveForms{i,j} ]=FindSpikes(data,Fs,threshold,0);

        AllWaveForms=[AllWaveForms WaveForms];
        
        WarpedTimes{i,j}=Times{i,j}.*((startidx(1)-endidx(1))/(startidx(j)-endidx(j))); % Scale relative to the example song + first data trace.
        
    end;
    
    save(SaveFileName, 'Freq', 'ISIs', 'Times', 'Events', 'WaveForms', 'WarpedTimes','T','F','P');

    function Rethreshold(hObject,eventdata,i,dirname,filename,startidx,endidx,T,F,P)
        
        global threshold;

        [RawData Fs]=ReadOKrankDataFilt(dirname,filename,i,600,9000);    
        
        dt=1/Fs;
        
        prompt={'New Threshold Value?'};
        name='New Threshold Value';
        numlines=1;
        defaultanswer={num2str(threshold)};
        answer=inputdlg(prompt,name,numlines,defaultanswer)
        threshold=str2num(answer{1});

%         threshold=str2num(answer); 
        
%         figure(1);
         AllWaveForms=[];

     for j=1:length(endidx)

            data=RawData(startidx(j):endidx(j));

            subplot((length(endidx)+2),4,([1:4]+([4].*(j))));         
            cla;

            time=(dt:dt:dt*length(data))';
            plot(data);
            hold on;
            [a b c Events WaveForms ]=FindSpikes(data,Fs,threshold,0);
            set(gca,'xtick',[],'ytick',[]);       
            if ~isempty(Events)
                plot(Events,0.5,'rx')
            end;
            AllWaveForms=[AllWaveForms WaveForms];

        end;

       
      