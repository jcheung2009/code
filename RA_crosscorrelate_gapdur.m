function [c lags shuffc] = RA_crosscorrelate_gapdur(batchfile,seqlen,minsampsize,...
    activitythresh,timewin,plotfig,singleunits,mode,gap_or_syll,ifr);
%finds burst at different time lags relative to target gap and computes
%correlation
%seqlen = length of syllable sequence,(6 for gap, 5 for syllable)
%minsampsize = minimum number of trials
%activitythresh = for peak detection (zsc relative to shuffled)
%timewin = [min max], min and max time in ms relative to target gap onset
%plotfit = 1 or 0, plot peak detection for troubleshooting
%singleunits = 1 or 0, restrict to single units if 1, use only multi units
%0 (both have to pass activity threshold)
%mode = 'burst' for restricting analysis to bursts and detectinb burst borders,'spikes' for counting
%any spikes in a set 40 ms window
%gap_or_syll = 'syll' or 'gap' 
%ifr = 1 use mean instantaneous FR or 0 use spike count, outputs NaN on
%trials with only one spike in analysis window

%parameters
win = gausswin(20);%for smoothing spike trains
win = win./sum(win);
shift = 20;%ms
motorwin = 40;%for spikes mode
shufftrials = 1000;
lags = [timewin(1):shift:timewin(2)];
c = cell(length(lags),1);
shuffc = cell(length(lags),1);

ff = load_batchf('batchfile');
for i = 1:length(ff)
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms
    
    if singleunits==0
        if mean(pct_error)<=0.01
            continue
        end
    else
        if mean(pct_error) > 0.01
            continue
        end
    end
    
    %unique gap id
    gapids = find_uniquelbls(labels,seqlen,minsampsize);
    
    %for each unique sequence found  
    gapdurs_all = onsets(2:end)-offsets(1:end-1);
    durs_all = offsets-onsets;
    
    for n = 1:length(gapids)
        
        %remove outliers
        idx = strfind(labels,gapids(n));
        seqons = onsets(bsxfun(@plus, idx',(0:seqlen-1)));%realtime 
        seqoffs = offsets(bsxfun(@plus,idx',(0:seqlen-1)));
        if strcmp(gap_or_syll,'gap')
            dur_id = jc_removeoutliers(gapdurs_all(idx+seqlen/2-1),3);
        elseif strcmp(gap_or_syll,'syll')
            dur_id = jc_removeoutliers(durs_all(idx+ceil(seqlen/2)-1),3);
        end
        dur_id = jc_removeoutliers(dur_id,3);
        id = find(isnan(dur_id));dur_id(id) = [];seqons(id,:) = [];seqoffs(id,:) = [];
        
        if ~isempty(find(seqoffs(:,end)-seqons(:,1)>=1000))
            id = find(seqoffs(:,end)-seqons(:,1)>=1000);
            seqons(id,:) = [];seqoffs(id,:) = [];dur_id(id) = [];
        end
        if length(dur_id)<25
            continue
        end
        
        %order trials by gapdur
        [~,ix] = sort(dur_id,'descend');
        dur_id = dur_id(ix);seqons = seqons(ix,:);seqoffs = seqoffs(ix,:);
        
        if strcmp(gap_or_syll,'gap')
            anchor = seqoffs(:,seqlen/2);%target gap onset
        elseif strcmp(gap_or_syll,'syll')
            anchor = seqons(:,ceil(seqlen/2));%syll onset 
        end
        landmarks = seqoffs(:,[1;1]*(1:size(seqoffs,2)));%align by landmarks (each onset/offset)
        landmarks(:,1:2:end) = seqons;  
        landmarks_aligned = landmarks-anchor;

        for lagind = 1:length(lags)
            %find landmarks bordering lag
            pt = max(find((lags(lagind)+(motorwin/2)-max(landmarks_aligned))>0));
            pt2 = min(find((lags(lagind)+(motorwin/2)-min(landmarks_aligned))<0));

            if isempty(pt) | isempty(pt2)
                continue
            elseif pt == 1 & (lags(lagind)+(motorwin/2)-max(landmarks_aligned(:,pt)))<motorwin/2
                continue
            elseif pt2 == size(landmarks,2) & abs(lags(lagind)+(motorwin/2)-...
                    min(landmarks_aligned(:,pt2)))<motorwin/2
            end

            %align by first landmark border
            anchorpt = landmarks(:,pt);
            seqst = ceil(max(anchorpt-seqons(:,1)));
            seqend = ceil(max(seqoffs(:,end)-anchorpt));
            [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,...
                seqst,seqend,anchorpt,win,ifr);

            tbid = find(tb>=lags(lagind)-mean(landmarks_aligned(:,pt)) & tb ...
                <lags(lagind)+motorwin-mean(landmarks_aligned(:,pt)));
            r = xcorr(smooth_spiketrains(:,tbid)',0,'coeff');
            r = reshape(r,[size(smooth_spiketrains,1) size(smooth_spiketrains,1)]);
            r = r(find(triu(r,1)));
            varfr = nanmean(r);

            %align by second landmark border
            anchorpt2 = landmarks(:,pt2);
            seqst2 = ceil(max(anchorpt2-seqons(:,1)));
            seqend2 = ceil(max(seqoffs(:,end)-anchorpt2));
            [PSTH_mn2 tb2 smooth_spiketrains2 spktms2] = smoothtrain(spiketimes,...
                seqst2,seqend2,anchorpt2,win,ifr);

            tb2id = find(tb2>=lags(lagind)-mean(landmarks_aligned(:,pt2)) & ...
                tb2 <lags(lagind)+motorwin-mean(landmarks_aligned(:,pt2)));
            r = xcorr(smooth_spiketrains(:,tb2id)',0,'coeff');
            r = reshape(r,[size(smooth_spiketrains2,1) size(smooth_spiketrains2,1)]);
            r = r(find(triu(r,1)));
            varfr2 = nanmean(r);

            if varfr < varfr2
                PSTH_mn = PSTH_mn2;tb = tb2; smooth_spiketrains = smooth_spiketrains2;
                spktms = spktms2; tbid = tb2id; anchorpt = anchorpt2;pt = pt2;
                seqst = seqst2; seqend = seqend2;
            end
            
            if strcmp(mode,'burst')
                %find peaks/bursts in PSTH
                [pks, locs, w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',10,...
                    'MinPeakWidth',10,'Annotate','extents','WidthReference','halfheight');
                wc = round(wc);
                pkid = find(tb(locs)>=lags(lagind)-mean(landmarks_aligned(:,pt)) & ...
                    tb(locs)<lags(lagind)+motorwin-mean(landmarks_aligned(:,pt)));
                if isempty(pkid)
                    continue
                end
                
                %shuffled spike train to detect peaks that are significantly
                %above shuffled activity
                smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
                PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;
                
                for ixx = 1:length(pkid)
                     pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);

                    if pkactivity < activitythresh
                        continue
                    end

                    [burstst burstend] = peakborder(wc,pkid(ixx),locs,tb);
                    npks_burst = countspks(spktms,tb(burstst),tb(burstend),ifr);
                    npks_burst(find(isnan(npks_burst))) = 0;

                    [r p] = corrcoef(npks_burst,dur_id,'rows','complete');
                    [r2 p2] = shuffle(npks_burst,dur_id,shufftrials);
                    c{lagind} = [c{lagind}; r(2) p(2)];
                    shuffc{lagind} = [shuffc{lagind} r2 p2];

                    if plotfig==1
                        figure;subplot(2,1,1);hold on;
                        plotraster(spktms,tb(burstst),tb(burstend),seqons,seqoffs,...
                            seqst,seqend,anchorpt,ff(i).name,gapids{n})

                        subplot(2,1,2);hold on;
                        plotPSTH(seqst,seqend,smooth_spiketrains,tb(burstst),tb(burstend));
                        pause
                    end  
                end    
            elseif strcmp(mode,'spikes')
                tbtrind = (tb>=lags(lagind)-landmarks_aligned(:,pt) & ...
                    tb <lags(lagind)+motorwin-landmarks_aligned(:,pt));
                
                %shuffled spike train to detect peaks that are significantly
                %above shuffled activity
                smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
                PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;
                
                mnfr = mean(PSTH_mn(tbid));
                if mnfr >= 25
                    pkactivity = (max(PSTH_mn(tbid))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);

                    if pkactivity < activitythresh
                        continue
                    end
                    
                    %indices in each trial for target window 
                    [row col] = find(tbtrind);
                    [~,ix] = sort(row);
                    row=row(ix);col=col(ix);
                    [~,ix] = unique(row);
                    st = num2cell(tb(col(ix)))';
                    [~,ix] = unique(row,'last');
                    ed = num2cell(tb(col(ix)))';
                    
                    npks_burst = countspks(spktms,st,ed,ifr);
                    if sum(~isnan(npks_burst)) < 25
                        continue
                    else
                        npks_burst(find(isnan(npks_burst))) = 0;
                    end
                    [r p] = corrcoef(npks_burst,dur_id);
                    [r2 p2] = shuffle(npks_burst,dur_id,shufftrials);
                    c{lagind} = [c{lagind}; r(2) p(2)];
                    shuffc{lagind} = [shuffc{lagind} r2 p2];

                    if plotfig==1
                        figure;subplot(2,1,1);hold on;
                        plotraster(spktms,st,ed,seqons,seqoffs,...
                            seqst,seqend,anchorpt,ff(i).name,gapids{n})

                        subplot(2,1,2);hold on;
                        plotPSTH(seqst,seqend,smooth_spiketrains,tb(tbid(1)),tb(tbid(end)));
                        
                    end  
                else
                    continue
                end
            end
        end
    end
end
                
function [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,seqst,seqend,anchor,win,ifr);
    spktms = cell(size(anchor,1),1);%spike times for each trial relative to target gap 
    smooth_spiketrains = zeros(size(anchor,1),seqst+seqend+1);
    for m = 1:size(anchor,1)
        temp = zeros(1,seqst+seqend+1);
        x = spiketimes(find(spiketimes>=(anchor(m)-seqst) & spiketimes<=(anchor(m)+seqend)));
        spktms{m} = x - anchor(m); 
        spktimes = round(spktms{m})+seqst+1;
        if ifr == 1
            temp(spktimes(1:end-1)) = 1./diff(x);
        else
            temp(spktimes) = 1;
        end
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
    
function npks = countspks(spktms,tm1,tm2,ifr);
if length(tm1) == 1
    if ifr == 0
        npks = cellfun(@(x) length(find(x>=tm1 & x<tm2)),spktms);%extract nspks in each trial
    elseif ifr == 1
        id = cellfun(@(x) find(x(1:end-1)>=tm1&x(1:end-1)<tm2),spktms,'un',0);
        spktms_diff = cellfun(@(x) diff(x),spktms,'un',0);
        npks = cellfun(@(x,y) mean(x(y)),spktms_diff,id);%average ifr in each trial
        npks = 1000*(1./npks);
    end
else
    if ifr == 0
        npks = cellfun(@(x,y,z) length(find(x>=y & x<z)),spktms,tm1,tm2);%extract nspks in each trial
    elseif ifr == 1
        id = cellfun(@(x,y,z) find(x(1:end-1)>=y & x(1:end-1)< z),spktms,tm1,tm2,'un',0);
        spktms_diff = cellfun(@(x) diff(x),spktms,'un',0);
        npks = cellfun(@(x,y) mean(x(y)),spktms_diff,id);
        npks = 1000*(1./npks);
    end
end

function [r p] = shuffle(npks_burst,dur_id_corr,shufftrials);
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff);
    [r p] = corrcoef([npks_burst_shuff',dur_id_corr]);
    r = r(1:end-1,end);
    p = p(1:end-1,end);  
    
function plotraster(spktms,tm1,tm2,seqons,seqoffs,...
    seqst,seqend,anchor,name,seqid)
    if length(tm1) == 1
        spktms_inburst = cellfun(@(x) x(find(x>=tm1&x<tm2)),spktms,'un',0);
    else
        spktms_inburst = cellfun(@(x,y,z) x(find(x>=y&x<z)),spktms,tm1,tm2,'un',0);
    end
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
    [~,stid] = regexp(name,'data_');
    enid = regexp(name,'_TH');
    unitid = name(stid+1:enid-1);
    xlabel('time (ms)');ylabel('trial');set(gca,'fontweight','bold');
    xlim([-seqst seqend]);ylim([0 cnt]);
    title([unitid,' ',seqid],'interpreter','none')
    
function plotPSTH(seqst,seqend,smooth_spiketrains,tm1,tm2);
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains,1)-...
        stderr(smooth_spiketrains,1)...
        fliplr(mean(smooth_spiketrains,1)+...
        stderr(smooth_spiketrains,1))])*1000,[0.8 0.8 0.8],'edgecolor','none','facealpha',0.7);
    yl = get(gca,'ylim');
    plot(repmat([tm1 tm2],2,1),yl,'g','linewidth',2);hold on;
    xlim([-seqst seqend]);
    xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');
