function [spk_allgapsdur_corr shuff] = RA_correlate_allgapdur(batchfile,seqlen,...
    minsampsize,activitythresh,motorwin,singleunits,plotcondition)
%for units that are significantly correlated with target gap, do they also
%%burst before other gaps and are those bursts correlated with their respective gaps? 
%minsampsize = minimum number of trials 
%activitythresh = for peak detection (zscore relative to shuffled activity)
%motorwin = -40 (40 ms premotor window)
%spk_allgapsdur_corr = [corrcoef(for other gap) pval corrcoef(target gap)]
%singleunits = 1 or 0, restrict to single units if 1, only use
%activitythresh for 0 

%parameters
config; 
win = gausswin(20);%for smoothing spike trains, 20 ms
win = win./sum(win);
shufftrials=1000;

spk_allgapsdur_corr = [];shuff = [];
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
        
        %compute PSTH from spike trains aligned to onset of target element
        seqst = ceil(max(seqoffs(:,seqlen/2)-seqons(:,1)));%boundaries for sequence activity relative to target gap (sylloff1)
        seqend = ceil(max(seqoffs(:,end)-seqoffs(:,seqlen/2)));
        spktms = cell(size(seqons,1),1);%spike times for each trial relative to target gap 
        smooth_spiketrains = zeros(length(gapdur_id),seqst+seqend+1);
        for m = 1:size(seqons,1)
            temp = zeros(1,seqst+seqend+1);
            x = spiketimes(find(spiketimes>=(seqoffs(m,seqlen/2)-seqst) & ...
                spiketimes<=(seqoffs(m,seqlen/2)+seqend)));
            spktms{m} = x - seqoffs(m,seqlen/2); %spike times aligned by sylloff1 
            spktimes = round(spktms{m})+seqst+1;
            temp(spktimes) = 1;
            smooth_spiketrains(m,:) = conv(temp,win,'same');
        end
        tb = [-seqst:seqend];
        PSTH_mn = mean(smooth_spiketrains,1).*1000;
        [pks, locs,w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',10,...
            'MinPeakWidth',10,'Annotate','extents','WidthReference','halfheight');%find bursts in premotor win
        pkid = find(tb(locs)>=-40 & tb(locs)<=0);
        wc = round(wc);
        if isempty(pkid)
            continue
        end
        
        %shuffled spike train to detect peaks that are significantly
        %above shuffled activity
        smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
        PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;
        
        %order trials by gapdur
        [~,ix] = sort(gapdur_id,'descend');
        gapdur_id = gapdur_id(ix);spktms = spktms(ix);seqons = seqons(ix,:);seqoffs = seqoffs(ix,:);smooth_spiketrains=smooth_spiketrains(ix,:);
        
        %for each burst found, test alignment and correlate with gapdur
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
            
            r = xcorr(smooth_spiketrains(:,burstst:burstend)',0,'coeff');
            r = reshape(r,[size(smooth_spiketrains,1) size(smooth_spiketrains,1)]);
            r = r(find(triu(r,1)));
            varburst1 = nanmean(r);%average pairwise correlation of spike trains 
            
            seqons_alignedoff1 = seqons-seqoffs(:,seqlen/2);
            anchor=seqons_alignedoff1(:,seqlen/2+1);
            spktms_on2 = arrayfun(@(x) spktms{x}-anchor(x),1:length(spktms),'un',0);%realign spike times in each trial by on2
            seqst2 = ceil(abs(min([spktms_on2{:}])));
            seqend2 = ceil(abs(max([spktms_on2{:}])));
            smooth_spiketrains_on2 = zeros(length(gapdur_id),seqst2+seqend2+1);
            for m = 1:length(gapdur_id)
                temp = zeros(1,seqst2+seqend2+1);
                spktimes = round(spktms_on2{m})+seqst2+1;
                temp(spktimes) = 1;
                smooth_spiketrains_on2(m,:) = conv(temp,win,'same');
            end  
            tb2 = [-seqst2:seqend2];
            PSTH_mn_on2 = mean(smooth_spiketrains_on2,1).*1000;
            [pks2, locs2,w2,~,wc2] = findpeaks2(PSTH_mn_on2,'MinPeakProminence',...
                10,'MinPeakWidth',10,'Annotate','extents','WidthReference','halfheight');
            if ~isempty(locs2)
                wc2 = round(wc2);
                ix = find(tb2(locs2)>=motorwin-mean(gapdur_id) & tb2(locs2)<=-mean(gapdur_id));
                if isempty(ix)
                     alignby=1;%off1
                     wth = w(pkid(ixx));
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

                    r = xcorr(smooth_spiketrains_on2(:,burstst2:burstend2)',0,'coeff');
                    r = reshape(r,[size(smooth_spiketrains_on2,1) size(smooth_spiketrains_on2,1)]);
                    r = r(find(triu(r,1)));
                    varburst2 = nanmean(r);

                    if varburst1 < varburst2
                        alignby=2;%on2
                        wth = w2(ix);
                        pkactivity = (pks2(ix)-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                        npks_burst = cellfun(@(x) length(find(x>=tb2(burstst2)&x<tb2(burstend2))),spktms_on2);%extract nspks in each trial
                    else
                        alignby=1;%off1
                        wth = w(pkid(ixx));
                        pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                        npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms)';%extract nspks in each trial
                    end
                end
            else
                 alignby=1;%off1
                 wth = w(pkid(ixx));
                 pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                 npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms)';%extract nspks in each trial
            end
                
            if singleunits==0
                if pkactivity < activitythresh
                    continue
                end
            else
                if mean(pct_error) > 0.01
                    continue
                end
            end
            
            [r p] = corrcoef(npks_burst,gapdur_id);
            if p(2) <= 0.05
                seqoffs_a = seqoffs-seqoffs(:,seqlen/2);%align time of each offset by gap onset
                seqons_a = seqons-seqoffs(:,seqlen/2);%align time of each onset by gap onset 
                motifgapdurs = seqons(:,2:end)-seqoffs(:,1:end-1);
                for numgap = 1:size(seqoffs_a,2)-1
                    if numgap == seqlen/2
                        continue
                    end
                    if alignby==1
                        anchorpt = seqoffs_a(:,numgap);
                    else
                        anchorpt = seqons_a(:,numgap+1);
                    end
                    spktms_aligned = arrayfun(@(x) spktms{x}-anchorpt(x),1:length(spktms),'un',0);
                    seqst2 = ceil(abs(min([spktms_aligned{:}])));
                    seqend2 = ceil(abs(max([spktms_aligned{:}])));
                    smooth_spiketrains_a = zeros(length(gapdur_id),seqst2+seqend2+1);
                    for m = 1:length(gapdur_id)
                        temp = zeros(1,seqst2+seqend2+1);
                        spktimes = round(spktms_aligned{m})+seqst2+1;
                        temp(spktimes) = 1;
                        smooth_spiketrains_a(m,:) = conv(temp,win,'same');
                    end  
                    tb_a = [-seqst2:seqend2];
                    PSTH_mn_a = mean(smooth_spiketrains_a,1).*1000;
                    [pks_a, locs_a, wa,~,wca] = findpeaks2(PSTH_mn_a,'MinPeakProminence',...
                        10,'MinPeakWidth',10,'Annotate','extents','WidthReference','halfheight');
                    wca = round(wca);
                    if alignby==1
                        targetpks = find(tb_a(locs_a)>=-motorwin & tb_a(locs_a)<0);
                    else
                        targetpks = find(tb_a(locs_a)>=motorwin-mean(motifgapdurs(:,numgap)) & tb_a(locs_a)<-mean(motifgapdurs(:,numgap)));
                    end
                    if isempty(targetpks)
                        continue
                    end
                    
                    for idxx = 1:length(targetpks)
                        burstend_a = wca(targetpks(idxx),2)+(wca(targetpks(idxx),2)-locs_a(targetpks(idxx)));
                        burstst_a = wca(targetpks(idxx),1)-(locs_a(targetpks(idxx))-wca(targetpks(idxx),1));
                        if targetpks(idxx) < size(wca,1) 
                            if burstend_a > wca(targetpks(idxx)+1,1)
                                burstend_a = ceil((wca(targetpks(idxx),2)+wca(targetpks(idxx)+1,1))/2);
                            end
                        end
                        if targetpks(idxx) ~= 1
                            if burstst_a < wca(targetpks(idxx)-1,2)
                                burstst_a = floor((wca(targetpks(idxx),1)+wca(targetpks(idxx)-1,2))/2);
                            end
                        end
                        if burstst_a <= 0
                            burstst_a = 1;
                        end
                        if burstend_a > length(tb_a)
                            burstend_a = length(tb_a);
                        end
                        
                        npks_burst = cellfun(@(x) length(find(x>=tb_a(burstst_a)&x<tb_a(burstend_a))),spktms_aligned);
                        [r2 p2] = corrcoef(npks_burst,motifgapdurs(:,numgap));
                        spk_allgapsdur_corr = [spk_allgapsdur_corr; r2(2) p2(2) r(2)];
                        
                        %shuffle analysis
                        npks_burst_shuff = repmat(npks_burst,shufftrials,1);
                        npks_burst_shuff = permute_rowel(npks_burst_shuff);
                        [r p] = corrcoef([npks_burst_shuff',motifgapdurs(:,numgap)]);
                        r = r(1:end-1,end);
                        p = p(1:end-1,end);
                        shuff = [shuff r p];

                        if p2(2)<=0.05 & plotcondition == 1
                            if alignby==1
                                seqoffs_aligned = seqoffs-seqoffs(:,numgap);%align time of each offset by gap onset
                                seqons_aligned = seqons-seqoffs(:,numgap);
                                seqst_aligned = ceil(max(seqoffs_aligned(:,numgap)-seqons_aligned(:,1)));%boundaries for sequence activity relative to target gap (sylloff1)
                                seqend_aligned = ceil(max(seqoffs_aligned(:,end)-seqoffs_aligned(:,numgap)));
                            else
                                seqoffs_aligned = seqoffs-seqons(:,numgap+1);%align time of each offset by gap onset
                                seqons_aligned = seqons-seqons(:,numgap+1);
                                seqst_aligned = ceil(max(seqons_aligned(:,numgap+1)-seqons_aligned(:,1)));%boundaries for sequence activity relative to target gap (sylloff1)
                                seqend_aligned = ceil(max(seqoffs_aligned(:,end)-seqons_aligned(:,numgap+1)));
                            end
                            [~,ixxx] = sort(motifgapdurs(:,numgap),'descend');
                            spktms_aligned = spktms_aligned(ixxx);seqons_aligned = seqons_aligned(ixxx,:);
                            seqoffs_aligned = seqoffs_aligned(ixxx,:);smooth_spiketrains_a = smooth_spiketrains_a(ixxx,:);
                            figure;subplot(2,1,1);hold on;cnt=0;
                            for m = 1:length(motifgapdurs)
                                if ~isempty(spktms_aligned{m})
                                    plot(repmat(spktms_aligned{m},2,1),[cnt cnt+1],'k');hold on;
                                end
                                
                                if alignby==1
                                    for syll=1:seqlen
                                        patch([seqons_aligned(m,syll) seqoffs_aligned(m,syll) seqoffs_aligned(m,syll) seqons_aligned(m,syll)]-seqoffs_aligned(m,numgap),...
                                             [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
                                    end
                                else
                                    for syll=1:seqlen
                                        patch([seqons_aligned(m,syll) seqoffs_aligned(m,syll) seqoffs_aligned(m,syll) seqons_aligned(m,syll)]-seqons_aligned(m,numgap+1),...
                                             [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
                                    end
                                end
                                cnt=cnt+1;
                            end
                            [~,stid] = regexp(ff(i).name,'data_');
                            enid = regexp(ff(i).name,'_TH');
                            unitid = ff(i).name(stid+1:enid-1);
                            title([unitid,' ',gapids{n},' r=',num2str(r2(2))],'interpreter','none');
                            xlabel('time (ms)');ylabel('trial');set(gca,'fontweight','bold');
                            xlim([-seqst2 seqend2]);ylim([0 cnt]);
                            
                            subplot(2,1,2);hold on;
                             patch([-seqst2:seqend2 fliplr(-seqst2:seqend2)],([mean(smooth_spiketrains_a,1)-...
                                stderr(smooth_spiketrains_a,1)...
                                fliplr(mean(smooth_spiketrains_a,1)+...
                                stderr(smooth_spiketrains_a,1))])*1000,[0.5 0.5 0.5],'edgecolor','none','facealpha',0.7);
                            yl = get(gca,'ylim');
                            plot(repmat([tb_a(burstst_a) tb_a(burstend_a)],2,1),yl,'g','linewidth',2);hold on;
                            xlim([-seqst2 seqend2]);
                            xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');  
                            pause
                        end   
                    end
                end
                break
            else
                continue
            end
        end
    end
end

