function [ FF ] = GetFF( songseg, Fs, start, b)
%Returns the FF of a preselected harmonic stack from ZF songs. 
% start is in percents, seglenth is in ms. 

 
    notestart=round(length(songseg)*start);
    noteend=notestart+b/(1/(Fs/1000)); %fixed syllable length ms increment.
    decnum=5;         
    
    songseg=songseg-mean(songseg);   
try
    [Pxx f]=psd(downsample(songseg(notestart:noteend),decnum),4096);
     [temp idx]=max(Pxx(1:round(0.3*end)));
% %     
    figure(1);
    hold on;
    plot(f,Pxx);
%     
    % parabolic fit to get more accurate peak
%     try
        x=f(idx-2):f(2)-f(1):f(idx+2);
        y=(Pxx(idx-2:idx+2));
        C = [x.^2;x;ones(1,length(x))]'\y;
        parabpeak=-C(2)/(2*C(1));

        FF=parabpeak*Fs/2/decnum; %and  scale to return frequency;
catch
     %keyboard
     FF=NaN;
end;
%     
   
%     catch
%         FF=NaN;
%     end;
%       
%        figure;
%     plot(f,Pxx);
%     title(num2str(FF));

% Scrap for debugging.     
% %     

% figure;
%     [S F T P]=spectrogram(songseg, 256,125,256,Fs);
%     surf(T,F,10*log10(abs(P)));
%     

%         [S F T P]=spectrogram(songseg(delay*Fs:delay*Fs+seglength*Fs),256,125,256,Fs);
%         surf(T,F,10*log10(abs(P)));
% % %         

end

    