%takes the structure generated from jc_tonality (for paired saline and drug 
%condition). Extracts each motif’s tonality waveform and plots the average 
%tonality waveform. Uses threshold segmentation on the average tonality waveform 
%to determine syllable onsets/offsets. The average waveform is then dynamically 
%time warped to the tonality waveform of every rendition of the motif. From 
%the warping, it extracts the corresponding syllable onsets/offsets for each 
%rendition, and saves that information in the structure.


%% make tonality_segment structures from jc_tonality
motif = 'dacb';
fs = 32000;
downsamp = 16;%needs to corresponding to the jog size used in tonality waveform computation in jc_tonality

%% find average tonality waveform
avg_wv = {};
for i = 1:length(tonality_segment_sal)
    wv = tonality_segment_sal(i).tonality;
    avg_wv = [avg_wv,wv]; 
end

avg_wv2 = {};
for i = 1:length(tonality_segment_naspm)
    wv = tonality_segment_naspm(i).tonality;
    avg_wv2 = [avg_wv2,wv]; 
end

maxlength = max([max(cellfun(@(x) length(x),avg_wv)) ...
    max(cellfun(@(x) length(x),avg_wv2))]);
avg_wv = cellfun(@(x) [x;zeros(maxlength-length(x),1)],avg_wv,'unif',0);
avg_wv = cell2mat(avg_wv);
meanavg_wv = mean(avg_wv,2);
avg_wv2 = cellfun(@(x) [x;zeros(maxlength-length(x),1)],avg_wv2,'unif',0);
avg_wv2 = cell2mat(avg_wv2);
meanavg_wv2 = mean(avg_wv2,2);    
    %align waveforms with cross correlation to recompute average, aligns by
    %center
%         avg_wv_aligned = {};
%         for i = 1:size(avg_wv,2)
%             [c lag] = xcorr(meanavg_wv,avg_wv(:,i));
%             c = c(ceil(length(c)/2):end);
%             lag = lag(ceil(length(lag)/2):end);
%             [m ind] = max(c);
%             if lag(ind) > 0
%                 wv = [zeros(lag(ind),1);avg_wv(:,i)];
%                 avg_wv_aligned = [avg_wv_aligned; wv];
%             elseif lag(ind) < 0
%                 wv = [avg_wv1(:,i); zeros(abs(lag(ind)),1)];
%                 avg_wv_aligned = [avg_wv_aligned; wv];
%             elseif lag(ind) == 0
%                 avg_wv_aligned = [avg_wv_aligned; avg_wv(:,i)];
%             end
%         end
% 
% 
%         avg_wv2_aligned = {};
%         for i = 1:size(avg_wv2,2)
%             [c lag] = xcorr(meanavg_wv,avg_wv2(:,i));%align naspm trials to average saline 
%             c = c(ceil(length(c)/2):end);
%             lag = lag(ceil(length(lag)/2):end);
%             [m ind] = max(c);
%             if lag(ind) > 0
%                 wv = [zeros(lag(ind),1);avg_wv2(:,i)];
%                 avg_wv2_aligned = [avg_wv2_aligned; wv];
%             elseif lag(ind) < 0
%                 wv = [avg_wv1(:,i); zeros(abs(lag(ind)),1)];
%                 avg_wv2_aligned = [avg_wv2_aligned; wv];
%             elseif lag(ind) == 0
%                 avg_wv2_aligned = [avg_wv2_aligned; avg_wv2(:,i)];
%             end
%         end
% 
%         maxlength = max([max(cellfun(@(x) length(x),avg_wv_aligned)) ...
%             max(cellfun(@(x) length(x),avg_wv2_aligned))]);
%         avg_wv = cellfun(@(x) [x;zeros(maxlength-length(x),1)],avg_wv_aligned,'unif',0);
%         avg_wv = cell2mat(avg_wv');
%         avg_wv2 = cellfun(@(x) [x;zeros(maxlength-length(x),1)],avg_wv2_aligned,'unif',0);
%         avg_wv2 = cell2mat(avg_wv2');
%         meanavg_wv = mean(avg_wv,2);
%         meanavg_wv2 = mean(avg_wv2,2);

figure;plot([1:maxlength]/(fs/downsamp),meanavg_wv);hold on;
plot([1:maxlength]/(fs/downsamp),meanavg_wv2,'r');

%% set onset and offsets of syllables based on average tonality wv
timebase = [1:length(meanavg_wv)]/(fs/downsamp);
thresh = 0.4;
[ons offs] = SegmentNotes(meanavg_wv,fs/downsamp,10,20,thresh);
if length(ons) ~= length(motif)
    error('segmentation error');
end
figure;plot([1:maxlength]/(fs/downsamp),meanavg_wv);hold on;
plot([ons ons],[min(meanavg_wv) max(meanavg_wv)],'r');hold on
plot([offs offs],[min(meanavg_wv) max(meanavg_wv)],'g');

onind = [];
offind = [];
for i = 1:length(ons)
    ind = find(timebase>=ons(i));
    onind = [onind;ind(1)];
    ind = find(timebase >=offs(i));
    offind = [offind;ind(1)];
end

%% find corresponding onsets and offsets of each syllable rendition based on dtw

for i = 1:length(tonality_segment_sal)
    [d ix iy] = dtw(meanavg_wv,avg_wv(:,i));%add restriction on warp
    onset = [];
    offset = [];
    for ii = 1:length(onind)
        ind = find(ix==onind(ii));
        ind = ind(ceil(length(ind)/2));
        onset = [onset;iy(ind)];
        ind = find(ix==offind(ii));
        ind = ind(ceil(length(ind)/2));
        offset = [offset;iy(ind)];
    end
    tonality_segment_sal(i).tonality_ons = (onset/(fs/downsamp))*1e3;
    tonality_segment_sal(i).tonality_offs = (offset/(fs/downsamp))*1e3;
end

for i = 1:length(tonality_segment_naspm)
    [d ix iy] = dtw(meanavg_wv,avg_wv2(:,i));%add restriction on warp
    onset = [];
    offset = [];
    for ii = 1:length(onind)
        ind = find(ix==onind(ii));
        ind = ind(ceil(length(ind)/2));
        onset = [onset;iy(ind)];
        ind = find(ix==offind(ii));
        ind = ind(ceil(length(ind)/2));
        offset = [offset;iy(ind)];
    end
    tonality_segment_naspm(i).tonality_ons = (onset/(fs/downsamp))*1e3;
    tonality_segment_naspm(i).tonality_offs = (offset/(fs/downsamp))*1e3;
end

%% plot 10 random renditions comparing tonality segmentation  
ind = randperm(length(tonality_segment_sal),10);
ind2 = randperm(length(tonality_segment_naspm),10);
for i = 1:10
    filtsong = tonality_segment_sal(ind(i)).filtsong;
    [sp f t] = spectrogram(filtsong,512,510,512,fs);
    wv = tonality_segment_sal(ind(i)).tonality;
    ons = tonality_segment_sal(ind(i)).tonality_ons;
    offs = tonality_segment_sal(ind(i)).tonality_offs;
    figure;
    h1 = subtightplot(3,1,1,0.07,0.1,0.1);hold on;
    h2 = subtightplot(3,1,2,0.07,0.1,0.1);hold on;
    h3 = subtightplot(3,1,3,0.07,0.1,0.1);hold on;
    imagesc(h1,t,f,log(abs(sp)));syn();ylim(h1,[1000 10000]);colormap('jet');
    plot(h2,[1:length(filtsong)]/fs,filtsong);
    plot(h3,[1:length(wv)]/(fs/downsamp),wv);
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
    plot(h1,([ons ons]/1e3)',[1000 10000],'r');
    plot(h1,([offs offs]/1e3)',[1000 10000],'g');
    plot(h2,([ons ons]/1e3)',[min(filtsong) max(filtsong)],'r');
    plot(h2,([offs offs]/1e3)',[min(filtsong) max(filtsong)],'g');
    plot(h3,([ons ons]/1e3)',[min(wv) max(wv)],'r');
    plot(h3,([offs offs]/1e3)',[min(wv) max(wv)],'g');
end

for i = 1:10
    filtsong = tonality_segment_naspm(ind2(i)).filtsong;
    [sp f t] = spectrogram(filtsong,512,510,512,fs);
    wv = tonality_segment_naspm(ind2(i)).tonality;
    ons = tonality_segment_naspm(ind2(i)).tonality_ons;
    offs = tonality_segment_naspm(ind2(i)).tonality_offs;
    figure;
    h1 = subtightplot(3,1,1,0.07,0.1,0.1);hold on;
    h2 = subtightplot(3,1,2,0.07,0.1,0.1);hold on;
    h3 = subtightplot(3,1,3,0.07,0.1,0.1);hold on;
    imagesc(h1,t,f,log(abs(sp)));syn();ylim(h1,[1000 10000]);colormap('jet');hold on;
    plot(h2,[1:length(filtsong)]/fs,filtsong);
    plot(h3,[1:length(wv)]/(fs/downsamp),wv);
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
    plot(h1,([ons ons]/1e3)',[1000 10000],'r');
    plot(h1,([offs offs]/1e3)',[1000 10000],'g');
    plot(h2,([ons ons]/1e3)',[min(filtsong) max(filtsong)],'r');
    plot(h2,([offs offs]/1e3)',[min(filtsong) max(filtsong)],'g');
    plot(h3,([ons ons]/1e3)',[min(wv) max(wv)],'r');
    plot(h3,([offs offs]/1e3)',[min(wv) max(wv)],'g');
end
