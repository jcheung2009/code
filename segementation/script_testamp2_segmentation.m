%this script tests the robustness of amp segmentation methods 

%% adjust SNR of single amp waveform by scaling syllables and test amp vs amp2 segmentation
fs=44100;
w = [0.95:0.01:1.05];%scaling factors for syllables
motifsegment = motifsegment_bcd_11_14_2015_saline;

%extract one amp wv to manipulate
smtemp = motifsegment(1).smtemp;
filtsong = abs(bandpass(smtemp,fs,1000,10000,'hanningffir'));
sm = log(evsmooth(filtsong,fs,'','','',2));
sm_amp=sm;sm_amp=sm_amp-min(sm_amp);sm_amp=sm_amp/max(sm_amp);
sm_amp2=sm;sm_amp2=(sm_amp2-mean(sm_amp2))/std(sm_amp2);
ons=motifsegment(1).amp_ons-0.004;
offs=motifsegment(1).amp_offs+0.004;

%measure gaps/syllables after scaling syllables
ampdurs = [];ampgaps = [];
amp2durs=[];amp2gaps=[];
for ii=1:length(w)
    interval=zeros(length(filtsong),1);
    for i = 1:length(ons)%sylls
        seg = floor(ons(i)*fs):floor(offs(i)*fs);
        interval(seg) = normrnd(1+(1-w(ii)),0.001,[length(seg),1]);
    end
    seg=1:floor(ons(1)*fs);%beginning
    interval(seg)=normrnd(1,0.001,[length(seg),1]);
    seg=floor(offs(end)*fs):length(interval);%end
    interval(seg)=normrnd(1,0.001,[length(seg),1]);
    for i = 1:length(ons)-1%gaps
        seg = floor(offs(i)*fs):floor(ons(i+1)*fs);
        interval(seg)=normrnd(1,0.001,[length(seg),1]);
    end
    filtsong2 = filtsong.^interval;
    sm_scaled = log(evsmooth(filtsong2,fs,'','','',2));
    
    %amp1
    sm2=sm_scaled-min(sm_scaled);sm2=sm2/max(sm2);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0.3);
    figure;hold on;
    plot(sm_amp,'k');hold on;plot(sm2,'r');hold on;
    plot([ons2 ons2]*fs,[0 1],'g');hold on;
    plot([offs2 offs2]*fs,[0 1],'g');hold on;
    title(['amp ',num2str(w(ii))]);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    
    %amp2
    sm2=(sm_scaled-mean(sm_scaled))/std(sm_scaled);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0);
    figure;hold on;
    plot(sm_amp2,'k');hold on;plot(sm2,'r');hold on;
    plot([ons2 ons2]*fs,[min(sm2) max(sm2)],'g');hold on;
    plot([offs2 offs2]*fs,[min(sm2) max(sm2)],'g');hold on;
    title(['amp2 ',num2str(w(ii))]);
    amp2durs=[amp2durs;mean(offs2-ons2)];
    amp2gaps=[amp2gaps;mean(ons2(2:end)-offs2(1:end-1))];
end
%plot syll/gaps measured for each method
figure;plot(w,ampdurs,'ok');hold on;plot(w,amp2durs,'or');
xlabel('scaling factor');ylabel('duration (sec)');title('syllables');
set(gca,'fontweight','bold');
legend('amp','amp2');
figure;plot(w,ampgaps,'ok');hold on;plot(w,amp2gaps,'or');
xlabel('scaling factor');ylabel('duration (sec)');title('gaps');
set(gca,'fontweight','bold');
legend('amp','amp2');

%% adjust SNR of amp wv from condition by scaling syllables and test amp1 vs amp2 segmentation
fs=44100;
w = 1.05;%percentage to increase sylls
motifsegment = motifsegment_bcd_11_14_2015_saline;
ampdurs = [];ampgaps = [];
amp2durs=[];amp2gaps=[];
for i = 1:length(motifsegment)
    smtemp = motifsegment(i).smtemp;
    filtsong = abs(bandpass(smtemp,fs,1000,10000,'hanningffir'));
    ons=motifsegment(i).amp_ons-0.004;
    offs=motifsegment(i).amp_offs+0.004;
    if isempty(ons) | floor(offs(end)*fs) > length(filtsong) | ons(1)<0
        continue
    end
    
    interval=zeros(length(filtsong),1);
    for ii = 1:length(ons)%sylls
        seg = floor(ons(ii)*fs):floor(offs(ii)*fs);
        interval(seg)=normrnd(1+(1-w),0.001,[length(seg),1]);
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
    
    %amp1
    sm2=sm_scaled-min(sm_scaled);sm2=sm2/max(sm2);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0.3);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    
    %amp2
    sm2=(sm_scaled-mean(sm_scaled))/std(sm_scaled);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0);
    amp2durs=[amp2durs;mean(offs2-ons2)];
    amp2gaps=[amp2gaps;mean(ons2(2:end)-offs2(1:end-1))];
end
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
set(gca,'fontweight','bold');title('syllables');
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
set(gca,'fontweight','bold');title('gaps');
xlabel('duration (seconds)');ylabel('probability');

%plot distribution of durations for amp2 segmentation
figure;subplot(2,1,1);hold on;
minval = min([amp2durs;durs2']);maxval = max([amp2durs;durs2']);
[n b] = hist(durs2,[minval:0.001:maxval]);stairs(b,n/sum(n),'k');
[n b] = hist(amp2durs,[minval:0.001:maxval]);stairs(b,n/sum(n),'r');
[h p] = ttest2(amp2durs,durs2);
y = get(gca,'ylim');set(gca,'ylim',y);
x = get(gca,'xlim');set(gca,'xlim',x);
text(x(1),y(2),{['p=',num2str(p)]});
legend('before','after');
set(gca,'fontweight','bold');title('syllables');
ylabel('probability');
subplot(2,1,2);hold on;
minval = min([amp2gaps;gaps2']);maxval = max([amp2gaps;gaps2']);
[n b] = hist(gaps2,[minval:0.001:maxval]);stairs(b,n/sum(n),'k');
[n b] = hist(amp2gaps,[minval:0.001:maxval]);stairs(b,n/sum(n),'r');
[h p] = ttest2(amp2gaps,gaps2);
y = get(gca,'ylim');set(gca,'ylim',y);
x = get(gca,'xlim');set(gca,'xlim',x);
text(x(1),y(2),{['p=',num2str(p)]});
legend('before','after');
set(gca,'fontweight','bold');title('gaps');
xlabel('duration (seconds)');ylabel('probability');

%% shorten the gaps in one amp wv and test amp segmentations 
fs=44100;
w = [0:0.01:0.1];%percentage of gaps to shorten
motifsegment = motifsegment_bcd_11_14_2015_saline;

%extract one amp wv to manipulate
smtemp = motifsegment(1).smtemp;
filtsong = abs(bandpass(smtemp,fs,1000,10000,'hanningffir'));
sm = log(evsmooth(filtsong,fs,'','','',2));
sm_amp=sm;sm_amp=sm_amp-min(sm_amp);sm_amp=sm_amp/max(sm_amp);
sm_amp2=sm;sm_amp2=(sm_amp2-mean(sm_amp2))/std(sm_amp2);
ons=motifsegment(1).amp_ons-0.004;
offs=motifsegment(1).amp_offs+0.004;

%measure sylls/gaps for both methods
ampdurs = [];ampgaps = [];
amp2durs=[];amp2gaps=[];
for ii=1:length(w)
    interval = [];
    seg=1:floor(ons(1)*fs);%beginning
    interval=[interval;seg'];
    seg=floor(offs(end)*fs):length(filtsong);%end
    interval=[interval;seg'];
    for i = 1:length(ons)-1%gaps
        seg = floor(offs(i)*fs):floor(ons(i+1)*fs);
        seg = seg(randperm(length(seg),floor((1-w(ii))*length(seg))));
        interval=[interval;seg'];
    end
    for i = 1:length(ons)
        seg = floor(ons(i)*fs):floor(offs(i)*fs);
        interval=[interval;seg'];
    end
    interval=sort(interval);
    filtsong2 = filtsong(interval);
    sm_scaled = log(evsmooth(filtsong2,fs,'','','',2));
    
    %amp1
    sm2=sm_scaled-min(sm_scaled);sm2=sm2/max(sm2);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0.3);
    figure;hold on;
    plot(sm_amp,'k');hold on;plot(sm2,'r');hold on;
    plot([ons2 ons2]*fs,[0 1],'g');hold on;
    plot([offs2 offs2]*fs,[0 1],'g');hold on;
    title(['amp ',num2str(w(ii))]);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    
    %amp2
    sm2=(sm_scaled-mean(sm_scaled))/std(sm_scaled);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0);
    figure;hold on;
    plot(sm_amp2,'k');hold on;plot(sm2,'r');hold on;
    plot([ons2 ons2]*fs,[min(sm2) max(sm2)],'g');hold on;
    plot([offs2 offs2]*fs,[min(sm2) max(sm2)],'g');hold on;
    title(['amp2 ',num2str(w(ii))]);
    amp2durs=[amp2durs;mean(offs2-ons2)];
    amp2gaps=[amp2gaps;mean(ons2(2:end)-offs2(1:end-1))];
end
figure;plot(w,ampdurs,'ok');hold on;plot(w,amp2durs,'or');
xlabel('percent shorten');ylabel('duration (sec)');title('syllables');
set(gca,'fontweight','bold');
legend('amp','amp2');
figure;plot(w,ampgaps,'ok');hold on;plot(w,amp2gaps,'or');
xlabel('percent shorten');ylabel('duration (sec)');title('gaps');
set(gca,'fontweight','bold');
legend('amp','amp2');

%% adjust gap of amp wv from condition and test amp segmentation
fs=44100;
w = 0.05;%percentage of gap to reduce
motifsegment = motifsegment_bcd_11_14_2015_saline;

ampdurs = [];ampgaps = [];
amp2durs=[];amp2gaps=[];
for ii=1:length(motifsegment)
    smtemp = motifsegment(ii).smtemp;
    filtsong = abs(bandpass(smtemp,fs,1000,10000,'hanningffir'));
    ons=motifsegment(ii).amp_ons-0.004;
    offs=motifsegment(ii).amp_offs+0.004;
    if isempty(ons) | floor(offs(end)*fs) > length(filtsong) | ons(1)<0
        continue
    end
    
    interval = [];
    seg=1:floor(ons(1)*fs);%beginning
    interval=[interval;seg'];
    seg=floor(offs(end)*fs):length(filtsong);%end
    interval=[interval;seg'];
    for i = 1:length(ons)-1%gaps
        seg = floor(offs(i)*fs):floor(ons(i+1)*fs);
        seg = seg(randperm(length(seg),floor((1-w)*length(seg))));
        interval=[interval;seg'];
    end
    for i = 1:length(ons)%sylls
        seg = floor(ons(i)*fs):floor(offs(i)*fs);
        interval=[interval;seg'];
    end
    interval=sort(interval);
    filtsong2 = filtsong(interval);
    sm_scaled = log(evsmooth(filtsong2,fs,'','','',2));
    
    %amp1
    sm2=sm_scaled-min(sm_scaled);sm2=sm2/max(sm2);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0.3);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    
    %amp2
    sm2=(sm_scaled-mean(sm_scaled))/std(sm_scaled);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0);
    amp2durs=[amp2durs;mean(offs2-ons2)];
    amp2gaps=[amp2gaps;mean(ons2(2:end)-offs2(1:end-1))];
end
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
set(gca,'fontweight','bold');title('syllables');
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
set(gca,'fontweight','bold');title('gaps');
xlabel('duration (seconds)');ylabel('probability');

%plot distribution of durations for amp2 segmentation
figure;subplot(2,1,1);hold on;
minval = min([amp2durs;durs2']);maxval = max([amp2durs;durs2']);
[n b] = hist(durs2,[minval:0.001:maxval]);stairs(b,n/sum(n),'k');
[n b] = hist(amp2durs,[minval:0.001:maxval]);stairs(b,n/sum(n),'r');
[h p] = ttest2(amp2durs,durs2);
y = get(gca,'ylim');set(gca,'ylim',y);
x = get(gca,'xlim');set(gca,'xlim',x);
text(x(1),y(2),{['p=',num2str(p)]});
legend('before','after');
set(gca,'fontweight','bold');title('syllables');
ylabel('probability');
subplot(2,1,2);hold on;
minval = min([amp2gaps;gaps2']);maxval = max([amp2gaps;gaps2']);
[n b] = hist(gaps2,[minval:0.001:maxval]);stairs(b,n/sum(n),'k');
[n b] = hist(amp2gaps,[minval:0.001:maxval]);stairs(b,n/sum(n),'r');
[h p] = ttest2(amp2gaps,gaps2);
y = get(gca,'ylim');set(gca,'ylim',y);
x = get(gca,'xlim');set(gca,'xlim',x);
text(x(1),y(2),{['p=',num2str(p)]});
legend('before','after');
set(gca,'fontweight','bold');title('gaps');
xlabel('duration (seconds)');ylabel('probability');