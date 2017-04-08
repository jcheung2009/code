sm_sal = motifsegment_bcd_11_14_2015_saline(4).sm;
h1 = figure;hold on;plot(sm_sal,'k')
sm_sal2 = log(sm_sal);sm_sal2 = (sm_sal2-mean(sm_sal2))./std(sm_sal2);
sm_sal3 = log(sm_sal);sm_sal3 = sm_sal3-min(sm_sal3);sm_sal3=sm_sal3./max(sm_sal3);
ph = angle(hilbert(sm_sal2));
syllsegments = (ph>=-0.7*pi & ph<0.7*pi);
gapsegments = (ph>=0.7*pi | ph<-0.7*pi);
h2 = figure;hold on;plot(sm_sal2,'k');
[ons offs] = SegmentNotes(syllsegments,44100,5,20,0.5);
syllsegments = double(syllsegments);
fs = 44100;
for i = 1:length(ons)
    interval = floor(ons(i)*fs):ceil(offs(i)*fs);
    syllsegments(interval) = randi([1 10],1,length(interval));
end
ind = find(syllsegments==0);
syllsegments(ind) = 1;
sm2 = sm_sal.*syllsegments;
len = round(fs*10/1000);
h   = ones(1,len)/len;
sm2 = conv(h, sm2);
offset = round((length(sm2)-length(sm_sal))/2);
sm2=sm2(1+offset:length(sm_sal)+offset);
figure(h1);hold on;plot(sm2,'r');

sm2_ph = log(sm2);sm2_ph=(sm2_ph-mean(sm2_ph))./std(sm2_ph);
figure(h2);hold on;plot(sm2_ph,'r');
sm2_amp = log(sm2);sm2_amp=(sm2_amp-min(sm2_amp));sm2_amp=sm2_amp./max(sm2_amp);
h3=figure;hold on;plot(sm2_amp,'r');hold on;plot(sm_sal3,'k');

[c lag] = xcorr(sm_sal3,'coeff');
c = c(ceil(length(lag)/2):end);
lag = lag(ceil(length(lag)/2):end);
[pks locs] = findpeaks(c,'minpeakwidth',256);
h4 = figure;hold on;plot(lag/fs,c,'k',locs/fs,pks,'ob');hold on;
[c lag] = xcorr(sm2_amp,'coeff');
c = c(ceil(length(lag)/2):end);
lag = lag(ceil(length(lag)/2):end);
[pks locs] = findpeaks(c,'minpeakwidth',256);
figure(h4);hold on;plot(lag/fs,c,'r',locs/fs,pks,'ob');hold on;

ph = angle(hilbert(sm_sal2));
syllsegments = (ph>=-0.7*pi & ph<0.7*pi);
gapsegments = (ph>=0.7*pi | ph<-0.7*pi);
[ons offs] = SegmentNotes(syllsegments,fs,5,20,0.5);
sm_sal_durs = offs-ons
sm_sal_gaps = ons(2:end)-offs(1:end-2)

ph = angle(hilbert(sm2_ph));
syllsegments = (ph>=-0.7*pi & ph<0.7*pi);
gapsegments = (ph>=0.7*pi | ph<-0.7*pi);
[ons offs] = SegmentNotes(syllsegments,fs,5,20,0.5);
sm2_durs = offs-ons
sm2_gaps = ons(2:end)-offs(1:end-2)

%% artifically increase amplitude of syllables and compare durs/gaps and
%acorr
fs=44100;
w = {[.3],[5],[2]};
motifsegment = motifsegment_bcd_11_14_2015_saline;
for i = 1:length(motifsegment)
    smtemp = motifsegment(i).smtemp;
    sm = bandpass(smtemp,fs,300,10000,'hanningffir');
    sm = envelope(sm);
    sm1 = filter(songfilt);
    %sm_ph = log(sm);sm_ph=(sm_ph-mean(sm_ph))./std(sm_ph);
    ph = angle(hilbert(sm1-mean(sm1)));
    syllsegments = (ph>=-0.5*pi & ph<=0.5*pi);
    [ons offs] = SegmentNotes(syllsegments,fs,5,20,0.5);
    if length(ons)==3
        motifsegment(i).ph_durs = offs-ons;
        motifsegment(i).ph_gaps = ons(2:end)-offs(1:end-1);
    else
        motifsegment(i).ph_durs = [];
        motifsegment(i).ph_gaps = [];
    end
    syllsegments = double(syllsegments);
    for ii = 1:length(ons)
        interval = floor(ons(ii)*fs):floor(offs(ii)*fs);
        syllsegments(interval) = repmat(w{ii},length(interval),1);
    end
    ind = find(syllsegments==0);
    syllsegments(ind) = 1;
    if length(syllsegments)~=length(sm)
        difflen = length(sm)-length(syllsegments);
        if difflen < 0
            syllsegments = syllsegments(1:end+difflen);
        else 
            syllsegments=[syllsegments;ones(difflen,1)];
        end
    end
    
    sm2 = smtemp.*syllsegments;
%     len = round(fs*10/1000);
%     h   = ones(1,len)/len;
%     sm2 = conv(h, sm2);
%     offset = round((length(sm2)-length(sm))/2);
%     sm2=sm2(1+offset:length(sm)+offset);
    %sm2_ph = log(sm2);sm2_ph=(sm2_ph-mean(sm2_ph))./std(sm2_ph);
    ph = angle(hilbert(sm2-mean(sm2)));
    syllsegments = (ph>=-0.5*pi & ph<=0.5*pi);
    [ons offs] = SegmentNotes(syllsegments,fs,5,20,0.5);
    if length(ons)==3
        motifsegment2(i).ph_durs = offs-ons;
        motifsegment2(i).ph_gaps = ons(2:end)-offs(1:end-1);
    else
        motifsegment2(i).ph_durs = [];
        motifsegment2(i).ph_gaps = [];
    end
    sm2_amp=log(sm2);sm2_amp=(sm2_amp-min(sm2_amp));sm2_amp=sm2_amp./max(sm2_amp);
    [ons offs] = SegmentNotes(sm2_amp,fs,5,20,0.3);
    if length(ons) == 3
        motifsegment2(i).amp_durs = offs-ons;
        motifsegment2(i).amp_gaps = ons(2:end)-offs(1:end-1);
    else
        motifsegment2(i).amp_durs = [];
        motifsegment2(i).amp_gaps = [];
    end
    [c lag] = xcorr(sm2_amp,'coeff');
    c = c(ceil(length(lag)/2):end);
    lag = lag(ceil(length(lag)/2):end);
    [pks locs] = findpeaks(c,'minpeakwidth',256);
    pkind = find(locs>0.1*fs & locs < 0.145*fs);
    if length(pkind)==1
        motifsegment2(i).firstpeakdistance = locs(pkind)/fs;
    else
        motifsegment2(i).firstpeakdistance=NaN;
    end
    motifsegment2(i).sm = sm2;

end

[h p] = ttest2([motifsegment(:).firstpeakdistance],[motifsegment2(:).firstpeakdistance]);
disp(['acorr ttest:p=',num2str(p)])
[h p] = ttest2(arrayfun(@(x) mean(x.amp_durs),motifsegment,'unif',1),arrayfun(@(x) mean(x.amp_durs),motifsegment2,'unif',1));
disp(['amp durs ttest:p=',num2str(p)])
[h p] = ttest2(arrayfun(@(x) mean(x.ph_durs),motifsegment,'unif',1),arrayfun(@(x) mean(x.ph_durs),motifsegment2,'unif',1));
disp(['ph durs ttest:p=',num2str(p)])
[h p] = ttest2(arrayfun(@(x) mean(x.amp_gaps),motifsegment,'unif',1),arrayfun(@(x) mean(x.amp_gaps),motifsegment2,'unif',1));
disp(['amp gaps ttest:p=',num2str(p)])
[h p] = ttest2(arrayfun(@(x) mean(x.ph_gaps),motifsegment,'unif',1),arrayfun(@(x) mean(x.ph_gaps),motifsegment2,'unif',1));
disp(['ph gaps ttest:p=',num2str(p)])
[h p] = ttest2(arrayfun(@(x) mean(x.sm),motifsegment,'unif',1),arrayfun(@(x) mean(x.sm),motifsegment2,'unif',1));
disp(['vol ttest:p=',num2str(p)])

x = nanmean(arrayfun(@(x) mean(x.amp_durs),motifsegment));
y=nanmean(arrayfun(@(x) mean(x.amp_durs),motifsegment2));
disp(['amp durs 1 vs 2: ',num2str(x),' ',num2str(y)])
x = nanmean(arrayfun(@(x) mean(x.ph_durs),motifsegment));
y=nanmean(arrayfun(@(x) mean(x.ph_durs),motifsegment2));
disp(['ph durs 1 vs 2: ',num2str(x),' ',num2str(y)])
x = nanmean(arrayfun(@(x) mean(x.amp_gaps),motifsegment));
y=nanmean(arrayfun(@(x) mean(x.amp_gaps),motifsegment2));
disp(['amp gaps 1 vs 2: ',num2str(x),' ',num2str(y)])
x = nanmean(arrayfun(@(x) mean(x.ph_gaps),motifsegment));
y=nanmean(arrayfun(@(x) mean(x.ph_gaps),motifsegment2));
disp(['ph gaps 1 vs 2: ',num2str(x),' ',num2str(y)])

%% artifically shorten gaps and compare durs/gaps and
%acorr
fs=44100;
w = {[.5],[0.5],[0.5]};
motifsegment = motifsegment_bcd_11_14_2015_saline;
for i = 1:length(motifsegment)
    sm = motifsegment(i).sm;
    sm_ph = log(sm);sm_ph=(sm_ph-mean(sm_ph))./std(sm_ph);
    ph = angle(hilbert(sm_ph));
    syllsegments = (ph>=-0.5*pi & ph<=0.5*pi);
    [ons offs] = SegmentNotes(syllsegments,fs,5,20,0.5);
    if length(ons)==3
        motifsegment(i).ph_durs = offs-ons;
        motifsegment(i).ph_gaps = ons(2:end)-offs(1:end-1);
    else
        motifsegment(i).ph_durs = [];
        motifsegment(i).ph_gaps = [];
    end
    syllsegments = double(syllsegments);
    for ii = 1:length(ons)
        interval = floor(ons(ii)*fs):floor(offs(ii)*fs);
        syllsegments(interval) = repmat(w{ii},length(interval),1);
    end
    ind = find(syllsegments==0);
    syllsegments(ind) = 1;
    if length(syllsegments)~=length(sm)
        difflen = length(sm)-length(syllsegments);
        if difflen < 0
            syllsegments = syllsegments(1:end+difflen);
        else 
            syllsegments=[syllsegments;ones(difflen,1)];
        end
    end
    sm2 = sm.*syllsegments;
%     len = round(fs*10/1000);
%     h   = ones(1,len)/len;
%     sm2 = conv(h, sm2);
%     offset = round((length(sm2)-length(sm))/2);
%     sm2=sm2(1+offset:length(sm)+offset);
    sm2_ph = log(sm2);sm2_ph=(sm2_ph-mean(sm2_ph))./std(sm2_ph);
    ph = angle(hilbert(sm2_ph));
    syllsegments = (ph>=-0.6*pi & ph<=0.6*pi);
    [ons offs] = SegmentNotes(syllsegments,fs,5,20,0.5);
    if length(ons)==3
        motifsegment2(i).ph_durs = offs-ons;
        motifsegment2(i).ph_gaps = ons(2:end)-offs(1:end-1);
    else
        motifsegment2(i).ph_durs = [];
        motifsegment2(i).ph_gaps = [];
    end
    sm2_amp=log(sm2);sm2_amp=(sm2_amp-min(sm2_amp));sm2_amp=sm2_amp./max(sm2_amp);
    [ons offs] = SegmentNotes(sm2_amp,fs,5,20,0.3);
    if length(ons) == 3
        motifsegment2(i).amp_durs = offs-ons;
        motifsegment2(i).amp_gaps = ons(2:end)-offs(1:end-1);
    else
        motifsegment2(i).amp_durs = [];
        motifsegment2(i).amp_gaps = [];
    end
    [c lag] = xcorr(sm2_amp,'coeff');
    c = c(ceil(length(lag)/2):end);
    lag = lag(ceil(length(lag)/2):end);
    [pks locs] = findpeaks(c,'minpeakwidth',256);
    pkind = find(locs>0.1*fs & locs < 0.145*fs);
    if length(pkind)==1
        motifsegment2(i).firstpeakdistance = locs(pkind)/fs;
    else
        motifsegment2(i).firstpeakdistance=NaN;
    end
    motifsegment2(i).sm = sm2;

end

[h p] = ttest2([motifsegment(:).firstpeakdistance],[motifsegment2(:).firstpeakdistance]);
disp(['acorr ttest:p=',num2str(p)])
[h p] = ttest2(arrayfun(@(x) mean(x.amp_durs),motifsegment,'unif',1),arrayfun(@(x) mean(x.amp_durs),motifsegment2,'unif',1));
disp(['amp durs ttest:p=',num2str(p)])
[h p] = ttest2(arrayfun(@(x) mean(x.ph_durs),motifsegment,'unif',1),arrayfun(@(x) mean(x.ph_durs),motifsegment2,'unif',1));
disp(['ph durs ttest:p=',num2str(p)])
[h p] = ttest2(arrayfun(@(x) mean(x.amp_gaps),motifsegment,'unif',1),arrayfun(@(x) mean(x.amp_gaps),motifsegment2,'unif',1));
disp(['amp gaps ttest:p=',num2str(p)])
[h p] = ttest2(arrayfun(@(x) mean(x.ph_gaps),motifsegment,'unif',1),arrayfun(@(x) mean(x.ph_gaps),motifsegment2,'unif',1));
disp(['ph gaps ttest:p=',num2str(p)])
[h p] = ttest2(arrayfun(@(x) mean(x.sm),motifsegment,'unif',1),arrayfun(@(x) mean(x.sm),motifsegment2,'unif',1));
disp(['vol ttest:p=',num2str(p)])

x = nanmean(arrayfun(@(x) mean(x.amp_durs),motifsegment));
y=nanmean(arrayfun(@(x) mean(x.amp_durs),motifsegment2));
disp(['amp durs 1 vs 2: ',num2str(x),' ',num2str(y)])
x = nanmean(arrayfun(@(x) mean(x.ph_durs),motifsegment));
y=nanmean(arrayfun(@(x) mean(x.ph_durs),motifsegment2));
disp(['ph durs 1 vs 2: ',num2str(x),' ',num2str(y)])
x = nanmean(arrayfun(@(x) mean(x.amp_gaps),motifsegment));
y=nanmean(arrayfun(@(x) mean(x.amp_gaps),motifsegment2));
disp(['amp gaps 1 vs 2: ',num2str(x),' ',num2str(y)])
x = nanmean(arrayfun(@(x) mean(x.ph_gaps),motifsegment));
y=nanmean(arrayfun(@(x) mean(x.ph_gaps),motifsegment2));
disp(['ph gaps 1 vs 2: ',num2str(x),' ',num2str(y)])

