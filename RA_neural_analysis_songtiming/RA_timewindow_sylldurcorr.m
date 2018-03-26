config; 
%% predictability syll duration of activity in time windows before and after target syll
%for all units 

win = gausswin(20);%for smoothing spike trains
win = win./sum(win);
seqlen = 6;%4 = 2 syllables before and after target gap
randpropsignificantnegcorr_hi = 0.037412;
randpropsignificantnegcorr_lo = 0.014809;
randpropsignificantposcorr_hi = 0.036633;
randpropsignificantposcorr_lo = 0.01403;

windowsize = 40;%ms
shift = 10;%ms
min_time_before = -350;
max_time_after = 350;
trials = [min_time_before:shift:max_time_after];
cases_lag_durs = cell(length(trials),1);

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

        seqst = ceil(max(seqons(:,seqlen/2+1)-seqons(:,1)));%boundaries for sequence activity relative to target syll
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
        seqons_a = seqons-seqons(:,seqlen/2+1);%align time of each onset by syll onset
        seqoffs_a = seqoffs-seqons(:,seqlen/2+1);%align time of each offset by syll onset
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
                    smooth_spiketrains_a = zeros(length(dur_id),seqst2+seqend2+1);
                    for m = 1:length(dur_id)
%                         plot(repmat(spktms_aligned{m},2,1),[cnt cnt+1],'k');hold on;
%                         for syll=1:seqlen
%                             patch([seqons_a(m,syll) seqoffs_a(m,syll) seqoffs_a(m,syll) seqons_a(m,syll)]-anchorpt(m),...
%                                  [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
%                         end
%                         cnt=cnt+1;
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
%         
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

                for ix = 1:length(targetpks)
                    npks_burst = cellfun(@(x) length(find(x>=tb_a(burstst_a(ix))&x<tb_a(burstend_a(ix)))),spktms_aligned);
                    [r p] = corrcoef(npks_burst,dur_id);
                    trialind = max(find(mean(anchorpt)+tb_a(locs_a(targetpks(ix)))-trials>0));
                    if isempty(trialind)
                        continue
                    else
                        cases_lag_durs{trialind} = [cases_lag_durs{trialind}; r(2) p(2)];
                    end
                end
        end
    end
end

ind = find(cellfun(@(x) ~isempty(x),cases_lag_durs));
[propnegsig hi lo] = cellfun(@(x) jc_BootstrapfreqCI(x(:,2)<=0.05 & x(:,1)<0),cases_lag_durs(ind),'un',1);
figure;hold on;plot(trials(ind),propnegsig,'b','marker','o','linewidth',2);
patch([trials(ind) fliplr(trials(ind))],[hi' fliplr(lo')],[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
plot([trials(ind(1)) trials(ind(end))],[randpropsignificantnegcorr_hi randpropsignificantnegcorr_hi],'color',[0.5 0.5 0.5],'linewidth',2);
plot([trials(ind(1)) trials(ind(end))],[randpropsignificantnegcorr_lo randpropsignificantnegcorr_lo],'color',[0.5 0.5 0.5],'linewidth',2);
xlabel('time relative to target syll (ms)');ylabel('proportion significantly negative cases');

[proppossig hi lo] = cellfun(@(x) jc_BootstrapfreqCI(x(:,2)<=0.05 & x(:,1)>0),cases_lag_durs(ind),'un',1);
figure;hold on;plot(trials(ind),proppossig,'r','marker','o','linewidth',2);
patch([trials(ind) fliplr(trials(ind))],[hi' fliplr(lo')],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
plot([trials(ind(1)) trials(ind(end))],[randpropsignificantposcorr_hi randpropsignificantposcorr_hi],'color',[0.5 0.5 0.5],'linewidth',2);
plot([trials(ind(1)) trials(ind(end))],[randpropsignificantposcorr_lo randpropsignificantposcorr_lo],'color',[0.5 0.5 0.5],'linewidth',2);
xlabel('time relative to target syll (ms)');ylabel('proportion significantly positive cases');
