function [spk_gapdur_corr case_name] = RA_correlate_gapdur(batchfile,seqlen,...
    minsampsize,activitythresh,motorwin,targetgapactivity,targetgapdur,plotcasecondition,shuff)
%correlate premotor spikes with gapdur 
%seqlen = length of syllable sequence 
%minsampsize = minimum number of trials 
%activitythresh = for peak detection (zscore relative to shuffled activity)
%motorwin = -40 (40 ms premotor window)
% targetgapactivity = 0;%-1:previous, 0:current, 1:next
% targetgapdur = 0;%-1:previous, 0:current, 1:next
%plotcasecondition = 'n' (don't plot), 'y+' (plot significant cases),'y++'
%(plot strongly significant cases),'y++su' (...single units)
%shuff = 'n' or 'y' (shuffled analysis, for cases with peak activity greater than thresh)
%spk_gapdur_corr = [corrcoef pval alignment firingrate width mn(pct_error)...
%numtrials, corrcoefdur1 pval corrcoefdur2 pval]


%parameters
config; 
win = gausswin(20);%for smoothing spike trains, 20 ms
win = win./sum(win);
if strcmp(plotcasecondition,'n')
    plotcasecondition = '1==0';
elseif strcmp(plotcasecondition,'y+')
    plotcasecondition = ['p(2)<=0.05 & pkactivity >=',num2str(activitythresh)];%plot significant and strongly correlated cases
elseif strcmp(plotcasecondition,'y++')
    plotcasecondition = ['p(2)<=0.05 & abs(r(2)) >= 0.3 & pkactivity >=',num2str(activitythresh)];%plot significant and strongly correlated cases
elseif strcmp(plotcasecondition,'y++su')
     plotcasecondition = ['p(2)<=0.05 & abs(r(2)) >= 0.3 & mean(pct_error)<=0.01 & pkactivity >=', num2str(activitythresh)];%plot significant and strongly correlated cases
end

spk_gapdur_corr = [];case_name = {};
ff = load_batchf(batchfile);
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

        %correlate target gaps' activity with target gapdur
        seqst = ceil(max(seqoffs(:,seqlen/2+targetgapactivity)-seqons(:,1)));%boundaries for sequence activity relative to target gap (sylloff1)
        seqend = ceil(max(seqoffs(:,end)-seqoffs(:,seqlen/2+targetgapactivity)));
        spktms = cell(size(seqons,1),1);%spike times for each trial relative to target gap 
        smooth_spiketrains = zeros(length(gapdur_id),seqst+seqend+1);
        for m = 1:size(seqons,1)
            temp = zeros(1,seqst+seqend+1);
            x = spiketimes(find(spiketimes>=(seqoffs(m,seqlen/2+targetgapactivity)-seqst) & ...
                spiketimes<=(seqoffs(m,seqlen/2+targetgapactivity)+seqend)));
            spktms{m} = x - seqoffs(m,seqlen/2+targetgapactivity); %spike times aligned by sylloff1 
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
        [~,ix] = sort(gapdur_id,'descend');
        gapdur_id = gapdur_id(ix);spktms = spktms(ix);seqons = seqons(ix,:);seqoffs = seqoffs(ix,:);smooth_spiketrains=smooth_spiketrains(ix,:);
        if targetgapdur ~= 0
            gapseq = seqons(:,2:end)-seqoffs(:,1:end-1);
            gapdur_id_corr = gapseq(:,seqlen/2+targetgapdur);%gapdur for correlation with activity
        else
            gapdur_id_corr = gapdur_id;    
        end
        
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
            
            seqons_alignedoff1 = seqons-seqoffs(:,seqlen/2+targetgapactivity);
            anchor=seqons_alignedoff1(:,seqlen/2+targetgapactivity+1);
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
            else
                 alignby=1;%off1
                 wth = w(pkid(ixx));
                 pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                 npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms)';%extract nspks in each trial
            end
            
            if strcmp(shuff,'y')
                shufftrials = 1000;
                if pkactivity >= activitythresh
                    npks_burst_shuff = repmat(npks_burst,shufftrials,1);
                    npks_burst_shuff = permute_rowel(npks_burst_shuff);
                    [r p] = corrcoef([npks_burst_shuff',gapdur_id_corr]);
                    r = r(1:end-1,end);
                    p = p(1:end-1,end);
                    spk_gapdur_corr = [spk_gapdur_corr r p];
                end
            else
                [r p] = corrcoef(npks_burst,gapdur_id_corr);
                dur1_id = seqoffs(:,seqlen/2+targetgapdur)-seqons(:,seqlen/2+targetgapdur);
                dur2_id = seqoffs(:,seqlen/2+targetgapdur+1)-seqons(:,seqlen/2+targetgapdur+1);
                [r1 p1] = corrcoef(npks_burst,dur1_id);
                [r2 p2] = corrcoef(npks_burst,dur2_id);
            
                spk_gapdur_corr = [spk_gapdur_corr; r(2) p(2) alignby pkactivity...
                    wth mean(pct_error) length(gapdur_id) r1(2) p1(2) r2(2) p2(2)];
            end

            [~,stid] = regexp(ff(i).name,'data_');
            enid = regexp(ff(i).name,'_TH');
            unitid = ff(i).name(stid+1:enid-1);
            case_name = [case_name,{unitid,gapids{n}}];

            if eval(plotcasecondition)
                thr1 = quantile(gapdur_id,0.25);%threshold for small gaps
                smallgaps_id = find(gapdur_id <= thr1);
                thr2 = quantile(gapdur_id,0.75);%threshold for large gaps
                largegaps_id = find(gapdur_id >= thr2);
                spktms_on2_inburst = cellfun(@(x) x(find(x>=tb2(burstst2)&x<tb2(burstend2))),spktms_on2,'un',0);
                spktms_inburst = cellfun(@(x) x(find(x>=tb(burstst)&x<tb(burstend))),spktms,'un',0);
                figure;subplot(2,1,1);hold on;cnt=0;
                for m = 1:length(gapdur_id)
                    if alignby==1
                        if isempty(spktms{m})
                            continue
                        end
                        plot(repmat(spktms{m},2,1),[cnt cnt+1],'k');hold on;
                        if ~isempty(spktms_inburst{m})
                            plot(repmat(spktms_inburst{m},2,1),[cnt cnt+1],'g');hold on;
                        end
                        for syll=1:seqlen
                            patch([seqons(m,syll) seqoffs(m,syll) seqoffs(m,syll) seqons(m,syll)]-seqoffs(m,seqlen/2+targetgapactivity),...
                                 [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
                        end
                    elseif alignby==2
                        if isempty(spktms_on2{m})
                            continue
                        end
                        plot(repmat(spktms_on2{m},2,1),[cnt cnt+1],'k');hold on;
                        if ~isempty(spktms_on2_inburst{m})
                            plot(repmat(spktms_on2_inburst{m},2,1),[cnt cnt+1],'g');hold on;
                        end
                        for syll=1:seqlen
                            patch([seqons(m,syll) seqoffs(m,syll) seqoffs(m,syll) seqons(m,syll)]-seqons(m,seqlen/2+targetgapactivity+1),...
                                 [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
                        end
                    end
                    cnt=cnt+1;
                end
                [~,stid] = regexp(ff(i).name,'data_');
                enid = regexp(ff(i).name,'_TH');
                unitid = ff(i).name(stid+1:enid-1);
                title([unitid,' ',gapids{n},' r=',num2str(r(2))],'interpreter','none');
                xlabel('time (ms)');ylabel('trial');set(gca,'fontweight','bold');
                if alignby==1
                    xlim([-seqst seqend]);ylim([0 cnt]);
                    plot(-seqst,min(smallgaps_id),'r>','markersize',4,'linewidth',2);hold on;
                    plot(-seqst,max(largegaps_id),'b>','markersize',4,'linewidth',2);hold on;
                elseif alignby==2
                    xlim([-seqst2 seqend2]);ylim([0 cnt]);
                    plot(-seqst2,min(smallgaps_id),'r>','markersize',4,'linewidth',2);hold on;
                    plot(-seqst2,max(largegaps_id),'b>','markersize',4,'linewidth',2);hold on;
                end   
                
                subplot(2,1,2);hold on;
                if alignby==1
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
                    plot(repmat([tb(burstst) tb(burstend)],2,1),yl,'g','linewidth',2);hold on;
                    xlim([-seqst seqend]);
                elseif alignby==2
                    patch([-seqst2:seqend2 fliplr(-seqst2:seqend2)],([mean(smooth_spiketrains_on2(smallgaps_id,:),1)-...
                        stderr(smooth_spiketrains_on2(smallgaps_id,:),1)...
                        fliplr(mean(smooth_spiketrains_on2(smallgaps_id,:),1)+...
                        stderr(smooth_spiketrains_on2(smallgaps_id,:),1))])*1000,[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
                    patch([-seqst2:seqend2 fliplr(-seqst2:seqend2)],([mean(smooth_spiketrains_on2(largegaps_id,:),1)-...
                        stderr(smooth_spiketrains_on2(largegaps_id,:),1)...
                        fliplr(mean(smooth_spiketrains_on2(largegaps_id,:),1)+...
                        stderr(smooth_spiketrains_on2(largegaps_id,:),1))])*1000,[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
                    patch([-seqst2:seqend2 fliplr(-seqst2:seqend2)],([mean(smooth_spiketrains_on2,1)-...
                        stderr(smooth_spiketrains_on2,1)...
                        fliplr(mean(smooth_spiketrains_on2,1)+...
                        stderr(smooth_spiketrains_on2,1))])*1000,[0.8 0.8 0.8],'edgecolor','none','facealpha',0.7);
                    yl = get(gca,'ylim');
                    plot(repmat([tb2(burstst2) tb2(burstend2)],2,1),yl,'g','linewidth',2);hold on;
                    xlim([-seqst2 seqend2]);
                end
                xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');
            
            end
        end
    end
end

% numcases = length(spk_gapdur_corr);
% numsignificant = length(find(spk_gapdur_corr(:,2)<=0.05));
% disp(['proportion of significant cases = ',num2str(numsignificant),'/',num2str(numcases),' =',num2str(numsignificant/numcases)]);
% negcorr = find(spk_gapdur_corr(:,2)<= 0.05 & spk_gapdur_corr(:,1)<0);
% poscorr = find(spk_gapdur_corr(:,2)<= 0.05 & spk_gapdur_corr(:,1)>0);
% sigcorr = find(spk_gapdur_corr(:,2)<= 0.05);
% notsigcorr = find(spk_gapdur_corr(:,2)> 0.05);
% disp(['proportion of cases that are significantly negatively correlated = ',num2str(length(negcorr)/numcases)]);
% disp(['proportion of cases that are positively correlated = ',num2str(length(poscorr)/numcases)]);
% disp(['average r value for significant negative correlations = ',num2str(mean(spk_gapdur_corr(negcorr,1)))]);
% disp(['average r value for significant positive correlations = ',num2str(mean(spk_gapdur_corr(poscorr,1)))]);
% durcorr_neg = find(spk_dur_corr(negcorr,2)<=0.05 | spk_dur_corr(negcorr,4)<=0.05);
% disp(['proportion of significant negative correlations that are also correlated with dur1 OR dur2 = ',num2str(length(durcorr_neg)/length(negcorr))]);
% durcorr_pos = find(spk_dur_corr(poscorr,2)<=0.05 | spk_dur_corr(poscorr,4)<=0.05);
% disp(['proportion of significant positive correlations that are also correlated with dur1 OR dur2 = ',num2str(length(durcorr_pos)/length(poscorr))]);
% 
% %plot distribution of significant correlation coefficients 
% ind = find(spk_gapdur_corr(:,2)<=0.05);
% figure;hold on;[n b] = hist(spk_gapdur_corr(ind,1),[-1:0.1:1]);
% stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
% plot(mean(spk_gapdur_corr(negcorr,1)),y(1),'b^','markersize',8);hold on;
% plot(mean(spk_gapdur_corr(poscorr,1)),y(1),'r^','markersize',8);hold on;
% title('r values for significant RA activity vs gap duration correlations');
% xlabel('correlation coefficient');ylabel('probability');set(gca,'fontweight','bold');
% text(0,1,{['total active units:',num2str(numcases)];...
%     ['proportion of significant cases:',num2str(numsignificant/numcases)];...
%     ['proportion significantly negative:',num2str(length(negcorr)/numcases)];...
%     ['proportion significantly positive:',num2str(length(poscorr)/numcases)];...
%     ['proportion neg corrs also correlated with dur1 OR dur2:',num2str(length(durcorr_neg)/length(negcorr))];...
%     ['proportion pos corrs also correlated with dur1 OR dur2:',num2str(length(durcorr_pos)/length(poscorr))]},'units','normalized',...
%     'verticalalignment','top');
% 
% %plot burst alignment vs firing rate
% figure;hold on;plot(spk_gapdur_corr(:,3),spk_gapdur_corr(:,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% bar(1,mean(spk_gapdur_corr(spk_gapdur_corr(:,3)==1,4)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
% bar(2,mean(spk_gapdur_corr(spk_gapdur_corr(:,3)==2,4)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
% xlim([0.5 2.5]);xticks([1 2]);xticklabels({'off1','ons2'});ylabel('Hz');xlabel('burst alignment');
% 
% %plot burst alignment vs burst width
% figure;hold on;plot(spk_gapdur_corr(:,3),spk_gapdur_corr(:,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% bar(1,mean(spk_gapdur_corr(spk_gapdur_corr(:,3)==1,5)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
% bar(2,mean(spk_gapdur_corr(spk_gapdur_corr(:,3)==2,5)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
% xlim([0.5 2.5]);xticks([1 2]);xticklabels({'off1','ons2'});ylabel('burst width (ms)');xlabel('burst alignment');
% 
% %plot burst alignment vs correlation for significant negatively correlated cases
% figure;hold on;plot(spk_gapdur_corr(negcorr,3),spk_gapdur_corr(negcorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% bar(1,mean(spk_gapdur_corr(negcorr(spk_gapdur_corr(negcorr,3)==1),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
% bar(2,mean(spk_gapdur_corr(negcorr(spk_gapdur_corr(negcorr,3)==2),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
% xlim([0.5 2.5]);xticks([1 2]);xticklabels({'off1','ons2'});ylabel('correlation');xlabel('burst alignment');
% 
% %plot burst alignment vs correlation for significant positively correlated cases
% figure;hold on;plot(spk_gapdur_corr(poscorr,3),spk_gapdur_corr(poscorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% bar(1,mean(spk_gapdur_corr(poscorr(spk_gapdur_corr(poscorr,3)==1),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
% bar(2,mean(spk_gapdur_corr(poscorr(spk_gapdur_corr(poscorr,3)==2),1)),'facecolor','none','edgecolor','k','linewidth',2);hold on;
% xlim([0.5 2.5]);xticks([1 2]);xticklabels({'off1','ons2'});ylabel('correlation');xlabel('burst alignment');
% [h p] = ttest2(spk_gapdur_corr(poscorr(spk_gapdur_corr(poscorr,3)==1),1),spk_gapdur_corr(poscorr(spk_gapdur_corr(poscorr,3)==2),1));
% 
% %compare proportion of bursts that are aligned to off1 for significantly negative/positive correlated cases
% [mn1 hi lo] = jc_BootstrapfreqCI(spk_gapdur_corr(negcorr,3)==1);
% figure;hold on;bar(1,mn1,'facecolor','none','edgecolor','b','linewidth',2);hold on;
% errorbar(1,mn1,hi-mn1,'b','linewidth',2);
% [mn2 hi lo] = jc_BootstrapfreqCI(spk_gapdur_corr(poscorr,3)==1);
% bar(2,mn2,'facecolor','none','edgecolor','r','linewidth',2);hold on;
% errorbar(2,mn2,hi-mn2,'r','linewidth',2);
% xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('proportion aligned to off1');xlabel('correlation');
% p = chisq_proptest(sum(spk_gapdur_corr(negcorr,3)==1),sum(spk_gapdur_corr(poscorr,3)==1),length(negcorr),length(poscorr));
% 
% %compare proportion of bursts that are aligned to off1 for significant/not significant correlated cases
% [mn hi lo] = jc_BootstrapfreqCI(spk_gapdur_corr(sigcorr,3)==1);
% figure;hold on;bar(1,mn,'facecolor','none','edgecolor','b','linewidth',2);hold on;
% errorbar(1,mn,hi-mn,'b','linewidth',2);
% [mn hi lo] = jc_BootstrapfreqCI(spk_gapdur_corr(notsigcorr,3)==1);
% bar(2,mn,'facecolor','none','edgecolor','r','linewidth',2);hold on;
% errorbar(2,mn,hi-mn,'r','linewidth',2);
% xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('proportion aligned to off1');xlabel('correlation');
% 
% %compare firing rate for bursts that are negatively/positively correlated 
% figure;hold on;plot(1,spk_gapdur_corr(negcorr,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% plot(2,spk_gapdur_corr(poscorr,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% bar(1,mean(spk_gapdur_corr(negcorr,4)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
% bar(2,mean(spk_gapdur_corr(poscorr,4)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
% xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('Hz');xlabel('correlation');
% 
% %compare firing rate for bursts that are significantly/not significantly correlated 
% figure;hold on;plot(1,spk_gapdur_corr(sigcorr,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% plot(2,spk_gapdur_corr(notsigcorr,4),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% bar(1,mean(spk_gapdur_corr(sigcorr,4)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
% bar(2,mean(spk_gapdur_corr(notsigcorr,4)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
% xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('Hz');xlabel('correlation');
% 
% %compare burst width for bursts that are negatively/positively correlated
% figure;hold on;plot(1,spk_gapdur_corr(negcorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% plot(2,spk_gapdur_corr(poscorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% bar(1,mean(spk_gapdur_corr(negcorr,5)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
% bar(2,mean(spk_gapdur_corr(poscorr,5)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
% xlim([0.5 2.5]);xticks([1 2]);xticklabels({'negative','positive'});ylabel('burst width (ms)');xlabel('correlation');
% 
% %compare burst width for bursts that are significantly/not significantly correlated
% figure;hold on;plot(1,spk_gapdur_corr(sigcorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% plot(2,spk_gapdur_corr(notsigcorr,5),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% bar(1,mean(spk_gapdur_corr(sigcorr,5)),'facecolor','none','edgecolor','b','linewidth',2);hold on;
% bar(2,mean(spk_gapdur_corr(notsigcorr,5)),'facecolor','none','edgecolor','r','linewidth',2);hold on;
% xlim([0.5 2.5]);xticks([1 2]);xticklabels({'significant','not significant'});ylabel('burst width (ms)');xlabel('correlation');
% 
% %correlate rvals of negative cases with firing rate
% figure;hold on;plot(spk_gapdur_corr(negcorr,4),spk_gapdur_corr(negcorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% xlabel('Hz');ylabel('correlation');
% [r p] = corrcoef(spk_gapdur_corr(negcorr,4),spk_gapdur_corr(negcorr,1));
% %correlate rvals of positive cases with firing rate
% figure;hold on;plot(spk_gapdur_corr(poscorr,4),spk_gapdur_corr(poscorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% xlabel('Hz');ylabel('correlation');
% [r p] = corrcoef(spk_gapdur_corr(poscorr,4),spk_gapdur_corr(poscorr,1));
% %correlate rvals of negative cases with burst width
% figure;hold on;plot(spk_gapdur_corr(negcorr,5),spk_gapdur_corr(negcorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% xlabel('burst width (ms)');ylabel('correlation');
% [r p] = corrcoef(spk_gapdur_corr(negcorr,5),spk_gapdur_corr(negcorr,1));
% %correlate rvals of positive cases with burst width
% figure;hold on;plot(spk_gapdur_corr(poscorr,5),spk_gapdur_corr(poscorr,1),'marker','o','color',[0.5 0.5 0.5],'linestyle','none');
% xlabel('burst width (ms)');ylabel('correlation');
% [r p] = corrcoef(spk_gapdur_corr(poscorr,5),spk_gapdur_corr(poscorr,1));
% text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized',...
%     'verticalalignment','top');
% 
% %compare percentage of cases with significant correlations with target gap
% %vs prev and next gap for neural activity at target gap
% figure;hold on;ax = gca;
% [mn1 hi1 lo1] = jc_BootstrapfreqCI(spk_gapdur_corr_prev(:,2)<=0.05);
% [mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_gapdur_corr(:,2)<=0.05);
% [mn3 hi3 lo3] = jc_BootstrapfreqCI(spk_gapdur_corr_next(:,2)<=0.05);
% b=bar(ax,[1 2],[mn1 mn2 mn3;NaN NaN NaN]);
% b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
% b(2).FaceColor = 'none';b(2).EdgeColor='r';
% b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
% offset = 0.2222;
% errorbar(1-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
% errorbar(1,mn2,hi2-mn2,'r');
% errorbar(1+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
% plot(ax,[1-2*offset 1+2*offset],[0.069129 0.069129],'--','color',[0.5 0.5 0.5]);
% 
% [mn1 hi1 lo1] = jc_BootstrapfreqCI(spk_gapdur_corr_prev(:,2)<=0.05 & spk_gapdur_corr_prev(:,1)<0);
% [mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_gapdur_corr(:,2)<=0.05 & spk_gapdur_corr(:,1)<0);
% [mn3 hi3 lo3] = jc_BootstrapfreqCI(spk_gapdur_corr_next(:,2)<=0.05 & spk_gapdur_corr_next(:,1)<0);
% b=bar(ax,[2 3],[mn1 mn2 mn3;NaN NaN NaN]);
% b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
% b(2).FaceColor = 'none';b(2).EdgeColor='r';
% b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
% errorbar(2-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
% errorbar(2,mn2,hi2-mn2,'r');
% errorbar(2+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
% plot(ax,[2-2*offset 2+2*offset],[.037879 0.037879],'--','color',[0.5 0.5 0.5]);
% 
% [mn1 hi1 lo1] = jc_BootstrapfreqCI(spk_gapdur_corr_prev(:,2)<=0.05 & spk_gapdur_corr_prev(:,1)>0);
% [mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_gapdur_corr(:,2)<=0.05 & spk_gapdur_corr(:,1)>0);
% [mn3 hi3 lo3] = jc_BootstrapfreqCI(spk_gapdur_corr_next(:,2)<=0.05 & spk_gapdur_corr_next(:,1)>0);
% b=bar(ax,[3 4],[mn1 mn2 mn3;NaN NaN NaN]);
% b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
% b(2).FaceColor = 'none';b(2).EdgeColor='r';
% b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
% errorbar(3-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
% errorbar(3,mn2,hi2-mn2,'r');
% errorbar(3+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
% plot(ax,[3-2*offset 3+2*offset],[.037879 0.037879],'--','color',[0.5 0.5 0.5]);
% xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
% ylabel('proportion of cases with significant correlations');
% 
% %compare percentage of cases with significant correlations with
% %prev/current/next gap's activity with current gapdur
% figure;hold on;ax = gca;
% [mn1 hi1 lo1] = jc_BootstrapfreqCI(prevspk_gapdur_corr(:,2)<=0.05);
% [mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_gapdur_corr(:,2)<=0.05);
% [mn3 hi3 lo3] = jc_BootstrapfreqCI(nextspk_gapdur_corr(:,2)<=0.05);
% b=bar(ax,[1 2],[mn1 mn2 mn3;NaN NaN NaN]);
% b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
% b(2).FaceColor = 'none';b(2).EdgeColor='r';
% b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
% offset = 0.2222;
% errorbar(1-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
% errorbar(1,mn2,hi2-mn2,'r');
% errorbar(1+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
% plot(ax,[1-2*offset 1+2*offset],[0.069129 0.069129],'--','color',[0.5 0.5 0.5]);
% 
% [mn1 hi1 lo1] = jc_BootstrapfreqCI(prevspk_gapdur_corr(:,2)<=0.05 & prevspk_gapdur_corr(:,1)<0);
% [mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_gapdur_corr(:,2)<=0.05 & spk_gapdur_corr(:,1)<0);
% [mn3 hi3 lo3] = jc_BootstrapfreqCI(nextspk_gapdur_corr(:,2)<=0.05 & nextspk_gapdur_corr(:,1)<0);
% b=bar(ax,[2 3],[mn1 mn2 mn3;NaN NaN NaN]);
% b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
% b(2).FaceColor = 'none';b(2).EdgeColor='r';
% b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
% errorbar(2-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
% errorbar(2,mn2,hi2-mn2,'r');
% errorbar(2+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
% plot(ax,[2-2*offset 2+2*offset],[.037879 0.037879],'--','color',[0.5 0.5 0.5]);
% 
% [mn1 hi1 lo1] = jc_BootstrapfreqCI(prevspk_gapdur_corr(:,2)<=0.05 & prevspk_gapdur_corr(:,1)>0);
% [mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_gapdur_corr(:,2)<=0.05 & spk_gapdur_corr(:,1)>0);
% [mn3 hi3 lo3] = jc_BootstrapfreqCI(nextspk_gapdur_corr(:,2)<=0.05 & nextspk_gapdur_corr(:,1)>0);
% b=bar(ax,[3 4],[mn1 mn2 mn3;NaN NaN NaN]);
% b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
% b(2).FaceColor = 'none';b(2).EdgeColor='r';
% b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
% errorbar(3-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
% errorbar(3,mn2,hi2-mn2,'r');
% errorbar(3+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
% plot(ax,[3-2*offset 3+2*offset],[.037879 0.037879],'--','color',[0.5 0.5 0.5]);
% xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
% ylabel('proportion of cases with significant correlations');
% 
