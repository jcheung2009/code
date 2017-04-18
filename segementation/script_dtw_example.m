%this script plots dtw spectrogram process
exemplar = motifsegment_bcd_11_11_2015_saline(214);

%spectrogram params
fs = 44100;
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

%extract template
temp=abs(dtwtemplate.filtsong);
temp_ons=dtwtemplate.ons;
temp_offs=dtwtemplate.offs;
[sp1 f tm1] = spectrogram(temp,w,overlap,NFFT,fs);
indf = find(f>1000 & f<10000);
temp = abs(sp1(indf,:));
temp = temp./sum(temp,2);

%extract one amp wv to manipulate
smtemp=exemplar.smtemp;
filtsong = abs(bandpass(smtemp,fs,1000,10000,'hanningffir'));
ons=exemplar.amp_ons;
offs=exemplar.amp_offs;
[sp2 f tm2] = spectrogram(filtsong,w,overlap,NFFT,fs);
indf = find(f>1000 & f <10000);
sm2_sp = abs(sp2(indf,:));
sm2_sp = sm2_sp./sum(sm2_sp,2);
[dist ix iy] = dtw(temp,sm2_sp);

%find corresponding onset/offset in exemplar that maps to the template
%onset/offset
onind = [];offind = [];%index in real time vector tm1 where onset/offset are set
for i = 1:length(temp_ons)
    [~, onind(i)] = min(abs(temp_ons(i)-tm1));
    [~, offind(i)]=min(abs(temp_offs(i)-tm1));
end
ons2 = [];
offs2 = [];
for i = 1:length(onind)
    ind = find(ix==onind(i));%index in the mapping vector ix that corresponds to onset index in tm1
    ind = ind(ceil(length(ind)/2));
    ons2 = [ons2;iy(ind)];%index in the real time vector tm2 that correspond to onset index in iy/ix 
    ind = find(ix==offind(i));
    ind = ind(ceil(length(ind)/2));
    offs2 = [offs2;iy(ind)];
end
ons2 = tm2(ons2)';offs2=tm2(offs2)';%onset in real time vector tm2 that corresponds to onset in real time tm1 

%find the template onset/offset in warped time  
ix_onind = [];ix_offind = [];%index in ix that corresponds to template onset/offset
iy_onind2 = [];iy_offind2 = [];
onind = [];offind = [];%index in real time vector tm1 where onset/offset are set
for i = 1:length(temp_ons)
    [~, onind(i)] = min(abs(temp_ons(i)-tm1));
    [~, offind(i)]=min(abs(temp_offs(i)-tm1));
end
for i = 1:length(onind)
    ind = find(ix==onind(i));%index in the mapping vector ix that corresponds to onset index in tm1
    ind = ind(ceil(length(ind)/2));
    [ix_onind] = [ix_onind;ind];

    ind = find(ix==offind(i));
    ind = ind(ceil(length(ind)/2));
    [ix_offind] = [ix_offind;ind];
end

%find the exemplar amp seg based onset/offset in warped time 
iy_onind = [];iy_offind = [];%index in iy that corresponds to amp onset/offset
onind = [];offind = [];%index in real time vector tm2 where onset/offset are set
for i = 1:length(ons)
    [~, onind(i)] = min(abs(ons(i)-tm2));
    [~, offind(i)]=min(abs(offs(i)-tm2));
end
for i = 1:length(onind)
    ind = find(iy==onind(i));%index in the mapping vector ix that corresponds to onset index in tm1
    ind = ind(ceil(length(ind)/2));
    [iy_onind] = [iy_onind;ind];
    ind = find(iy==offind(i));
    ind = ind(ceil(length(ind)/2));
    [iy_offind] = [iy_offind;ind];
end

%plot unwarped template and exemplar with amp seg and dtw based
%onsets/offsets
figure;
subplot(3,1,1);hold on;
imagesc(tm1,f(indf),log(abs(sp1(indf,:))));set(gca,'YDir','normal');hold on;
plot([temp_ons temp_ons],[1000 10000],'r');hold on;
plot([temp_offs temp_offs],[1000 10000],'r');hold on;
ylim([1000 10000]);xlim([tm1(1) tm1(end)]);
x = get(gca,'xlim');y = get(gca,'ylim');
ylabel('frequency (hz)');set(gca,'fontweight','bold');
title('template unwarped');

subplot(3,1,2);hold on;
imagesc(tm2,f(indf),log(abs(sp2(indf,:))));set(gca,'YDir','normal');hold on;
plot([ons ons],[1000 10000],'r');hold on;
plot([offs offs],[1000 10000],'r');hold on;
set(gca,'xlim',x,'ylim',y);
ylabel('frequency (hz)');set(gca,'fontweight','bold');
title('exemplar unwarped');

subplot(3,1,3);hold on;
imagesc(tm2,f(indf),log(abs(sp2(indf,:))));set(gca,'YDir','normal');hold on;
plot([ons2 ons2],[1000 10000],'r');hold on;
plot([offs2 offs2],[1000 10000],'r');hold on;
set(gca,'xlim',x,'ylim',y);
ylabel('frequency (hz)');set(gca,'fontweight','bold');
title('exemplar unwarped (dtw segmentation)');
xlabel('time (seconds)');

%plot warped template and exemplar with both amp/dtw segmentation
%onsets/offsets
figure;
subplot(2,1,1);hold on;
dtwtm = [0:length(ix)-1]/fs;
imagesc(dtwtm,f(indf),log(abs(sp1(indf,ix))));set(gca,'YDir','normal');hold on;
plot([dtwtm(ix_onind)' dtwtm(ix_onind)'],[1000 10000],'r');hold on;
plot([dtwtm(ix_offind)' dtwtm(ix_offind)'],[1000 10000],'r');hold on;
ylim([1000 10000]);xlim([dtwtm(1) dtwtm(end)]);
ylabel('frequency (hz)');set(gca,'fontweight','bold');
title('template warped');

subplot(2,1,2);hold on;
imagesc(dtwtm,f(indf),log(abs(sp2(indf,iy))));set(gca,'YDir','normal');hold on;
plot([dtwtm(iy_onind)' dtwtm(iy_onind)'],[1000 10000],'r');hold on;
plot([dtwtm(iy_offind)' dtwtm(iy_offind)'],[1000 10000],'r');hold on;
plot([dtwtm(ix_onind)' dtwtm(ix_onind)'],[1000 10000],'c');hold on;
plot([dtwtm(ix_offind)' dtwtm(ix_offind)'],[1000 10000],'c');hold on;
ylim([1000 10000]);xlim([dtwtm(1) dtwtm(end)]);
ylabel('frequency (hz)');set(gca,'fontweight','bold');
title('exemplar warped');
xlabel('time (seconds)');


