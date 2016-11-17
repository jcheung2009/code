%11_15_2016: testing data saved from jc_tonality on bu42o17 saline and naspm for 5-30 and 6-11-2016
%tonality_segment_sal = jc_tonality('batch.keep','abcc','obs0');
%tonality_segment_naspm = jc_tonality('batch.keep','abcc','obs0');

%6-11
vol_sal = cell2mat(arrayfun(@(x) x.vol,tonality_segment_sal_6_29,'unif',0)');
sylls_tonal_sal = cell2mat(arrayfun(@(x) (x.tonality_offs-x.tonality_ons)',tonality_segment_sal_6_29,'unif',0)');
gaps_tonal_sal = cell2mat(arrayfun(@(x) (x.tonality_ons(2:end)-x.tonality_offs(1:end-1))',tonality_segment_sal_6_29,'unif',0)');
vol_naspm = cell2mat(arrayfun(@(x) x.vol,tonality_segment_naspm_6_29,'unif',0)');
sylls_tonal_naspm = cell2mat(arrayfun(@(x) (x.tonality_offs-x.tonality_ons)',tonality_segment_naspm_6_29,'unif',0)');
gaps_tonal_naspm = cell2mat(arrayfun(@(x) (x.tonality_ons(2:end)-x.tonality_offs(1:end-1))',tonality_segment_naspm_6_29,'unif',0)');

sylls_amp_sal = cell2mat(arrayfun(@(x) (x.amp_offs-x.amp_ons)',tonality_segment_sal_6_29,'unif',0)');
gaps_amp_sal = cell2mat(arrayfun(@(x) (x.amp_ons(2:end)-x.amp_offs(1:end-1))',tonality_segment_sal_6_29,'unif',0)');
sylls_amp_naspm = cell2mat(arrayfun(@(x) (x.amp_offs-x.amp_ons)',tonality_segment_naspm_6_29,'unif',0)');
gaps_amp_naspm = cell2mat(arrayfun(@(x) (x.amp_ons(2:end)-x.amp_offs(1:end-1))',tonality_segment_naspm_6_29,'unif',0)');

motif_tonal_sal = arrayfun(@(x) (x.tonality_offs(end)-x.tonality_ons(1)),tonality_segment_sal_6_29,'unif',1)';
motif_tonal_naspm = arrayfun(@(x) (x.tonality_offs(end)-x.tonality_ons(1)),tonality_segment_naspm_6_29,'unif',1)';
motif_amp_sal = arrayfun(@(x) (x.amp_offs(end)-x.amp_ons(1)),tonality_segment_sal_6_29,'unif',1)';
motif_amp_naspm = arrayfun(@(x) (x.amp_offs(end)-x.amp_ons(1)),tonality_segment_naspm_6_29,'unif',1)';

%5-430
vol_sal = cell2mat(arrayfun(@(x) x.vol,tonality_segment_sal_5_30,'unif',0)');
sylls_tonal_sal = cell2mat(arrayfun(@(x) (x.tonality_offs-x.tonality_ons)',tonality_segment_sal_5_30,'unif',0)');
gaps_tonal_sal = cell2mat(arrayfun(@(x) (x.tonality_ons(2:end)-x.tonality_offs(1:end-1))',tonality_segment_sal_5_30,'unif',0)');
vol_naspm = cell2mat(arrayfun(@(x) x.vol,tonality_segment_naspm_5_30,'unif',0)');
sylls_tonal_naspm = cell2mat(arrayfun(@(x) (x.tonality_offs-x.tonality_ons)',tonality_segment_naspm_5_30,'unif',0)');
gaps_tonal_naspm = cell2mat(arrayfun(@(x) (x.tonality_ons(2:end)-x.tonality_offs(1:end-1))',tonality_segment_naspm_5_30,'unif',0)');

sylls_amp_sal = cell2mat(arrayfun(@(x) (x.amp_offs-x.amp_ons)',tonality_segment_sal_5_30,'unif',0)');
gaps_amp_sal = cell2mat(arrayfun(@(x) (x.amp_ons(2:end)-x.amp_offs(1:end-1))',tonality_segment_sal_5_30,'unif',0)');
sylls_amp_naspm = cell2mat(arrayfun(@(x) (x.amp_offs-x.amp_ons)',tonality_segment_naspm_5_30,'unif',0)');
gaps_amp_naspm = cell2mat(arrayfun(@(x) (x.amp_ons(2:end)-x.amp_offs(1:end-1))',tonality_segment_naspm_5_30,'unif',0)');

motif_tonal_sal = arrayfun(@(x) (x.tonality_offs(end)-x.tonality_ons(1)),tonality_segment_sal_5_30,'unif',1)';
motif_tonal_naspm = arrayfun(@(x) (x.tonality_offs(end)-x.tonality_ons(1)),tonality_segment_naspm_5_30,'unif',1)';
motif_amp_sal = arrayfun(@(x) (x.amp_offs(end)-x.amp_ons(1)),tonality_segment_sal_5_30,'unif',1)';
motif_amp_naspm = arrayfun(@(x) (x.amp_offs(end)-x.amp_ons(1)),tonality_segment_naspm_5_30,'unif',1)';


%% example tonal/amp segmentation
%plot example of spectrogram of motif with amplitude waveform, tonality
%waveform, and tonal/amplitude segmentation for saline condition and naspm condition where
%volumes are very different

%% tonality sal ex
tonality_segment_sal = tonality_segment_sal_6_29;
fs = 32000;
[c ind] = min(mean(vol_sal,2));
tonality = tonality_segment_sal(ind).tonality;
dat = tonality_segment_sal(ind).filtsong;

figure;
h1 = subtightplot(3,1,1,0.07,0.1,0.1);hold on;
h2 = subtightplot(3,1,2,0.07,0.1,0.1);hold on;
h3 = subtightplot(3,1,3,0.07,0.1,0.1);hold on;

[sp f t]= spectrogram(dat,512,510,512,fs);
imagesc(h1,t,f,log(abs(sp)));ylim(h1,[1000 10000]);colormap('jet');
plot(h2,[1:length(dat)]/fs,dat);
plot(h3,[1:length(tonality)]/(fs/4),tonality);
xlabel(h3,'seconds');
ylabel(h3,'amplitude of first peak in acorr')
ylabel(h2,'amplitude');
ylabel(h1,'frequency (hz)');
title(h2,'amplitude envelop');
title(h3,'tonality');
x = get(h2,'xlim');
set(h1,'xlim',x);
set(h2,'xlim',x);
set(h3,'xlim',x);

onsets = tonality_segment_sal(ind).tonality_ons;
offsets = tonality_segment_sal(ind).tonality_offs;
for i = 1:length(onsets)
    plot(h1,[onsets(i) onsets(i)]/1e3,[1000 10000],'r');
    plot(h1,[offsets(i) offsets(i)]/1e3,[1000 10000],'g');
    plot(h2,[onsets(i) onsets(i)]/1e3,[min(dat) max(dat)],'r');
    plot(h2,[offsets(i) offsets(i)]/1e3,[min(dat) max(dat)],'g');
    plot(h3,[onsets(i) onsets(i)]/1e3,[min(tonality) max(tonality)],'r');
    plot(h3,[offsets(i) offsets(i)]/1e3,[min(tonality) max(tonality)],'g');
end

%% tonality naspm ex
tonality_segment_naspm = tonality_segment_naspm_6_29;

[c ind] = max(mean(vol_naspm,2));
tonality = tonality_segment_naspm(ind).tonality;
dat = tonality_segment_naspm(ind).filtsong;

figure;
h1 = subtightplot(3,1,1,0.07,0.1,0.1);hold on;
h2 = subtightplot(3,1,2,0.07,0.1,0.1);hold on;
h3 = subtightplot(3,1,3,0.07,0.1,0.1);hold on;

[sp f t]= spectrogram(dat,512,510,512,fs);
imagesc(h1,t,f,log(abs(sp)));ylim(h1,[1000 10000]);colormap('jet');
plot(h2,[1:length(dat)]/fs,dat);
plot(h3,[1:length(tonality)]/(fs/4),tonality);
xlabel(h3,'seconds');
ylabel(h3,'amplitude of first peak in acorr')
ylabel(h2,'amplitude');
ylabel(h1,'frequency (hz)');
title(h2,'amplitude envelop');
title(h3,'tonality');
x = get(h2,'xlim');
set(h1,'xlim',x);
set(h2,'xlim',x);
set(h3,'xlim',x);

onsets = tonality_segment_naspm(ind).tonality_ons;
offsets = tonality_segment_naspm(ind).tonality_offs;
for i = 1:length(onsets)
    plot(h1,[onsets(i) onsets(i)]/1e3,[1000 10000],'r');
    plot(h1,[offsets(i) offsets(i)]/1e3,[1000 10000],'g');
    plot(h2,[onsets(i) onsets(i)]/1e3,[min(dat) max(dat)],'r');
    plot(h2,[offsets(i) offsets(i)]/1e3,[min(dat) max(dat)],'g');
    plot(h3,[onsets(i) onsets(i)]/1e3,[min(tonality) max(tonality)],'r');
    plot(h3,[offsets(i) offsets(i)]/1e3,[min(tonality) max(tonality)],'g');
end

%% amp sal ex
[c ind] = min(mean(vol_sal,2));
dat = tonality_segment_sal(ind).dat;

figure;
h1 = subtightplot(3,1,1,0.07,0.1,0.1);hold on;
h2 = subtightplot(3,1,2,0.07,0.1,0.1);hold on;

[sp f t]= spectrogram(dat,512,510,512,fs);
imagesc(h1,t,f,log(abs(sp)));ylim(h1,[0 10000]);colormap('jet');
plot(h2,[1:length(dat)]/fs,dat);
xlabel(h2,'seconds');
ylabel(h2,'amplitude');
ylabel(h1,'frequency (hz)');
title(h2,'amplitude envelop');
x = get(h2,'xlim');
set(h1,'xlim',x);
set(h2,'xlim',x);

onsets = tonality_segment_sal(ind).amp_ons;
offsets = tonality_segment_sal(ind).amp_offs;
for i = 1:length(onsets)
    plot(h1,[onsets(i) onsets(i)]/1e3,[1000 10000],'r');
    plot(h1,[offsets(i) offsets(i)]/1e3,[1000 10000],'g');
    plot(h2,[onsets(i) onsets(i)]/1e3,[min(dat) max(dat)],'r');
    plot(h2,[offsets(i) offsets(i)]/1e3,[min(dat) max(dat)],'g');
end

%% amp naspm ex
[c ind] = max(mean(vol_naspm,2));
dat = tonality_segment_naspm(ind).dat;

figure;
h1 = subtightplot(3,1,1,0.07,0.1,0.1);hold on;
h2 = subtightplot(3,1,2,0.07,0.1,0.1);hold on;

[sp f t]= spectrogram(dat,512,510,512,fs);
imagesc(h1,t,f,log(abs(sp)));ylim(h1,[0 10000]);colormap('jet');
plot(h2,[1:length(dat)]/fs,dat);
xlabel(h2,'seconds');
ylabel(h2,'amplitude');
ylabel(h1,'frequency (hz)');
title(h2,'amplitude envelop');
x = get(h2,'xlim');
set(h1,'xlim',x);
set(h2,'xlim',x);

onsets = tonality_segment_naspm(ind).amp_ons;
offsets = tonality_segment_naspm(ind).amp_offs;
for i = 1:length(onsets)
    plot(h1,[onsets(i) onsets(i)]/1e3,[1000 10000],'r');
    plot(h1,[offsets(i) offsets(i)]/1e3,[1000 10000],'g');
    plot(h2,[onsets(i) onsets(i)]/1e3,[min(dat) max(dat)],'r');
    plot(h2,[offsets(i) offsets(i)]/1e3,[min(dat) max(dat)],'g');
end
 

%% distribution of syllable and gap duration in saline vs naspm for
%tonality/amp segmentation

%% tonality sylls distr
figure;
h1 = subplot(4,1,1);
h2 = subplot(4,1,2);
h3 = subplot(4,1,3);
h4 = subplot(4,1,4);

minval = floor(min([sylls_tonal_sal(:,1);sylls_tonal_naspm(:,1)])); 
maxval = ceil(max([sylls_tonal_sal(:,1);sylls_tonal_naspm(:,1)]));
[n b] = hist(sylls_tonal_sal(:,1),[minval:0.5:maxval]);stairs(h1,b,n/sum(n),'k');hold(h1,'on');
[n b] = hist(sylls_tonal_naspm(:,1),[minval:0.5:maxval]);stairs(h1,b,n/sum(n),'r');hold(h1,'on');
plot(h1,mean(sylls_tonal_sal(:,1)),0,'k^');hold(h1,'on');
plot(h1,mean(sylls_tonal_naspm(:,1)),0,'r^');
title(h1,'tonal syllable duration');
ylabel(h1,'probability');
[h p] = ttest2(sylls_tonal_sal(:,1),sylls_tonal_naspm(:,1));
y = get(h1,'ylim');
x = get(h1,'xlim');
set(h1,'xlim',x,'ylim',y);
text(h1,x(1),y(2),['p=',num2str(p)]);

minval = floor(min([sylls_tonal_sal(:,2);sylls_tonal_naspm(:,2)])); 
maxval = ceil(max([sylls_tonal_sal(:,2);sylls_tonal_naspm(:,2)]));
[n b] = hist(sylls_tonal_sal(:,2),[minval:0.5:maxval]);stairs(h2,b,n/sum(n),'k');hold(h2,'on');
[n b] = hist(sylls_tonal_naspm(:,2),[minval:0.5:maxval]);stairs(h2,b,n/sum(n),'r');hold(h2,'on');
plot(h2,mean(sylls_tonal_sal(:,2)),0,'k^');hold(h2,'on');
plot(h2,mean(sylls_tonal_naspm(:,2)),0,'r^');
ylabel(h2,'probability');
[h p] = ttest2(sylls_tonal_sal(:,2),sylls_tonal_naspm(:,2));
y = get(h2,'ylim');
x = get(h2,'xlim');
set(h2,'xlim',x,'ylim',y);
text(h2,x(1),y(2),['p=',num2str(p)]);

minval = floor(min([sylls_tonal_sal(:,3);sylls_tonal_naspm(:,3)])); 
maxval = ceil(max([sylls_tonal_sal(:,3);sylls_tonal_naspm(:,3)]));
[n b] = hist(sylls_tonal_sal(:,3),[minval:0.5:maxval]);stairs(h3,b,n/sum(n),'k');hold(h3,'on');
[n b] = hist(sylls_tonal_naspm(:,3),[minval:0.5:maxval]);stairs(h3,b,n/sum(n),'r');hold(h3,'on');
plot(h3,mean(sylls_tonal_sal(:,3)),0,'k^');hold(h3,'on');
plot(h3,mean(sylls_tonal_naspm(:,3)),0,'r^');
ylabel(h3,'probability');
[h p] = ttest2(sylls_tonal_sal(:,3),sylls_tonal_naspm(:,3));
y = get(h3,'ylim');
x = get(h3,'xlim');
set(h3,'xlim',x,'ylim',y);
text(h3,x(1),y(2),['p=',num2str(p)]);

minval = floor(min([sylls_tonal_sal(:,4);sylls_tonal_naspm(:,4)])); 
maxval = ceil(max([sylls_tonal_sal(:,4);sylls_tonal_naspm(:,4)]));
[n b] = hist(sylls_tonal_sal(:,4),[minval:0.5:maxval]);stairs(h4,b,n/sum(n),'k');hold(h4,'on');
[n b] = hist(sylls_tonal_naspm(:,4),[minval:0.5:maxval]);stairs(h4,b,n/sum(n),'r');hold(h4,'on');
plot(h4,mean(sylls_tonal_sal(:,4)),0,'k^');hold(h3,'on');
plot(h4,mean(sylls_tonal_naspm(:,4)),0,'r^');
ylabel(h4,'probability');
[h p] = ttest2(sylls_tonal_sal(:,4),sylls_tonal_naspm(:,4));
y = get(h4,'ylim');
x = get(h4,'xlim');
set(h4,'xlim',x,'ylim',y);
text(h4,x(1),y(2),['p=',num2str(p)]);

%% amplitude sylls distr
figure;
h1 = subplot(4,1,1);
h2 = subplot(4,1,2);
h3 = subplot(4,1,3);
h4 = subplot(4,1,4);

minval = floor(min([sylls_amp_sal(:,1);sylls_amp_naspm(:,1)])); 
maxval = ceil(max([sylls_amp_sal(:,1);sylls_amp_naspm(:,1)]));
[n b] = hist(sylls_amp_sal(:,1),[minval:0.5:maxval]);stairs(h1,b,n/sum(n),'k');hold(h1,'on');
[n b] = hist(sylls_amp_naspm(:,1),[minval:0.5:maxval]);stairs(h1,b,n/sum(n),'r');
plot(h1,mean(sylls_amp_sal(:,1)),0,'k^');hold(h1,'on');
plot(h1,mean(sylls_amp_naspm(:,1)),0,'r^');
title(h1,'amp syllable duration');
ylabel(h1,'probability');
[h p] = ttest2(sylls_amp_sal(:,1),sylls_amp_naspm(:,1));
y = get(h1,'ylim');
x = get(h1,'xlim');
set(h1,'xlim',x,'ylim',y);
text(h1,x(1),y(2),['p=',num2str(p)]);

minval = floor(min([sylls_amp_sal(:,2);sylls_amp_naspm(:,2)])); 
maxval = ceil(max([sylls_amp_sal(:,2);sylls_amp_naspm(:,2)]));
[n b] = hist(sylls_amp_sal(:,2),[minval:0.5:maxval]);stairs(h2,b,n/sum(n),'k');hold(h2,'on');
[n b] = hist(sylls_amp_naspm(:,2),[minval:0.5:maxval]);stairs(h2,b,n/sum(n),'r');
plot(h2,mean(sylls_amp_sal(:,2)),0,'k^');hold(h2,'on');
plot(h2,mean(sylls_amp_naspm(:,2)),0,'r^');
ylabel(h2,'probability');
[h p] = ttest2(sylls_amp_sal(:,2),sylls_amp_naspm(:,2));
y = get(h2,'ylim');
x = get(h2,'xlim');
set(h2,'xlim',x,'ylim',y);
text(h2,x(1),y(2),['p=',num2str(p)]);

minval = floor(min([sylls_amp_sal(:,3);sylls_amp_naspm(:,3)])); 
maxval = ceil(max([sylls_amp_sal(:,3);sylls_amp_naspm(:,3)]));
[n b] = hist(sylls_amp_sal(:,3),[minval:0.5:maxval]);stairs(h3,b,n/sum(n),'k');hold(h3,'on');
[n b] = hist(sylls_amp_naspm(:,3),[minval:0.5:maxval]);stairs(h3,b,n/sum(n),'r');
plot(h3,mean(sylls_amp_sal(:,3)),0,'k^');hold(h3,'on');
plot(h3,mean(sylls_amp_naspm(:,3)),0,'r^');
ylabel(h3,'probability');
[h p] = ttest2(sylls_amp_sal(:,3),sylls_amp_naspm(:,3));
y = get(h3,'ylim');
x = get(h3,'xlim');
set(h3,'xlim',x,'ylim',y);
text(h3,x(1),y(2),['p=',num2str(p)]);

minval = floor(min([sylls_amp_sal(:,4);sylls_amp_naspm(:,4)])); 
maxval = ceil(max([sylls_amp_sal(:,4);sylls_amp_naspm(:,4)]));
[n b] = hist(sylls_amp_sal(:,4),[minval:0.5:maxval]);stairs(h4,b,n/sum(n),'k');hold(h4,'on');
[n b] = hist(sylls_amp_naspm(:,4),[minval:0.5:maxval]);stairs(h4,b,n/sum(n),'r');
plot(h4,mean(sylls_amp_sal(:,4)),0,'k^');hold(h4,'on');
plot(h4,mean(sylls_amp_naspm(:,4)),0,'r^');
ylabel(h4,'probability');
[h p] = ttest2(sylls_amp_sal(:,4),sylls_amp_naspm(:,4));
y = get(h4,'ylim');
x = get(h4,'xlim');
set(h4,'xlim',x,'ylim',y);
text(h4,x(1),y(2),['p=',num2str(p)]);

%% tonality gaps distr
figure;
h1 = subplot(3,1,1);
h2 = subplot(3,1,2);
h3 = subplot(3,1,3);

minval = floor(min([gaps_tonal_sal(:,1);gaps_tonal_naspm(:,1)])); 
maxval = ceil(max([gaps_tonal_sal(:,1);gaps_tonal_naspm(:,1)]));
[n b] = hist(gaps_tonal_sal(:,1),[minval:0.5:maxval]);stairs(h1,b,n/sum(n),'k');hold(h1,'on');
[n b] = hist(gaps_tonal_naspm(:,1),[minval:0.5:maxval]);stairs(h1,b,n/sum(n),'r');
plot(h1,mean(gaps_tonal_sal(:,1)),0,'k^');hold(h1,'on');
plot(h1,mean(gaps_tonal_naspm(:,1)),0,'r^');
title(h1,'tonal gap duration');
ylabel(h1,'probability');
[h p] = ttest2(gaps_tonal_sal(:,1),gaps_tonal_naspm(:,1));
y = get(h1,'ylim');
x = get(h1,'xlim');
set(h1,'xlim',x,'ylim',y);
text(h1,x(1),y(2),['p=',num2str(p)]);

minval = floor(min([gaps_tonal_sal(:,2);gaps_tonal_naspm(:,2)])); 
maxval = ceil(max([gaps_tonal_sal(:,2);gaps_tonal_naspm(:,2)]));
[n b] = hist(gaps_tonal_sal(:,2),[minval:0.5:maxval]);stairs(h2,b,n/sum(n),'k');hold(h2,'on');
[n b] = hist(gaps_tonal_naspm(:,2),[minval:0.5:maxval]);stairs(h2,b,n/sum(n),'r');
plot(h2,mean(gaps_tonal_sal(:,2)),0,'k^');hold(h2,'on');
plot(h2,mean(gaps_tonal_naspm(:,2)),0,'r^');
ylabel(h2,'probability');
[h p] = ttest2(gaps_tonal_sal(:,2),gaps_tonal_naspm(:,2));
y = get(h2,'ylim');
x = get(h2,'xlim');
set(h2,'xlim',x,'ylim',y);
text(h2,x(1),y(2),['p=',num2str(p)]);

minval = floor(min([gaps_tonal_sal(:,3);gaps_tonal_naspm(:,3)])); 
maxval = ceil(max([gaps_tonal_sal(:,3);gaps_tonal_naspm(:,3)]));
[n b] = hist(gaps_tonal_sal(:,3),[minval:0.5:maxval]);stairs(h3,b,n/sum(n),'k');hold(h3,'on');
[n b] = hist(gaps_tonal_naspm(:,3),[minval:0.5:maxval]);stairs(h3,b,n/sum(n),'r');
plot(h3,mean(gaps_tonal_sal(:,3)),0,'k^');hold(h3,'on');
plot(h3,mean(gaps_tonal_naspm(:,3)),0,'r^');
ylabel(h3,'probability');
[h p] = ttest2(gaps_tonal_sal(:,3),gaps_tonal_naspm(:,3));
y = get(h3,'ylim');
x = get(h3,'xlim');
set(h3,'xlim',x,'ylim',y);
text(h3,x(1),y(2),['p=',num2str(p)]);

%% gaps amp distr
figure;
h1 = subplot(3,1,1);
h2 = subplot(3,1,2);
h3 = subplot(3,1,3);

minval = floor(min([gaps_amp_sal(:,1);gaps_amp_naspm(:,1)])); 
maxval = ceil(max([gaps_amp_sal(:,1);gaps_amp_naspm(:,1)]));
[n b] = hist(gaps_amp_sal(:,1),[minval:0.5:maxval]);stairs(h1,b,n/sum(n),'k');hold(h1,'on');
[n b] = hist(gaps_amp_naspm(:,1),[minval:0.5:maxval]);stairs(h1,b,n/sum(n),'r');
plot(h1,mean(gaps_amp_sal(:,1)),0,'k^');hold(h1,'on');
plot(h1,mean(gaps_amp_naspm(:,1)),0,'r^');
title(h1,'amp gap duration');
ylabel(h1,'probability');
[h p] = ttest2(gaps_amp_sal(:,1),gaps_amp_naspm(:,1));
y = get(h1,'ylim');
x = get(h1,'xlim');
set(h1,'xlim',x,'ylim',y);
text(h1,x(1),y(2),['p=',num2str(p)]);

minval = floor(min([gaps_amp_sal(:,2);gaps_amp_naspm(:,2)])); 
maxval = ceil(max([gaps_amp_sal(:,2);gaps_amp_naspm(:,2)]));
[n b] = hist(gaps_amp_sal(:,2),[minval:0.5:maxval]);stairs(h2,b,n/sum(n),'k');hold(h2,'on');
[n b] = hist(gaps_amp_naspm(:,2),[minval:0.5:maxval]);stairs(h2,b,n/sum(n),'r');
plot(h2,mean(gaps_amp_sal(:,2)),0,'k^');hold(h2,'on');
plot(h2,mean(gaps_amp_naspm(:,2)),0,'r^');
ylabel(h2,'probability');
[h p] = ttest2(gaps_amp_sal(:,2),gaps_amp_naspm(:,2));
y = get(h2,'ylim');
x = get(h2,'xlim');
set(h2,'xlim',x,'ylim',y);
text(h2,x(1),y(2),['p=',num2str(p)]);

minval = floor(min([gaps_amp_sal(:,3);gaps_amp_naspm(:,3)])); 
maxval = ceil(max([gaps_amp_sal(:,3);gaps_amp_naspm(:,3)]));
[n b] = hist(gaps_amp_sal(:,3),[minval:0.5:maxval]);stairs(h3,b,n/sum(n),'k');hold(h3,'on');
[n b] = hist(gaps_amp_naspm(:,3),[minval:0.5:maxval]);stairs(h3,b,n/sum(n),'r');
plot(h3,mean(gaps_amp_sal(:,3)),0,'k^');hold(h3,'on');
plot(h3,mean(gaps_amp_naspm(:,3)),0,'r^');
ylabel(h3,'probability');
[h p] = ttest2(gaps_amp_sal(:,3),gaps_amp_naspm(:,3));
y = get(h3,'ylim');
x = get(h3,'xlim');
set(h3,'xlim',x,'ylim',y);
text(h3,x(1),y(2),['p=',num2str(p)]);


%% correlation syll duration with volume

%% amplitude segmentation corr
figure;
h1 = subtightplot(4,1,1,0.07,0.1,0.1);
h2 = subtightplot(4,1,2,0.07,0.1,0.1);
h3 = subtightplot(4,1,3,0.07,0.1,0.1);
h4 = subtightplot(4,1,4,0.07,0.1,0.1);

plot(h1,log(vol_sal(:,1)),sylls_amp_sal(:,1),'ok');hold(h1,'on');
plot(h1,log(vol_naspm(:,1)),sylls_amp_naspm(:,1),'or');
plot(h2,log(vol_sal(:,2)),sylls_amp_sal(:,2),'ok');hold(h2,'on');
plot(h2,log(vol_naspm(:,2)),sylls_amp_naspm(:,2),'or');
plot(h3,log(vol_sal(:,3)),sylls_amp_sal(:,3),'ok');hold(h3,'on');
plot(h3,log(vol_naspm(:,3)),sylls_amp_naspm(:,3),'or');
plot(h4,log(vol_sal(:,4)),sylls_amp_sal(:,4),'ok');hold(h4,'on');
plot(h4,log(vol_naspm(:,4)),sylls_amp_naspm(:,4),'or');
xlabel(h4,'amplitude');
ylabel(h1,'syll amp dur (ms)');
ylabel(h2,'syll amp dur (ms)');
ylabel(h3,'syll amp dur (ms)');
ylabel(h4,'syll amp dur (ms)');
[r p] = corrcoef([log(vol_sal(:,1));log(vol_naspm(:,1))],[sylls_amp_sal(:,1);sylls_amp_naspm(:,1)]);
title(h1,{['r=',num2str(r(2))],['p=',num2str(p(2))]});
[r p] = corrcoef([log(vol_sal(:,2));log(vol_naspm(:,2))],[sylls_amp_sal(:,2);sylls_amp_naspm(:,2)]);
title(h2,{['r=',num2str(r(2))],['p=',num2str(p(2))]});
[r p] = corrcoef([log(vol_sal(:,3));log(vol_naspm(:,3))],[sylls_amp_sal(:,3);sylls_amp_naspm(:,3)]);
title(h3,{['r=',num2str(r(2))],['p=',num2str(p(2))]});
[r p] = corrcoef([log(vol_sal(:,4));log(vol_naspm(:,4))],[sylls_amp_sal(:,4);sylls_amp_naspm(:,4)]);
title(h4,{['r=',num2str(r(2))],['p=',num2str(p(2))]});

%% tonality segmentation corr
figure; 
h1 = subtightplot(4,1,1,0.07,0.1,0.1);
h2 = subtightplot(4,1,2,0.07,0.1,0.1);
h3 = subtightplot(4,1,3,0.07,0.1,0.1);
h4 = subtightplot(4,1,4,0.07,0.1,0.1);

plot(h1,log(vol_sal(:,1)),sylls_tonal_sal(:,1),'ok');hold(h1,'on');
plot(h1,log(vol_naspm(:,1)),sylls_tonal_naspm(:,1),'or');
plot(h2,log(vol_sal(:,2)),sylls_tonal_sal(:,2),'ok');hold(h2,'on');
plot(h2,log(vol_naspm(:,2)),sylls_tonal_naspm(:,2),'or');
plot(h3,log(vol_sal(:,3)),sylls_tonal_sal(:,3),'ok');hold(h3,'on');
plot(h3,log(vol_naspm(:,3)),sylls_tonal_naspm(:,3),'or');
plot(h4,log(vol_sal(:,4)),sylls_tonal_sal(:,4),'ok');hold(h4,'on');
plot(h4,log(vol_naspm(:,4)),sylls_tonal_naspm(:,4),'or');
xlabel(h4,'amplitude');
ylabel(h1,'syll tonal dur (ms)');
ylabel(h2,'syll tonal dur (ms)');
ylabel(h3,'syll tonal dur (ms)');
ylabel(h4,'syll tonal dur (ms)');
[r p] = corrcoef([log(vol_sal(:,1));log(vol_naspm(:,1))],[sylls_tonal_sal(:,1);sylls_tonal_naspm(:,1)]);
title(h1,{['r=',num2str(r(2))],['p=',num2str(p(2))]});
[r p] = corrcoef([log(vol_sal(:,2));log(vol_naspm(:,2))],[sylls_tonal_sal(:,2);sylls_tonal_naspm(:,2)]);
title(h2,{['r=',num2str(r(2))],['p=',num2str(p(2))]});
[r p] = corrcoef([log(vol_sal(:,3));log(vol_naspm(:,3))],[sylls_tonal_sal(:,3);sylls_tonal_naspm(:,3)]);
title(h3,{['r=',num2str(r(2))],['p=',num2str(p(2))]});
[r p] = corrcoef([log(vol_sal(:,4));log(vol_naspm(:,4))],[sylls_tonal_sal(:,4);sylls_tonal_naspm(:,4)]);
title(h4,{['r=',num2str(r(2))],['p=',num2str(p(2))]});

%% distribution of motif duration in saline vs naspm 

%% tonality motif distr
figure;h1 = gca;
minval = floor(min([motif_tonal_sal;motif_tonal_naspm])); 
maxval = ceil(max([motif_tonal_sal;motif_tonal_naspm]));
[n b] = hist(motif_tonal_sal(:,1),[minval:1:maxval]);stairs(h1,b,n/sum(n),'k');hold(h1,'on');
[n b] = hist(motif_tonal_naspm(:,1),[minval:1:maxval]);stairs(h1,b,n/sum(n),'r');hold(h1,'on');
plot(h1,mean(motif_tonal_sal(:,1)),0,'k^');
plot(h1,mean(motif_tonal_naspm(:,1)),0,'r^');
title(h1,'tonal motif duration');
ylabel(h1,'probability');
[h p] = ttest2(motif_tonal_sal(:,1),motif_tonal_naspm(:,1));
y = get(h1,'ylim');
x = get(h1,'xlim');
set(h1,'xlim',x,'ylim',y);
text(h1,x(1),y(2),['p=',num2str(p)]);

%% amp motif distr
figure;h1 = gca;
minval = floor(min([motif_amp_sal;motif_amp_naspm])); 
maxval = ceil(max([motif_amp_sal;motif_amp_naspm]));
[n b] = hist(motif_amp_sal(:,1),[minval:1:maxval]);stairs(h1,b,n/sum(n),'k');hold(h1,'on');
[n b] = hist(motif_amp_naspm(:,1),[minval:1:maxval]);stairs(h1,b,n/sum(n),'r');hold(h1,'on');
plot(h1,mean(motif_amp_sal(:,1)),0,'k^');
plot(h1,mean(motif_amp_naspm(:,1)),0,'r^');
title(h1,'amp motif duration');
ylabel(h1,'probability');
[h p] = ttest2(motif_amp_sal(:,1),motif_amp_naspm(:,1));
y = get(h1,'ylim');
x = get(h1,'xlim');
set(h1,'xlim',x,'ylim',y);
text(h1,x(1),y(2),['p=',num2str(p)]);
