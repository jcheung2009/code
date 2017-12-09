config; 
%% predictability gap duration of activity in time windows before and after target gap
%for units with bursts in gap premotor window that are significantly
%correlated

win = gausswin(20);%for smoothing spike trains
win = win./sum(win);
seqlen = 6;%4 = 2 syllables before and after target gap
randpropsignificantnegcorr_hi = 0.036932;
randpropsignificantnegcorr_lo = 0.012311;
randpropsignificantposcorr_hi = 0.037879;
randpropsignificantposcorr_lo = 0.013258;

windowsize = 40;%ms
shift = 10;%ms
min_time_before = -350;
max_time_after = 350;
trials = [min_time_before:shift:max_time_after];
negcases_lag_gaps = cell(length(trials),1);
poscases_lag_gaps = cell(length(trials),1);


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
        [pks, locs,w,~,wc] = findpeaks2(PSTH_mn,'MinPeakHeight',50,...
            'MinPeakDistance',20,'MinPeakWidth',10,'Annotate','extents');%find bursts in premotor win
        
         pkid = find(tb(locs)>=-40 & tb(locs)<=0);
        wc = round(wc);
        if isempty(pkid)
            continue
        end
        [~,ix] = sort(gapdur_id,'descend');%order trials by gapdur
        gapdur_id = gapdur_id(ix);spktms = spktms(ix);seqons = seqons(ix,:);seqoffs = seqoffs(ix,:);smooth_spiketrains=smooth_spiketrains(ix,:);
        
        for ixx = 1:length(pkid)%for each burst found
            burstend = wc(pkid(ixx),2);
            burstst = wc(pkid(ixx),1);
            r = xcorr(smooth_spiketrains(:,burstst:burstend)',0,'coeff');
            r = reshape(r,[size(smooth_spiketrains,1) size(smooth_spiketrains,1)]);
            r = r(find(triu(r,1)));
            varburst1 = nanmean(r);%average pairwise correlation of spike trains 
            %varburst1 = (nanstd(cell2mat(cellfun(@(x) (x(find(x>=tb(burstst)&x<tb(burstend))))',spktms,'un',0))));%variability of spiketimes in burst aligned by off1
            
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
            [pks2, locs2,w2,~,wc2] = findpeaks2(PSTH_mn_on2,'MinPeakHeight',50,...
                'MinPeakDistance',20,'MinPeakWidth',10,'Annotate','extents');
            if ~isempty(locs2)
                wc2 = round(wc2);
                [xy,ix] = min(abs(tb2(locs2)-(tb(locs(pkid(ixx)))-mean(anchor))));
                burstend2 = wc2(ix,2);%find burst border
                burstst2 = wc2(ix,1);
                r = xcorr(smooth_spiketrains_on2(:,burstst2:burstend2)',0,'coeff');
                r = reshape(r,[size(smooth_spiketrains_on2,1) size(smooth_spiketrains_on2,1)]);
                r = r(find(triu(r,1)));
                varburst2 = nanmean(r);
                %varburst2 = (nanstd(cell2mat(cellfun(@(x) (x(find(x>=tb2(burstst2)&x<tb2(burstend2)))),spktms_on2,'un',0))));%variability of spiketimes in burst aligned by off1
                
                if varburst1 < varburst2
                    alignby=2;%on2
                    wth = w2(ix);
                    npks_burst = cellfun(@(x) length(find(x>=tb2(burstst2)&x<tb2(burstend2))),spktms_on2);%extract nspks in each trial
                else
                    alignby=1;%off1
                    wth = w(pkid(ixx));
                    npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms);%extract nspks in each trial
                end
            else
                 alignby=1;%off1
                 wth = w(pkid(ixx));
                 npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms);%extract nspks in each trial
            end
            [r_target p] = corrcoef(npks_burst,gapdur_id);
            
            if p(2)<=0.05 
                seqons_a = seqons-seqoffs(:,seqlen/2);%align time of each onset by gap onset
                seqoffs_a = seqoffs-seqoffs(:,seqlen/2);%align time of each offset by gap onset
                landmarks = seqoffs_a(:,[1;1]*(1:size(seqoffs_a,2)));
                landmarks(:,1:2:end) = seqons_a;  
                bounds = mean(diff(landmarks,1,2));
                for pt = 2:size(landmarks,2)
                        anchorpt = landmarks(:,pt);
                        bound = bounds(pt-1);
        %                 figure;subplot(2,1,1);hold on;cnt=0;
                            spktms_aligned = arrayfun(@(x) spktms{x}-anchorpt(x),1:length(spktms),'un',0);
                            seqst2 = ceil(abs(min([spktms_aligned{:}])));
                            seqend2 = ceil(abs(max([spktms_aligned{:}])));
                            smooth_spiketrains_a = zeros(length(gapdur_id),seqst2+seqend2+1);
                            for m = 1:length(gapdur_id)
        %                         plot(repmat(spktms_aligned{m},2,1),[cnt cnt+1],'k');hold on;
        %                         for syll=1:seqlen
        %                             patch([seqons_a(m,syll) seqoffs_a(m,syll) seqoffs_a(m,syll) seqons_a(m,syll)]-anchorpt(m),...
        %                                  [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
        %                         end
%                               cnt=cnt+1;
                                temp = zeros(1,seqst2+seqend2+1);
                                spktimes = round(spktms_aligned{m})+seqst2+1;
                                temp(spktimes) = 1;
                                smooth_spiketrains_a(m,:) = conv(temp,win,'same');
                            end  
        %                     xlim([-seqst2 seqend2]);ylim([0 cnt]);xlabel('time (ms)');ylabel('trial');
        %         
        %                  subplot(2,1,2);hold on;
        %                  patch([-seqst2:seqend2 fliplr(-seqst2:seqend2)],([mean(smooth_spiketrains_a,1)-...
        %                     stderr(smooth_spiketrains_a,1)...
        %                     fliplr(mean(smooth_spiketrains_a,1)+...
        %                     stderr(smooth_spiketrains_a,1))])*1000,[0.5 0.5 0.5],'edgecolor','none','facealpha',0.7);
        %                 xlim([-seqst2 seqend2]);xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');

                        tb_a = [-seqst2:seqend2];
                        PSTH_mn_a = mean(smooth_spiketrains_a,1).*1000;
                        [pks_a, locs_a, wa,~,wca] = findpeaks2(PSTH_mn_a,'MinPeakHeight',50,...
                            'MinPeakDistance',20,'MinPeakWidth',10,'Annotate','extents');
                        wca = round(wca);
        %                 plot(tb_a(locs_a),pks_a,'ok');hold on;
                        targetpks = find(tb_a(locs_a)>=-bound & tb_a(locs_a)<0);
                        if isempty(targetpks)
                            continue
                        end

        %                 plot(tb_a(locs_a(targetpks)),pks_a(targetpks),'or');hold on;
                        burstend_a = wca(targetpks,2);
                        burstst_a = wca(targetpks,1);
        %                 yl = get(gca,'ylim');
        %                 plot(repmat([tb_a(burstst_a) tb_a(burstend_a)],2,1),yl,'b');hold on;

                        for idxx = 1:length(targetpks)
                            npks_burst = cellfun(@(x) length(find(x>=tb_a(burstst_a(idxx))&x<tb_a(burstend_a(idxx)))),spktms_aligned);
                            [r p] = corrcoef(npks_burst,gapdur_id);
                            trialind = max(find(mean(anchorpt)+tb_a(locs_a(targetpks(idxx)))-trials>0));
                            if isempty(trialind)
                                continue
                            else
                                if r_target(2)<0
                                    negcases_lag_gaps{trialind} = [negcases_lag_gaps{trialind}; r(2) p(2)];
                                else
                                    poscases_lag_gaps{trialind} = [poscases_lag_gaps{trialind}; r(2) p(2)];
                                end
                            end
                        end
                end
            end
        end
    end
end

ind = find(cellfun(@(x) ~isempty(x),negcases_lag_gaps));
[hi lo mnrneg] = cellfun(@(x) mBootstrapCI(x(:,1)),negcases_lag_gaps(ind),'un',1);
figure;subplot(2,1,1);hold on;plot(trials(ind),mnrneg,'b','marker','o','linewidth',2);
patch([trials(ind) fliplr(trials(ind))],[hi' fliplr(lo')],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
xlabel('time relative to target gap (ms)');ylabel('average correlation');

ind = find(cellfun(@(x) ~isempty(x),poscases_lag_gaps));
[hi lo mnrpos] = cellfun(@(x) mBootstrapCI(x(:,1)),poscases_lag_gaps(ind),'un',1);
subplot(2,1,2);hold on;plot(trials(ind),mnrpos,'r','marker','o','linewidth',2);
patch([trials(ind) fliplr(trials(ind))],[hi' fliplr(lo')],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
xlabel('time relative to target gap (ms)');ylabel('average correlation');





                
                
      