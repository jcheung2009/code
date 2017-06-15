function jc_spectrogram(filtsong,fs);

%spectrogram params
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

[sp f tm pxx] = spectrogram(filtsong,w,overlap,NFFT,fs);
indf = find(f>=1000 & f<=10000);
figure;imagesc(tm,f(indf),log(abs(sp(indf,:))));axis('xy');hold on;