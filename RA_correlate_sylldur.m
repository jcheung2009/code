config;
%% correlate premotor spikes with sylldur 
%also measure burst alignment with syllon2 or sylloff1 

spk_dur_corr = [];spk_gapdur_corr = [];
win = gausswin(20);%for smoothing spike trains
win = win./sum(win);
seqlen = 6;%4 = 2 syllables before and after target gap

windowsize = 40;%ms
shift = 10;%ms
min_time_before = -250;
max_time_after = 250;
trials = [min_time_before:shift:max_time_after];
prop_significant_negcases_lag_gaps = {};
prop_significant_poscases_lag_gaps = {};

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
    durs_all = offsets-onsets;
    for n = 1:length(gapids)
        idx = strfind(labels,gapids(n));
        seqons = onsets(bsxfun(@plus, idx',(0:seqlen-1)));%realtime 
        seqoffs = offsets(bsxfun(@plus,idx',(0:seqlen-1)));
        dur_id = jc_removeoutliers(durs_all(idx+seqlen/2),3);
        dur_id = jc_removeoutliers(dur_id,3);
        id = find(isnan(dur_id));dur_id(id) = [];seqons(id,:) = [];seqoffs(id,:) = [];
        if ~isempty(find(seqoffs(:,end)-seqons(:,1)>=1000))
            id = find(seqoffs(:,end)-seqons(:,1)>=1000);
            seqons(id,:) = [];seqoffs(id,:) = [];dur_id(id) = [];
        end
        if length(dur_id)<25
            continue
        end

        seqst = ceil(max(seqons(:,seqlen/2+1)-seqons(:,1)));%boundaries for sequence activity relative to target gap (syllon2)
        seqend = ceil(max(seqoffs(:,end)-seqons(:,seqlen/2+1)));
        
        spktms = cell(size(seqons,1),1);%spike times for each trial relative to target gap 
        smooth_spiketrains = zeros(length(dur_id),seqst+seqend+1);
        for m = 1:size(seqons,1)
            temp = zeros(1,seqst+seqend+1);
            x = spiketimes(find(spiketimes>=(seqons(m,seqlen/2+1)-seqst) & ...
                spiketimes<=(seqons(m,seqlen/2+1)+seqend)));
            spktms{m} = x - seqons(m,seqlen/2+1); %spike times aligned by syllon2
            spktimes = round(spktms{m})+seqst+1;
            temp(spktimes) = 1;
            smooth_spiketrains(m,:) = conv(temp,win,'same');
        end
        tb = [-seqst:seqend];
        PSTH_mn = mean(smooth_spiketrains,1).*1000;
        [pks, locs,w,~,wc] = findpeaks2(PSTH_mn,'MinPeakHeight',50,...
            'MinPeakDistance',20,'MinPeakWidth',10,'Annotate','extents');%find bursts in premotor win
        pkid = find(tb(locs)>=-40 & tb(locs)<=0);
        wc = round(wc);
        if isempty(pkid)
            continue
        end
        [~,ix] = sort(dur_id,'descend');%order trials by gapdur
        dur_id = dur_id(ix);spktms = spktms(ix);seqons = seqons(ix,:);seqoffs = seqoffs(ix,:);smooth_spiketrains=smooth_spiketrains(ix,:);
        
        for ixx = 1:length(pkid)%for each burst found
            burstend = wc(pkid(ixx),2);
            burstst = wc(pkid(ixx),1);
            r = xcorr(smooth_spiketrains(:,burstst:burstend)',0,'coeff');
            r = reshape(r,[size(smooth_spiketrains,1) size(smooth_spiketrains,1)]);
            r = r(find(triu(r,1)));
            varburst1 = nanmean(r);%average pairwise correlation of spike trains 
            varburst1 = (nanstd(cell2mat(cellfun(@(x) (x(find(x>=tb(burstst)&x<tb(burstend))))',spktms,'un',0))));%variability of spiketimes in burst aligned by on2

            seqoffs_alignedon2 = seqoffs-seqons(:,seqlen/2+1);
            anchor=seqoffs_alignedon2(:,seqlen/2);
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
            [pks2, locs2,w2,~,wc2] = findpeaks2(PSTH_mn_off1,'MinPeakHeight',50,...
                'MinPeakDistance',20,'MinPeakWidth',10,'Annotate','extents');
            if ~isempty(locs2)
                wc2 = round(wc2);
                [xy,ix] = min(abs(tb2(locs2)-(tb(locs(pkid(ixx)))-mean(anchor))));
                burstend2 = wc2(ix,2);%find burst border
                burstst2 = wc2(ix,1);
                r = xcorr(smooth_spiketrains_off1(:,burstst2:burstend2)',0,'coeff');
                r = reshape(r,[size(smooth_spiketrains_off1,1) size(smooth_spiketrains_off1,1)]);
                r = r(find(triu(r,1)));
                varburst2 = nanmean(r);
                %varburst2 = (nanstd(cell2mat(cellfun(@(x) (x(find(x>=tb2(burstst2)&x<tb2(burstend2)))),spktms_off1,'un',0))));%variability of spiketimes in burst aligned by off1
                if varburst1 < varburst2
                    alignby=2;%off1
                    wth=w2(ix);
                    npks_burst = cellfun(@(x) length(find(x>=tb2(burstst2)&x<tb2(burstend2))),spktms_off1);%extract nspks in each trial
                else
                    alignby=1;%on2
                    wth=w(pkid(ixx));
                    npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms);%extract nspks in each trial
                end
            else
                alignby=1;
                wth=w(pkid(ixx));
                npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms);%extract nspks in each trial
            end
            [r p] = corrcoef(npks_burst,dur_id);
            spk_dur_corr = [spk_dur_corr; r(2) p(2) alignby pks(pkid(ixx)) wth];
            gapdur1_id = seqons(:,seqlen/2+1)-seqoffs(:,seqlen/2);
            [r1 p1] = corrcoef(npks_burst,gapdur1_id);
            spk_gapdur_corr = [spk_gapdur_corr; r1(2) p1(2)]; 
            
            if p(2)<=0.05 & abs(r(2)) >= 0.35 %plot significant and strongly correlated cases
                thr1 = quantile(dur_id,0.25);%threshold for small gaps
                smalldurs_id = find(dur_id <= thr1);
                thr2 = quantile(dur_id,0.75);%threshold for large gaps
                largedurs_id = find(dur_id >= thr2);
                figure;subplot(2,1,1);hold on;cnt=0;
                for m = 1:length(dur_id)
                    if alignby==1
                        if isempty(spktms{m})
                            continue
                        end
                        plot(repmat(spktms{m},2,1),[cnt cnt+1],'k');hold on;
                        for syll=1:seqlen
                            patch([seqons(m,syll) seqoffs(m,syll) seqoffs(m,syll) seqons(m,syll)]-seqons(m,seqlen/2+1),...
                                 [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
                        end
                    elseif alignby==2
                        if isempty(spktms_off1{m})
                            continue
                        end
                        plot(repmat(spktms_off1{m},2,1),[cnt cnt+1],'k');hold on;
                        for syll=1:seqlen
                            patch([seqons(m,syll) seqoffs(m,syll) seqoffs(m,syll) seqons(m,syll)]-seqoffs(m,seqlen/2),...
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
                    plot(-seqst,min(smalldurs_id),'r>','markersize',4,'linewidth',2);hold on;
                    plot(-seqst,max(largedurs_id),'b>','markersize',4,'linewidth',2);hold on;
                elseif alignby==2
                    xlim([-seqst2 seqend2]);ylim([0 cnt]);
                    plot(-seqst2,min(smalldurs_id),'r>','markersize',4,'linewidth',2);hold on;
                    plot(-seqst2,max(largedurs_id),'b>','markersize',4,'linewidth',2);hold on;
                end   
                
                subplot(2,1,2);hold on;
                if alignby==1
                    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(smalldurs_id,:),1)-...
                        stderr(smooth_spiketrains(smalldurs_id,:),1)...
                        fliplr(mean(smooth_spiketrains(smalldurs_id,:),1)+...
                        stderr(smooth_spiketrains(smalldurs_id,:),1))])*1000,[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
                    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(largedurs_id,:),1)-...
                        stderr(smooth_spiketrains(largedurs_id,:),1)...
                        fliplr(mean(smooth_spiketrains(largedurs_id,:),1)+...
                        stderr(smooth_spiketrains(largedurs_id,:),1))])*1000,[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
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
                    yl = get(gca,'ylim');
                    plot(repmat([tb2(burstst2) tb2(burstend2)],2,1),yl,'g','linewidth',2);hold on;
                    xlim([-seqst2 seqend2]);
                end
                xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');
            
            end
        end
    end
end