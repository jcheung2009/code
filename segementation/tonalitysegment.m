function [tonons tonoffs] = tonalitysegment(smtemp,fs,varargin);
%segments based on tonality 
%tonality is when power in the psd becomes less spread out (less like white
%noise) and more tonal (harmonic, concentrated in discrete frequency bands) 
%tonality is measured as the magnitude of the highest peak in the
%autocorrelation of the filtered amplitude waveform 
%tonality measure highly sensitive to bandpass frequency and will depend on
%each bird's song; for bengalese, 1-4 kHz seems to work ok
%still requires either peak or"amplitude" algorithm to segment the tonality
%waveform (findpeaks2/SegmentNotes)

if isempty(varargin)
    freq = [1000 4000];
else
    freq = varargin{1};
end
filtsong = bandpass(smtemp,fs,freq(1),freq(2),'hanningffir'); 

startind = 1;
tonality = []; startind = 1;
downsamp=44;%faster to downsample 

while length(filtsong)-startind>=512
    endind = startind+512-1;
    win = filtsong(startind:endind);
    win = [win;zeros(512,1)];
    [c lag] = xcorr(win,'coeff');
    len=5;
    h = ones(1,len)/len;
    smooth = conv(h, c);%smoothed autocorrelation 
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
% [pks,locs,w,~,wc] = findpeaks2(tonality,'MinPeakDistance',0.023*fs/downsamp,...
%     'MinPeakProminence',0.3,'MinPeakWidth',0.02*fs/downsamp,'Annotate','extents','widthreference','halfheight');%segment the tonality waveform
% tonons = wc(:,1)./(fs/downsamp);
% tonoffs = wc(:,2)./(fs/downsamp);
[tonons tonoffs] = SegmentNotes(tonality,fs/downsamp,5,20,0.3);

%plot tonality waveform
if nargout < 1 
    tb = [0:length(tonality)-1]./(fs/downsamp);
    plot(tb,tonality,'k');
end
