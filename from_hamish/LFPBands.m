[filename path]=uigetfile('*.rec');
filename=filename(1:end-4);
% filename='Orange98Blue46_101711164126';
[sound soundFs Chans]=ReadOKrankDataHeaders('.',filename,0);

for i = 1:Chans-1;
    [data Fs]=ReadOKrankData('.',filename,i);    
    [alpha{i} beta{i} gamma{i} delta{i} theta{i} highgamma{i} spks{i}]=GetLFPWaves(data,Fs);
        
    figure(1);
    title(['Electrode ' num2str(i)]);    
    subplot(8,1,1);plot(sound);
    
    subplot(8,1,2);plot(alpha{i});
    ylabel('\alpha');
    
    subplot(8,1,3);plot(beta{i});
    ylabel('\beta');    
    subplot(8,1,4);plot(theta{i});
    ylabel('\theta');    
    subplot(8,1,5);plot(delta{i});
    ylabel('\delta');    
    
    subplot(8,1,6);plot(gamma{i});
    ylabel('\gamma');    
    subplot(8,1,7);plot(highgamma{i});
    ylabel('high \gamma');    
            
    subplot(8,1,7);plot(spks{i});
    ylabel('high pass');
    
    figure;
    [S, F, T, P]=spectrogram(data,512);
    surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
    view(0,90);
end;





