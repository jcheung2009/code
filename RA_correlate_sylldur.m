function [spk_dur_corr case_name dattable] = RA_correlate_sylldur(batchfile,seqlen,...
    minsampsize,activitythresh,motorwin,targetactivity,targetdur,plotcasecondition,shuff)
%correlate premotor spikes with dur 
%seqlen = length of syllable sequence (use 5)
%minsampsize = minimum number of trials 
%activitythresh = for peak detection (zscore relative to shuffled activity)
%motorwin = -40 (40 ms premotor window)
% targetgapactivity = 0;%-1:previous, 0:current, 1:next
% targetgapdur = 0;%-1:previous, 0:current, 1:next
%plotcasecondition = 'n' (don't plot), 'y+' (plot significant multi unit cases),'y++'
%(plot strongly significant multi unit cases),'y+su' (...single units)
%shuff = 'n' or 'y' (shuffled analysis, for cases with peak activity
%greater than thresh and multi unit), or 'ysu' (for activity greater than thresh and single units)
%spk_dur_corr = [corrcoef pval alignment firingrate width mn(pct_error)...
%numtrials corrcoefgap2 pvalgap2 gapmotorwin]
%alignby=1 or 2 (on2 vs off1)

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

spk_dur_corr = [];case_name = {};
dattable = table([],[],[],[],[],[],[],[],'VariableNames',{'dur','spikes',...
    'unittype','activity','birdid','unitid','seqid','corrpval'});
ff = load_batchf('batchfile');
birdid = arrayfun(@(x) x.birdname,params,'unif',0);
for i = 1:length(ff)
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms
    
    %unique gap id
    gapids = find_uniquelbls(labels,seqlen,minsampsize);
    
    %for each unique sequence found  
    durs_all = offsets-onsets;
    for n = 1:length(gapids)
        idx = strfind(labels,gapids(n));
        seqons = onsets(bsxfun(@plus, idx',(0:seqlen-1)));%realtime 
        seqoffs = offsets(bsxfun(@plus,idx',(0:seqlen-1)));
        dur_id = jc_removeoutliers(durs_all(idx+ceil(seqlen/2)-1),3);
        dur_id = jc_removeoutliers(dur_id,3);
        id = find(isnan(dur_id));dur_id(id) = [];seqons(id,:) = [];seqoffs(id,:) = [];
        
        if ~isempty(find(seqoffs(:,end)-seqons(:,1)>=1000))
            id = find(seqoffs(:,end)-seqons(:,1)>=1000);
            seqons(id,:) = [];seqoffs(id,:) = [];dur_id(id) = [];
        end
        if length(dur_id)<25
            continue
        end

        %compute PSTH from spike trains aligned to onset of target element
        seqst = ceil(max(seqons(:,ceil(seqlen/2)+targetactivity)-seqons(:,1)));%boundaries for sequence activity relative to target gap (syllon2)
        seqend = ceil(max(seqoffs(:,end)-seqons(:,ceil(seqlen/2)+targetactivity)));
        spktms = cell(size(seqons,1),1);%spike times for each trial relative to target syll 
        smooth_spiketrains = zeros(length(dur_id),seqst+seqend+1);
        for m = 1:size(seqons,1)
            temp = zeros(1,seqst+seqend+1);
            x = spiketimes(find(spiketimes>=(seqons(m,ceil(seqlen/2)+targetactivity)-seqst) & ...
                spiketimes<=(seqons(m,ceil(seqlen/2)+targetactivity)+seqend)));
            spktms{m} = x - seqons(m,ceil(seqlen/2)+targetactivity); %spike times aligned by syllon2
            spktimes = round(spktms{m})+seqst+1;
            temp(spktimes) = 1;
            smooth_spiketrains(m,:) = conv(temp,win,'same');
        end
        tb = [-seqst:seqend];
        PSTH_mn = mean(smooth_spiketrains,1).*1000;
        [pks, locs,w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',10,...
            'MinPeakWidth',10,'Annotate','extents','WidthReference','halfheight');%find bursts in premotor win
        pkid = find(tb(locs)>=motorwin & tb(locs)<=0);
        wc = round(wc);
        if isempty(pkid)
            continue
        end
        
        %shuffled spike train to detect peaks that are significantly
        %above shuffled activity
        smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
        PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;
        
        %order trials by gapdur
        [~,ix] = sort(dur_id,'descend');
        dur_id = dur_id(ix);spktms = spktms(ix);seqons = seqons(ix,:);seqoffs = seqoffs(ix,:);smooth_spiketrains=smooth_spiketrains(ix,:);
        if targetdur ~= 0
            durseq = seqoffs-seqons;
            dur_id_corr = durseq(:,ceil(seqlen/2)+targetdur);
        else
            dur_id_corr = dur_id;
        end
        
        %for each burst found, test alignment and correlate with dur
        for ixx = 1:length(pkid)
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
            if burstst<=0
                burstst=1;
            end
            if burstend > length(tb)
                burstend = length(tb);
            end
                    
            r = xcorr(smooth_spiketrains(:,burstst:burstend)',0,'coeff');
            r = reshape(r,[size(smooth_spiketrains,1) size(smooth_spiketrains,1)]);
            r = r(find(triu(r,1)));
            varburst1 = nanmean(r);%average pairwise correlation of spike trains 
         
            seqoffs_alignedon2 = seqoffs-seqons(:,ceil(seqlen/2)+targetactivity);
            anchor=seqoffs_alignedon2(:,ceil(seqlen/2)+targetactivity-1);
            spktms_off1 = arrayfun(@(x) spktms{x}-anchor(x),1:length(spktms),'un',0);%realign spike times in each trial by off1
            seqst2 = ceil(abs(min([spktms_off1{:}])));
            seqend2 = ceil(abs(max([spktms_off1{:}])));
            smooth_spiketrains_off1 = zeros(length(dur_id),seqst2+seqend2+1);
            for m = 1:length(dur_id)
                temp = zeros(1,seqst2+seqend2+1);
                spktimes = round(spktms_off1{m})+seqst2+1;
                temp(spktimes) = 1;
                smooth_spiketrains_off1(m,:) = conv(temp,win,'same');
            end  
            tb2 = [-seqst2:seqend2];
            PSTH_mn_off1 = mean(smooth_spiketrains_off1,1).*1000;
            [pks2, locs2,w2,~,wc2] = findpeaks2(PSTH_mn_off1,'MinPeakProminence',...
                10,'MinPeakWidth',10,'Annotate','extents','WidthReference','halfheight');
            if ~isempty(locs2)
                wc2 = round(wc2);
                ix = find(tb2(locs2)>=motorwin-mean(anchor) & tb2(locs2)<=-mean(anchor));
                if isempty(ix)
                    alignby=1;
                    wth=w(pkid(ixx));
                    pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                    npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms)';%extract nspks in each trial
                else
                    [xy,ix] = min(abs(tb2(locs2)-(tb(locs(pkid(ixx)))-mean(anchor))));
                    burstend2 = wc2(ix,2)+(wc2(ix,2)-locs2(ix));%find burst border
                    burstst2 = wc2(ix,1)-(locs2(ix)-wc2(ix,1));
                    if ix < size(wc2,1) 
                        if burstend2 > wc2(ix+1,1)
                            burstend2 = ceil((wc2(ix,2)+wc2(ix+1,1))/2);
                        end
                    end
                    if ix ~= 1
                        if burstst2 < wc2(ix-1,2)
                            burstst2 = floor((wc2(ix,1)+wc2(ix-1,2))/2);
                        end
                    end
                    if burstst2<=0
                        burstst2=1;
                    end
                    if burstend2 > length(tb2)
                        burstend2 = length(tb2);
                    end

                    r = xcorr(smooth_spiketrains_off1(:,burstst2:burstend2)',0,'coeff');
                    r = reshape(r,[size(smooth_spiketrains_off1,1) size(smooth_spiketrains_off1,1)]);
                    r = r(find(triu(r,1)));
                    varburst2 = nanmean(r);

                    if varburst1 < varburst2
                        alignby=2;%off1
                        wth=w2(ix);
                        pkactivity = (pks2(ix)-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                        npks_burst = cellfun(@(x) length(find(x>=tb2(burstst2)&x<tb2(burstend2))),spktms_off1);%extract nspks in each trial
                    else
                        alignby=1;%on2
                        wth=w(pkid(ixx));
                        pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                        npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms)';%extract nspks in each trial
                    end
                end
            else
                alignby=1;
                wth=w(pkid(ixx));
                pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms)';%extract nspks in each trial
            end
            
            %shuffle analysis
            if ~isempty(strfind(shuff,'y'))
                shufftrials = 1000;
                if isempty(strfind(shuff,'su'))
                    if pkactivity >= activitythresh & mean(pct_error)>0.01
                        npks_burst_shuff = repmat(npks_burst,shufftrials,1);
                        npks_burst_shuff = permute_rowel(npks_burst_shuff);
                        [r p] = corrcoef([npks_burst_shuff',dur_id_corr]);
                        r = r(1:end-1,end);
                        p = p(1:end-1,end);
                        spk_dur_corr = [spk_dur_corr r p];
                    end
                else
                    if mean(pct_error)<=0.01 & pkactivity >= activitythresh
                        npks_burst_shuff = repmat(npks_burst,shufftrials,1);
                        npks_burst_shuff = permute_rowel(npks_burst_shuff);
                        [r p] = corrcoef([npks_burst_shuff',dur_id_corr]);
                        r = r(1:end-1,end);
                        p = p(1:end-1,end);
                        spk_dur_corr = [spk_dur_corr r p];
                    end
                end
            else
                [r p] = corrcoef(npks_burst,dur_id_corr);
               
                gap2_id = seqons(:,ceil(seqlen/2)+1)-seqoffs(:,ceil(seqlen/2));
                [rd pd] = corrcoef(npks_burst,gap2_id);
                if alignby==1
                    gapmotorwin = tb(locs(pkid(ixx)))-mean(seqoffs(:,ceil(seqlen/2))-seqons(:,ceil(seqlen/2)));
                elseif alignby == 2
                    gapmotorwin = tb2(locs2(ix))-(mean(seqons(:,ceil(seqlen/2))-seqoffs(:,ceil(seqlen/2)-1))+...
                        mean(seqoffs(:,ceil(seqlen/2))-seqons(:,ceil(seqlen/2))));
                end
                spk_dur_corr = [spk_dur_corr; r(2) p(2) alignby pkactivity...
                    wth mean(pct_error) length(dur_id) rd(2) pd(2) gapmotorwin];
                
            end
            
            [~,stid] = regexp(ff(i).name,'data_');
            enid = regexp(ff(i).name,'_TH');
            unitid = ff(i).name(stid+1:enid-1);
            case_name = [case_name,{unitid,gapids{n}}];
            birdid = repmat({unitid(1:regexp(unitid,'_')-1)},length(dur_id_corr),1);
            unitid = repmat({unitid},length(dur_id_corr),1);
            seqid = repmat(gapids(n),length(dur_id_corr),1);
            dur_id_corrn = (dur_id_corr-nanmean(dur_id_corr))/nanstd(dur_id_corr);
            npks_burstn = (npks_burst-mean(npks_burst))/std(npks_burst);
            unittype = repmat(mean(pct_error),length(dur_id_corr),1);
            activitylevel = repmat(pkactivity,length(dur_id_corr),1);
            corrpval = repmat(p(2),length(dur_id_corr),1);
            T = table(dur_id_corrn,npks_burstn',unittype,activitylevel,birdid,unitid,seqid,corrpval,'VariableNames',...
                {'dur','spikes','unittype','activity','birdid','unitid','seqid','corrpval'});
            dattable=[dattable;T];
            
            if eval(plotcasecondition)
                thr1 = quantile(dur_id,0.25);%threshold for small gaps
                smalldurs_id = find(dur_id <= thr1);
                thr2 = quantile(dur_id,0.75);%threshold for large gaps
                largedurs_id = find(dur_id >= thr2);
                if alignby==1
                    spktms_inburst = cellfun(@(x) x(find(x>=tb(burstst)&x<tb(burstend))),spktms,'un',0);
                elseif alignby==2
                    spktms_off1_inburst = cellfun(@(x) x(find(x>=tb2(burstst2)&x<tb2(burstend2))),spktms_off1,'un',0);
                end
                figure;subplot(3,1,1);hold on;cnt=0;
                for m = 1:length(dur_id)
                    if alignby==1
                        if isempty(spktms{m})
                            continue
                        end
                        plot(repmat(spktms{m},2,1),[cnt cnt+1],'k');hold on;
                        if ~isempty(spktms_inburst{m})
                            plot(repmat(spktms_inburst{m},2,1),[cnt cnt+1],'g');hold on;
                        end
                        for syll=1:seqlen
                            patch([seqons(m,syll) seqoffs(m,syll) seqoffs(m,syll) seqons(m,syll)]-seqons(m,ceil(seqlen/2)),...
                                 [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
                        end
                    elseif alignby==2
                        if isempty(spktms_off1{m})
                            continue
                        end
                        plot(repmat(spktms_off1{m},2,1),[cnt cnt+1],'k');hold on;
                        if ~isempty(spktms_off1_inburst{m})
                            plot(repmat(spktms_off1_inburst{m},2,1),[cnt cnt+1],'g');hold on;
                        end
                        for syll=1:seqlen
                            patch([seqons(m,syll) seqoffs(m,syll) seqoffs(m,syll) seqons(m,syll)]-seqoffs(m,ceil(seqlen/2)-1),...
                                 [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
                        end
                    end
                    cnt=cnt+1;
                end
                [~,stid] = regexp(ff(i).name,'data_');
                enid = regexp(ff(i).name,'_TH');
                unitid = ff(i).name(stid+1:enid-1);
                singleunit = mean(pct_error)<=0.01;
                title([unitid,' ',gapids{n},' r=',num2str(r(2)),' unit=',num2str(singleunit)],'interpreter','none');
                xlabel('time (ms)');ylabel('trial');set(gca,'fontweight','bold');
                if alignby==1
                    xlim([-seqst seqend]);ylim([0 cnt]);
                    plot(-seqst,min(smalldurs_id),'r>','markersize',4,'linewidth',2);hold on;
                    plot(-seqst,max(largedurs_id),'b>','markersize',4,'linewidth',2);hold on;
                elseif alignby==2
                    xlim([-seqst2 seqend2]);ylim([0 cnt]);
                    plot(-seqst2,min(smalldurs_id),'r>','markersize',4,'linewidth',2);hold on;
                    plot(-seqst2,max(largedurs_id),'b>','markersize',4,'linewidth',2);hold on;
                end   
                
                subplot(3,1,2);hold on;
                if alignby==1
                    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(smalldurs_id,:),1)-...
                        stderr(smooth_spiketrains(smalldurs_id,:),1)...
                        fliplr(mean(smooth_spiketrains(smalldurs_id,:),1)+...
                        stderr(smooth_spiketrains(smalldurs_id,:),1))])*1000,[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
                    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(largedurs_id,:),1)-...
                        stderr(smooth_spiketrains(largedurs_id,:),1)...
                        fliplr(mean(smooth_spiketrains(largedurs_id,:),1)+...
                        stderr(smooth_spiketrains(largedurs_id,:),1))])*1000,[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
                    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains,1)-...
                        stderr(smooth_spiketrains,1)...
                        fliplr(mean(smooth_spiketrains,1)+...
                        stderr(smooth_spiketrains,1))])*1000,[0.8 0.8 0.8],'edgecolor','none','facealpha',0.7);
                    yl = get(gca,'ylim');
                    plot(repmat([tb(burstst) tb(burstend)],2,1),yl,'g','linewidth',2);hold on;
                    xlim([-seqst seqend]);
                elseif alignby==2
                    patch([-seqst2:seqend2 fliplr(-seqst2:seqend2)],([mean(smooth_spiketrains_off1(smalldurs_id,:),1)-...
                        stderr(smooth_spiketrains_off1(smalldurs_id,:),1)...
                        fliplr(mean(smooth_spiketrains_off1(smalldurs_id,:),1)+...
                        stderr(smooth_spiketrains_off1(smalldurs_id,:),1))])*1000,[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
                    patch([-seqst2:seqend2 fliplr(-seqst2:seqend2)],([mean(smooth_spiketrains_off1(largedurs_id,:),1)-...
                        stderr(smooth_spiketrains_off1(largedurs_id,:),1)...
                        fliplr(mean(smooth_spiketrains_off1(largedurs_id,:),1)+...
                        stderr(smooth_spiketrains_off1(largedurs_id,:),1))])*1000,[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
                    patch([-seqst2:seqend2 fliplr(-seqst2:seqend2)],([mean(smooth_spiketrains_off1,1)-...
                        stderr(smooth_spiketrains_off1,1)...
                        fliplr(mean(smooth_spiketrains_off1,1)+...
                        stderr(smooth_spiketrains_off1,1))])*1000,[0.8 0.8 0.8],'edgecolor','none','facealpha',0.7);
                    yl = get(gca,'ylim');
                    plot(repmat([tb2(burstst2) tb2(burstend2)],2,1),yl,'g','linewidth',2);hold on;
                    xlim([-seqst2 seqend2]);
                end
                xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');
            
                subplot(3,1,3);hold on;
                scatter(npks_burst,dur_id_corr,'k.');hold on;
                xlim([min(npks_burst)-1 max(npks_burst)+1]);lsline
                xlabel('number of spikes');ylabel('duration (ms)');
                set(gca,'fontweight','bold');
                
            end
        end
    end
end

