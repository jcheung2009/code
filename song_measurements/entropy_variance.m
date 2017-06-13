function ev = entropy_variance(smtmp,fs);
%measure entropy variance of sylable

%spectrogram params
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

filtsong = bandpass(smtmp,fs,500,10000,'hanningffir');
[sp f tm pxx] = spectrogram(filtsong,w,overlap,NFFT,fs);
indf = find(f>=500 & f<= 10000);
pxx = pxx(indf,:);
ev = var(log(geomean(pxx)./mean(pxx)));