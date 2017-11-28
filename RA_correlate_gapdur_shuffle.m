config;

%% shuffle 
ntrials = 1000;aph = 0.01;%99% CI 
win = gausswin(20);%for smoothing spike trains, 20 ms
win = win./sum(win);
seqlen = 6;%4 = 2 syllables before and after target gap
spk_gapdur_corr_rand = [];spk_gapdur_pval_rand=[];

ff = load_batchf('batchfile');
birdid = arrayfun(@(x) x.birdname,params,'unif',0);
for i = 1:length(ff)
    load(ff(i).name);
    if mean(pct_error)>0.01
        continue
    end
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
            burstend = wc(pkid(ixx),2)+(wc(pkid(ixx),2)-locs(pkid(ixx)));
            burstst = wc(pkid(ixx),1)-(locs(pkid(ixx))-(wc(pkid(ixx),1)));
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
                burstend2 = wc2(ix,2)+(wc2(ix,2)-locs2(ix));%find burst border
                burstst2 = wc2(ix,1)-(locs2(ix)-wc2(ix,1));
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
            [~,permmat] = sort(rand(ntrials,length(npks_burst)),2);
            npks_rand = npks_burst(permmat');
            [r p] = corrcoef([npks_rand,gapdur_id]);
            r = r(1:end-1,end);
            p = p(1:end-1,end);
            spk_gapdur_corr_rand = [spk_gapdur_corr_rand r];
            spk_gapdur_pval_rand = [spk_gapdur_pval_rand p];
        end
    end
end
save('shuffledata','spk_gapdur_corr_rand','spk_gapdur_pval_rand');

randnumsignificant = sum(spk_gapdur_pval_rand<=0.05,2);    
randpropsignificant = randnumsignificant/size(spk_gapdur_pval_rand,2);
randpropsignificant_sorted = sort(randpropsignificant);
randpropsignificant_lo = randpropsignificant_sorted(floor(aph*ntrials/2));
randpropsignificant_hi = randpropsignificant_sorted(ceil(ntrials-(aph*ntrials/2)));

randnumsignificantnegcorr = sum((spk_gapdur_pval_rand<=0.05).*(spk_gapdur_corr_rand<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(spk_gapdur_pval_rand,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_lo = randpropsignificantnegcorr_sorted(floor(aph*ntrials/2));
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));

randnumsignificantposcorr = sum((spk_gapdur_pval_rand<=0.05).*(spk_gapdur_corr_rand>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(spk_gapdur_pval_rand,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_lo = randpropsignificantposcorr_sorted(floor(aph*ntrials/2));
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));

disp(['shuffled proportion of cases that are significant (99% CI):',num2str(randpropsignificant_lo),'-',num2str(randpropsignificant_hi)]);%0.034091, 0.069129
disp(['shuffled proportion of cases that are significantly negative corr (99% CI):',num2str(randpropsignificantnegcorr_lo),'-',num2str(randpropsignificantnegcorr_hi)]);%0.013258,0.037879
disp(['shuffled proportion of cases that are significantly positive corr (99% CI):',num2str(randpropsignificantposcorr_lo),'-',num2str(randpropsignificantposcorr_hi)]);%0.014205,0.037879

figure;hold on;[n b] = hist(randpropsignificant,[0:0.001:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificant_hi,y(1),'k^','markersize',8);hold on;
plot(randpropsignificant_lo,y(1),'k^','markersize',8);hold on;
plot(numsignificant/numcases,y(1),'k^','markersize',8,'markerfacecolor','k');hold on;
title('shuffled RA activity vs gap duration correlations');
xlabel('proportion of significant correlations');ylabel('probability');set(gca,'fontweight','bold');

figure;hold on;[n b] = hist(randpropsignificantnegcorr,[0:0.001:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantnegcorr_hi,y(1),'b^','markersize',8);hold on;
plot(randpropsignificantnegcorr_lo,y(1),'b^','markersize',8);hold on;
plot(length(negcorr)/numcases,y(1),'b^','markersize',8,'markerfacecolor','b');hold on;
title('shuffled RA activity vs gap duration correlations');
xlabel('proportion of significantly negative correlations');ylabel('probability');set(gca,'fontweight','bold');

figure;hold on;[n b] = hist(randpropsignificantposcorr,[0:0.001:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantposcorr_lo,y(1),'r^','markersize',8);hold on;
plot(randpropsignificantposcorr_hi,y(1),'r^','markersize',8);hold on;
plot(length(poscorr)/numcases,y(1),'r^','markersize',8,'markerfacecolor','r');hold on;
title('shuffled RA activity vs gap duration correlations');
xlabel('proportion of significantly positive correlations');ylabel('probability');set(gca,'fontweight','bold');
