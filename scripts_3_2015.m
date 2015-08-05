fv = [];
for i = 1:length(sp)
    c = xcorr(abs(sp(:,i)),'coeff');
    c = c(ceil(length(c)/2):end);
    [pks locs] = findpeaks(abs(sp(:,i)).*c,'SortStr','descend');
    fv = cat(2,fv,f(locs(1:2)));
    %[pks locs] = findpeaks(c,'MINPEAKDISTANCE',24,'NPEAKS',3);
    %fv = cat(1,fv,mean(diff([1;f(locs)])));
end

N = 512;
t = -N/2+1:N/2;
sigma = 1;
sigma=(sigma/1000)*fs;
w = exp(-(t/sigma).^2);
spect = {};
for i = 1:length(fv)
    [sp f t] = spectrogram(fv(i).smtmp,w,N-2,N,fs);
    spect{i} = abs(sp);
end





peaksforcluster = [];
for i = 1:length(sp)
    c = xcorr(abs(sp(:,i)),'coeff');
    c = c(ceil(length(c)/2):end);
    [pks locs] = findpeaks(c,'MINPEAKDISTANCE',8);%below 6 kHz
    peaksforcluster = cat(1,peaksforcluster,locs);
end

[idx cen] = kmeans(peaksforcluster,2); %2 peaks
dev = [3*std(peaksforcluster(idx == 1)),3*std(peaksforcluster(idx==2))];


fv = [];
npnts = 1;
for i = 1:length(sp)
    fdat = abs(sp(:,i));
    c = xcorr(fdat,'coeff');
    c = c(ceil(length(c)/2):end);
    [pks locs] = findpeaks(c);
    a = [];
    for ii = 1:length(cen)
        ind = find(f(locs) >= cen(ii)-dev(ii) & f(locs) <= cen(ii)+dev(ii));
        [mx id] = max(pks(ind));
        a = cat(1,a,locs(ind(id)));
    end
    a = [a(1) + [-npnts:npnts];a(2) + [-npnts:npnts]];%each row are three points that are indices for frequency range
    fv = cat(2,fv,sort([pinterp(f(a(1,:)),c(a(1,:)));pinterp(f(a(2,:)),c(a(2,:)))]));
    %fv = cat(2,fv,sort([dot(f(a(1,:)),fdat(a(1,:)))/sum(fdat(a(1,:)));...
%        dot(f(a(2,:)),fdat(a(2,:)))/sum(fdat(a(2,:)))]));
end

window = 512;
noverlap = 510;
nfft = 512;
[pxx freq] = pwelch(dattmp,window,noverlap,nfft,fs,'one-sided');

spectralent = 0;
for i = 1:length(freq)
    spectralent = spectralent - (pxx1(i)*log(pxx1(i)));
end

spectralentropy = [];
for i = 1:size(pxx,2)
    pxx_n = pxx(:,i)./sum(pxx(:,i));
    spectent = 0;
    for ii = 1:length(pxx_n)
        spectent = spectent - pxx_n(ii)*log(pxx_n(ii));
    end
    spectralentropy = cat(1,spectralentropy,spectent);
end

fvlim = find(f>= 1000 & f <= 6000);
fvsamp = randsample(f(fvlim),10000,'true',mean(abs(sp(fvlim,:)),2));
[idx cen] = kmeans(fvsamp,2);
dev = [3*std(fvsamp(idx == 1)),3*std(fvsamp(idx==2))];



        