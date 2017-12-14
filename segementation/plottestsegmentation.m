%% params
path  = '/opt/data/from_brad/pk64gr80/';
listoffiles = 'batch'; 

%song parameters
motif = 'cdef';%target motif
load([path,'dtwtemplate']);% example of target motif to use as template for spectral based dtw (make_dtw_temp.m)
load([path,'dtwtemplateAMP'])% example of target motif to use as template for amplitude based dtw (make_dtw2_temp_motif.m)
fs = 44100;%sampling rate
filtype = 'w';%'obs0' or 'w' for cbin or wav files 

%amplitude segmentation parameters
min_int = 5;%minimum length for gaps in ms
min_dur = 20;%minimum length for syllables in ms
thresh = 0.5;%amplitude threshold from 0-1 for segmenting normalized smoothed amp envelop

testmotifsegment = testsegmentation(path,listoffiles,motif,dtwtemplate,dtwtemplateAMP,min_int,min_dur,thresh,'w',44100);


motif = 'cdef';
fs = 44100;

%% variance of syllable durations and gaps 
dtwsylls = cell2mat(arrayfun(@(x) (x.dtwsegment(:,2)-x.dtwsegment(:,1))',testmotifsegment,'un',0)');

ind = arrayfun(@(x) size(x.ampsegment,1)==length(motif),testmotifsegment,'un',1);
ampsylls = cell2mat(arrayfun(@(x) (x.ampsegment(:,2)-x.ampsegment(:,1))',testmotifsegment(ind),'un',0)');

ind = arrayfun(@(x) size(x.pksegment,1)==length(motif),testmotifsegment,'un',1);
pksylls = cell2mat(arrayfun(@(x) (x.pksegment(:,2)-x.pksegment(:,1))',testmotifsegment(ind),'un',0)');

ind = arrayfun(@(x) size(x.dtwpksegment,1)==length(motif),testmotifsegment,'un',1);
dtwpksylls = cell2mat(arrayfun(@(x) (x.dtwpksegment(:,2)-x.dtwpksegment(:,1))',testmotifsegment(ind),'un',0)');

ind = arrayfun(@(x) size(x.tonalitysegment,1)==length(motif),testmotifsegment,'un',1);
tonsylls = cell2mat(arrayfun(@(x) (x.tonalitysegment(:,2)-x.tonalitysegment(:,1))',testmotifsegment(ind),'un',0)');

dtwampsylls = cell2mat(arrayfun(@(x) (x.dtwampsegment(:,2)-x.dtwampsegment(:,1))',testmotifsegment,'un',0)');


dtwgaps = cell2mat(arrayfun(@(x) (x.dtwsegment(2:end,1)-x.dtwsegment(1:end-1,2))',testmotifsegment,'un',0)');

ind = arrayfun(@(x) size(x.ampsegment,1)==length(motif),testmotifsegment,'un',1);
ampgaps = cell2mat(arrayfun(@(x) (x.ampsegment(2:end,1)-x.ampsegment(1:end-1,2))',testmotifsegment(ind),'un',0)');

ind = arrayfun(@(x) size(x.pksegment,1)==length(motif),testmotifsegment,'un',1);
pkgaps = cell2mat(arrayfun(@(x) (x.pksegment(2:end,1)-x.pksegment(1:end-1,2))',testmotifsegment(ind),'un',0)');

ind = arrayfun(@(x) size(x.dtwpksegment,1)==length(motif),testmotifsegment,'un',1);
dtwpkgaps = cell2mat(arrayfun(@(x) (x.dtwpksegment(2:end,1)-x.dtwpksegment(1:end-1,2))',testmotifsegment(ind),'un',0)');

ind = arrayfun(@(x) size(x.tonalitysegment,1)==length(motif),testmotifsegment,'un',1);
tongaps = cell2mat(arrayfun(@(x) (x.tonalitysegment(2:end,1)-x.tonalitysegment(1:end-1,2))',testmotifsegment(ind),'un',0)');

dtwampgaps = cell2mat(arrayfun(@(x) (x.dtwampsegment(2:end,1)-x.dtwampsegment(1:end-1,2))',testmotifsegment,'un',0)');

figure;hold on;
onsvars = [];
for i = 1:length(motif)
    [mn hi lo] = mBootstrapCI_CV(dtwsylls(:,i));
    plot(1,mn,'ok','markersize',8);hold on;
    errorbar(1,mn,hi-mn,'k','linewidth',2);hold on;
    [mn2 hi2 lo2] = mBootstrapCI_CV(ampsylls(:,i));
    plot(2,mn2,'or','markersize',8);hold on;
    errorbar(2,mn2,hi2-mn2,'r','linewidth',2);hold on;
    try
        [mn3 hi3 lo3] = mBootstrapCI_CV(pksylls(:,i));
        plot(3,mn3,'ob','markersize',8);hold on;
        errorbar(3,mn3,hi3-mn3,'b','linewidth',2);hold on;
    catch
            mn3 = NaN;
    end
    try
        [mn4 hi4 lo4] = mBootstrapCI_CV(dtwpksylls(:,i));
        plot(4,mn4,'og','markersize',8);hold on;
        errorbar(4,mn4,hi4-mn4,'g','linewidth',2);hold on;
    catch
            mn4 = NaN;
    end
    try
        [mn5 hi5 lo5] = mBootstrapCI_CV(tonsylls(:,i));
        plot(5,mn5,'oc','markersize',8);hold on;
        errorbar(5,mn5,hi5-mn5,'c','linewidth',2);hold on;
    catch
        mn5 = NaN;
    end
    try
        [mn6 hi6 lo6] = mBootstrapCI_CV(dtwampsylls(:,i));
        plot(6,mn6,'oc','markersize',8);hold on;
        errorbar(6,mn6,hi6-mn6,'m','linewidth',2);hold on;
    catch
        mn6 = NaN;
    end
    onsvars = [onsvars [mn mn2 mn3 mn4 mn5 mn6]'];
end
plot(1:6,onsvars,'color',[0.5 0.5 0.5],'linewidth',2);
ylabel('cv');title('syllable durations');xticklabels({'dtw','amp','pk','dtwpk','tonality','dtwamp'}); 

figure;hold on;
onsvars = [];
for i = 1:length(motif)-1
    [mn hi lo] = mBootstrapCI_CV(dtwgaps(:,i));
    plot(1,mn,'ok','markersize',8);hold on;
    errorbar(1,mn,hi-mn,'k','linewidth',2);hold on;
    [mn2 hi2 lo2] = mBootstrapCI_CV(ampgaps(:,i));
    plot(2,mn2,'or','markersize',8);hold on;
    errorbar(2,mn2,hi2-mn2,'r','linewidth',2);hold on;
    [mn3 hi3 lo3] = mBootstrapCI_CV(pkgaps(:,i));
    plot(3,mn3,'ob','markersize',8);hold on;
    errorbar(3,mn3,hi3-mn3,'b','linewidth',2);hold on;
    [mn4 hi4 lo4] = mBootstrapCI_CV(dtwpkgaps(:,i));
    plot(4,mn4,'og','markersize',8);hold on;
    errorbar(4,mn4,hi4-mn4,'g','linewidth',2);hold on;
    [mn5 hi5 lo5] = mBootstrapCI_CV(tongaps(:,i));
    plot(5,mn5,'oc','markersize',8);hold on;
    errorbar(5,mn5,hi5-mn5,'c','linewidth',2);hold on;
    [mn6 hi6 lo6] = mBootstrapCI_CV(dtwampgaps(:,i));
    plot(6,mn6,'oc','markersize',8);hold on;
    errorbar(6,mn6,hi6-mn6,'m','linewidth',2);hold on;
    onsvars = [onsvars [mn mn2 mn3 mn4 mn5 mn6]'];
end
plot(1:6,onsvars','color',[0.5 0.5 0.5],'linewidth',2);
ylabel('cv');title('gaps');xticklabels({'dtw','amp','pk','dtwpk','tonality','dtwamp'}); 

%% distribution of syllable and gap durations
dtwsylls = cell2mat(arrayfun(@(x) (x.dtwsegment(:,2)-x.dtwsegment(:,1))',testmotifsegment,'un',0)');
ampsylls = arrayfun(@(x) (x.ampsegment(:,2)-x.ampsegment(:,1))',testmotifsegment,'un',0)';
maxlen = max(cellfun(@length,ampsylls));
ampsylls = cell2mat(cellfun(@(x) [x NaN(1,maxlen-length(x))],ampsylls,'un',0));
pksylls = (arrayfun(@(x) (x.pksegment(:,2)-x.pksegment(:,1))',testmotifsegment,'un',0)');
maxlen = max(cellfun(@length,pksylls));
pksylls = cell2mat(cellfun(@(x) [x NaN(1,maxlen-length(x))],pksylls,'un',0));
dtwpksylls = (arrayfun(@(x) (x.dtwpksegment(:,2)-x.dtwpksegment(:,1))',testmotifsegment,'un',0)');
maxlen = max(cellfun(@length,dtwpksylls));
dtwpksylls = cell2mat(cellfun(@(x) [x NaN(1,maxlen-length(x))],dtwpksylls,'un',0));
dtwampsylls = cell2mat(arrayfun(@(x) (x.dtwampsegment(:,2)-x.dtwampsegment(:,1))',testmotifsegment,'un',0)');

dtwgaps = cell2mat(arrayfun(@(x) (x.dtwsegment(2:end,1)-x.dtwsegment(1:end-1,2))',testmotifsegment,'un',0)');
ampgaps = (arrayfun(@(x) (x.ampsegment(2:end,1)-x.ampsegment(1:end-1,2))',testmotifsegment,'un',0)');
maxlen = max(cellfun(@length,ampgaps));
ampgaps = cell2mat(cellfun(@(x) [x NaN(1,maxlen-length(x))],ampgaps,'un',0));
pkgaps = (arrayfun(@(x) (x.pksegment(2:end,1)-x.pksegment(1:end-1,2))',testmotifsegment,'un',0)');
maxlen = max(cellfun(@length,pkgaps));
pkgaps = cell2mat(cellfun(@(x) [x NaN(1,maxlen-length(x))],pkgaps,'un',0));
dtwpkgaps = (arrayfun(@(x) (x.dtwpksegment(2:end,1)-x.dtwpksegment(1:end-1,2))',testmotifsegment,'un',0)');
maxlen = max(cellfun(@length,dtwpkgaps));
dtwpkgaps = cell2mat(cellfun(@(x) [x NaN(1,maxlen-length(x))],dtwpkgaps,'un',0));
dtwampgaps = cell2mat(arrayfun(@(x) (x.dtwampsegment(2:end,1)-x.dtwampsegment(1:end-1,2))',testmotifsegment,'un',0)');

figure;hold on;
[n b] = hist(dtwsylls(:),[0.01:0.001:0.250]);
stairs(b,n/sum(n),'k');hold on;
[n b] = hist(ampsylls(:),[0.01:0.001:0.250]);
stairs(b,n/sum(n),'r');hold on;
[n b] = hist(pksylls(:),[0.01:0.002:0.250]);
stairs(b,n/sum(n),'b');hold on;
[n b] = hist(dtwpksylls(:),[0.01:0.002:0.250]);
stairs(b,n/sum(n),'g');hold on;
[n b] = hist(dtwampsylls(:),[0.01:0.002:0.250]);
stairs(b,n/sum(n),'m');hold on;

figure;hold on;
[n b] = hist(dtwgaps(:),[0:0.001:0.2]);
stairs(b,n/sum(n),'k');hold on;
[n b] = hist(ampgaps(:),[0:0.001:0.2]);
stairs(b,n/sum(n),'r');hold on;
[n b] = hist(pkgaps(:),[0.01:0.002:0.250]);
stairs(b,n/sum(n),'b');hold on;
[n b] = hist(dtwpkgaps(:),[0.01:0.002:0.250]);
stairs(b,n/sum(n),'g');hold on;
[n b] = hist(dtwampgaps(:),[0.01:0.002:0.250]);
stairs(b,n/sum(n),'m');hold on;

%% plot example spectrograms and segmentation for dtw vs amp 
sm = arrayfun(@(x) log(x.sm),testmotifsegment,'un',0);%extract amp env for each trial
filtsong = arrayfun(@(x) bandpass(x.smtemp,fs,500,10000,'hanningffir'),testmotifsegment,'un',0);
%params for spectrogram
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

ind = find(arrayfun(@(x) size(x.ampsegment,1)~=length(motif),testmotifsegment,'un',1));%index for cases of missegmentation with amplitude
for i = 1:length(ind)
    figure;
    subplot(2,1,1);hold on;
    [sp f tm] = spectrogram(filtsong{ind(i)},w,overlap,NFFT,fs);
    indf = find(f>500&f<10000);
    imagesc(tm,f(indf),log(abs(sp(indf,:))));hold on;
    plot(repmat(testmotifsegment(ind(i)).ampsegment(:,1),1,2)',[500 10000],'r');hold on;
    plot(repmat(testmotifsegment(ind(i)).ampsegment(:,2),1,2)',[500 10000],'r');hold on;
    title('amplitude');
    
    subplot(2,1,2);hold on;
    [sp f tm] = spectrogram(filtsong{ind(i)},w,overlap,NFFT,fs);
    indf = find(f>500&f<10000);
    imagesc(tm,f(indf),log(abs(sp(indf,:))));hold on;
    plot(repmat(testmotifsegment(ind(i)).dtwsegment(:,1),1,2)',[500 10000],'r');hold on;
    plot(repmat(testmotifsegment(ind(i)).dtwsegment(:,2),1,2)',[500 10000],'r');hold on;
    title('dtw');
end


mnvol = cellfun(@mean,sm,'un',1);
[~,ind] = sort(mnvol);
ind = [ind(1:5) ind(end-5:end)];%take the quietest 5 renditions and loudest 5 renditions
for i = 1:length(ind)
    figure;
    subplot(2,1,1);hold on;
    [sp f tm] = spectrogram(filtsong{ind(i)},w,overlap,NFFT,fs);
    indf = find(f>500&f<10000);
    imagesc(tm,f(indf),log(abs(sp(indf,:))));hold on;
    plot(repmat(testmotifsegment(ind(i)).ampsegment(:,1),1,2)',[500 10000],'r');hold on;
    plot(repmat(testmotifsegment(ind(i)).ampsegment(:,2),1,2)',[500 10000],'r');hold on;
    title('amplitude');
    
    subplot(2,1,2);hold on;
    [sp f tm] = spectrogram(filtsong{ind(i)},w,overlap,NFFT,fs);
    indf = find(f>500&f<10000);
    imagesc(tm,f(indf),log(abs(sp(indf,:))));hold on;
    plot(repmat(testmotifsegment(ind(i)).dtwsegment(:,1),1,2)',[500 10000],'r');hold on;
    plot(repmat(testmotifsegment(ind(i)).dtwsegment(:,2),1,2)',[500 10000],'r');hold on;
    title('dtw');
end

%% plot example of peak segmentation 
sm = arrayfun(@(x) log(x.sm),testmotifsegment,'un',0);%extract amp env for each trial
filtsong = arrayfun(@(x) bandpass(x.smtemp,fs,500,10000,'hanningffir'),testmotifsegment,'un',0);

for i = 1:length(ind)
    figure;
    subplot(2,1,1);hold on;
    [sp f tm] = spectrogram(filtsong{ind(i)},w,overlap,NFFT,fs);
    indf = find(f>500&f<10000);
    imagesc(tm,f(indf),log(abs(sp(indf,:))));hold on;
    plot(repmat(testmotifsegment(ind(i)).pksegment(:,1),1,2)',[500 10000],'r');hold on;
    plot(repmat(testmotifsegment(ind(i)).pksegment(:,2),1,2)',[500 10000],'r');hold on;
    
    subplot(2,1,2);hold on;
    tb = [0:length(sm{ind(i)})-1]./fs;
    sm2 = log(sm{ind(i)});sm2 = sm2-min(sm2);sm2=sm2./max(sm2);
    plot(tb,sm2,'k');hold on;
    plot(repmat(testmotifsegment(ind(i)).pksegment(:,1),1,2)',[0 1],'r');hold on;
    plot(repmat(testmotifsegment(ind(i)).pksegment(:,2),1,2)',[0 1],'r');hold on;
end

%% plot example of tonality segmentation 
sm = arrayfun(@(x) log(x.sm),testmotifsegment,'un',0);%extract amp env for each trial
filtsong = arrayfun(@(x) bandpass(x.smtemp,fs,500,10000,'hanningffir'),testmotifsegment,'un',0);

for i = 1:length(ind)
    figure;
    subplot(3,1,1);hold on;
    [sp f tm] = spectrogram(filtsong{ind(i)},w,overlap,NFFT,fs);
    indf = find(f>500&f<10000);
    imagesc(tm,f(indf),log(abs(sp(indf,:))));hold on;
    plot(repmat(testmotifsegment(ind(i)).tonalitysegment(:,1),1,2)',[500 10000],'r');hold on;
    plot(repmat(testmotifsegment(ind(i)).tonalitysegment(:,2),1,2)',[500 10000],'r');hold on;
    
    subplot(3,1,2);hold on;
    tb = [0:length(sm{ind(i)})-1]./fs;
    sm2 = log(sm{ind(i)});sm2 = sm2-min(sm2);sm2=sm2./max(sm2);
    plot(tb,sm2,'k');hold on;
    plot(repmat(testmotifsegment(ind(i)).tonalitysegment(:,1),1,2)',[0 1],'r');hold on;
    plot(repmat(testmotifsegment(ind(i)).tonalitysegment(:,2),1,2)',[0 1],'r');hold on;
    
    subplot(3,1,3);hold on;
    smtemp = testmotifsegment(ind(i)).smtemp;
    tonalitysegment(smtemp,fs);
    plot(repmat(testmotifsegment(ind(i)).tonalitysegment(:,1),1,2)',[0 1],'r');hold on;
    plot(repmat(testmotifsegment(ind(i)).tonalitysegment(:,2),1,2)',[0 1],'r');hold on;
end

%% plot example of peak segmentation 
sm = arrayfun(@(x) log(x.sm),testmotifsegment,'un',0);%extract amp env for each trial
filtsong = arrayfun(@(x) bandpass(x.smtemp,fs,500,10000,'hanningffir'),testmotifsegment,'un',0);

for i = 1:length(ind)
    figure;
    subplot(2,1,1);hold on;
    [sp f tm] = spectrogram(filtsong{ind(i)},w,overlap,NFFT,fs);
    indf = find(f>500&f<10000);
    imagesc(tm,f(indf),log(abs(sp(indf,:))));hold on;
    plot(repmat(testmotifsegment(ind(i)).dtwpksegment(:,1),1,2)',[500 10000],'r');hold on;
    plot(repmat(testmotifsegment(ind(i)).dtwpksegment(:,2),1,2)',[500 10000],'r');hold on;
    
    subplot(2,1,2);hold on;
    tb = [0:length(sm{ind(i)})-1]./fs;
    sm2 = log(sm{ind(i)});sm2 = sm2-min(sm2);sm2=sm2./max(sm2);
    plot(tb,sm2,'k');hold on;
    plot(repmat(testmotifsegment(ind(i)).dtwpksegment(:,1),1,2)',[0 1],'r');hold on;
    plot(repmat(testmotifsegment(ind(i)).dtwpksegment(:,2),1,2)',[0 1],'r');hold on;
end

%% add pink noise to filtsong
ind = 1;
len = length(filtsong{ind});
cn = dsp.ColoredNoise('Color','pink','SamplesPerFrame',NFFT);
winid = 1;filtandnoise = [];
while length(filtandnoise)<len
    if winid+NFFT-1 < len
        audioRMS = rms(filtsong{ind}(winid:winid+NFFT-1));
        noise = cn();
        noiseRMS = rms(noise);
        noise = noise*(audioRMS/noiseRMS);
        filtandnoise = [filtandnoise; filtsong{ind}(winid:winid+NFFT-1)+noise];
        winid = winid+NFFT;
    else
        len = length(filtsong{ind}(winid:len));
        audioRMS = rms(filtsong{ind}(winid:winid+len-1));
        cn = dsp.ColoredNoise('Color','pink','SamplesPerFrame',len);
        noise = cn();
        noiseRMS = rms(noise);
        noise = noise*(audioRMS/noiseRMS);
        filtandnoise = [filtandnoise; filtsong{ind}(winid:winid+len-1)+noise];
    end
end

figure;subplot(2,1,1);
[sp f tm] = spectrogram(filtsong{ind},w,overlap,NFFT,fs);
indf = find(f>500&f<10000);
imagesc(tm,f(indf),log(abs(sp(indf,:))));set(gca,'YDir','normal');hold on;
sm = evsmooth(filtsong{ind},fs,'','',5);
sm=log(sm);sm=sm-min(sm);sm=sm./max(sm);
[ons offs] = SegmentNotes(sm,fs,5,20,0.5);
plot([ons ons],[500 10000],'r');hold on;
plot([offs offs],[500 10000],'r');hold on;
[ons offs] = dtw_segment(filtsong{ind},dtwtemplate_cdef,fs);
plot([ons ons],[500 10000],'g');hold on;
plot([offs offs],[500 10000],'g');hold on;
subplot(2,1,2);
[sp f tm] = spectrogram(filtandnoise,w,overlap,NFFT,fs);
indf = find(f>500&f<10000);
imagesc(tm,f(indf),log(abs(sp(indf,:))));set(gca,'YDir','normal');hold on;
sm = evsmooth(filtandnoise,fs,'','',5);
sm=log(sm);sm=sm-min(sm);sm=sm./max(sm);
[ons offs] = SegmentNotes(sm,fs,5,20,0.5);
plot([ons ons],[500 10000],'r');hold on;
plot([offs offs],[500 10000],'r');hold on;
[ons offs] = dtw_segment(filtandnoise,dtwtemplate_cdef,fs);
plot([ons ons],[500 10000],'g');hold on;
plot([offs offs],[500 10000],'g');hold on;

%% consistency of segmentation when pink noise added
ampnoise = cell(length(filtsong),1);
dtwnoise = cell(length(filtsong),1);
for i = 1:length(filtsong)
    len = length(filtsong{i});
    cn = dsp.ColoredNoise('Color','pink','SamplesPerFrame',NFFT);
    winid = 1;filtandnoise = [];
    while length(filtandnoise)<len
        if winid+NFFT-1 < len
            audioRMS = rms(filtsong{i}(winid:winid+NFFT-1));
            noise = cn();
            noiseRMS = rms(noise);
            noise = noise*(audioRMS/noiseRMS);
            filtandnoise = [filtandnoise; filtsong{i}(winid:winid+NFFT-1)+noise];
            winid = winid+NFFT;
        else
            len = length(filtsong{i}(winid:len));
            audioRMS = rms(filtsong{i}(winid:winid+len-1));
            cn = dsp.ColoredNoise('Color','pink','SamplesPerFrame',len);
            noise = cn();
            noiseRMS = rms(noise);
            noise = noise*(audioRMS/noiseRMS);
            filtandnoise = [filtandnoise; filtsong{i}(winid:winid+len-1)+noise];
        end
    end
    sm = evsmooth(filtandnoise,fs,'','',5);
    sm=log(sm);sm=sm-min(sm);sm=sm./max(sm);
    [ons offs] = SegmentNotes(sm,fs,5,20,0.5);
    ampnoise{i} = [ons offs];
    [ons offs] = dtw_segment(filtandnoise,dtwtemplate_cdef,fs);
    dtwnoise{i} = [ons offs];
end

dtwnoisesylls = cell2mat(cellfun(@(x) (x(:,2)-x(:,1))',dtwnoise,'un',0));
ampnoisesylls = cellfun(@(x) (x(:,2)-x(:,1))',ampnoise,'un',0);
maxlen = max(cellfun(@length,ampnoisesylls));
ampnoisesylls = cell2mat(cellfun(@(x) [x NaN(1,maxlen-length(x))],ampnoisesylls,'un',0));

dtwnoisegaps = cell2mat(cellfun(@(x) (x(2:end,1)-x(1:end-1,2))',dtwnoise,'un',0));
ampnoisegaps = cellfun(@(x) (x(2:end,1)-x(1:end-1,2))',ampnoise,'un',0);
maxlen = max(cellfun(@length,ampnoisegaps));
ampnoisegaps = cell2mat(cellfun(@(x) [x NaN(1,maxlen-length(x))],ampnoisegaps,'un',0));

w = sum(~isnan(dtwnoisesylls))./length(dtwnoisesylls(:));
sum(cv(dtwnoisesylls).*w)
w = sum(~isnan(ampnoisesylls))./length(ampnoisesylls(:));
sum(cv(ampnoisesylls).*w)

w = sum(~isnan(dtwnoisegaps))./length(dtwnoisegaps(:));
sum(cv(dtwnoisegaps).*w)
w = sum(~isnan(ampnoisegaps))./length(ampnoisegaps(:));
sum(cv(ampnoisegaps).*w)
