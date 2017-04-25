%% this script tests the robustness of dtw on spectrograms for segmentation

%% adjust SNR of single spectrogram by scaling syllables and test dtw vs amp segmentation
fs=44100;
wgt = [0.95:0.01:1.05];%scaling factors for syllables
motifsegment = motifsegment_bcd_11_14_2015_saline;

%params for spectrogram
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

%extract template
temp=abs(dtwtemplate.filtsong);
temp_ons=dtwtemplate.ons;
temp_offs=dtwtemplate.offs;
[sp f tm1] = spectrogram(temp,w,overlap,NFFT,fs);
indf = find(f>1000 & f<10000);
temp = abs(sp(indf,:));
temp = temp./sum(temp,2);

%extract one amp wv to manipulate
smtemp=motifsegment(1).smtemp;
filtsong = abs(bandpass(smtemp,fs,1000,10000,'hanningffir'));
ons=motifsegment(1).amp_ons-0.004;
offs=motifsegment(1).amp_offs+0.004;
sm = log(evsmooth(filtsong,fs,'','','',2));

%measure gaps/syllables after scaling syllables
ampdurs = [];ampgaps = [];
dtwdurs=[];dtwgaps=[];
for ii=1:length(wgt)
    interval=zeros(length(filtsong),1);
    for i = 1:length(ons)%sylls
        seg = floor(ons(i)*fs):floor(offs(i)*fs);
        interval(seg) = normrnd(1+(1-wgt(ii)),0.001,[length(seg),1]);%(1+(1-w(ii)) because wav files bc multiplying to negative vals in wav file
    end
    seg=1:floor(ons(1)*fs);%beginning
    interval(seg)=normrnd(1,0.001,[length(seg),1]);
    seg=floor(offs(3)*fs):length(interval);%end
    interval(seg)=normrnd(1,0.001,[length(seg),1]);
    for i = 1:length(ons)-1%gaps
        seg = floor(offs(i)*fs):floor(ons(i+1)*fs);
        interval(seg)=normrnd(1,0.001,[length(seg),1]);
    end
    filtsong2 = filtsong.^interval;
    sm_scaled = log(evsmooth(filtsong2,fs,'','','',2));
    
    %amp
    sm2=(sm_scaled-mean(sm_scaled))/std(sm_scaled);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0);
    figure;hold on;
    plot((sm-mean(sm))/std(sm),'k');hold on;plot(sm2,'r');hold on;
    plot([ons2 ons2]*fs,[min(sm2) max(sm2)],'g');hold on;
    plot([offs2 offs2]*fs,[min(sm2) max(sm2)],'g');hold on;
    title(['amp ',num2str(wgt(ii))]);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    
    %dtw
    [sp f tm2] = spectrogram(filtsong2,w,overlap,NFFT,fs);
    indf = find(f>1000 & f <10000);
    sm2_sp = abs(sp(indf,:));
    sm2_sp = sm2_sp./sum(sm2_sp,2);
    [dist ix iy] = dtw(temp,sm2_sp);
    onind = [];offind = [];
    for i = 1:length(temp_ons)
        [~, onind(i)] = min(abs(temp_ons(i)-tm1));
        [~, offind(i)]=min(abs(temp_offs(i)-tm1));
    end
    ons2 = [];
    offs2 = [];
    for i = 1:length(onind)
        ind = find(ix==onind(i));
        ind = ind(ceil(length(ind)/2));
        ons2 = [ons2;iy(ind)];
        ind = find(ix==offind(i));
        ind = ind(ceil(length(ind)/2));
        offs2 = [offs2;iy(ind)];
    end
    ons2 = tm2(ons2)';offs2=tm2(offs2)';
    figure;hold on;
    plot(sm,'k');hold on;plot(sm_scaled,'r');hold on;
    plot([ons2 ons2]*fs,[min(sm) max(sm)],'g');hold on;
    plot([offs2 offs2]*fs,[min(sm) max(sm)],'g');hold on;
    title(['dtw ',num2str(wgt(ii))]);
    dtwdurs=[dtwdurs;mean(offs2-ons2)];
    dtwgaps=[dtwgaps;mean(ons2(2:end)-offs2(1:end-1))];
end
figure;plot(wgt,ampdurs,'ok');hold on;plot(wgt,dtwdurs,'or');
xlabel('scaling factor');ylabel('duration (sec)');title('syllables');
set(gca,'fontweight','bold');
legend('amp','dtw');
figure;plot(wgt,ampgaps,'ok');hold on;plot(wgt,dtwgaps,'or');
xlabel('scaling factor');ylabel('duration (sec)');title('gaps');
set(gca,'fontweight','bold');
legend('amp','dtw');

%% adjust SNR of amp wv from condition by scaling syllables and test dtw vs amp segmentation
fs=44100;
wgt = 1.05;%percentage to scale syllable
motifsegment = motifsegment_bcd_11_14_2015_saline;

%params for spectrogram
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

%extract template 
temp=abs(dtwtemplate.filtsong);
temp_ons=dtwtemplate.ons;
temp_offs=dtwtemplate.offs;
[sp f tm1] = spectrogram(temp,w,overlap,NFFT,fs);
indf = find(f>1000 & f<10000);
temp = abs(sp(indf,:));
temp = temp./sum(temp,2);

%for each motif, measure syll/gaps after scaling syllables
ampdurs = [];ampgaps = [];
dtwdurs=[];dtwgaps=[];
for i = 1:length(motifsegment)
    smtemp=motifsegment(i).smtemp;
    filtsong = abs(bandpass(smtemp,fs,1000,10000,'hanningffir'));
    ons=motifsegment(i).amp_ons-0.004;
    offs=motifsegment(i).amp_offs+0.004;
    if isempty(ons) | floor(offs(end)*fs) > length(filtsong)
        continue
    end
    
    interval=zeros(length(filtsong),1);
    for ii = 1:length(ons)%sylls
        seg = floor(ons(ii)*fs):floor(offs(ii)*fs);
        interval(seg)=normrnd(1+(1-wgt),0.001,[length(seg),1]);
    end
    seg=1:floor(ons(1)*fs);%beginning
    interval(seg)=normrnd(1,0.001,[length(seg),1]);
    seg=floor(offs(end)*fs):length(interval);%end
    interval(seg)=normrnd(1,0.001,[length(seg),1]);
    for ii = 1:length(ons)-1%gaps
        seg = floor(offs(ii)*fs):floor(ons(ii+1)*fs);
        interval(seg)=normrnd(1,0.001,[length(seg),1]);
    end
    filtsong2 = filtsong.^interval;
    sm_scaled = log(evsmooth(filtsong2,fs,'','','',2));
    
    %amp
    sm2=(sm_scaled-mean(sm_scaled))/std(sm_scaled);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    
    %dtw
    [sp f tm2] = spectrogram(filtsong2,w,overlap,NFFT,fs);
    indf = find(f>1000 & f <10000);
    sm2_sp = abs(sp(indf,:));
    sm2_sp = sm2_sp./sum(sm2_sp,2);
    [dist ix iy] = dtw(temp,sm2_sp);
    onind = [];offind = [];
    for ii = 1:length(temp_ons)
        [~, onind(ii)] = min(abs(temp_ons(ii)-tm1));
        [~, offind(ii)]=min(abs(temp_offs(ii)-tm1));
    end
    ons2 = [];
    offs2 = [];
    for ii = 1:length(onind)
        ind = find(ix==onind(ii));
        ind = ind(ceil(length(ind)/2));
        ons2 = [ons2;iy(ind)];
        ind = find(ix==offind(ii));
        ind = ind(ceil(length(ind)/2));
        offs2 = [offs2;iy(ind)];
    end
    ons2 = tm2(ons2)';offs2=tm2(offs2)';
    dtwdurs=[dtwdurs;mean(offs2-ons2)];
    dtwgaps=[dtwgaps;mean(ons2(2:end)-offs2(1:end-1))];
end
durs1 = mean([motifsegment(:).amp_durs]);
durs2 = mean([motifsegment(:).ph_durs]);
gaps1 = mean([motifsegment(:).amp_gaps]);
gaps2 = mean([motifsegment(:).ph_gaps]);

%plot distribution of durations for amp2 segmentation
figure;subplot(2,1,1);hold on;
minval = min([ampdurs;durs1']);maxval = max([ampdurs;durs1']);
[n b] = hist(durs1,[minval:0.001:maxval]);stairs(b,n/sum(n),'k');
[n b] = hist(ampdurs,[minval:0.001:maxval]);stairs(b,n/sum(n),'r');
[h p] = ttest2(ampdurs,durs1);
y = get(gca,'ylim');set(gca,'ylim',y);
x = get(gca,'xlim');set(gca,'xlim',x);
text(x(1),y(2),{['p=',num2str(p)]});
legend('before','after');
set(gca,'fontweight','bold');title('syllables amp');
ylabel('probability');
subplot(2,1,2);hold on;
minval = min([ampgaps;gaps1']);maxval = max([ampgaps;gaps1']);
[n b] = hist(gaps1,[minval:0.001:maxval]);stairs(b,n/sum(n),'k');
[n b] = hist(ampgaps,[minval:0.001:maxval]);stairs(b,n/sum(n),'r');
[h p] = ttest2(ampgaps,gaps1);
y = get(gca,'ylim');set(gca,'ylim',y);
x = get(gca,'xlim');set(gca,'xlim',x);
text(x(1),y(2),{['p=',num2str(p)]});
legend('before','after');
set(gca,'fontweight','bold');title('gaps amp');
xlabel('duration (sec)');ylabel('probability')

%plot distribution of durations for dtw segmentation
figure;subplot(2,1,1);hold on;
minval = min([dtwdurs;durs2']);maxval = max([dtwdurs;durs2']);
[n b] = hist(durs2,[minval:0.001:maxval]);stairs(b,n/sum(n),'k');
[n b] = hist(dtwdurs,[minval:0.001:maxval]);stairs(b,n/sum(n),'r');
[h p] = ttest2(dtwdurs,durs2);
y = get(gca,'ylim');set(gca,'ylim',y);
x = get(gca,'xlim');set(gca,'xlim',x);
text(x(1),y(2),{['p=',num2str(p)]});
legend('before','after');
set(gca,'fontweight','bold');title('syllables dtw');
ylabel('probability');
subplot(2,1,2);hold on;
minval = min([dtwgaps;gaps2']);maxval = max([dtwgaps;gaps2']);
[n b] = hist(gaps2,[minval:0.001:maxval]);stairs(b,n/sum(n),'k');
[n b] = hist(dtwgaps,[minval:0.001:maxval]);stairs(b,n/sum(n),'r');
[h p] = ttest2(dtwgaps,gaps2);
y = get(gca,'ylim');set(gca,'ylim',y);
x = get(gca,'xlim');set(gca,'xlim',x);
text(x(1),y(2),{['p=',num2str(p)]});
legend('before','after');
set(gca,'fontweight','bold');title('gaps dtw');
xlabel('duration (sec)');ylabel('probability');

%% shorten the gaps in one amp wv and test dtw 
fs=44100;
wgt = [0:0.01:0.1];%percentage of gaps to shorten
motifsegment = motifsegment_bcd_11_14_2015_saline;

%params for spectrogram
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

%extract template spectrogram to use for dtw 
temp=abs(dtwtemplate.filtsong);
temp_ons=dtwtemplate.ons;
temp_offs=dtwtemplate.offs;
[sp f tm1] = spectrogram(temp,w,overlap,NFFT,fs);
indf = find(f>1000 & f<10000);
temp = abs(sp(indf,:));
temp = temp./sum(temp,2);

%extract one amp wv to manipulate
smtemp=motifsegment(1).smtemp;
filtsong = abs(bandpass(smtemp,fs,1000,10000,'hanningffir'));
ons=motifsegment(1).amp_ons-0.008;
offs=motifsegment(1).amp_offs+0.008;
sm = log(evsmooth(filtsong,fs,'','','',2));

%measure sylls/gaps at different gap lengths
ampdurs = [];ampgaps = [];
dtwdurs=[];dtwgaps=[];
for ii=1:length(wgt)
    interval = [];
    seg=1:floor(ons(1)*fs);%beginning 
    interval=[interval;seg'];
    seg=floor(offs(end)*fs):length(filtsong);%end
    interval=[interval;seg'];
    for i = 1:length(ons)-1%gaps
        seg = floor(offs(i)*fs):floor(ons(i+1)*fs);
        seg = seg(randperm(length(seg),floor((1-wgt(ii))*length(seg))));
        interval=[interval;seg'];
    end
    for i = 1:length(ons)%sylls
        seg = floor(ons(i)*fs):floor(offs(i)*fs);
        interval=[interval;seg'];
    end
    interval=sort(interval);
    filtsong2 = filtsong(interval);
    sm_scaled = log(evsmooth(filtsong2,fs,'','','',2));
    
    %amp
    sm2=(sm_scaled-mean(sm_scaled))/std(sm_scaled);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0);
    figure;hold on;
    plot((sm-mean(sm))/std(sm),'k');hold on;plot(sm2,'r');hold on;
    plot([ons2 ons2]*fs,[min(sm2) max(sm2)],'g');hold on;
    plot([offs2 offs2]*fs,[min(sm2) max(sm2)],'g');hold on;
    title(['amp ',num2str(wgt(ii))]);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    
    %dtw
    [sp f tm2] = spectrogram(filtsong2,w,overlap,NFFT,fs);
    indf = find(f>1000 & f <10000);
    sm2_sp = abs(sp(indf,:));
    sm2_sp = sm2_sp./sum(sm2_sp,2);
    [dist ix iy] = dtw(temp,sm2_sp);
    onind = [];offind = [];
    for i = 1:length(temp_ons)
        [~, onind(i)] = min(abs(temp_ons(i)-tm1));
        [~, offind(i)]=min(abs(temp_offs(i)-tm1));
    end
    ons2 = [];
    offs2 = [];
    for i = 1:length(onind)
        ind = find(ix==onind(i));
        ind = ind(ceil(length(ind)/2));
        ons2 = [ons2;iy(ind)];
        ind = find(ix==offind(i));
        ind = ind(ceil(length(ind)/2));
        offs2 = [offs2;iy(ind)];
    end
    ons2 = tm2(ons2)';offs2=tm2(offs2)';
    figure;hold on;
    plot(sm,'k');hold on;plot(sm_scaled,'r');hold on;
    plot([ons2 ons2]*fs,[min(sm) max(sm)],'g');hold on;
    plot([offs2 offs2]*fs,[min(sm) max(sm)],'g');hold on;
    title(['dtw ',num2str(wgt(ii))]);
    dtwdurs=[dtwdurs;mean(offs2-ons2)];
    dtwgaps=[dtwgaps;mean(ons2(2:end)-offs2(1:end-1))];
end

%plot syll/gap measurements at different gap lengths for both methods
figure;plot(wgt,ampdurs,'ok');hold on;plot(wgt,dtwdurs,'or');
xlabel('percent shorten');ylabel('duration (sec)');title('syllables');
set(gca,'fontweight','bold');
legend('amp','dtw');
figure;plot(wgt,ampgaps,'ok');hold on;plot(wgt,dtwgaps,'or');
xlabel('percent shorten');ylabel('duration (sec)');title('gaps');
set(gca,'fontweight','bold');
legend('amp','dtw');

%% adjust gap of all amp wvs in real data and test dtw vs amp segmentation
fs=44100;
wgt = 0.05;%percentage of gap to reduce
motifsegment = motifsegment_bcd_11_14_2015_saline;

%params for spectrogram
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

%extract template 
temp=abs(dtwtemplate.filtsong);
temp_ons=dtwtemplate.ons;
temp_offs=dtwtemplate.offs;
[sp f tm1] = spectrogram(temp,w,overlap,NFFT,fs);
indf = find(f>1000 & f<10000);
temp = abs(sp(indf,:));
temp = temp./sum(temp,2);

%for each motif, shorten gaps by wgt percentage
ampdurs = [];ampgaps = [];
dtwdurs=[];dtwgaps=[];
for ii=1:length(motifsegment)
    smtemp=motifsegment(ii).smtemp;
    filtsong = abs(bandpass(smtemp,fs,1000,10000,'hanningffir'));
    ons=motifsegment(ii).amp_ons-0.008;
    offs=motifsegment(ii).amp_offs+0.008;
    if isempty(ons) | floor(offs(end)*fs) > length(filtsong)
        continue
    end
    
    interval = [];
    seg=1:floor(ons(1)*fs);%beginning
    interval=[interval;seg'];
    seg=floor(offs(end)*fs):length(filtsong);%end
    interval=[interval;seg'];
    for i = 1:length(ons)-1 %gaps
        seg = floor(offs(i)*fs):floor(ons(i+1)*fs);
        seg = seg(randperm(length(seg),floor((1-wgt)*length(seg))));
        interval=[interval;seg'];
    end
    for i = 1:length(ons) %sylls
        seg = floor(ons(i)*fs):floor(offs(i)*fs);
        interval=[interval;seg'];
    end
    interval=sort(interval);
    filtsong2 = filtsong(interval);
    sm_scaled = log(evsmooth(filtsong2,fs,'','','',2));
    
    %amp segmentation
    sm2=(sm_scaled-mean(sm_scaled))/std(sm_scaled);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    
    %dtw 
    [sp f tm2] = spectrogram(filtsong2,w,overlap,NFFT,fs);
    indf = find(f>1000 & f <10000);
    sm2_sp = abs(sp(indf,:));
    sm2_sp = sm2_sp./sum(sm2_sp,2);
    [dist ix iy] = dtw(temp,sm2_sp);
    onind = [];offind = [];
    for i = 1:length(temp_ons)
        [~, onind(i)] = min(abs(temp_ons(i)-tm1));
        [~, offind(i)]=min(abs(temp_offs(i)-tm1));
    end
    ons2 = [];
    offs2 = [];
    for i = 1:length(onind)
        ind = find(ix==onind(i));
        ind = ind(ceil(length(ind)/2));
        ons2 = [ons2;iy(ind)];
        ind = find(ix==offind(i));
        ind = ind(ceil(length(ind)/2));
        offs2 = [offs2;iy(ind)];
    end
    ons2 = tm2(ons2)';offs2=tm2(offs2)';
    
    dtwdurs=[dtwdurs;mean(offs2-ons2)];
    dtwgaps=[dtwgaps;mean(ons2(2:end)-offs2(1:end-1))];
end
%extract original amp and dtw segmentation
durs1 = mean([motifsegment(:).amp_durs]);
durs2 = mean([motifsegment(:).ph_durs]);
gaps1 = mean([motifsegment(:).amp_gaps]);
gaps2 = mean([motifsegment(:).ph_gaps]);

%plot distribution of durations for amp1 segmentation
figure;subplot(2,1,1);hold on;
minval = min([ampdurs;durs1']);maxval = max([ampdurs;durs1']);
[n b] = hist(durs1,[minval:0.001:maxval]);stairs(b,n/sum(n),'k');
[n b] = hist(ampdurs,[minval:0.001:maxval]);stairs(b,n/sum(n),'r');
[h p] = ttest2(ampdurs,durs1);
y = get(gca,'ylim');set(gca,'ylim',y);
x = get(gca,'xlim');set(gca,'xlim',x);
text(x(1),y(2),{['p=',num2str(p)]});
legend('before','after');
set(gca,'fontweight','bold');title('syllables amp');
ylabel('probability');
subplot(2,1,2);hold on;
minval = min([ampgaps;gaps1']);maxval = max([ampgaps;gaps1']);
[n b] = hist(gaps1,[minval:0.001:maxval]);stairs(b,n/sum(n),'k');
[n b] = hist(ampgaps,[minval:0.001:maxval]);stairs(b,n/sum(n),'r');
[h p] = ttest2(ampgaps,gaps1);
y = get(gca,'ylim');set(gca,'ylim',y);
x = get(gca,'xlim');set(gca,'xlim',x);
text(x(1),y(2),{['p=',num2str(p)]});
legend('before','after');
set(gca,'fontweight','bold');title('gaps amp');
xlabel('duration (seconds)');ylabel('probability');

%plot distribution of durations for dtw segmentation
figure;subplot(2,1,1);hold on;
minval = min([dtwdurs;durs2']);maxval = max([dtwdurs;durs2']);
[n b] = hist(durs2,[minval:0.001:maxval]);stairs(b,n/sum(n),'k');
[n b] = hist(dtwdurs,[minval:0.001:maxval]);stairs(b,n/sum(n),'r');
[h p] = ttest2(dtwdurs,durs2);
y = get(gca,'ylim');set(gca,'ylim',y);
x = get(gca,'xlim');set(gca,'xlim',x);
text(x(1),y(2),{['p=',num2str(p)]});
legend('before','after');
set(gca,'fontweight','bold');title('syllables dtw');
ylabel('probability');
subplot(2,1,2);hold on;
minval = min([dtwgaps;gaps2']);maxval = max([dtwgaps;gaps2']);
[n b] = hist(gaps2,[minval:0.001:maxval]);stairs(b,n/sum(n),'k');
[n b] = hist(dtwgaps,[minval:0.001:maxval]);stairs(b,n/sum(n),'r');
[h p] = ttest2(dtwgaps,gaps2);
y = get(gca,'ylim');set(gca,'ylim',y);
x = get(gca,'xlim');set(gca,'xlim',x);
text(x(1),y(2),{['p=',num2str(p)]});
legend('before','after');
set(gca,'fontweight','bold');title('gaps dtw');
xlabel('duration (seconds)');ylabel('probability');