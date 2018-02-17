function RA_correlate_gapdur_plot(batchfile,caseid,motorwin,mode,gap_or_syll)
%plot cases to compare IFR vs FR (spike cnt)
%caseid = table with list of unitid and seqid to plot 
%motorwin = -40 (40 ms premotor window)
%mode = 'burst' for restricting analysis to bursts and detectinb burst borders,'spikes' for counting
%any spikes in a set 40 ms window
%gap_or_syll = 'gap' or 'syll'

%% parameters
config; 
win = gausswin(20);%for smoothing spike trains, 20 ms
win = win./sum(win);
shufftrials = 1000;%number of trials for shuffle
fs= 32000;%sampling rate

%% 

ff = load_batchf(batchfile);
ind = [];
for i = 1:size(caseid,1)
    id = find(arrayfun(@(x) (contains(x.name,caseid{i,{'unitid'}})),ff));
    ind = [ind;id];
end
ff = ff(ind);

for i = 1:length(ff)
    disp(ff(i).name);
    [~,stid] = regexp(ff(i).name,'data_');enid = regexp(ff(i).name,'_TH');
    unitid = ff(i).name(stid+1:enid-1);
    birdid = unitid(1:regexp(unitid,'_')-1);
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms
    
    %for each unique sequence found  
    gapdurs_all = onsets(2:end)-offsets(1:end-1);
    durs_all = offsets-onsets;
    seqlen = length(caseid{i,{'seqid'}}{:});

    %remove outliers 
    idx = strfind(labels,caseid{i,{'seqid'}});
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
        id = find(seqoffs(:,end)-seqons(:,1)>=1000);%remove trials where sequence length > 1 sec
        seqons(id,:) = [];seqoffs(id,:) = [];dur_id(id) = [];
    end

    %order trials by gapdur
    [~,ix] = sort(dur_id,'descend');
    dur_id = dur_id(ix);seqons = seqons(ix,:);seqoffs = seqoffs(ix,:);

    %offsets for alignment
    durseq = seqoffs-seqons;
    gapseq = seqons(:,2:end)-seqoffs(:,1:end-1);
    if strcmp(gap_or_syll,'gap')
        offset = durseq(:,seqlen/2);
        offset = [mean(offset)+motorwin, mean(offset)];
    elseif strcmp(gap_or_syll,'syll')
        offset = gapseq(:,ceil(seqlen/2)-1);
        offset = [mean(offset)+motorwin, mean(offset)];
    end

    %target dur for correlation 
    if strcmp(gap_or_syll,'gap')
        dur_id_corr = gapseq(:,seqlen/2);%gapdur for correlation with activity
    elseif strcmp(gap_or_syll,'syll')
        dur_id_corr = durseq(:,ceil(seqlen/2));
    end

    %anchors for aligning by onset of target element
    pt = [motorwin 0];
    if strcmp(gap_or_syll,'gap')
        anchor = seqoffs(:,seqlen/2);
    elseif strcmp(gap_or_syll,'syll')
        anchor = seqons(:,ceil(seqlen/2));
    end
    seqst = ceil(max(anchor-seqons(:,1)));%start border for sequence activity relative to target gap (sylloff1)
    seqend = ceil(max(seqoffs(:,end)-anchor));%end border 
    
    %anchors for aligning by secondary element
    pt2 = offset;
    if strcmp(gap_or_syll,'gap')
        anchor2 = seqons(:,seqlen/2);
    elseif strcmp(gap_or_syll,'syll')
        anchor2 = seqoffs(:,ceil(seqlen/2)-1);
    end
    seqst2 = ceil(max(anchor2-seqons(:,1)));%boundaries for sequence activity relative to on1
    seqend2 = ceil(max(seqoffs(:,end)-anchor2));
    
    %average pairwise correlation of spike trains 
    varfr = trialbytrialcorr_spiketrain(spiketimes,seqst,seqend,anchor,pt,win);

    %average pairwise trial by trial correlation
    varfr2 = trialbytrialcorr_spiketrain(spiketimes,seqst2,seqend2,anchor2,pt2,win);
    
    %decide to align by target or secondary 
    if varfr<varfr2
        alignby=2;anchor = anchor2;seqst = seqst2; seqend = seqend2;
        pt = pt2;varfr=varfr2;
    else
        alignby=1;
    end
    
    %compute PSTH from spike trains for specific alignment for IFR
    [PSTH_mn_IFR tb_IFR smooth_spiketrains_IFR spktms] = smoothtrain(...
        spiketimes,seqst,seqend,anchor,win,1);
    [PSTH_mn_FR tb_FR smooth_spiketrains_FR spktms] = smoothtrain(...
        spiketimes,seqst,seqend,anchor,win,0);

    %shuffled spike train to detect peaks that are significantly
    %above shuffled activity
    [PSTH_mn_rand_IFR smooth_spiketrains_rand_IFR] = shuffletrain(spiketimes,...
            seqst,seqend,anchor,win,1);
    [PSTH_mn_rand_FR smooth_spiketrains_rand_FR] = shuffletrain(spiketimes,...
            seqst,seqend,anchor,win,0);

    if strcmp(mode,'burst')
        ixx = caseid{i,{'burstid'}};
        
        %find peaks/bursts in PSTH in premotor window for IFR
        [pks, locs,w,~,wc] = findpeaks2(PSTH_mn_IFR,'MinPeakProminence',10,'MinPeakWidth',10,...
            'Annotate','extents','WidthReference','halfheight');
        pkid = find(tb_IFR(locs)>=pt(1) & tb_IFR(locs)<=pt(2));
        wc = round(wc);

        %plot for IFR 
        figure;hold on;
        if ~isempty(pkid) 
            if length(pkid) >= ixx
                [burstst burstend] = peakborder(wc,pkid(ixx),locs,tb_IFR);
                pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand_IFR))/std(PSTH_mn_rand_IFR);
            else
                [burstst burstend] = peakborder(wc,pkid(1),locs,tb_IFR);
                pkactivity = (pks(pkid(1))-mean(PSTH_mn_rand_IFR))/std(PSTH_mn_rand_IFR);
            end
            npks_burst = burstifr(spktms,tb_IFR(burstst),tb_IFR(burstend));
%             notoutliers = find(npks_burst<=400);
            notoutliers = 1:length(npks_burst);
            
            [r p] = corrcoef(npks_burst(notoutliers),dur_id_corr(notoutliers));
            
            subplot(3,2,1);hold on;
            plotraster(dur_id_corr,spktms,tb_IFR(burstst),tb_IFR(burstend),...
                seqons,seqoffs,seqst,seqend,anchor,ff(i).name,...
                (pct_error),caseid{i,{'seqid'}}{:},r(2),p(2),pkactivity);

            subplot(3,2,3);hold on;
            plotPSTH(seqst,seqend,smooth_spiketrains_IFR,dur_id_corr,...
                tb_IFR(burstst),tb_IFR(burstend));

            subplot(3,2,5);hold on;
            plotCORR(npks_burst(notoutliers),dur_id_corr(notoutliers),1);
        else
            subplot(3,2,1);hold on;
            plotraster(dur_id_corr,spktms,'','',seqons,seqoffs,seqst,seqend,...
                anchor,ff(i).name,(pct_error),caseid{i,{'seqid'}}{:},'','','');

            subplot(3,2,3);hold on;
            plotPSTH(seqst,seqend,smooth_spiketrains_IFR,dur_id_corr,'','');
        end
        
        %find peaks/bursts in PSTH in premotor window for FR
        [pks, locs,w,~,wc] = findpeaks2(PSTH_mn_FR,'MinPeakProminence',10,'MinPeakWidth',10,...
            'Annotate','extents','WidthReference','halfheight');
        pkid = find(tb_FR(locs)>=pt(1) & tb_FR(locs)<=pt(2));
        wc = round(wc);
        
        %plot for FR
        if ~isempty(pkid)
            [burstst burstend] = peakborder(wc,pkid(ixx),locs,tb_FR);
            pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand_FR))/std(PSTH_mn_rand_FR);
            npks_burst = countspks(spktms,tb_FR(burstst),tb_FR(burstend));
            
            [r p] = corrcoef(npks_burst,dur_id_corr);
            
            subplot(3,2,2);hold on;
            plotraster(dur_id_corr,spktms,tb_FR(burstst),tb_FR(burstend),...
                seqons,seqoffs,seqst,seqend,anchor,ff(i).name,...
                (pct_error),caseid{i,{'seqid'}}{:},r(2),p(2),pkactivity);

            subplot(3,2,4);hold on;
            plotPSTH(seqst,seqend,smooth_spiketrains_FR,dur_id_corr,...
                tb_FR(burstst),tb_FR(burstend));

            subplot(3,2,6);hold on;
            plotCORR(npks_burst,dur_id_corr,0);
        else
            subplot(3,2,4);hold on;
            plotraster(dur_id_corr,spktms,'','',seqons,seqoffs,seqst,seqend,...
                anchor,ff(i).name,(pct_error),caseid{i,{'seqid'}}{:},'','','');

            subplot(3,2,6);hold on;
            plotPSTH(seqst,seqend,smooth_spiketrains_IFR,dur_id_corr,'','');
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
            %temp(spktimes(1:end-1)) = 1./diff(x);
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
    r = xcorr(smooth_spiketrains(:,tbid)',0,'coeff');
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
    
function npks = countspks(spktms,tm1,tm2);
    if length(tm1) == 1
        npks = cellfun(@(x) length(find(x>=tm1 & x<tm2)),spktms);%extract nspks in each trial
    else
        npks = cellfun(@(x,y,z) length(find(x>=y & x<z)),spktms,tm1,tm2);%extract nspks in each trial
    end
    npks = 1000*(npks./(tm2-tm1));

function npks = burstifr(spktms,tm1,tm2,win);
    npks = cellfun(@(x) x(find(x>=tm1 & x<tm2)),spktms,'un',0);
    npks = cell2mat(cellfun(@(x) median(instantfr(x)),npks,'un',0)).*1000;
    npks(isnan(npks)) = 0;
    %npks = mean(cell2mat(cellfun(@(x) conv(instantfr(x,tm1:tm2),win,'same'),npks,'un',0)),2).*1000;


function plotraster(dur_id,spktms,tm1,tm2,seqons,seqoffs,...
    seqst,seqend,anchor,name,pct_error,seqid,corrval,pval,pkactivity)
    thr1 = quantile(dur_id,0.25);%threshold for small gaps
    smallgaps_id = find(dur_id <= thr1);
    thr2 = quantile(dur_id,0.75);%threshold for large gaps
    largegaps_id = find(dur_id >= thr2);
    if length(tm1) == 1
        spktms_inburst = cellfun(@(x) x(find(x>=tm1&x<tm2)),spktms,'un',0);
    elseif length(tm1)==1
        spktms_inburst = cellfun(@(x,y,z) x(find(x>=y&x<z)),spktms,tm1,tm2,'un',0);
    elseif isempty(tm1) & isempty(tm2)
        spktms_inburst = [];
    end
    cnt=0;
    for m = 1:length(dur_id)
        if ~isempty(spktms{m})
            plot(repmat(spktms{m},2,1),[cnt cnt+1],'k');hold on;
        end
        if ~isempty(spktms_inburst) & ~isempty(spktms_inburst{m})
            plot(repmat(spktms_inburst{m},2,1),[cnt cnt+1],'b');hold on;
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
    singleunit = mean(pct_error)<=0.02;
    title([unitid,' ',seqid,' r=',num2str(corrval),' p=',num2str(pval),...
        ' pkact=',num2str(pkactivity),' unit=',num2str(singleunit)],'interpreter','none');
    xlabel('time (ms)');ylabel('trial');set(gca,'fontweight','bold');
    xlim([-seqst seqend]);ylim([0 cnt]);
    plot(-seqst,min(smallgaps_id),'r>','markersize',4,'linewidth',2);hold on;
    plot(-seqst,max(largegaps_id),'b>','markersize',4,'linewidth',2);hold on;
        
function plotPSTH(seqst,seqend,smooth_spiketrains,dur_id,tm1,tm2);
    thr1 = quantile(dur_id,0.25);%threshold for small gaps
    smallgaps_id = find(dur_id <= thr1);
    thr2 = quantile(dur_id,0.75);%threshold for large gaps
    largegaps_id = find(dur_id >= thr2);
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(smallgaps_id,:),1)-...
        stderr(smooth_spiketrains(smallgaps_id,:),1)...
        fliplr(mean(smooth_spiketrains(smallgaps_id,:),1)+...
        stderr(smooth_spiketrains(smallgaps_id,:),1))])*1000,[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(largegaps_id,:),1)-...
        stderr(smooth_spiketrains(largegaps_id,:),1)...
        fliplr(mean(smooth_spiketrains(largegaps_id,:),1)+...
        stderr(smooth_spiketrains(largegaps_id,:),1))])*1000,[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains,1)-...
        stderr(smooth_spiketrains,1)...
        fliplr(mean(smooth_spiketrains,1)+...
        stderr(smooth_spiketrains,1))])*1000,[0.8 0.8 0.8],'edgecolor','none','facealpha',0.7);
    yl = get(gca,'ylim');
    if ~isempty(tm1) & ~isempty(tm2)
        plot(repmat([tm1 tm2],2,1),yl,'g','linewidth',2);hold on;
    end
    xlim([-seqst seqend]);
    xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');

function plotCORR(npks_burst,dur_id_corr,ifr);
    scatter(npks_burst,dur_id_corr,'k.');hold on;
    xlim([min(npks_burst)-1 max(npks_burst)+1]);lsline
    if ifr == 0
        xlabel('FR');
    else
        xlabel('IFR');
    end
    ylabel('gap duration (ms)');
    set(gca,'fontweight','bold');