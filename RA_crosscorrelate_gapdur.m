function [c lags shuffc] = RA_crosscorrelate_gapdur(batchfile,seqlen,minsampsize,...
    activitythresh,timewin,plotfig,singleunits);
%finds burst at different time lags relative to target gap and computes
%correlation
%seqlen = length of syllable sequence, target gap is middle
%minsampsize = minimum number of trials
%activitythresh = for peak detection (zsc relative to shuffled)
%timewin = [min max], min and max time in ms relative to target gap onset
%plotfit = 1 or 0, plot peak detection for troubleshooting
%singleunits = 1 or 0, restrict to single units if 1, only use
%activitythresh for 0 

config;
win = gausswin(20);%for smoothing spike trains
win = win./sum(win);
shift = 20;%ms
shufftrials = 1000;
lags = [timewin(1):shift:timewin(2)];
c = cell(length(lags),1);
shuffc = cell(length(lags),1);

ff = load_batchf('batchfile');
birdid = arrayfun(@(x) x.birdname,params,'unif',0);
for i = 1:length(ff)
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms
    
    %unique gap id
    gapids = find_uniquelbls(labels,seqlen,minsampsize);
    
    %for each unique sequence found  
    gapdurs_all = onsets(2:end)-offsets(1:end-1);
    for n = 1:length(gapids)
        idx = strfind(labels,gapids(n));
        seqons = onsets(bsxfun(@plus, idx',(0:seqlen-1)));%realtime 
        seqoffs = offsets(bsxfun(@plus,idx',(0:seqlen-1)));
        gapdur_id = jc_removeoutliers(gapdurs_all(idx+seqlen/2-1),3);
        gapdur_id = jc_removeoutliers(gapdur_id,3);
        id = find(isnan(gapdur_id));gapdur_id(id) = [];seqons(id,:) = [];seqoffs(id,:) = [];
        
        if ~isempty(find(seqoffs(:,end)-seqons(:,1)>=1000))
            id = find(seqoffs(:,end)-seqons(:,1)>=1000);
            seqons(id,:) = [];seqoffs(id,:) = [];gapdur_id(id) = [];
        end
        if length(gapdur_id)<25
            continue
        end
        
        %align spike times by gap onset
        seqst = ceil(max(seqoffs(:,seqlen/2)-seqons(:,1)));%boundaries for sequence activity relative to target gap (sylloff1)
        seqend = ceil(max(seqoffs(:,end)-seqoffs(:,seqlen/2)));
        spktms = cell(size(seqons,1),1);%spike times for each trial relative to target gap 
        for m = 1:size(seqons,1)
            temp = zeros(1,seqst+seqend+1);
            x = spiketimes(find(spiketimes>=(seqoffs(m,seqlen/2)-seqst) & ...
                spiketimes<=(seqoffs(m,seqlen/2)+seqend)));
            spktms{m} = x - seqoffs(m,seqlen/2); %spike times aligned by sylloff1 
        end
        
        %align spike times by landmarks (each onset/offset in sequence)
        seqons_a = seqons-seqoffs(:,seqlen/2);%align time of each onset by gap onset
        seqoffs_a = seqoffs-seqoffs(:,seqlen/2);%align time of each offset by gap onset
        landmarks = seqoffs_a(:,[1;1]*(1:size(seqoffs_a,2)));
        landmarks(:,1:2:end) = seqons_a;  
        bounds = mean(diff(landmarks,1,2));
        for pt = 2:size(landmarks,2)
                anchorpt = landmarks(:,pt);
                bound = bounds(pt-1);
                    spktms_aligned = arrayfun(@(x) spktms{x}-anchorpt(x),1:length(spktms),'un',0);
                    seqst2 = ceil(abs(min([spktms_aligned{:}])));
                    seqend2 = ceil(abs(max([spktms_aligned{:}])));
                    smooth_spiketrains = zeros(length(gapdur_id),seqst2+seqend2+1);
                    for m = 1:length(gapdur_id)
                        temp = zeros(1,seqst2+seqend2+1);
                        spktimes = round(spktms_aligned{m})+seqst2+1;
                        temp(spktimes) = 1;
                        smooth_spiketrains(m,:) = conv(temp,win,'same');
                    end  
                    tb = [-seqst2:seqend2];
                    PSTH_mn = mean(smooth_spiketrains,1).*1000;
                    [pks, locs, w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',10,...
                        'MinPeakWidth',10,'Annotate','extents','WidthReference','halfheight');
                    wc = round(wc);
                    pkid = find(tb(locs)>=-bound & tb(locs)<0);
                    if isempty(pkid)
                        continue
                    end
                    
                    %shuffled spike train to detect peaks that are significantly
                    %above shuffled activity
                    smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
                    PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;
                    
                    %for each burst found
                    for ixx = 1:length(pkid)
                        pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                        
                        if singleunits==0
                            if pkactivity < activitythresh
                                continue
                            end
                        else
                            if mean(pct_error) > 0.01
                                continue
                            end
                        end
                        
                        burstend = wc(pkid(ixx),2)+(wc(pkid(ixx),2)-locs(pkid(ixx)));
                        burstst = wc(pkid(ixx),1)-(locs(pkid(ixx))-(wc(pkid(ixx),1)));
                        if pkid(ixx)<size(wc,1)
                            if burstend > wc(pkid(ixx)+1,1)
                                burstend = ceil((wc(pkid(ixx),2)+wc(pkid(ixx)+1,1))/2);
                            end
                        end
                        if pkid(ixx) ~= 1
                            if burstst < wc(pkid(ixx)-1,2)
                                burstst = floor((wc(pkid(ixx),1)+wc(pkid(ixx)-1,2))/2);
                            end
                        end
                        if burstst <= 0
                            burstst = 1;
                        end
                        if burstend > length(tb)
                            burstend = length(tb);
                        end
                        
                        npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms_aligned);
                        [r p] = corrcoef(npks_burst,gapdur_id);
                        npks_burst_shuff = repmat(npks_burst,shufftrials,1);
                        npks_burst_shuff = permute_rowel(npks_burst_shuff);
                        [r2 p2] = corrcoef([npks_burst_shuff',gapdur_id]);
                        r2 = r2(1:end-1,end);
                        p2 = p2(1:end-1,end);
                        
                        lagind = max(find(mean(anchorpt)+tb(locs(pkid(ixx)))-lags>0));
                        if isempty(lagind)
                            continue
                        else
                            c{lagind} = [c{lagind}; r(2) p(2)];
                            shuffc{lagind} = [shuffc{lagind} r2 p2];
                        end
                        
                        if plotfig==1
                            figure;subplot(2,1,1);hold on;cnt=0;
                            for m = 1:length(gapdur_id)
                                if isempty(spktms_aligned{m})
                                    continue
                                end
                                plot(repmat(spktms_aligned{m},2,1),[cnt cnt+1],'k');hold on;
                                for syll=1:seqlen
                                patch([seqons_a(m,syll) seqoffs_a(m,syll) seqoffs_a(m,syll) seqons_a(m,syll)]-anchorpt(m),...
                                     [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
                                end
                                cnt=cnt+1; 
                            end
                            xlim([-seqst2 seqend2]);ylim([0 cnt]);xlabel('time (ms)');ylabel('trial');
                            
                            subplot(2,1,2);hold on;
                            patch([-seqst2:seqend2 fliplr(-seqst2:seqend2)],([mean(smooth_spiketrains,1)-...
                                stderr(smooth_spiketrains,1)...
                                fliplr(mean(smooth_spiketrains,1)+...
                                stderr(smooth_spiketrains,1))])*1000,[0.5 0.5 0.5],'edgecolor','none','facealpha',0.7);
                            xlim([-seqst2 seqend2]);xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');
                            plot(tb(locs),pks,'ok');hold on; 
                            plot(tb(locs(pkid(ixx))),pks(pkid(ixx)),'or');hold on;
                            yl = get(gca,'ylim');
                            plot(repmat([tb(burstst) tb(burstend)],2,1),yl,'b');hold on;
                            pause
                        end  
                    end
        end
    end
end

