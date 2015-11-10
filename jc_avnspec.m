function [avn, tm, f pcstruct] = jc_avnspec(fv)
%fv is structure from jc_findwnote5
%also plots pitch contour

NFFT = 512;
fs = 44100;

overlap = NFFT-2;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);%gaussian window for spectrogram
                
                
for i = 1:length(fv)
    filtsong = bandpass(fv(i).smtmp,fs,300,15000,'hanningffir');
    [sp f tm pxx] = spectrogram(filtsong,w,overlap,NFFT,fs);
    spec(i).sp = abs(sp);
    spec(i).tm = tm;
    spec(i).f = f;
end

[maxlength ind1] = max(arrayfun(@(x) length(x.tm),spec));
freqlength = max(arrayfun(@(x) length(x.f),spec));
avgspec = zeros(freqlength,maxlength);
for ii = 1:length(spec)
    pad = maxlength-length(spec(ii).tm);
    avgspec = avgspec+[spec(ii).sp,zeros(size(spec(ii).sp,1),pad)];
end
avn = avgspec./length(spec);
tm = spec(ind1).tm;
f = spec(ind1).f; 

pcstruct = jc_getpc(fv);