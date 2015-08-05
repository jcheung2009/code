 function ChunkDataToSongChannelByChannelMultiFiles

motif='abcdefg';
[FileList dirname]=UIgetfile('*.rec','MultiSelect','on');
debug=0;

MotifCount=0;

for FileLoop=1:length(FileList)
    
    filename=FileList{FileLoop}(1:end-4);

    


    if (exist([filename '.not.mat'])==2)
        noteinfo=load([filename '.not.mat']);
        starts=find(noteinfo.labels==motif(1));
        stops=find(noteinfo.labels==motif(end));
        goodstops=[];
        crap=0;
        [starts stops]=regexp(noteinfo.labels,motif)

    end;

    [sound Fs,ChanNo]=ReadOKrankData(dirname,filename,1);
    
    endidx{FileLoop}=noteinfo.offsets(stops) * (Fs/1000); 
    startidx{FileLoop}=noteinfo.onsets(starts)* (Fs/1000); 
    endidx{FileLoop}=endidx{FileLoop}+500;
    startidx{FileLoop}=startidx{FileLoop}-500;
    
    MotifCount=MotifCount+length(startidx{FileLoop})+1;
    
end;



    for i=2:ChanNo
        

        drrrrr= input('dffs','s')
    
            
            MainPlot=figure(1);
            clf(MainPlot)
            set(MainPlot,'Toolbar','figure')
            hand=subplot(MotifCount+2,4,[1:4]); 
            title(num2str(i));
            
            set(gca,'xtick',[],'ytick',[])
            
            SubPlotCount=2;
        
        for FileLoop=1:length(FileList)

            
%             keyboard
            
            filename=FileList{FileLoop}(1:end-4);
            [sound Fs,ChanNo]=ReadOKrankData(dirname,filename,1);                

 try            song{1}=sound(startidx{FileLoop}(1):endidx{FileLoop}(1));    
 catch
     keyboard
 end 
%             SampleSongLength=length(song{1});
% 
%             dt=1/Fs;
%             dt=dt*1000;

%             [S,F,T,P] = spectrogram(song{1},256,250,256,1E3);
%             surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
%             view(0,90);

        %     time=0:dt:dt*length(song{j})-dt;
        %     plot(time,song{j});
%             set(gca,'xtick',[],'ytick',[])
%             AllWaveForms=zeros(31,1);
            [RawData Fs]=ReadOKrankData(dirname,filename,i); %Filt(dirname,filename,i,600,9000);       

            for j=1:length(endidx{FileLoop})


                data=RawData(startidx{FileLoop}(j):endidx{FileLoop}(j));
                
                subplot(MotifCount+2,4,([1:4]+([4].*(SubPlotCount-1))));         
%                 WarpLength=length(data)/SampleSongLength;
%                 time=(dt:dt:dt*length(data))';
                plot(data);            
                set(gca,'xtick',[],'ytick',[])
%                 ylim([-1.5 1.5]);   
                
%                 hold on;
%                 [a b c Events WaveForms ]=FindSpikes(data,Fs,0);
%                 set(gca,'xtick',[],'ytick',[]);       
%                 if ~isempty(Events)
%                     plot(Events,0.5,'rx')
%                 end;
%                 AllWaveForms=[AllWaveForms WaveForms];
                SubPlotCount=SubPlotCount+1;
                
            end;

%             set(gca,'xtickMode', 'auto')
% 
%             subplot(MotifCount+2,4,(SubPlotCount*4)-3);
%             plot(AllWaveForms,'k');
%             hold on;    
%             plot(mean(AllWaveForms'),'r','LineWidth',4);
%             [y]=ylim;
%             if y(2) < 1
%                 ylim([-2 2]);
%             end;
%          
%             STDRatio=mean(max(AllWaveForms))/std(data);
%             title(num2str(STDRatio));
% 
%             subplot(MotifCount+2,4,((SubPlotCount+2)*4)-2);  
%             plot(min(AllWaveForms),max(AllWaveForms),'ko');
%             [x]=xlim;
%             if x(2)<1
%                 xlim([-1 0.25]);
%             end;
%             [y]=ylim;
%             if y(1) > -0.5
%                 ylim([-0.25 1]);
%             end;
% %             
% %             SubPlotCount=SubPlotCount+1;

%             hObject=uicontrol('Style', 'pushbutton','String', 'Export','Position', [450 00 100 50],'Callback', {@ButtonPressed, i, dirname, filename,startidx, endidx,T,F,P});     
%             set(hObject,'Units','Points')               % Was normalized
%             panelSizePts = get(hObject,'Position');     % Now in points
%             panelHeight = panelSizePts(4);
%             set(hObject,'Units','normalized'); 
        end;
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
        WarpFactor{i,j}=((startidx(1)-endidx(1))/(startidx(j)-endidx(j)))
        
        WarpedTimes{i,j}=Times{i,j}.*WarpFactor{i,j}; % Scale relative to the example song + first data trace.
        
    end;
    
    save(SaveFileName, 'Freq', 'ISIs', 'Times', 'Events', 'WaveForms', 'WarpedTimes','T','F','P','WarpFactor');

