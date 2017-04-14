%% adjust SNR of single amp waveform by scaling syllables and test amp vs amp2 segmentation
fs=44100;
w = [-3:5];
motifsegment = motifsegment_bcd_11_14_2015_saline;

sm=log(motifsegment(1).sm);
sm_amp = sm;sm_amp=sm_amp-min(sm_amp);sm_amp=sm_amp/max(sm_amp);
sm_amp2=sm;sm_amp2=sm_amp2-mean(sm_amp2);
ons=motifsegment(1).ph_ons;
offs=motifsegment(1).ph_offs;
interval=zeros(length(sm),1);
ampdurs = [];ampgaps = [];
amp2durs=[];amp2gaps=[];
for ii=1:length(w)
    for i = 1:length(ons)
        seg = floor(ons(i)*fs):floor(offs(i)*fs);
        interval(seg)=normrnd(w(ii),0.1,[length(seg),1]);
    end
    seg=1:floor(ons(1)*fs);
    interval(seg)=normrnd(0,0.1,[length(seg),1]);
    seg=floor(offs(3)*fs):length(interval);
    interval(seg)=normrnd(0,0.1,[length(seg),1]);
    for i = 1:length(ons)-1
        seg = floor(offs(i)*fs):floor(ons(i+1)*fs);
        interval(seg)=normrnd(0,0.1,[length(seg),1]);
    end
    
    sm2 = sm+interval;sm2=sm2-min(sm2);sm2=sm2/max(sm2);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0.3);
    figure;hold on;
    plot(sm_amp,'k');hold on;plot(sm2,'r');hold on;
    plot([ons2 ons2]*fs,[-5 5],'g');hold on;
    plot([offs2 offs2]*fs,[-5 5],'g');hold on;
    title(['amp ',num2str(w(ii))]);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    
    sm2 = sm+interval;sm2=sm2-mean(sm2);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0.3);
    figure;hold on;
    plot(sm_amp2,'k');hold on;plot(sm2,'r');hold on;
    plot([ons2 ons2]*fs,[-5 5],'g');hold on;
    plot([offs2 offs2]*fs,[-5 5],'g');hold on;
    title(['amp2 ',num2str(w(ii))]);
    amp2durs=[amp2durs;mean(offs2-ons2)];
    amp2gaps=[amp2gaps;mean(ons2(2:end)-offs2(1:end-1))];
end
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
w = 3;
motifsegment = motifsegment_bcd_11_14_2015_saline;
ampdurs = [];ampgaps = [];
amp2durs=[];amp2gaps=[];
for i = 1:length(motifsegment)
    sm=log(motifsegment(i).sm);
    ons=motifsegment(i).ph_ons;
    offs=motifsegment(i).ph_offs;
    interval=zeros(length(sm),1);
    for ii = 1:length(ons)
        seg = floor(ons(ii)*fs):floor(offs(ii)*fs);
        interval(seg)=normrnd(w,0.1,[length(seg),1]);
    end
    seg=1:floor(ons(1)*fs);
    interval(seg)=normrnd(0,0.1,[length(seg),1]);
    seg=floor(offs(3)*fs):length(interval);
    interval(seg)=normrnd(0,0.1,[length(seg),1]);
    for ii = 1:length(ons)-1
        seg = floor(offs(ii)*fs):floor(ons(ii+1)*fs);
        interval(seg)=normrnd(0,0.1,[length(seg),1]);
    end
    
    sm2 = sm+interval;sm2=sm2-min(sm2);sm2=sm2/max(sm2);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0.3);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    
    sm2 = sm+interval;sm2=sm2-mean(sm2);
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

%% shorten the gaps in one amp wv and test dtw 
fs=44100;
w = [1:5];
motifsegment = motifsegment_bcd_11_14_2015_saline;
sm=log(motifsegment(1).sm);
sm_amp = sm;sm_amp=sm_amp-min(sm_amp);sm_amp=sm_amp/max(sm_amp);
sm_amp2=sm;sm_amp2=sm_amp2-mean(sm_amp2);
ons=motifsegment(1).ph_ons;
offs=motifsegment(1).ph_offs;
ampdurs = [];ampgaps = [];
amp2durs=[];amp2gaps=[];
for ii=1:length(w)
    interval = [];
    seg=1:floor(ons(1)*fs);
    seg = downsample(seg,w(ii));
    interval=[interval;seg'];
    seg=floor(offs(end)*fs):length(interval);
    seg=downsample(seg,w(ii));
    interval=[interval;seg'];
    for i = 1:length(ons)-1
        seg = floor(offs(i)*fs):floor(ons(i+1)*fs);
        seg =downsample(seg,w(ii));
        interval=[interval;seg'];
    end
    for i = 1:length(ons)
        seg = floor(ons(i)*fs):floor(offs(i)*fs);
        interval=[interval;seg'];
    end
    interval=sort(interval);
    
    sm2 = sm(interval);sm2=sm2-min(sm2);sm2=sm2/max(sm2);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0.3);
    figure;hold on;
    plot(sm_amp,'k');hold on;plot(sm2,'r');hold on;
    plot([ons2 ons2]*fs,[-5 5],'g');hold on;
    plot([offs2 offs2]*fs,[-5 5],'g');hold on;
    title(['amp ',num2str(w(ii))]);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    
    sm2 = sm(interval);sm2=sm2-mean(sm2);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0);
    figure;hold on;
    plot(sm_amp2,'k');hold on;plot(sm2,'r');hold on;
    plot([ons2 ons2]*fs,[-5 5],'g');hold on;
    plot([offs2 offs2]*fs,[-5 5],'g');hold on;
    title(['amp2 ',num2str(w(ii))]);
    amp2durs=[amp2durs;mean(offs2-ons2)];
    amp2gaps=[amp2gaps;mean(ons2(2:end)-offs2(1:end-1))];
end
figure;plot(w,ampdurs,'ok');hold on;plot(w,amp2durs,'or');
xlabel('downsampling factor');ylabel('duration (sec)');title('syllables');
set(gca,'fontweight','bold');
legend('amp','amp2');
figure;plot(w,ampgaps,'ok');hold on;plot(w,amp2gaps,'or');
xlabel('downsampling factor');ylabel('duration (sec)');title('gaps');
set(gca,'fontweight','bold');
legend('amp','amp2');

%% adjust gap of amp wv from condition and test dtw vs amp segmentation
fs=44100;
w = 2;
motifsegment = motifsegment_bcd_11_14_2015_saline;
ampdurs = [];ampgaps = [];
amp2durs=[];amp2gaps=[];
for ii=1:length(motifsegment)
    sm=log(motifsegment(ii).sm);
    ons=motifsegment(ii).ph_ons;
    offs=motifsegment(ii).ph_offs;
    interval = [];
    seg=1:floor(ons(1)*fs);
    interval=[interval;seg'];
    seg=floor(offs(end)*fs):length(sm);
    interval=[interval;seg'];
    for i = 1:length(ons)-1
        seg = floor(offs(i)*fs):floor(ons(i+1)*fs);
        seg =downsample(seg,w);
        interval=[interval;seg'];
    end
    for i = 1:length(ons)
        seg = floor(ons(i)*fs):floor(offs(i)*fs);
        interval=[interval;seg'];
    end
    interval=sort(interval);
    
    sm2 = sm(interval);sm2=sm2-min(sm2);sm2=sm2/max(sm2);
    [ons2 offs2] = SegmentNotes(sm2,fs,5,20,0.3);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    
    sm2 = sm(interval);sm2=sm2-mean(sm2);
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