function [tonons tonoffs] = tonalitysegment(smtemp,fs);
%segments based on tonality 

%spectrogram params
NFFT=512;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

filtsong = bandpass(smtemp,fs,1000,4000,'hanningffir'); 

startind = 1;
tonality = []; startind = 1;
downsamp=44;

while length(filtsong)-startind>=512
    endind = startind+512-1;
    win = filtsong(startind:endind);
    win = [win;zeros(512,1)];
    [c lag] = xcorr(win,'coeff');
    len=5;
    h = ones(1,len)/len;
    smooth = conv(h, c);
    offset = round((length(smooth)-length(c))/2);
    smooth=smooth(1+offset:length(c)+offset);
    smooth=smooth(ceil(length(smooth)/2):end);
    [pks locs] = findpeaks(smooth);
    if ~isempty(pks)
        tonality=[tonality;max(pks)];
    else
        tonality=[tonality;NaN];
    end
    startind=startind+downsamp;
end
tonality=log(tonality);
tonality=tonality-min(tonality);tonality=tonality/max(tonality);
[pks,locs,w,~,wc] = findpeaks2(tonality,'MinPeakDistance',0.023*fs/downsamp,...
    'MinPeakProminence',0.3,'MinPeakWidth',0.02*fs/downsamp,'Annotate','extents','widthreference','halfheight');
tonons = wc(:,1)./(fs/downsamp);
tonoffs = wc(:,2)./(fs/downsamp);
