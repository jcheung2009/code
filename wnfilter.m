file = 'rd36gr25_110218_0746.6262.cbin';
[dat fs] = evsoundin('',file,'obs0');
filtsong = bandpass(dat,fs,300,10000,'hanningffir');

nfft = 256;

noise = filtsong(1:fs);
s = filtsong(3*fs:3*fs+fs-1);

fxnoise = fft(noise,nfft);
fxs = fft(s,nfft);
pxnoise = fxnoise.*conj(fxnoise);
pxs = fxs.*conj(fxs);
pxnxs = fxs.*conj(fxnoise);
cxy = pxnxs./sqrt(pxnoise.*pxs);
cxy = 

pxnoise = pwelch(noise,hann(nfft),nfft-10,nfft,fs);
pxsignalnoise = pwelch(s,hann(nfft),nfft-10,nfft,fs);





pxns = cpsd(noise',s',hann(nfft),nfft-10,nfft,fs);

H = pxns./pxnoise;
H = H'.*exp(-1j*2*pi./length(H)*[0:length(H)-1].*[0:length(H)-1]/2);

h = real(ifft(H));

y = conv(filtsong,h,'same');

squared_song = y.^2;
len = round(fs*10/1000);
h   = ones(1,len)/len;
smy = conv(h, squared_song);
offset = round((length(smooth)-length(y))/2);
smy=smy(1+offset:length(y)+offset);