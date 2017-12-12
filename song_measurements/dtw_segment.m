function [sm_ons sm_offs tm2 sp2 f2] = dtw_segment(smtemp,dtwtemplate,fs);
%performs spectrogram dtw using template and exemplar (smtemp). returns
%time in seconds into smtemp that corresponds to onsets and offsets of
%template
%the template has defined syll onsets/offsets; dtw will compare the spectral 
%feature at each time point in the template with the spectral feature in the
%exemplar. therefore, you can find the corresponding syll onsets/offsets in the exemplar 

%spectrogram params
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

%extract the dtwtemplate spectrogram and ons/offs
temp = dtwtemplate.filtsong;
temp_ons=dtwtemplate.ons;
temp_offs=dtwtemplate.offs;
[sp f tm1] = spectrogram(temp,w,overlap,NFFT,fs);
indf = find(f>500 & f<10000);
temp = abs(sp(indf,:));
temp = temp./sum(temp,2);
temp_onind = NaN(length(temp_ons),1);temp_offind = NaN(length(temp_offs),1);
for m = 1:length(temp_ons)
    [~, temp_onind(m)] = min(abs(temp_ons(m)-tm1));
    [~, temp_offind(m)]=min(abs(temp_offs(m)-tm1));
end

%extract exemplar spectrogram 
filttemp = bandpass(smtemp,fs,500,10000,'hanningffir');
[sp2 f2 tm2] = spectrogram(filttemp,w,overlap,NFFT,fs);
indf = find(f2>500 & f2 <10000);
f2 = f2(indf);
sp2 = abs(sp2(indf,:));
sp2 = sp2./sum(sp2,2);

%dtw and find corresponding ons/offs to temp
sm_ons = NaN(length(temp_onind),1);sm_offs = NaN(length(temp_offind),1);
[dist ix iy] = dtw(temp,sp2);
for m = 1:length(temp_onind)
    ind = find(ix==temp_onind(m));
    ind = ind(ceil(length(ind)/2));
    sm_ons(m) = tm2(iy(ind));
    ind = find(ix==temp_offind(m));
    ind = ind(ceil(length(ind)/2));
    sm_offs(m) = tm2(iy(ind));
end

