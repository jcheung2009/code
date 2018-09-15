function [c lags shuffc] = RA_crosscorrelate_gapdur(batchfile,seqlen,minsampsize,...
    activitythresh,timewin,plotfig,mode,ifr,winsize,gap_or_syll);
%finds burst at different time windows relative to target gap/syllable and computes
%correlation between neural activity and target element duration
%seqlen = length of syllable sequence,(6 for gap, 5 for syllable)
%minsampsize = minimum number of trials
%activitythresh = for peak detection (zsc relative to shuffled)
%timewin = [min max], min and max time in ms relative to target gap onset
%plotfig = 1 or 0, plot peak detection for troubleshooting
%mode = 'burst' for restricting analysis to bursts and detecting burst borders,'spikes' for counting
%any spikes in a set 40 ms window
%gap_or_syll = 'syll' or 'gap' 
%ifr = 1 use mean instantaneous FR or 0 use spike count, outputs NaN on
%trials with only one spike in analysis window

%% parameters
win = gausswin(winsize);%for smoothing spike trains
win = win./sum(win);
shift = 20;%ms
motorwin = 40;%for spikes mode
shufftrials = 1000;
lags = [timewin(1):shift:timewin(2)];
c = cell(length(lags),1);
shuffc = cell(length(lags),1);
%% 
%iterate through each unit summary "combined data" file 
ff = load_batchf(batchfile);
for i = 1:length(ff)
    disp(ff(i).name)
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms

    %unique sequences of a given length that greater than min # of trials
    gapids = find_uniquelbls(labels,seqlen,minsampsize);
    gapdurs_all = onsets(2:end)-offsets(1:end-1);
    durs_all = offsets-onsets;
    
    %iterate through each unique sequence found
    for n = 1:length(gapids)
    
        %remove trials that are outliers where target element duration > 3
        %STD
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
        %remove trials where sequence length > 1 sec
        if ~isempty(find(seqoffs(:,end)-seqons(:,1)>=1000))
            id = find(seqoffs(:,end)-seqons(:,1)>=1000);
            seqons(id,:) = [];seqoffs(id,:) = [];dur_id(id) = [];
        end
        if length(dur_id)<minsampsize
            continue
        end
        
        %order trials by target element duration
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

            %anchors for aligning by first landmark 
            anchorpt = landmarks(:,pt);
            seqst = ceil(max(anchorpt-seqons(:,1)));
            seqend = ceil(max(seqoffs(:,end)-anchorpt));
            
            %average pairwise correlation
            varfr = trialbytrialcorr_spiketrain(spiketimes,seqst,seqend,anchorpt,...
                [lags(lagind)-mean(landmarks_aligned(:,pt)) ...
                lags(lagind)+motorwin-mean(landmarks_aligned(:,pt))],win);

            %anchors for aligning by second landmark
            anchorpt2 = landmarks(:,pt2);
            seqst2 = ceil(max(anchorpt2-seqons(:,1)));
            seqend2 = ceil(max(seqoffs(:,end)-anchorpt2));

            %average pairwise correlation 
            varfr2 = trialbytrialcorr_spiketrain(spiketimes,seqst2,seqend2,anchorpt2,...
                [lags(lagind)-mean(landmarks_aligned(:,pt2)) ...
                lags(lagind)+motorwin-mean(landmarks_aligned(:,pt2))],win);

            if varfr < varfr2
               anchorpt = anchorpt2;pt = pt2;
               seqst = seqst2; seqend = seqend2;
            end
            
            %PSTH from spike trains for specific alignment
            [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,...
                seqst,seqend,anchorpt,win,ifr);
            
            %shuffled spike train to detect peaks that are significantly
            %above shuffled activity
            [PSTH_mn_rand smooth_spiketrains_rand] = shuffletrain(spiketimes,...
                seqst,seqend,anchorpt,win,ifr);
    
            if strcmp(mode,'burst')
                %find peaks/bursts in PSTH
                [pks, locs,w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',20,'MinPeakWidth',10,...
                    'MinPeakDistance',15,'MinPeakHeight',mean(PSTH_mn_rand)+20,...
                    'Annotate','extents','WidthReference','halfheight');
                wc = round(wc);
                pkid = find(tb(locs)>=lags(lagind)-mean(landmarks_aligned(:,pt)) & ...
                    tb(locs)<lags(lagind)+motorwin-mean(landmarks_aligned(:,pt)));
                if isempty(pkid)
                    continue
                end
                
                lastburstst=NaN;lastburstend=NaN;
                for ixx = 1:length(pkid)
                    [burstst burstend] = peakborder2(locs(pkid(ixx)),...
                        tb,PSTH_mn,mean(PSTH_mn_rand));
                    pkFR = mean(PSTH_mn(burstst:burstend));
                    if tb(burstend)>lags(lagind)+motorwin-mean(landmarks_aligned(:,pt))+20 |...
                            tb(burstst)< lags(lagind)-mean(landmarks_aligned(:,pt))-20 | ...
                            tb(burstend)-tb(burstst)<10 | ...
                            pkFR < activitythresh | ...
                            (burstst==lastburstst & burstend==lastburstend)
                        continue
                    end
                    lastburstst = burstst;lastburstend = burstend;
                    
                    npks_burst = mean(smooth_spiketrains(:,burstst:burstend),2).*1000;  
                    [r p] = corrcoef(npks_burst,dur_id);
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
                    [~,ix1] = unique(row);
                    st = num2cell(tb(col(ix1)))';
                    [~,ix2] = unique(row,'last');
                    ed = num2cell(tb(col(ix2)))';
                    
                    if ifr == 1
                        npks_burst = mean(smooth_spiketrains(:,col(ix1):col(ix2)),2).*1000;
                    else
                        npks_burst = countspks(spktms,st,ed,ifr);
                    end
                    
                    if sum(~isnan(npks_burst)) < 25
                        continue
                    else
                        keepid = find(~isnan(npks_burst));
                        npks_burst = npks_burst(keepid);
                    end
                    [r p] = corrcoef(npks_burst,dur_id(keepid));
                    [r2 p2] = shuffle(npks_burst,dur_id(keepid),shufftrials);
                    c{lagind} = [c{lagind}; r(2) p(2)];
                    shuffc{lagind} = [shuffc{lagind} r2 p2];

                    if plotfig==1
                        figure;subplot(2,1,1);hold on;
                        plotraster(spktms(keepid),st,ed,seqons(keepid,:),seqoffs(keepid,:),...
                            seqst,seqend,anchorpt(keepid),ff(i).name,gapids{n})

                        subplot(2,1,2);hold on;
                        plotPSTH(seqst,seqend,smooth_spiketrains(keepid,:),tb(tbid(1)),tb(tbid(end)));
                        
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
            temp = instantfr(spktms{m},-seqst:seqend);
        else
            temp(spktimes) = 1;
        end
        smooth_spiketrains(m,:) = conv(temp,win,'same');
    end
    tb = [-seqst:seqend];
    PSTH_mn = mean(smooth_spiketrains,1).*1000;%spikes/second
    
function [PSTH_mn_rand smooth_spiketrains_rand] = shuffletrain(spiketimes,...
            seqst,seqend,anchor,win,ifr);
    spktms = cell(size(anchor,1),1);%spike times for each trial relative to target gap 
    smooth_spiketrains = zeros(size(anchor,1),seqst+seqend+1);
    for m = 1:size(anchor,1)
        temp = zeros(1,seqst+seqend+1);
        x = spiketimes(find(spiketimes>=(anchor(m)-seqst) & spiketimes<=(anchor(m)+seqend)));
        spktms{m} = x - anchor(m); 
        spktimes = round(spktms{m})+seqst+1;
        if ifr == 1
            temp = instantfr(spktms{m},-seqst:seqend);
        else
            temp(spktimes) = 1;
        end
        smooth_spiketrains(m,:) = temp;
    end
    tb = [-seqst:seqend];
    smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
    smooth_spiketrains_rand = conv2(1,win,smooth_spiketrains_rand,'same');
    PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;    
    
function r = trialbytrialcorr_spiketrain(spiketimes,seqst,seqend,anchor,pt,win);
 %trial by trial correlation based on smoothed spike trains when computed by spikes not ifr
    [~,tb,smooth_spiketrains] = smoothtrain(spiketimes,seqst,seqend,anchor,win,0);
    tbid = find(tb>=pt(1) & tb<=pt(2));
    r = xcov(smooth_spiketrains(:,tbid)',0,'coeff');
    r = reshape(r,[size(smooth_spiketrains,1) size(smooth_spiketrains,1)]);
    r = r(find(triu(r,1)));
    r = nanmean(r);
    
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
    
function [burstst burstend] = peakborder2(id,tb,PSTH,activitythresh);
 %peak borders based on when activity falls back below activity threshold   
    FRbelow = find(PSTH<=activitythresh);
    if FRbelow(1) ~= 1
        FRbelow = [1 FRbelow];
    elseif FRbelow(end) ~= length(tb)
        FRbelow = [FRbelow length(tb)];
    end
    burstst = FRbelow(find(diff(id-FRbelow>0)<0));
    burstend = FRbelow(find(diff(id-FRbelow<0)==1)+1);
    
function npks = countspks(spktms,tm1,tm2,ifr);
if length(tm1) == 1
    if ifr == 0
        npks = cellfun(@(x) length(find(x>=tm1 & x<tm2)),spktms);%extract nspks in each trial
    elseif ifr == 1
        id = cellfun(@(x) find(x(1:end-1)>=tm1&x(1:end-1)<tm2),spktms,'un',0);
        spktms_diff = cellfun(@(x) diff(x),spktms,'un',0);
        npks = cellfun(@(x,y) median(x(y)),spktms_diff,id);%average ifr in each trial
        npks = 1000*(1./npks);
    end
else
    if ifr == 0
        npks = cellfun(@(x,y,z) length(find(x>=y & x<z)),spktms,tm1,tm2);%extract nspks in each trial
    elseif ifr == 1
        id = cellfun(@(x,y,z) find(x(1:end-1)>=y & x(1:end-1)< z),spktms,tm1,tm2,'un',0);
        spktms_diff = cellfun(@(x) diff(x),spktms,'un',0);
        npks = cellfun(@(x,y) median(x(y)),spktms_diff,id);
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
