[dat fs] = evsoundin('','bk93bk94_301016_0753.1782.cbin','obs0');
filtsong= bandpass(dat,fs,1000,10000,'hanningfir');
startind = 1;
tonality = [];
while length(filtsong)-startind>=256
    endind = startind+256-1;
    x = fft(filtsong(startind:endind));
    corr = ifft(x.*conj(x));
    corr = corr(1:length(corr)/4);
    [pks locs] = findpeaks(corr);
    tonality = [tonality;pks(1)];
    startind = startind+4;
end

tonality = abs(tonality);
figure;plot([1:length(tonality)]/8000,tonality);
thresh = std(tonality)/8

figure(4);hold on;
for i = 1:length(onsets)
    plot([onsets(i) onsets(i)]/1e3,[0 4.5e9],'r');hold on;
    plot([offsets(i) offsets(i)]/1e3,[0 4.5e9],'g');hold on;
end