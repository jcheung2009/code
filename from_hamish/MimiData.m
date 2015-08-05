
clear;
close('all')

filename=uigetfile('*.mat','bc');

load(filename)
% 
% Song=AnalysisOutput.UnDirSong;
% Spikes=AnalysisOutput.UnDirFileInfo.SpikeData;
% labels=AnalysisOutput.UnDirFileInfo.NoteLabels;
% onsets=AnalysisOutput.UnDirFileInfo.NoteOnsets;
% offsets=AnalysisOutput.UnDirFileInfo.NoteOffsets;
% SpikeTrain=AnalysisOutput.UnDirFileInfo.UWSpikeTrain;
% motif=AnalysisOutput.Motif;
% time=AnalysisOutput.MedianMotif.Length;

Spikes=seq.spike_times;

count=1;
MotifInBoutSpikesWarp=struct; %(1,4);
MotifInBoutSpikesWarp(1).SpikeTrain={};
MotifInBoutSpikesWarp(2).SpikeTrain={};
MotifInBoutSpikesWarp(3).SpikeTrain={};
MotifInBoutSpikesWarp(4).SpikeTrain={};
MotifInBoutSpikesWarp(5).SpikeTrain={};
MotifInBoutSpikesWarp(6).SpikeTrain={};
MotifInBoutSpikesWarp(7).SpikeTrain={};
MotifInBoutSpikesWarp(8).SpikeTrain={};
MotifInBoutSpikesWarp(9).SpikeTrain={};
MotifInBoutSpikesWarp(10).SpikeTrain={};



% Sort by Motif;

for i=1:length(labels)
    [startidx]=regexp(labels{i},motif);
    
    if ~isempty(startidx)
        stopidx=startidx+length(motif)-1;
    
        
       
        off=offsets(i);
        on=onsets(i);
    
    
        fullsonglength=off{1}(stopidx)-on{1}(startidx);
        SongScaler=fullsonglength./fullsonglength(1);
    
        for j=1:length(startidx);
            MotifInBoutSpikesWarp(j).SpikeTrain{length(MotifInBoutSpikesWarp(j).SpikeTrain)+1}=[SpikeTrain{count}]*(SongScaler(j));
    %         SongWarpedSpikes=(j).SpikeTrain{length(MotifInBoutSpikes(j).SpikeTrain)}=SpikeTrain(count).*SongScaler;
            count=count+1;
        end;
    end;
    
end;

figure(1);
subplot(5,1,2)

for i=1:4

       subplot(5,1,i+1)
       xlim([0 time*1000]);
       hold on;
    
       for j=1:length(MotifInBoutSpikesWarp(i).SpikeTrain)
           
                TickTimes=([MotifInBoutSpikesWarp(i).SpikeTrain{j}]');
                TickTimes=round(TickTimes*1000);
                RowVector=[ones(size(TickTimes))*j*1;ones(size(TickTimes))*(j*1-1)];           
                plot([TickTimes;TickTimes],RowVector,'-k','LineWidth',0.5);
           
       end;
end;





figure(2);
subplot(5,1,2)

    gaussFilter = gausswin(5);
    gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.

for i=1:4

       subplot(5,1,i+1)
       xlim([0 time*1000]);
       hold on;
       PSTH=zeros(round(time*1000)+500,1);
       
       for j=1:length(MotifInBoutSpikesWarp(i).SpikeTrain)
 
                TickTimes=([MotifInBoutSpikesWarp(i).SpikeTrain{j}]');
                TickTimes=round(TickTimes*1000);
                PSTHtemp=zeros(round(time*1000),1);
                
                a=find(TickTimes<1);
                TickTimes(a)=[];
                
                if ~isempty(TickTimes)
                    PSTHtemp(TickTimes)=1;
                    PSTHtemp=conv(PSTHtemp,gaussFilter);                                                                                        
                    PSTH(1:length(PSTHtemp))=PSTH(1:length(PSTHtemp))+PSTHtemp;
                end;

%                 RowVector=[ones(size(TickTimes))*j*1;ones(size(TickTimes))*(j*1-1)];           
%                 plot([TickTimes;TickTimes],RowVector,'-k','LineWidth',0.5);
           
       end;
       
       if ~isempty(j)
        PSTH=(PSTH./j)*1000;
        PlotTime=1:length(PSTH);
        plot(PlotTime,PSTH);
       end;
       
       if i==1
           FirstPSTH=PSTH;
       end;
       if i==2
           SecondPSTH=PSTH;
       end;
       if i==3
           ThirdPSTH=PSTH;
       end;
           
    end;  

 save([filename '.PSTH.mat'],'FirstPSTH','SecondPSTH','ThirdPSTH');





