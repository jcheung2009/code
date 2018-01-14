function [spk_rep_corr case_name dattable] = RA_correlate_rep(batchfile,...
    minsampsize,activitythresh,motorwin,plotcasecondition,shuff,burstmode,ifr)
%correlate premotor spikes with repeat length 
%minsampsize = minimum number of trials 
%activitythresh = for peak detection (zscore relative to shuffled activity)
%motorwin = -40 (40 ms premotor window)
%plotcasecondition = 'n' (don't plot), 'y+' (plot significant cases),'y++'
%(plot strongly significant cases),'y+su' (...single units)
%shuff = 'n' or 'y' (shuffled analysis, for cases with peak activity
%greater than thresh and multi unit), or 'ysu' (for activity greater than thresh and single units)
%mode = 'burst' for restricting analysis to bursts and detectinb burst borders,'spikes' for counting
%any spikes in a set 40 ms window
%ifr = 1 use mean instantaneous FR or 0 use spike count

%parameters
config; 
win = gausswin(20);%for smoothing spike trains, 20 ms
win = win./sum(win);
if strcmp(plotcasecondition,'n')
    plotcasecondition = '1==0';
elseif strcmp(plotcasecondition,'y+')
    plotcasecondition = ['p(2)<=0.05 & pkactivity >=',num2str(activitythresh)];
elseif strcmp(plotcasecondition,'y++')
    plotcasecondition = ['p(2)<=0.05 & abs(r(2)) >= 0.3 & pkactivity >=',num2str(activitythresh)];
elseif strcmp(plotcasecondition,'y+su')
     plotcasecondition = ['p(2)<=0.05 & mean(pct_error)<=0.01 & pkactivity >=',num2str(activitythresh)];
end

spk_rep_corr = [];case_name = {};
dattable = table([],[],[],[],[],[],[],[],'VariableNames',{'dur','spikes',...
    'unittype','activity','birdid','unitid','seqid','corrpval'});
ff = load_batchf(batchfile);
for i = 1:length(ff)
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms
    
    %identify variable repeats
    syllables = unique(labels);
    repsylls = [];onind = {};offind = {};replength = {};
    for nsyll = 1:length(syllables)
        p = ismember(labels,syllables(nsyll));
        kk = [find(diff([-1 p -1])~=0)];
        runlength = diff(kk);
        runlength = runlength(1+(p(1)==0):2:end);
        if mode(runlength) > 1 & std(runlength) > 0
            repsylls = [repsylls,syllables(nsyll)];
            pp = find(diff([0 p])==1);
            onind = [onind pp];%start index for each repeat run
            offind = [offind pp+runlength-1];%end index for each repeat run
            replength = [replength runlength];
        end
    end
    introind = strfind(repsylls,'i');repsylls(introind) = [];
    onind(introind) = [];offind(introind) = [];replength(introind) = [];

    %for each repeat,plot PSTH/rasters for different repeat lengths 
    for nrep = 1:length(repsylls) 
        
        if length(replength{nrep}) < 25
            continue
        end
        seqons = arrayfun(@(x,y,z) onsets(x+[-1:y-1])',onind{nrep},replength{nrep},'un',0);%includes pre-syllable
        seqoffs = arrayfun(@(x,y,z) offsets(x+[-1:y-1])',onind{nrep},replength{nrep},'un',0);
        
        %remove outliers
        if ~isempty(find(cellfun(@(x,y) y(end)-x(1),seqons,seqoffs) >= 2000))
            id = find(cellfun(@(x,y) y(end)-x(1),seqons,seqoffs) >= 2000);
            seqons(id) = [];seqoffs(id) = [];replength{nrep}(id) = [];
            onind{nrep}(id) = [];offind{nrep}(id) = [];
        end
        
        %order by repeat length
        [~,ix] = sort(replength{nrep});
        seqons = seqons(ix);seqoffs = seqoffs(ix); replength{nrep} = replength{nrep}(ix);
        onind{nrep} = onind{nrep}(ix); offind{nrep} = offind{nrep}(ix);
        
        durs = cellfun(@(x,y) y-x,seqons,seqoffs,'un',0);
        gaps = cellfun(@(x,y) x(2:end)-y(1:end-1),seqons,seqoffs,'un',0);
        %compute PSTH aligned to each syllable 
        for repid = 1:max(replength{nrep})+1
            if length(find(replength{nrep}>=repid))<minsampsize
                continue
            end
            mask = find(cellfun(@(x) length(x)>=repid,durs));
            mndur = mean(cellfun(@(x) x(repid),durs(mask)));
            if repid ~= 1
                mask = find(cellfun(@(x) length(x)>=repid-1,gaps));
                mngap = mean(cellfun(@(x) x(repid-1),gaps(mask)));
            else
                mngap = 0;
            end
            anchorind = repid;
            
            %align by onset
            anchor = cellfun(@(x) x(anchorind),seqons)';
            seqst = cellfun(@(x,y) x(anchorind)-y(1),seqons,seqons);
            seqend = cellfun(@(x,y) y(end)-x(anchorind),seqoffs,seqons);
            [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,seqst,seqend,anchor,win,ifr);
            
            %align by offset
            anchor2 = cellfun(@(x) x(anchorind),seqoffs)';
            seqst2 = cellfun(@(x,y) x(anchorind)-y(1),seqoffs,seqons);
            seqend2 = cellfun(@(x,y) y(end)-x(anchorind),seqoffs,seqoffs);
            [PSTH_mn2 tb2 smooth_spiketrains2 spktms2] = smoothtrain(spiketimes,seqst2,seqend2,anchor2,win,ifr);
            
            %find peaks in PSTHs 
            [pks, locs,w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',5,...
                'MinPeakWidth',10,'Annotate','extents','WidthReference','halfheight');
            pkid = find(tb(locs)>=-mngap & tb(locs)<=0);
            wc = round(wc);
            [pks2, locs2,w2,~,wc2] = findpeaks2(PSTH_mn2,'MinPeakProminence',5,...
                'MinPeakWidth',10,'Annotate','extents','WidthReference','halfheight');
            pkid2 = find(tb2(locs2)>=-mndur & tb2(locs2)<=0);
            wc2 = round(wc2);

            if isempty(pkid) & isempty(pkid2)
                continue
            end
            
            %shuffled spike train to detect peaks that are significantly
            %above shuffled activity
            smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
            PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;
            
            if ~isempty(pkid)
            	for ixx = 1:length(pkid)
                    [burstst burstend] = peakborder(wc,pkid(ixx),locs,tb);
                    pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                    npks_burst = countspks(spktms,tb(burstst),tb(burstend),ifr);
                     if sum(~isnan(npks_burst)) < 25
                        continue
                    else
                        npks_burst(find(isnan(npks_burst))) = 0;
                    end
                    
                    %average pairwise correlation of spike trains 
                    r = xcorr(smooth_spiketrains(:,burstst:burstend)',0,'coeff');
                    r = reshape(r,[size(smooth_spiketrains,1) size(smooth_spiketrains,1)]);
                    r = r(find(triu(r,1)));
                    paircorr = nanmean(r);
                    
                    [r p] = corrcoef(npks_burst,replength{nrep});
                    [r2 p2] = corrcoef(paircorr,replength{nrep});
                end
            end
                    
            if ~isempty(pkid2)
            	for ixx = 1:length(pkid2)
                    [burstst burstend] = peakborder(wc,pkid2(ixx),locs2,tb2);
                    pkactivity = (pks(pkid2(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                    npks_burst = countspks(spktms2,tb(burstst),tb(burstend),ifr);
                     if sum(~isnan(npks_burst)) < 25
                        continue
                     else
                        npks_burst(find(isnan(npks_burst))) = 0;
                     end
                    
                    [r p] = corrcoef(npks_burst,replength{nrep});
                end
            end        
    
            %plot raster and PSTH
            if p<=0.05
            figure;subplot(2,1,1);hold on;
            plotraster(replength{nrep},spktms,[],[],seqons,seqoffs,...
                max(seqst),max(seqend),anchor,ff(i).name,pct_error,repsylls(nrep),0);
            
            subplot(2,1,2);hold on;
            plotPSTH(ceil(max(seqst)),ceil(max(seqend)),smooth_spiketrains,replength{nrep},[],[]);
            
            figure;subplot(2,1,1);hold on;
            plotraster(replength{nrep},spktms2,[],[],seqons,seqoffs,...
                max(seqst2),max(seqend2),anchor2,ff(i).name,pct_error,repsylls(nrep),0);
            
            subplot(2,1,2);hold on;
            plotPSTH(ceil(max(seqst2)),ceil(max(seqend2)),smooth_spiketrains2,replength{nrep},[],[]);
        end
            
    end
end

function [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,seqst,seqend,anchor,win,ifr);
    spktms = cell(size(anchor,1),1);%spike times for each trial relative to target gap 
    smooth_spiketrains = zeros(size(anchor,1),ceil(max(seqst))+ceil(max(seqend))+1);
    for m = 1:size(anchor,1)
        temp = zeros(1,size(smooth_spiketrains,2));
        x = spiketimes(find(spiketimes>=(anchor(m)-seqst(m)) & spiketimes<=(anchor(m)+seqend(m))));
        spktms{m} = x - anchor(m); 
        spktimes = round(spktms{m})+ceil(seqst(m))+1;
        if ifr == 1
            temp(spktimes(1:end-1)) = 1./diff(x);
        else
            temp(spktimes) = 1;
        end
        smooth_spiketrains(m,:) = conv(temp,win,'same');
    end
    tb = [-ceil(max(seqst)):ceil(max(seqend))];
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
    
function plotraster(replen,spktms,tm1,tm2,seqons,seqoffs,...
    seqst,seqend,anchor,name,pct_error,seqid,corrval)
    if ~isempty(tm1)
        if length(tm1) == 1
            spktms_inburst = cellfun(@(x) x(find(x>=tm1&x<tm2)),spktms,'un',0);
        else
            spktms_inburst = cellfun(@(x,y,z) x(find(x>=y&x<z)),spktms,tm1,tm2,'un',0);
        end
    end
    cnt=0;
    for m = 1:length(replen)
        if ~isempty(spktms{m})
            plot(repmat(spktms{m},2,1),[cnt cnt+1],'k');hold on;
        end
        if ~isempty(tm1)
            if ~isempty(spktms_inburst{m})
                plot(repmat(spktms_inburst{m},2,1),[cnt cnt+1],'g');hold on;
            end
        end
        for syll=1:size(seqons{m},2)
            patch([seqons{m}(syll) seqoffs{m}(syll) seqoffs{m}(syll) seqons{m}(syll)]-anchor(m),...
                 [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
        end
        cnt=cnt+1;
    end
    [~,stid] = regexp(name,'data_');
    enid = regexp(name,'_TH');
    unitid = name(stid+1:enid-1);
    singleunit = mean(pct_error)<=0.01;
    title([unitid,' ',seqid,' r=',num2str(corrval),' unit=',num2str(singleunit)],'interpreter','none');
    xlabel('time (ms)');ylabel('trial');set(gca,'fontweight','bold');
    xlim([-seqst seqend]);ylim([0 cnt]);
        
function plotPSTH(seqst,seqend,smooth_spiketrains,replen,tm1,tm2);

%     patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(smallgaps_id,:),1)-...
%         stderr(smooth_spiketrains(smallgaps_id,:),1)...
%         fliplr(mean(smooth_spiketrains(smallgaps_id,:),1)+...
%         stderr(smooth_spiketrains(smallgaps_id,:),1))])*1000,[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
%     patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(largegaps_id,:),1)-...
%         stderr(smooth_spiketrains(largegaps_id,:),1)...
%         fliplr(mean(smooth_spiketrains(largegaps_id,:),1)+...
%         stderr(smooth_spiketrains(largegaps_id,:),1))])*1000,[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains,1)-...
        stderr(smooth_spiketrains,1)...
        fliplr(mean(smooth_spiketrains,1)+...
        stderr(smooth_spiketrains,1))])*1000,[0.8 0.8 0.8],'edgecolor','none','facealpha',0.7);
    yl = get(gca,'ylim');
    if ~isempty(tm1)
        plot(repmat([tm1 tm2],2,1),yl,'g','linewidth',2);hold on;
    end
    xlim([-seqst seqend]);
    xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');        
        
        
    %for each repeat syllable, correlate activity with probability of
    %following syllable
    
    %correlate activity before repeat start with repeat length
    
    