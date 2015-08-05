function [entlist] = mEnt(rawsong,fs,hipass,lopass)
%
%
%
%
%
%
nfft = 256;
indlst = (1:nfft:length(rawsong)-nfft); % vector of bins, each nfft points long
olap = 0.8;

entlist = zeros(1,length(indlst));
vol_list = zeros(1,length(indlst));


startind=1;
for jj=1:length(indlst)
    datvals=rawsong(indlst(jj):indlst(jj)+nfft-1);
    startind=startind+nfft;
    %filtsong=bandpass(datvals,Fs,F_low,F_high,filter_type);
    spect_win = nfft;
    noverlap = floor(olap*nfft);

    fdat=(abs(fft(hamming(nfft).*datvals))./nfft);
    ffv=get_fft_freqs(nfft,fs);
    ffv=ffv(1:end/2);
    frqind=find((ffv>=hipass)&(ffv<=lopass));

    %volume calculation:
    volcalc=sum(fdat(frqind));
    vol_list(jj) = volcalc;
    

    %entropy calculation:
    frqind = find((ffv>=hipass)&(ffv<=lopass));
    pnorm=(fdat(frqind))/sum(fdat(frqind));
    entcalc=-(pnorm'*log2(pnorm));
    entlist(jj) = entcalc;
end



