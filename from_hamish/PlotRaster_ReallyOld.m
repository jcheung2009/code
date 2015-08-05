
clear
filename=uigetfile; %load('AllSpikeEvents_y15o34.14.14.1_071112095101.SpikeData.mat_y15o34_071112095122.SpikeData.mat')
load(filename);

WarpedTimes=results.AllWarpedTimes;
WaveForms=results.AllWaveForms;
NotEmpty=find(~cellfun(@isempty,WarpedTimes));
% a=find(NotEmpty<33); %Can't be more channels than this!
% NotEmpty=NotEmpty(a);
temp=zeros(32,length(WarpedTimes));
temp(NotEmpty)=1;
NotEmpty=heaviside(sum(temp')-0.1);
[a b]=find(NotEmpty>0)
NotEmpty=b;


figure('Color',[1 1 1]);
subplot(length(NotEmpty)+1,10,[1:7]);
set(gca,'xtick',[],'ytick',[])
surf(results.T,results.F,10*log10(results.P),'edgecolor','none'); axis tight; 
view(0,90);
set(gca,'xtick',[],'ytick',[]);   

cnt=1;    

for i=NotEmpty    
    
    subplot(length(NotEmpty)+1,10,([1:7]+(10*cnt)));
    hold on;        
    
    set(gca,'xtick',[],'ytick',[]);   
    WaveOut=zeros(31,1);
    
        for j=1:size(WarpedTimes,2) % e.g. Number of Bouts.         
% 
          if ~isempty(WarpedTimes{i,j})
            
            TickTimes=round(WarpedTimes{i,j})';
            RowVector=[ones(size(TickTimes))*j;ones(size(TickTimes))*(j-1)];           
            
            plot([TickTimes;TickTimes],RowVector,'-k','LineWidth',2);            
       
            if max(xlim)<max(WarpedTimes{i,j})
                xlim([0 max(WarpedTimes{i,j})]);  % & we have to find these limits. Maybe Fix Spect first....
            end;                   
            
            WaveOut=[WaveOut WaveForms{i,j}];
            ylabel(num2str(i-1));
          end;
        end;
    ylim([0 j]); % %We know these limits
    
    subplot(length(NotEmpty)+1,10,([9:10]+(10*cnt)));   
    plot(WaveOut,'k');
    hold on;        
    plot(mean(WaveOut'),'r','LineWidth',2);
    xlim([0 30]);
    cnt=cnt+1;
end;


%--------------
%Make PSTHs
% 

figure('Color',[1 1 1]);
subplot(length(NotEmpty),10,[1:7]);
set(gca,'xtick',[],'ytick',[])
surf(results.T,results.F,10*log10(results.P),'edgecolor','none'); axis tight; 
view(0,90);
set(gca,'xtick',[],'ytick',[]);   
[xax]=xlim;
    
hold on;


%Setuip Windowing;
Fs=32000;
%Down to: 1Khz
Fs=Fs/32;
dt=(1/Fs);
win=7; %ms

gaussFilter = gausswin(win)
gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
cnt=1;

for i=NotEmpty'
    
    subplot(length(NotEmpty)+1,10,([1:7]+(10*cnt)));
    set(gca,'xtick',[],'ytick',[]);    

%     keyboard
    
    Idx=ceil(WarpedTimes{i,1});
    Idx(1)=Idx(1)+1;

        outlayer=zeros(max(Idx)+75,1); % Seriosuly an extra second. Should be enough for chrissakes. 


        for j=1:size(WarpedTimes,2) % e.g. Number of Bouts.                           

            Idx=round(WarpedTimes{i,j});   
            if ~isempty(Idx)
                Idx(1)=Idx(1)+1;
                outlayer(Idx)=outlayer(Idx)+1;                               
            end;
         end;

         PSTH{i}=conv(outlayer,gaussFilter);
         times=dt:dt:(length(PSTH{i})).*dt;

         subplot(length(NotEmpty)+1,10,([1:7]+(10*cnt)));
         plot(PSTH{i})
         xlim([0 250])
         cnt=cnt+1;
         
end;

