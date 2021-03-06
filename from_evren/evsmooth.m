function [smooth,spec,t,f]=evsmooth(rawsong,Fs,SPTH,nfft,olap,sm_win,F_low,F_High);
% [smooth,spec,t,f]=evsmooth(rawsong,Fs,SPTH,nfft,olap,sm_win,F_low,F_High);
% returns the smoothed waveform/envelope + the spectrum
%

if (~exist('F_low')) | isempty('F_low')
    F_low  = 750.0; %750, 300 from evsonganaly
end
if (~exist('F_High')) | isempty('F_High')
    F_High = 15000.0;%15000, 8000 from evsonganaly
end
if (~exist('nfft')) | isempty('nfft')
    nfft = 512;
end
if (~exist('olap')) | isempty('olap')
    olap = 0.8;
end
if (~exist('sm_win')) | isempty('sm_win')
    sm_win = 2.0;%ms
end
if(~exist('SPTH')) | isempty('SPTH')
    SPTH=0.01;
end

filter_type = 'hanningffir';

filtsong=bandpass(rawsong,Fs,F_low,F_High,filter_type);
%filtsong=rawsong;

if (nargout > 1)
    spect_win = nfft;
    noverlap = floor(olap*nfft);
    [spec,f,t] = specgram(filtsong,nfft,Fs,spect_win,noverlap);
    if (exist('SPTH'))
        if(SPTH == 0)
            SPTH = mean(mean(abs(spec)));
            p = find(abs(spec)<=SPTH);
            spec(p) = SPTH / 2;
        else
            p = find(abs(spec)<=SPTH);
            spec(p) = SPTH;
        end
    end
end

squared_song = filtsong.^2;

%smooth the rectified song
len = round(Fs*sm_win/1000);
h   = ones(1,len)/len;
smooth = conv(h, squared_song);
offset = round((length(smooth)-length(filtsong))/2);
smooth=smooth(1+offset:length(filtsong)+offset);


return;
