config;
%% for units that are significantly correlated with target gap, do they also
%%burst before other gaps and are those bursts correlated with their respective gaps? 

spk_allgapsdur_corr = [];
win = gausswin(20);%for smoothing spike trains
win = win./sum(win);
seqlen = 6;%4 = 2 syllables before and after target gap
randpropsignificantcorr_hi = 0.069129;
randpropsignificantnegcorr_hi = 0.037879;
randpropsignificantnegcorr_lo = 0.013258;
randpropsignificantposcorr_hi = 0.037879;
randpropsignificantposcorr_lo = 0.014205;
plotcondition = 1;

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
        
        %correlate target gaps' activity with target gapdur
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
            [r p] = corrcoef(npks_burst,gapdur_id);
           
            if p(2) <= 0.05
                seqoffs_a = seqoffs-seqoffs(:,seqlen/2);%align time of each offset by gap onset
                seqons_a = seqons-seqoffs(:,seqlen/2);%align time of each onset by gap onset 
                motifgapdurs = seqons(:,2:end)-seqoffs(:,1:end-1);
                for numgap = 1:size(seqoffs_a,2)-1
                    if numgap == 3
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
                    [pks_a, locs_a, wa,~,wca] = findpeaks2(PSTH_mn_a,'MinPeakHeight',50,...
                        'MinPeakDistance',20,'MinPeakWidth',10,'Annotate','extents');
                    wca = round(wca);
                    if alignby==1
                        targetpks = find(tb_a(locs_a)>=-40 & tb_a(locs_a)<0);
                    else
                        targetpks = find(tb_a(locs_a)>=-(mean(motifgapdurs(:,numgap))+40) & tb_a(locs_a)<-mean(motifgapdurs(:,numgap)));
                    end
                    if isempty(targetpks)
                        continue
                    end
                    burstend_a = wca(targetpks,2);
                    burstst_a = wca(targetpks,1);
                    for idxx = 1:length(targetpks)
                        npks_burst = cellfun(@(x) length(find(x>=tb_a(burstst_a(idxx))&x<tb_a(burstend_a(idxx)))),spktms_aligned);
                        [r2 p2] = corrcoef(npks_burst,motifgapdurs(:,numgap));
                        spk_allgapsdur_corr = [spk_allgapsdur_corr; r2(2) p2(2) r(2)];
                        
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
                                plot(repmat(spktms_aligned{m},2,1),[cnt cnt+1],'k');hold on;
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
                            plot(repmat([tb_a(burstst_a(idxx)) tb_a(burstend_a(idxx))],2,1),yl,'g','linewidth',2);hold on;
                            xlim([-seqst2 seqend2]);
                            xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');    
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

%compare percentage of cases with significant all/negative/positive
%correlations for bursts at other gaps in motif when unit has significant
%correlation at target gap 
figure;hold on;ax=gca;
[mn1 hi1 lo1] = jc_BootstrapfreqCI(spk_allgapsdur_corr(:,2)<=0.05);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_gapdur_corr(:,2)<=0.05);
b=bar(ax,[1 2],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
offset = 0.1429;
errorbar(1-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(1+offset,mn2,hi2-mn2,'r');
plot(ax,[1-2*offset 1+2*offset],[randpropsignificantcorr_hi randpropsignificantcorr_hi],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(spk_allgapsdur_corr(:,2)<=0.05 & spk_allgapsdur_corr(:,1)<0);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_gapdur_corr(:,2)<=0.05 & spk_gapdur_corr(:,1)<0);
b=bar(ax,[2 3],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
offset = 0.1429;
errorbar(2-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(2+offset,mn2,hi2-mn2,'r');
plot(ax,[2-2*offset 2+2*offset],[randpropsignificantnegcorr_hi randpropsignificantnegcorr_hi],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(spk_allgapsdur_corr(:,2)<=0.05 & spk_allgapsdur_corr(:,1)>0);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_gapdur_corr(:,2)<=0.05 & spk_gapdur_corr(:,1)>0);
b=bar(ax,[3 4],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
offset = 0.1429;
errorbar(3-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(3+offset,mn2,hi2-mn2,'r');
plot(ax,[3-2*offset 3+2*offset],[randpropsignificantposcorr_hi randpropsignificantposcorr_hi],'--','color',[0.5 0.5 0.5]);

xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion of cases with significant correlations');

%% compare when unit was negatively correlated with target gap, proportion of cases that are significant/negative/positive for bursts at other gaps
figure;hold on;ax = gca;
ind = find(spk_allgapsdur_corr(:,3)<0);
[mn1 hi1 lo1] = jc_BootstrapfreqCI(spk_allgapsdur_corr(ind,2) <= 0.05);
ind = find(spk_allgapsdur_corr(:,3)>0);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_allgapsdur_corr(ind,2) <= 0.05);
b=bar(ax,[1 2],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor='b';
b(2).FaceColor = 'none';b(2).EdgeColor='r';
offset = 0.1429;
errorbar(1-offset,mn1,hi1-mn1,'b');
errorbar(1+offset,mn2,hi2-mn2,'r');
plot(ax,[1-2*offset 1+2*offset],[randpropsignificantcorr_hi randpropsignificantcorr_hi],'--','color',[0.5 0.5 0.5]);

ind = find(spk_allgapsdur_corr(:,3)<0);
[mn1 hi1 lo1] = jc_BootstrapfreqCI(spk_allgapsdur_corr(ind,2) <= 0.05 & spk_allgapsdur_corr(ind,1)<0);
ind = find(spk_allgapsdur_corr(:,3)>0);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_allgapsdur_corr(ind,2) <= 0.05 & spk_allgapsdur_corr(ind,1)<0);
b=bar(ax,[2 3],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor='b';
b(2).FaceColor = 'none';b(2).EdgeColor='r';
offset = 0.1429;
errorbar(2-offset,mn1,hi1-mn1,'b');
errorbar(2+offset,mn2,hi2-mn2,'r');
plot(ax,[2-2*offset 2+2*offset],[randpropsignificantnegcorr_hi randpropsignificantnegcorr_hi],'--','color',[0.5 0.5 0.5]);

ind = find(spk_allgapsdur_corr(:,3)<0);
[mn1 hi1 lo1] = jc_BootstrapfreqCI(spk_allgapsdur_corr(ind,2) <= 0.05 & spk_allgapsdur_corr(ind,1)>0);
ind = find(spk_allgapsdur_corr(:,3)>0);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_allgapsdur_corr(ind,2) <= 0.05 & spk_allgapsdur_corr(ind,1)>0);
b=bar(ax,[3 4],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor='b';
b(2).FaceColor = 'none';b(2).EdgeColor='r';
offset = 0.1429;
errorbar(3-offset,mn1,hi1-mn1,'b');
errorbar(3+offset,mn2,hi2-mn2,'r');
plot(ax,[3-2*offset 3+2*offset],[randpropsignificantposcorr_hi randpropsignificantposcorr_hi],'--','color',[0.5 0.5 0.5]);

xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion of cases with significant correlations');
