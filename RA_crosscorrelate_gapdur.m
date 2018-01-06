function [c lags shuffc] = RA_crosscorrelate_gapdur(batchfile,seqlen,minsampsize,...
    activitythresh,timewin,plotfig,singleunits,mode);
%finds burst at different time lags relative to target gap and computes
%correlation
%seqlen = length of syllable sequence, target gap is middle
%minsampsize = minimum number of trials
%activitythresh = for peak detection (zsc relative to shuffled)
%timewin = [min max], min and max time in ms relative to target gap onset
%plotfit = 1 or 0, plot peak detection for troubleshooting
%singleunits = 1 or 0, restrict to single units if 1, use only multi units
%0 (both have to pass activity threshold)
%mode = 'burst' for restricting analysis to bursts and detectinb burst borders,'spikes' for counting
%any spikes in a set 40 ms window

%parameters
config;
win = gausswin(20);%for smoothing spike trains
win = win./sum(win);
shift = 20;%ms
motorwin = 40;%for spikes mode
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
        
        %remove outliers
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
        
        
        anchor = seqoffs(:,seqlen/2);%gap onset
        
        if strcmp(mode,'burst')
            %align spike times by landmarks (each onset/offset in sequence)
            landmarks = seqoffs(:,[1;1]*(1:size(seqoffs,2)));
            landmarks(:,1:2:end) = seqons;  
            bounds = mean(diff(landmarks,1,2));
            for pt = 2:size(landmarks,2)
                anchorpt = landmarks(:,pt);
                bound = bounds(pt-1);
                seqst2 = ceil(max(anchorpt-seqons(:,1)));
                seqend2 = ceil(max(seqoffs(:,end)-anchorpt));
                [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,...
                    seqst2,seqend2,anchorpt,win);

                %shuffled spike train to detect peaks that are significantly
                %above shuffled activity
                smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
                PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;

                %find peaks/bursts in PSTH
                [pks, locs, w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',10,...
                    'MinPeakWidth',10,'Annotate','extents','WidthReference','halfheight');
                wc = round(wc);
                pkid = find(tb(locs)>=-bound & tb(locs)<0);
                if isempty(pkid)
                    continue
                end

                %for each burst found
                for ixx = 1:length(pkid)
                    pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);

                    if singleunits==0
                        if mean(pct_error)<=0.01 | pkactivity < activitythresh
                            continue
                        end
                    else
                        if mean(pct_error) > 0.01 | pkactivity < activitythresh
                            continue
                        end
                    end

                    [burstst burstend] = peakborder(wc,pkid(ixx),locs,tb);
                    npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms);
                    [r p] = corrcoef(npks_burst,gapdur_id);
                    [r2 p2] = shuffle(npks_burst,gapdur_id,shufftrials);

                    lagind = max(find(mean(anchorpt-anchor)+tb(locs(pkid(ixx)))-lags>0));
                    if isempty(lagind)
                        continue
                    else
                        c{lagind} = [c{lagind}; r(2) p(2)];
                        shuffc{lagind} = [shuffc{lagind} r2 p2];
                    end

                    if plotfig==1
                        figure;subplot(2,1,1);hold on;
                        plotraster(spktms,tb,burstst,burstend,seqons,seqoffs,...
                            seqst2,seqend2,anchorpt)

                        subplot(2,1,2);hold on;
                        plotPSTH(seqst2,seqend2,smooth_spiketrains,tb,burstst,burstend);
                        pause
                    end  
                end
            end
        elseif strcmp(mode,'spikes')
            landmarks = seqoffs(:,[1;1]*(1:size(seqoffs,2)));
            landmarks(:,1:2:end) = seqons;  
            landmarks_aligned = mean(landmarks-anchor);
            for lagind = 1:length(lags)
                [~,pt] = min(abs(lags(lagind)+motorwin-landmarks_aligned));
                anchorpt = landmarks(:,pt);
                seqst2 = ceil(max(anchorpt-seqons(:,1)));
                seqend2 = ceil(max(seqoffs(:,end)-anchorpt));
                [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,...
                    seqst2,seqend2,anchorpt,win);
                
                %shuffled spike train to detect peaks that are significantly
                %above shuffled activity
                smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
                PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;
                
                tbid = find(tb>=lags(lagind)-landmarks_aligned(pt) & tb <lags(lagind)+motorwin-landmarks_aligned(pt));
                if length(tbid) < motorwin
                    continue
                end
                mnfr = mean(PSTH_mn(tbid));
                if mnfr >= 25
                    pkactivity = (mean(PSTH_mn(tbid))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);

                    if singleunits==0
                        if mean(pct_error)<=0.01 | pkactivity < activitythresh
                            continue
                        end
                    else
                        if mean(pct_error) > 0.01 | pkactivity < activitythresh
                            continue
                        end
                    end

                    npks_burst = cellfun(@(x) length(find(x>=tb(tbid(1))&x<tb(tbid(end)))),spktms);%extract nspks in each trial
                    [r p] = corrcoef(npks_burst,gapdur_id);
                    [r2 p2] = shuffle(npks_burst,gapdur_id,shufftrials);
                    c{lagind} = [c{lagind}; r(2) p(2)];
                    shuffc{lagind} = [shuffc{lagind} r2 p2];

                    if plotfig==1
                        figure;subplot(2,1,1);hold on;
                        plotraster(spktms,tb,tbid(1),tbid(end),seqons,seqoffs,...
                            seqst2,seqend2,anchorpt)

                        subplot(2,1,2);hold on;
                        plotPSTH(seqst2,seqend2,smooth_spiketrains,tb,tbid(1),tbid(end));
                        pause
                    end  
                else
                    continue
                end
            end  
        end
    end
end

function [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,seqst,seqend,anchor,win);
    spktms = cell(size(anchor,1),1);%spike times for each trial relative to target gap 
    smooth_spiketrains = zeros(size(anchor,1),seqst+seqend+1);
    for m = 1:size(anchor,1)
        temp = zeros(1,seqst+seqend+1);
        x = spiketimes(find(spiketimes>=(anchor(m)-seqst) & spiketimes<=(anchor(m)+seqend)));
        spktms{m} = x - anchor(m); 
        spktimes = round(spktms{m})+seqst+1;
        temp(spktimes) = 1;
        smooth_spiketrains(m,:) = conv(temp,win,'same');
    end
    tb = [-seqst:seqend];
    PSTH_mn = mean(smooth_spiketrains,1).*1000;%spikes/second
    
function [burstst burstend] = peakborder(wc,id,locs,tb);
    burstend = wc(id,2)+(wc(id,2)-locs(id));
    burstst = wc(id,1)-(locs(id)-(wc(id,1)));
    if id<size(wc,1)
        if burstend > wc(id+1,1)
            burstend = ceil((wc(id,2)+wc(id+1,1))/2);
        end
    end
    if id ~= 1
        if burstst < wc(id-1,2)
            burstst = floor((wc(id,1)+wc(id-1,2))/2);
        end
    end
    if burstst <= 0
        burstst = 1;
    end
    if burstend > length(tb)
        burstend = length(tb);
    end
    
function [r p] = shuffle(npks_burst,gapdur_id_corr,shufftrials);
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff);
    [r p] = corrcoef([npks_burst_shuff',gapdur_id_corr]);
    r = r(1:end-1,end);
    p = p(1:end-1,end);  
    
function plotraster(spktms,tb,burstst,burstend,seqons,seqoffs,...
    seqst,seqend,anchor)
    spktms_inburst = cellfun(@(x) x(find(x>=tb(burstst)&x<tb(burstend))),spktms,'un',0);
    cnt=0;
    for m = 1:length(spktms)
        if ~isempty(spktms{m})
            plot(repmat(spktms{m},2,1),[cnt cnt+1],'k');hold on;
        end
        if ~isempty(spktms_inburst{m})
            plot(repmat(spktms_inburst{m},2,1),[cnt cnt+1],'g');hold on;
        end
        for syll=1:size(seqons,2)
            patch([seqons(m,syll) seqoffs(m,syll) seqoffs(m,syll) seqons(m,syll)]-anchor(m),...
                 [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
        end
        cnt=cnt+1;
    end
    xlabel('time (ms)');ylabel('trial');set(gca,'fontweight','bold');
    xlim([-seqst seqend]);ylim([0 cnt]);
    
function plotPSTH(seqst,seqend,smooth_spiketrains,tb,burstst,burstend);
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains,1)-...
        stderr(smooth_spiketrains,1)...
        fliplr(mean(smooth_spiketrains,1)+...
        stderr(smooth_spiketrains,1))])*1000,[0.8 0.8 0.8],'edgecolor','none','facealpha',0.7);
    yl = get(gca,'ylim');
    plot(repmat([tb(burstst) tb(burstend)],2,1),yl,'g','linewidth',2);hold on;
    xlim([-seqst seqend]);
    xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');
