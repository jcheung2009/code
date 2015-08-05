function [fffilt ffconf timebase] = rolling_ff(songfile)
%
% [ff ffconf timebase] = rolling_ff(songfile)
%
% returns rolling pitch measurement and pitch confidence for songfile
% pitch is measured from location of largest peak in the raw waveform's 
% autocorrelation, confidence is the height of that peak.
%
%

winsize = 128;
freqthresh = 750; % highpass threshold 

[filepath,filename,fileext] = fileparts(songfile);

if(strcmpi(fileext,'.cbin'))
    [plainsong,fs] = ReadCbinFile(songfile);
elseif(strcmpi(fileext,'.wav'))
    [plainsong,fs] = wavread(songfile);
    % plainsong = plainsong *10e3; % boost amplitude to cbin levels
end

decfactor=winsize/2;

ff = zeros(1,round(length(plainsong)/decfactor));
ffconf = zeros(1,round(length(plainsong)/decfactor));

%sm = plainsong;

for i=1:1:length(ff)
    winStart = min([(i*decfactor) length(plainsong)]);
    
    if((winStart+winsize) > length(plainsong))
        winStop = length(plainsong);
    else
        winStop = winStart+winsize;
    end
    
    thesegment = plainsong(winStart:winStop);
    acorr = xcorr(thesegment);
    acorr = acorr((round(length(acorr)/2)):length(acorr));
    acorr = smooth(acorr,3);
    %    if(length(acorr)>3)
    %        [peaks peaklocs] = findpeaks(acorr);
    %    end
    if(length(acorr)>3)
        [interppeakloc maxpeak] = minterppeak(acorr,fs);
        if((1/(interppeakloc/fs)) > freqthresh)
            %       [maxpeak maxloc] = max(peaks);
            %       ff(i) = 1/(peaklocs(maxloc)/fs);
            %       ffconf(i) = abs(maxpeak);
            ff(i) = 1/(interppeakloc/fs);
            ffconf(i) = abs(maxpeak);
            
        end
    end
end

fffilt = mfffilt(ff,ffconf);
timebase = maketimebase(length(ff),round(fs/decfactor));

