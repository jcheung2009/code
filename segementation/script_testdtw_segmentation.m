%% adjust SNR of single amp waveform by scaling syllables and test dtw vs amp segmentation
fs=44100;
downsamp=2;
w = [-3:5];
motifsegment = motifsegment_bcd_11_14_2015_saline;

temp=downsample(log(dtwtemplate.sm),downsamp);
temp=temp-mean(temp);
temp_ons=dtwtemplate.ons;
temp_offs=dtwtemplate.offs;
sm=downsample(motifsegment(1).sm,downsamp);
sm=log(sm);sm=sm-mean(sm);
ons=motifsegment(1).ph_ons;
offs=motifsegment(1).ph_offs;
interval=zeros(length(sm),1);
ampdurs = [];ampgaps = [];
dtwdurs=[];dtwgaps=[];
for ii=1:length(w)
    for i = 1:length(ons)
        seg = floor(ons(i)*fs/downsamp):floor(offs(i)*fs/downsamp);
        interval(seg)=normrnd(w(ii),0.1,[length(seg),1]);
    end
    seg=1:floor(ons(1)*fs/downsamp);
    interval(seg)=normrnd(0,0.1,[length(seg),1]);
    seg=floor(offs(3)*fs/downsamp):length(interval);
    interval(seg)=normrnd(0,0.1,[length(seg),1]);
    for i = 1:length(ons)-1
        seg = floor(offs(i)*fs/downsamp):floor(ons(i+1)*fs/downsamp);
        interval(seg)=normrnd(0,0.1,[length(seg),1]);
    end
    sm2 = sm+interval;sm2=sm2-mean(sm2);
    [ons2 offs2] = SegmentNotes(sm2,fs/downsamp,5,20,0);
    figure;hold on;
    plot(sm,'k');hold on;plot(sm2,'r');hold on;
    plot([ons2 ons2]*fs/downsamp,[-5 5],'g');hold on;
    plot([offs2 offs2]*fs/downsamp,[-5 5],'g');hold on;
    title(['amp ',num2str(w(ii))]);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    [dist ix iy] = dtw(temp,sm2);
     onind =floor(temp_ons*fs/downsamp);offind=floor(temp_offs*fs/downsamp);
    ons2 = [];
    offs2 = [];
    for m = 1:length(onind)
        ind = find(ix==onind(m));
        ind = ind(ceil(length(ind)/2));
        ons2 = [ons2;iy(ind)];
        ind = find(ix==offind(m));
        ind = ind(ceil(length(ind)/2));
        offs2 = [offs2;iy(ind)];
    end
    ons2=ons2/(fs/downsamp);offs2=offs2/(fs/downsamp);
    figure;hold on;
    plot(sm,'k');hold on;plot(sm2,'r');hold on;
    plot([ons2 ons2]*fs/downsamp,[-5 5],'g');hold on;
    plot([offs2 offs2]*fs/downsamp,[-5 5],'g');hold on;
    title(['dtw ',num2str(w(ii))]);
    dtwdurs=[dtwdurs;mean(offs2-ons2)];
    dtwgaps=[dtwgaps;mean(ons2(2:end)-offs2(1:end-1))];
end
figure;plot(w,ampdurs,'ok');hold on;plot(w,dtwdurs,'or');
xlabel('scaling factor');ylabel('duration (sec)');title('syllables');
set(gca,'fontweight','bold');
legend('amp','dtw');
figure;plot(w,ampgaps,'ok');hold on;plot(w,dtwgaps,'or');
xlabel('scaling factor');ylabel('duration (sec)');title('gaps');
set(gca,'fontweight','bold');
legend('amp','dtw');

%% adjust SNR of amp wv from condition by scaling syllables and test dtw vs amp segmentation
fs=44100;
downsamp=2;
w = 3;
motifsegment = motifsegment_bcd_11_14_2015_saline;
temp=downsample(log(dtwtemplate.sm),downsamp);
temp=temp-mean(temp);
temp_ons=dtwtemplate.ons;
temp_offs=dtwtemplate.offs;
ampdurs = [];ampgaps = [];
dtwdurs=[];dtwgaps=[];
for i = 1:length(motifsegment)
    sm=downsample(motifsegment(i).sm,downsamp);
    sm=log(sm);sm=sm-mean(sm);
    ons=motifsegment(i).amp_ons;
    offs=motifsegment(i).amp_offs;
    interval=zeros(length(sm),1);
    for ii = 1:length(ons)
        seg = floor(ons(ii)*fs/downsamp):floor(offs(ii)*fs/downsamp);
        interval(seg)=normrnd(w,0.1,[length(seg),1]);
    end
    seg=1:floor(ons(1)*fs/downsamp);
    interval(seg)=normrnd(0,0.1,[length(seg),1]);
    seg=floor(offs(3)*fs/downsamp):length(interval);
    interval(seg)=normrnd(0,0.1,[length(seg),1]);
    for ii = 1:length(ons)-1
        seg = floor(offs(ii)*fs/downsamp):floor(ons(ii+1)*fs/downsamp);
        interval(seg)=normrnd(0,0.1,[length(seg),1]);
    end
    sm2 = sm+interval;sm2=sm2-mean(sm2);
    [ons2 offs2] = SegmentNotes(sm2,fs/downsamp,5,20,0);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    [dist ix iy] = dtw(temp,sm2);
    onind =floor(temp_ons*fs/downsamp);offind=floor(temp_offs*fs/downsamp);
    ons2 = [];
    offs2 = [];
    for m = 1:length(onind)
        ind = find(ix==onind(m));
        ind = ind(ceil(length(ind)/2));
        ons2 = [ons2;iy(ind)];
        ind = find(ix==offind(m));
        ind = ind(ceil(length(ind)/2));
        offs2 = [offs2;iy(ind)];
    end
    ons2=ons2/(fs/downsamp);offs2=offs2/(fs/downsamp);
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
xlabel('duration (sec)');

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
xlabel('duration (sec)');

%% shorten the gaps in one amp wv and test dtw 
fs=44100;
downsamp=2;
w = [1:5];
motifsegment = motifsegment_bcd_11_14_2015_saline;

temp=downsample(log(dtwtemplate.sm),downsamp);
temp=temp-mean(temp);
temp_ons=dtwtemplate.ons;
temp_offs=dtwtemplate.offs;
sm=downsample(motifsegment(1).sm,downsamp);
sm=log(sm);sm=sm-mean(sm);
ons=motifsegment(1).ph_ons-0.004;
offs=motifsegment(1).ph_offs+0.004;
ampdurs = [];ampgaps = [];
dtwdurs=[];dtwgaps=[];
for ii=1:length(w)
    interval = [];
    seg=1:floor(ons(1)*fs/downsamp);
    interval=[interval;seg'];
    seg=floor(offs(end)*fs/downsamp):length(sm);
    interval=[interval;seg'];
    for i = 1:length(ons)-1
        seg = floor(offs(i)*fs/downsamp):floor(ons(i+1)*fs/downsamp);
        seg =downsample(seg,w(ii));
        interval=[interval;seg'];
    end
    for i = 1:length(ons)
        seg = floor(ons(i)*fs/downsamp):floor(offs(i)*fs/downsamp);
        interval=[interval;seg'];
    end
    interval=sort(interval);
    sm2 = sm(interval);
    [ons2 offs2] = SegmentNotes(sm2,fs/downsamp,5,20,0);
    figure;hold on;
    plot(temp,'k');hold on;plot(sm2,'r');hold on;
    plot([ons2 ons2]*fs/downsamp,[-5 5],'g');hold on;
    plot([offs2 offs2]*fs/downsamp,[-5 5],'g');hold on;
    title(['amp ',num2str(w(ii))]);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    [dist ix iy] = dtw(temp,sm2);
     onind =floor(temp_ons*fs/downsamp);offind=floor(temp_offs*fs/downsamp);
    ons2 = [];
    offs2 = [];
    for m = 1:length(onind)
        ind = find(ix==onind(m));
        ind = ind(ceil(length(ind)/2));
        ons2 = [ons2;iy(ind)];
        ind = find(ix==offind(m));
        ind = ind(ceil(length(ind)/2));
        offs2 = [offs2;iy(ind)];
    end
    ons2=ons2/(fs/downsamp);offs2=offs2/(fs/downsamp);
    figure;hold on;
    plot(temp,'k');hold on;plot(sm2,'r');hold on;
    plot([ons2 ons2]*fs/downsamp,[-5 5],'g');hold on;
    plot([offs2 offs2]*fs/downsamp,[-5 5],'g');hold on;
    title(['dtw ',num2str(w(ii))]);
    dtwdurs=[dtwdurs;mean(offs2-ons2)];
    dtwgaps=[dtwgaps;mean(ons2(2:end)-offs2(1:end-1))];
end
figure;plot(w,ampdurs,'ok');hold on;plot(w,dtwdurs,'or');
xlabel('downsampling factor');ylabel('duration (sec)');title('syllables');
set(gca,'fontweight','bold');
legend('amp','dtw');
figure;plot(w,ampgaps,'ok');hold on;plot(w,dtwgaps,'or');
xlabel('downsampling factor');ylabel('duration (sec)');title('gaps');
set(gca,'fontweight','bold');
legend('amp','dtw');

%% adjust gap of amp wv from condition and test dtw vs amp segmentation
fs=44100;
downsamp=2;
w = 2;
motifsegment = motifsegment_bcd_11_14_2015_saline;

temp=downsample(log(dtwtemplate.sm),downsamp);
temp=temp-mean(temp);
temp_ons=dtwtemplate.ons;
temp_offs=dtwtemplate.offs;
ampdurs = [];ampgaps = [];
dtwdurs=[];dtwgaps=[];
for ii=1:length(motifsegment)
    sm=log(downsample(motifsegment(ii).sm,downsamp));
    ons=motifsegment(ii).amp_ons;
    offs=motifsegment(ii).amp_offs;
    interval = [];
    seg=1:floor(ons(1)*fs/downsamp);
    interval=[interval;seg'];
    seg=floor(offs(end)*fs/downsamp):length(sm);
    interval=[interval;seg'];
    for i = 1:length(ons)-1
        seg = floor(offs(i)*fs/downsamp):floor(ons(i+1)*fs/downsamp);
        seg =downsample(seg,w);
        interval=[interval;seg'];
    end
    for i = 1:length(ons)
        seg = floor(ons(i)*fs/downsamp):floor(offs(i)*fs/downsamp);
        interval=[interval;seg'];
    end
    interval=sort(interval);
    
    sm2 = sm(interval);sm2=sm2-mean(sm2);
    [ons2 offs2] = SegmentNotes(sm2,fs/downsamp,5,20,0);
    ampdurs = [ampdurs;mean(offs2-ons2)];
    ampgaps = [ampgaps;mean(ons2(2:end)-offs2(1:end-1))];
    
    [dist ix iy] = dtw(temp,sm2);
     onind =floor(temp_ons*fs/downsamp);offind=floor(temp_offs*fs/downsamp);
    ons2 = [];
    offs2 = [];
    for m = 1:length(onind)
        ind = find(ix==onind(m));
        ind = ind(ceil(length(ind)/2));
        ons2 = [ons2;iy(ind)];
        ind = find(ix==offind(m));
        ind = ind(ceil(length(ind)/2));
        offs2 = [offs2;iy(ind)];
    end
    ons2=ons2/(fs/downsamp);offs2=offs2/(fs/downsamp);
    dtwdurs=[dtwdurs;mean(offs2-ons2)];
    dtwgaps=[dtwgaps;mean(ons2(2:end)-offs2(1:end-1))];
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
set(gca,'fontweight','bold');title('syllables amp');
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