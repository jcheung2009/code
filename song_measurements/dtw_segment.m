function [sm_ons sm_offs tm2 sp2 f2] = dtw_segment(smtemp,dtwtemplate,fs);
%performs spectrogram dtw using template and exemplar (smtemp). returns
%time in seconds into smtemp that corresponds to onsets and offsets of
%template

%spectrogram params
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

%extract the dtwtemplate spectrogram and ons/offs
temp = abs(dtwtemplate.filtsong);
temp_ons=dtwtemplate.ons;
temp_offs=dtwtemplate.offs;
[sp f tm1] = spectrogram(temp,w,overlap,NFFT,fs);
indf = find(f>1000 & f<10000);
temp = abs(sp(indf,:));
temp = temp./sum(temp,2);
temp_onind = [];temp_offind = [];
for m = 1:length(temp_ons)
    [~, temp_onind(m)] = min(abs(temp_ons(m)-tm1));
    [~, temp_offind(m)]=min(abs(temp_offs(m)-tm1));
end

%process smtemp
filttemp = bandpass(smtemp,fs,1000,10000,'hanningffir');
[sp2 f2 tm2] = spectrogram(filttemp,w,overlap,NFFT,fs);
indf = find(f2>1000 & f2 <10000);
f2 = f2(indf);
sp2 = abs(sp2(indf,:));
sp2 = sp2./sum(sp2,2);

%dtw and find corresponding ons/offs to temp
sm_ons = [];sm_offs = [];
[dist ix iy] = dtw(temp,sp2);
for m = 1:length(temp_onind)
    ind = find(ix==temp_onind(m));
    ind = ind(ceil(length(ind)/2));
    sm_ons = [sm_ons;tm2(iy(ind))];
    ind = find(ix==temp_offind(m));
    ind = ind(ceil(length(ind)/2));
    sm_offs = [sm_offs;tm2(iy(ind))];
end

