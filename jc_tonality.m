function [tonality_segment] = jc_tonality(batch,motif,chanspec);

ff = load_batchf(batch);
tonality_segment = struct();

trialcnt = 0;
for i = 1:length(ff)
    fn = (ff(i).name);
    fnn=[fn,'.not.mat'];
    if (~exist(fnn,'file'))
        continue;
    end
    load(fnn);
    [dat fs] = evsoundin('',fn,chanspec);
    p = strfind(labels,motif);
    for ii = 1:length(p)
        motifdat = dat(floor(onsets(p(ii))*1e-3*fs)-1024:ceil(offsets(p(ii)+length(motif)-1)*1e-3*fs)+1024);
        filtsong= bandpass(motifdat,fs,1000,10000,'hanningfir');%tried tonality on unfiltered song, but changes the thresholding and peaks in corr not as well defined?
        startind = 1;
        tonality = [];
        while length(filtsong)-startind>=256
            endind = startind+256-1;
            win = filtsong(startind:endind);
            win = [win;zeros(256,1)];
            x = fft(win);
            corr = ifft(x.*conj(x));
            m = [2*corr(1)];
            numlags = length(corr)-1;
            for k = 1:numlags
                xt = win(k)^2;
                xt2 = win(end-k+1)^2;
                m = [m; m(end)-xt-xt2];
            end
            nsdf = (2*corr)./m;
            nsdf = nsdf(1:256/2);
            [pks locs] = findpeaks(nsdf);
            if max(pks) > 1
                break
            end
            if isempty(pks)
                tonality = [tonality;NaN];
            else
                tonality = [tonality;max(pks)];
            end
%             x = fft(filtsong(startind:endind));
%             corr = ifft(x.*conj(x));
%             corr = corr(1:length(corr)/4);
%             [pks locs] = findpeaks(corr);
%             if isempty(pks)
%                 tonality = [tonality;NaN];
%             else
%                 tonality = [tonality;pks(1)];
%             end
%             if length(tonality)==1920
%                 break
%             end
            startind = startind+4;
        end
        tonality = abs(tonality);
        thresh = otsuthresh(tonality);%for normalized nsdf method
        %thresh = std(tonality)/1e2;%for bu42o17, cbin
        %thresh = std(tonality)/50;%for pk88gr54, wav
%         [ons offs] = SegmentSong(tonality,fs/4,5,20,thresh);%for bu42o17
        
        sm = evsmooth(motifdat,fs,'','','',5);
        sm2 = log(sm);
        sm2 = sm2-min(sm2);
        sm2 = sm2./max(sm2);
        [ons2 offs2] = SegmentSong(sm2,fs,5,20,0.35);
        
        if length(ons) ~= length(motif) 
            disp(['tonal segmentation error: ',fn]);
            continue
        elseif length(ons2) ~= length(motif)
            disp(['amp segmentation error: ',fn]);
            continue
        end
        
        amp = [];
        for m = 0:length(motif)-1
            sylldat = dat(floor(onsets(p(ii)+m)*1e-3*fs)-512:ceil(offsets(p(ii)+m)*1e-3*fs)+512);
            sylldat = bandpass(sylldat,fs,1000,10000,'hanningfir');
            amp = [amp mean(sylldat.^2)];
        end
        
        trialcnt=trialcnt+1;
        tonality_segment(trialcnt).filtsong = filtsong;
        tonality_segment(trialcnt).dat = motifdat;
        tonality_segment(trialcnt).tonality = tonality;
%         tonality_segment(trialcnt).tonality_ons = ons;
%         tonality_segment(trialcnt).tonality_offs = offs;
        tonality_segment(trialcnt).amp_ons = ons2;
        tonality_segment(trialcnt).amp_offs = offs2;
        tonality_segment(trialcnt).vol = amp;
        
        
    end
end

% figure;plot([1:length(tonality)]/8000,tonality);hold on
% for i = 1:length(ons)
%     plot([ons(i) ons(i)]/1e3,[min(tonality) max(tonality)],'r');hold on;
%     plot([offs(i) offs(i)]/1e3,[min(tonality) max(tonality)],'g');hold on;
% end
% 
% for i = 1:length(ons)
%     plot([ons(i) ons(i)]/1e3,[0 1],'r');hold on;
%     plot([offs(i) offs(i)]/1e3,[0 1],'g');hold on;
% end
% % 
% for i = 1:length(ons)
%     plot([ons(i) ons(i)]/1e3,[0 16000],'r');hold on;
%     plot([offs(i) offs(i)]/1e3,[0 16000],'g');hold on;
% end
% 
% for i = 1:length(ons)
%     plot([ons(i) ons(i)]/1e3,[min(sm2) max(sm2)],'r');hold on;
%     plot([offs(i) offs(i)]/1e3,[min(sm2) max(sm2)],'g');hold on;
% end

% figure;
% h1 = subplot(4,1,1);
% h2 = subplot(4,1,2);
% h3 = subplot(4,1,3);
% h4 = subplot(4,1,4);
% 
% minval = floor(min([sylls_tonal(:,1);sylls_amp(:,1)])); 
% maxval = ceil(max([sylls_tonal(:,1);sylls_amp(:,1)]));
% [n b] = hist(sylls_tonal(:,1),[minval:0.5:maxval]);stairs(h1,b,n/sum(n),'k');hold(h1,'on');
% [n b] = hist(sylls_amp(:,1),[minval:0.5:maxval]);stairs(h1,b,n/sum(n),'r');
% title(h1,'syllable duration');
% ylabel(h1,'probability');
% legend(h1,'tonal','amp');
% 
% minval = floor(min([sylls_tonal(:,2);sylls_amp(:,2)])); 
% maxval = ceil(max([sylls_tonal(:,2);sylls_amp(:,2)]));
% [n b] = hist(sylls_tonal(:,2),[minval:0.5:maxval]);stairs(h2,b,n/sum(n),'k');hold(h2,'on');
% [n b] = hist(sylls_amp(:,2),[minval:0.5:maxval]);stairs(h2, b,n/sum(n),'r');hold on;
% ylabel(h2,'probability');
% 
% minval = floor(min([sylls_tonal(:,3);sylls_amp(:,3)])); 
% maxval = ceil(max([sylls_tonal(:,3);sylls_amp(:,3)]));
% [n b] = hist(sylls_tonal(:,3),[minval:0.5:maxval]);stairs(h3,b,n/sum(n),'k');hold(h3,'on');
% [n b] = hist(sylls_amp(:,3),[minval:0.5:maxval]);stairs(h3, b,n/sum(n),'r');
% ylabel(h3,'probability');
% 
% minval = floor(min([sylls_tonal(:,4);sylls_amp(:,4)])); 
% maxval = ceil(max([sylls_tonal(:,4);sylls_amp(:,4)]));
% [n b] = hist(sylls_tonal(:,4),[minval:0.5:maxval]);stairs(h4,b,n/sum(n),'k');hold(h4,'on');
% [n b] = hist(sylls_amp(:,4),[minval:0.5:maxval]);stairs(h4, b,n/sum(n),'r');
% ylabel(h4,'probability');
% xlabel(h4,'ms');
% 
% figure;
% h1 = subplot(3,1,1);
% h2 = subplot(3,1,2);
% h3 = subplot(3,1,3);
% 
% minval = floor(min([gaps_tonal(:,1);gaps_amp(:,1)])); 
% maxval = ceil(max([gaps_tonal(:,1);gaps_amp(:,1)]));
% [n b] = hist(gaps_tonal(:,1),[minval:0.5:maxval]);stairs(h1,b,n/sum(n),'k');hold(h1,'on');
% [n b] = hist(gaps_amp(:,1),[minval:0.5:maxval]);stairs(h1, b,n/sum(n),'r');
% ylabel(h1,'probability');
% title(h1,'gap duration');
% legend(h1,'tonal','amp');
% 
% minval = floor(min([gaps_tonal(:,2);gaps_amp(:,2)])); 
% maxval = ceil(max([gaps_tonal(:,2);gaps_amp(:,2)]));
% [n b] = hist(gaps_tonal(:,2),[minval:0.5:maxval]);stairs(h2,b,n/sum(n),'k');hold(h2,'on');
% [n b] = hist(gaps_amp(:,2),[minval:0.5:maxval]);stairs(h2, b,n/sum(n),'r');
% ylabel(h2,'probability');
% 
% minval = floor(min([gaps_tonal(:,3);gaps_amp(:,3)])); 
% maxval = ceil(max([gaps_tonal(:,3);gaps_amp(:,3)]));
% [n b] = hist(gaps_tonal(:,3),[minval:0.5:maxval]);stairs(h3,b,n/sum(n),'k');hold(h3,'on');
% [n b] = hist(gaps_amp(:,3),[minval:0.5:maxval]);stairs(h3, b,n/sum(n),'r');
% xlabel(h3,'ms');
% ylabel(h3,'probability');
% 
% figure;
% h1 = subplot(4,2,1);
% h2 = subplot(4,2,2);
% h3 = subplot(4,2,3);
% h4 = subplot(4,2,4);
% 
% plot(h1,vol(:,1),sylls_tonal(:,1),'ok');hold(h1,'on');
% plot(h1,vol(:,1),sylls_amp(:,1),'or');
% title(h1,'volume vs syllable duration');
% ylabel(h1,'ms');
% plot(h2,vol(:,2),sylls_tonal(:,2),'ok');hold(h2,'on');
% plot(h2,vol(:,2),sylls_amp(:,2),'or');
% ylabel(h2,'ms');
% plot(h3,vol(:,3),sylls_tonal(:,3),'ok');hold(h3,'on');
% plot(h3,vol(:,3),sylls_amp(:,3),'or');
% ylabel(h3,'ms');
% plot(h4,vol(:,4),sylls_tonal(:,4),'ok');hold(h4,'on');
% plot(h4,vol(:,4),sylls_amp(:,4),'or');
% ylabel(h4,'ms');
% xlabel('amplitude');

        

% [dat fs] = evsoundin('','bk93bk94_301016_0753.1782.cbin','obs0');
% filtsong= bandpass(dat,fs,1000,10000,'hanningfir');
% startind = 1;
% tonality = [];
% while length(filtsong)-startind>=256
%     endind = startind+256-1;
%     x = fft(filtsong(startind:endind));
%     corr = ifft(x.*conj(x));
%     corr = corr(1:length(corr)/4);
%     [pks locs] = findpeaks(corr);
%     tonality = [tonality;pks(1)];
%     startind = startind+4;
% end
% 
% tonality = abs(tonality);
% figure;plot([1:length(tonality)]/8000,tonality);
% thresh = std(tonality)/1e3;
% [onsets offsets] = SegmentSong(tonality,fs/4,10,20,thresh);
% 
% figure(2);hold on;
% for i = 1:length(onsets)
%     plot([onsets(i) onsets(i)]/1e3,[0 4.5e9],'r');hold on;
%     plot([offsets(i) offsets(i)]/1e3,[0 4.5e9],'g');hold on;
% end
% 
% figure(3);hold on;
% for i = 1:length(onsets)
%     plot([onsets(i) onsets(i)]/1e3,[-1e4 1e4],'r');hold on;
%     plot([offsets(i) offsets(i)]/1e3,[-1e4 1e4],'g');hold on;
% end
% 
% figure(1);hold on;
% for i = 1:length(onsets)
%     plot([onsets(i) onsets(i)]/1e3,[1000 10000],'r');hold on;
%     plot([offsets(i) offsets(i)]/1e3,[1000 10000],'g');hold on;
% end