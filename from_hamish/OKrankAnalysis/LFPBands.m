function LFPBands;

[filename path]=uigetfile('*.rec');
filename=filename(1:end-4);
% filename='Orange98Blue46_101711164126';
[sound soundFs Chans]=ReadOKrankDataHeaders('.',filename,0);

for i = 1:Chans-1;
    [data Fs]=ReadOKrankData('.',filename,i);    
    [alpha{i} beta{i} gamma{i} delta{i} theta{i} highgamma{i} spks{i}]=GetLFPWaves(data,Fs);
        
    figure;
    title(['Electrode ' num2str(i)]);    
    PlotHandle=subplot(8,1,1);plot(sound);
set(gca,'xtick',[],'ytick',[])    
    subplot(8,1,2);plot(alpha{i});
    ylabel('\alpha');
set(gca,'xtick',[],'ytick',[])    
    subplot(8,1,3);plot(beta{i});
    ylabel('\beta');    
set(gca,'xtick',[],'ytick',[])    
    subplot(8,1,4);plot(theta{i});
    ylabel('\theta');    
set(gca,'xtick',[],'ytick',[])    
    subplot(8,1,5);plot(delta{i});
    ylabel('\delta');    
set(gca,'xtick',[],'ytick',[])    
    
    subplot(8,1,6);plot(gamma{i});
    ylabel('\gamma');    
 set(gca,'xtick',[],'ytick',[])
    subplot(8,1,7);plot(highgamma{i});
    ylabel('high \gamma');    
 set(gca,'xtick',[],'ytick',[])           
    subplot(8,1,7);plot(spks{i});
    ylabel('high pass');
set(gca,'xtick',[],'ytick',[])    

    hObject=uicontrol('Style', 'pushbutton','String', 'Rezoom to Song','Position', [450 00 100 50],'Callback', {@ButtonPressed, PlotHandle});     
    set(hObject,'Units','Points')               % Was normalized
    panelSizePts = get(hObject,'Position');     % Now in points
    panelHeight = panelSizePts(4);
    set(hObject,'Units','normalized'); 
    
%      figure;
%     [S, F, T, P]=spectrogram(data,512);
%     surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
%     view(0,90);
end;


function ButtonPressed(hObject,eventdata,PlotHandle)
    
    
    global threshold;
    axes(PlotHandle); 
    subplot(8,1,1);
    xVect=xlim;
    
    for i=1:8
        subplot(8,1,i)
        xlim(xVect);
    end;

 



