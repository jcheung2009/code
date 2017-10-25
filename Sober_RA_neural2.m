config; 
%% correlate premotor spikes with gapdur 
%also measure burst alignment with sylloff1 or syllon2 

spk_gapdur_corr = [];
win = gausswin(20);%for smoothing spike trains
win = win./sum(win);
seqlen = 6;%4 = 2 syllables before and after target gap

ff = load_batchf('batchfile');
birdid = arrayfun(@(x) x.birdname,params,'unif',0);
for i = 1:length(ff)
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms
    
    %unique gap id
    N = length(labels);
    [a, ~, nn] = unique(labels(bsxfun(@plus,1:seqlen,(0:N-seqlen)')),'rows');
    cnts = sum(bsxfun(@(x,y)x==y,1:size(a,1),nn))';
    removeind = [];
    for ii = 1:size(a,1)
        if length(unique(a(ii,:)))==1 | sum(~isletter(a(ii,:))) > 0 %remove repeats and sequences with non-
            removeind = [removeind;ii];
        end
    end
    cnts(removeind) = [];a(removeind,:) = [];
    ind = find(cnts >= 25);%only sequences that occur more than 25 times 
    a = a(ind,:);cnts = cnts(ind);
    
    %for each unique sequence found  
    gapids = mat2cell(a,repmat(1,size(a,1),1))';
    gapdurs_all = onsets(2:end)-offsets(1:end-1);
    for n = 1:length(gapids)
        idx = strfind(labels,gapids(n));
        seqons = onsets(bsxfun(@plus, idx',(0:seqlen-1)));%realtime 
        seqoffs = offsets(bsxfun(@plus,idx',(0:seqlen-1)));
        seqst = ceil(max(seqoffs(:,seqlen/2)-seqons(:,1)));%boundaries for sequence activity relative to target gap (sylloff1)
        seqend = ceil(max(seqoffs(:,end)-seqoffs(:,seqlen/2)));
        gapdur_id = jc_removeoutliers(gapdurs_all(idx+seqlen/2-1),3);
        gapdur_id = jc_removeoutliers(gapdur_id,3);
        id = find(isnan(gapdur_id));gapdur_id(id) = [];seqons(id,:) = [];seqoffs(id,:) = [];
        
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
        [pks locs] = findpeaks(PSTH_mn,'MinPeakHeight',50,'MinPeakDistance',20);%find bursts in premotor win
        pkid = find(tb(locs)>=-50 & tb(locs)<=0)
        if isempty(pkid)
            continue
        end
        [~,ix] = sort(gapdur_id,'descend');%order trials by gapdur
        gapdur_id = gapdur_id(ix);spktms = spktms(ix);seqons = seqons(ix,:);seqoffs = seqoffs(ix,:);
        [tr trlocs] = findpeaks(-PSTH_mn,'MinPeakHeight',-0.75*mean(pks),'MinPeakDistance',20);%
        trlocs = [1 trlocs length(PSTH_mn)];
        
        for ixx = 1:length(pkid)%for each burst found
            burstend = trlocs(min(find(trlocs > locs(pkid(ixx)))));%find burst border
            burstst = trlocs(max(find(trlocs < locs(pkid(ixx)))));
            npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms);%extract nspks in each trial
            [r p] = corrcoef(npks_burst,gapdur_id);
            
            if p(2)<=0.05
                varburst1 = nanstd(cellfun(@(x) mean(x(find(x>=tb(burstst)&x<tb(burstend)))),spktms,'un',1));%variability of spiketimes in burst aligned by off1
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
                [pks2 locs2] = findpeaks(PSTH_mn_on2,'MinPeakHeight',50,'MinPeakDistance',20,'Annotate','extents');
                [xy,ix] = min(abs(tb2(locs2)-(tb(locs(pkid(ixx)))-mean(anchor))));
                [tr2 trlocs2] = findpeaks(-PSTH_mn_on2,'MinPeakHeight',-0.75*mean(pks2),'MinPeakDistance',20);%
                trlocs2 = [1 trlocs2 length(PSTH_mn_on2)];    
                burstend2 = trlocs2(min(find(trlocs2 > locs2(ix))));%find burst border
                burstst2 = trlocs2(max(find(trlocs2 < locs2(ix))));
                varburst2 = nanstd(cellfun(@(x) mean(x(find(x>=tb2(burstst2)&x<tb2(burstend2)))),spktms_on2,'un',1));%variability of spiketimes in burst aligned by off1
                if varburst1 > varburst2
                    alignby=2;%on2
                else
                    alignby=1;%off1
                end
            else
                alignby=NaN;
            end
            spk_gapdur_corr = [spk_gapdur_corr; r(2) p(2) alignby];
            
            if p(2)<=0.05 & r(2) >= 0.3 %plot significant and strongly correlated cases
                thr1 = quantile(gapdur_id,0.25);%threshold for small gaps
                smallgaps_id = find(gapdur_id <= thr1);
                thr2 = quantile(gapdur_id,0.75);%threshold for large gaps
                largegaps_id = find(gapdur_id >= thr2);
                figure;subplot(2,1,1);hold on;cnt=0;
                for m = 1:length(gapdur_id)
                    if alignby==1
                        if isempty(spktms{m})
                            continue
                        end
                        plot(repmat(spktms{m},2,1),[cnt cnt+1],'k');hold on;
                        for syll=1:seqlen
                            patch([seqons(m,syll) seqoffs(m,syll) seqoffs(m,syll) seqons(m,syll)]-seqoffs(m,seqlen/2),...
                                 [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
                        end
                    elseif alignby==2
                        if isempty(spktms_on2{m})
                            continue
                        end
                        plot(repmat(spktms_on2{m},2,1),[cnt cnt+1],'k');hold on;
                        for syll=1:seqlen
                            patch([seqons(m,syll) seqoffs(m,syll) seqoffs(m,syll) seqons(m,syll)]-seqons(m,seqlen/2+1),...
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
                    yl = get(gca,'ylim');
                    plot(repmat([tb2(burstst2) tb2(burstend2)],2,1),yl,'g','linewidth',2);hold on;
                    xlim([-seqst2 seqend2]);
                end
                xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');
            
            end
        end
    end
end
        
            
            
            
           