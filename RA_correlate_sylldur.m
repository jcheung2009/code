config;
%% correlate premotor spikes with sylldur 
%also measure burst alignment with syllon2 or sylloff1 

spk_dur_corr = [];case_name = {};
spk_dur_corr_prev = []; spk_dur_corr_next = [];
prevspk_dur_corr = []; nextspk_dur_corr = [];
win = gausswin(20);%for smoothing spike trains, 20 ms
win = win./sum(win);
seqlen = 6;%4 = 2 syllables before and after target gap
plotcasecondition = 'p(2)<=0.05 & abs(r(2)) >= 0.35';%plot significant and strongly correlated cases 
%plotcasecondition = 'p(2)<= 0.05 & p(2) > 0.05';%not plot anything

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

        %correlate prev dur's activity with target dur
        seqst_prev = ceil(max(seqons(:,seqlen/2)-seqons(:,1)));%boundaries for sequence activity relative to target gap (syllon2)
        seqend_prev = ceil(max(seqoffs(:,end)-seqons(:,seqlen/2)));
        spktms_prev = cell(size(seqons,1),1);%spike times for each trial relative to target syll 
        smooth_spiketrains_prev = zeros(length(dur_id),seqst_prev+seqend_prev+1);
        for m = 1:size(seqons,1)
            temp = zeros(1,seqst_prev+seqend_prev+1);
            x = spiketimes(find(spiketimes>=(seqons(m,seqlen/2)-seqst_prev) & ...
                spiketimes<=(seqons(m,seqlen/2)+seqend_prev)));
            spktms_prev{m} = x - seqons(m,seqlen/2); %spike times aligned by syllon2
            spktimes = round(spktms_prev{m})+seqst_prev+1;
            temp(spktimes) = 1;
            smooth_spiketrains_prev(m,:) = conv(temp,win,'same');
        end
        tb_prev = [-seqst_prev:seqend_prev];
        PSTH_mn_prev = mean(smooth_spiketrains_prev,1).*1000;
        [pks, locs,w,~,wc] = findpeaks2(PSTH_mn_prev,'MinPeakHeight',50,...
            'MinPeakDistance',20,'MinPeakWidth',10,'Annotate','extents');%find bursts in premotor win
        wc = round(wc);
        pkid = find(tb_prev(locs)>=-40 & tb_prev(locs)<=0);
        if ~isempty(pkid)
            burstend = wc(pkid(end),2);
            burstst = wc(pkid(end),1);
            wth = w(pkid(end));
            npks_burst = cellfun(@(x) length(find(x>=tb_prev(burstst)&x<tb_prev(burstend))),spktms_prev);%extract nspks in each trial
            [r5 p5] = corrcoef(npks_burst,dur_id);
            prevspk_dur_corr = [prevspk_dur_corr; r5(2) p5(2)];
        end
        
        %correlate next dur's activity with target dur
        seqst_next = ceil(max(seqons(:,seqlen/2+2)-seqons(:,1)));%boundaries for sequence activity relative to target gap (syllon2)
        seqend_next = ceil(max(seqoffs(:,end)-seqons(:,seqlen/2+2)));
        spktms_next = cell(size(seqons,1),1);%spike times for each trial relative to target syll 
        smooth_spiketrains_next = zeros(length(dur_id),seqst_next+seqend_next+1);
        for m = 1:size(seqons,1)
            temp = zeros(1,seqst_next+seqend_next+1);
            x = spiketimes(find(spiketimes>=(seqons(m,seqlen/2+2)-seqst_next) & ...
                spiketimes<=(seqons(m,seqlen/2+2)+seqend_next)));
            spktms_next{m} = x - seqons(m,seqlen/2+2); %spike times aligned by syllon2
            spktimes = round(spktms_next{m})+seqst_next+1;
            temp(spktimes) = 1;
            smooth_spiketrains_next(m,:) = conv(temp,win,'same');
        end
        tb_next = [-seqst_next:seqend_next];
        PSTH_mn_next = mean(smooth_spiketrains_next,1).*1000;
        [pks, locs,w,~,wc] = findpeaks2(PSTH_mn_next,'MinPeakHeight',50,...
            'MinPeakDistance',20,'MinPeakWidth',10,'Annotate','extents');%find bursts in premotor win
        wc = round(wc);
        pkid = find(tb_next(locs)>=-40 & tb_next(locs)<=0);
        if ~isempty(pkid)
            burstend = wc(pkid(end),2);
            burstst = wc(pkid(end),1);
            wth = w(pkid(end));
            npks_burst = cellfun(@(x) length(find(x>=tb_next(burstst)&x<tb_next(burstend))),spktms_next);%extract nspks in each trial
            [r5 p5] = corrcoef(npks_burst,dur_id);
            nextspk_dur_corr = [nextspk_dur_corr; r5(2) p5(2)];
        end
        
        %correlate current dur's activity with target dur
        seqst = ceil(max(seqons(:,seqlen/2+1)-seqons(:,1)));%boundaries for sequence activity relative to target gap (syllon2)
        seqend = ceil(max(seqoffs(:,end)-seqons(:,seqlen/2+1)));
        spktms = cell(size(seqons,1),1);%spike times for each trial relative to target syll 
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
        durseq = seqoffs-seqons;
        dur_id_prev = durseq(:,seqlen/2);%gapdur of gap before target gap
        dur_id_next = durseq(:,seqlen/2+2);%gapdur of gap after target gap
        for ixx = 1:length(pkid)%for each burst found
            burstend = wc(pkid(ixx),2);
            burstst = wc(pkid(ixx),1);
%             r = xcorr(smooth_spiketrains(:,burstst:burstend)',0,'coeff');
%             r = reshape(r,[size(smooth_spiketrains,1) size(smooth_spiketrains,1)]);
%             r = r(find(triu(r,1)));
%             varburst1 = nanmean(r);%average pairwise correlation of spike trains 
%             %varburst1 = (nanstd(cell2mat(cellfun(@(x) (x(find(x>=tb(burstst)&x<tb(burstend))))',spktms,'un',0))));%variability of spiketimes in burst aligned by on2
% 
%             seqoffs_alignedon2 = seqoffs-seqons(:,seqlen/2+1);
%             anchor=seqoffs_alignedon2(:,seqlen/2);
%             spktms_off1 = arrayfun(@(x) spktms{x}-anchor(x),1:length(spktms),'un',0);%realign spike times in each trial by off1
%             seqst2 = ceil(abs(min([spktms_off1{:}])));
%             seqend2 = ceil(abs(max([spktms_off1{:}])));
%             smooth_spiketrains_off1 = zeros(length(dur_id),seqst2+seqend2+1);
%             for m = 1:length(dur_id)
%                 temp = zeros(1,seqst2+seqend2+1);
%                 spktimes = round(spktms_off1{m})+seqst2+1;
%                 temp(spktimes) = 1;
%                 smooth_spiketrains_off1(m,:) = conv(temp,win,'same');
%             end  
%             tb2 = [-seqst2:seqend2];
%             PSTH_mn_off1 = mean(smooth_spiketrains_off1,1).*1000;
%             [pks2, locs2,w2,~,wc2] = findpeaks2(PSTH_mn_off1,'MinPeakHeight',50,...
%                 'MinPeakDistance',20,'MinPeakWidth',10,'Annotate','extents');
%             if ~isempty(locs2)
%                 wc2 = round(wc2);
%                 [xy,ix] = min(abs(tb2(locs2)-(tb(locs(pkid(ixx)))-mean(anchor))));
%                 burstend2 = wc2(ix,2);%find burst border
%                 burstst2 = wc2(ix,1);
%                 r = xcorr(smooth_spiketrains_off1(:,burstst2:burstend2)',0,'coeff');
%                 r = reshape(r,[size(smooth_spiketrains_off1,1) size(smooth_spiketrains_off1,1)]);
%                 r = r(find(triu(r,1)));
%                 varburst2 = nanmean(r);
%                 %varburst2 = (nanstd(cell2mat(cellfun(@(x) (x(find(x>=tb2(burstst2)&x<tb2(burstend2)))),spktms_off1,'un',0))));%variability of spiketimes in burst aligned by off1
%                 
%                 if varburst1 < varburst2
%                     alignby=2;%off1
%                     wth=w2(ix);
%                     npks_burst = cellfun(@(x) length(find(x>=tb2(burstst2)&x<tb2(burstend2))),spktms_off1);%extract nspks in each trial
%                 else
%                     alignby=1;%on2
%                     wth=w(pkid(ixx));
%                     npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms);%extract nspks in each trial
%                 end
%             else
%                 alignby=1;
%                 wth=w(pkid(ixx));
%                 npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms);%extract nspks in each trial
%             end
            alignby=1;
            wth=w(pkid(ixx));
            npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms);%extract nspks in each trial
            
            [r p] = corrcoef(npks_burst,dur_id);
            spk_dur_corr = [spk_dur_corr; r(2) p(2)];
            [~,stid] = regexp(ff(i).name,'data_');
            enid = regexp(ff(i).name,'_TH');
            unitid = ff(i).name(stid+1:enid-1);
            case_name = [case_name,{unitid,gapids{n}}];
            [r3 p3] = corrcoef(npks_burst,dur_id_prev);
            spk_dur_corr_prev = [spk_dur_corr_prev; r3(2) p3(2)];
            [r4 p4] = corrcoef(npks_burst,dur_id_next);
            spk_dur_corr_next = [spk_dur_corr_next; r4(2) p4(2)];
            
            if eval(plotcasecondition)
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

numcases = length(spk_dur_corr);
numsignificant = length(find(spk_dur_corr(:,2)<=0.05));
disp(['proportion of significant cases = ',num2str(numsignificant),'/',num2str(numcases),' =',num2str(numsignificant/numcases)]);
negcorr = find(spk_dur_corr(:,2)<= 0.05 & spk_dur_corr(:,1)<0);
poscorr = find(spk_dur_corr(:,2)<= 0.05 & spk_dur_corr(:,1)>0);
disp(['proportion of cases that are significantly negatively correlated = ',num2str(length(negcorr)/numcases)]);
disp(['proportion of cases that are positively correlated = ',num2str(length(poscorr)/numcases)]);
disp(['average r value for significant negative correlations = ',num2str(mean(spk_dur_corr(negcorr,1)))]);
disp(['average r value for significant positive correlations = ',num2str(mean(spk_dur_corr(poscorr,1)))]);

%plot distribution of significant correlation coefficients            
ind = find(spk_dur_corr(:,2)<=0.05);
figure;hold on;[n b] = hist(spk_dur_corr(ind,1),[-1:0.1:1]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(mean(spk_dur_corr(negcorr,1)),y(1),'b^','markersize',8);hold on;
plot(mean(spk_dur_corr(poscorr,1)),y(1),'r^','markersize',8);hold on;
title('r values for significant RA activity vs syll duration correlations');
xlabel('correlation coefficient');ylabel('probability');set(gca,'fontweight','bold');
text(0,1,{['total active units:',num2str(numcases)];...
    ['proportion of significant cases:',num2str(numsignificant/numcases)];...
    ['proportion significantly negative:',num2str(length(negcorr)/numcases)];...
    ['proportion significantly positive:',num2str(length(poscorr)/numcases)]},'units','normalized',...
    'verticalalignment','top');

%compare percentage of cases with significant correlations with target syll
%vs prev and next syll for neural activity at target syll
figure;hold on;ax = gca;
[mn1 hi1 lo1] = jc_BootstrapfreqCI(spk_dur_corr_prev(:,2)<=0.05);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_dur_corr(:,2)<=0.05);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(spk_dur_corr_next(:,2)<=0.05);
b=bar(ax,[1 2],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
offset = 0.2222;
errorbar(1-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(1,mn2,hi2-mn2,'r');
errorbar(1+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[1-2*offset 1+2*offset],[0.06703 0.06703],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(spk_dur_corr_prev(:,2)<=0.05 & spk_dur_corr_prev(:,1)<0);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_dur_corr(:,2)<=0.05 & spk_dur_corr(:,1)<0);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(spk_dur_corr_next(:,2)<=0.05 & spk_dur_corr_next(:,1)<0);
b=bar(ax,[2 3],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(2-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(2,mn2,hi2-mn2,'r');
errorbar(2+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[2-2*offset 2+2*offset],[.037412 0.037412],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(spk_dur_corr_prev(:,2)<=0.05 & spk_dur_corr_prev(:,1)>0);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_dur_corr(:,2)<=0.05 & spk_dur_corr(:,1)>0);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(spk_dur_corr_next(:,2)<=0.05 & spk_dur_corr_next(:,1)>0);
b=bar(ax,[3 4],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(3-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(3,mn2,hi2-mn2,'r');
errorbar(3+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[3-2*offset 3+2*offset],[.036633 0.036633],'--','color',[0.5 0.5 0.5]);
xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion of cases with significant correlations');

%compare percentage of cases with significant correlations with
%prev/current/next syll's activity with current sylldur
figure;hold on;ax = gca;
[mn1 hi1 lo1] = jc_BootstrapfreqCI(prevspk_dur_corr(:,2)<=0.05);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_dur_corr(:,2)<=0.05);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(nextspk_dur_corr(:,2)<=0.05);
b=bar(ax,[1 2],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
offset = 0.2222;
errorbar(1-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(1,mn2,hi2-mn2,'r');
errorbar(1+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[1-2*offset 1+2*offset],[0.06703 0.06703],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(prevspk_dur_corr(:,2)<=0.05 & prevspk_dur_corr(:,1)<0);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_dur_corr(:,2)<=0.05 & spk_dur_corr(:,1)<0);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(nextspk_dur_corr(:,2)<=0.05 & nextspk_dur_corr(:,1)<0);
b=bar(ax,[2 3],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(2-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(2,mn2,hi2-mn2,'r');
errorbar(2+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[2-2*offset 2+2*offset],[.037412 0.037412],'--','color',[0.5 0.5 0.5]);

[mn1 hi1 lo1] = jc_BootstrapfreqCI(prevspk_dur_corr(:,2)<=0.05 & prevspk_dur_corr(:,1)>0);
[mn2 hi2 lo2] = jc_BootstrapfreqCI(spk_dur_corr(:,2)<=0.05 & spk_dur_corr(:,1)>0);
[mn3 hi3 lo3] = jc_BootstrapfreqCI(nextspk_dur_corr(:,2)<=0.05 & nextspk_dur_corr(:,1)>0);
b=bar(ax,[3 4],[mn1 mn2 mn3;NaN NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor=[0.5 0.5 0.5];
b(2).FaceColor = 'none';b(2).EdgeColor='r';
b(3).FaceColor = 'none';b(3).EdgeColor=[0.5 0.5 0.5];
errorbar(3-offset,mn1,hi1-mn1,'color',[0.5 0.5 0.5]);
errorbar(3,mn2,hi2-mn2,'r');
errorbar(3+offset,mn3,hi3-mn3,'color',[0.5 0.5 0.5]);
plot(ax,[3-2*offset 3+2*offset],[.036633 0.036633],'--','color',[0.5 0.5 0.5]);
xticks(ax,[1,2,3]);xticklabels({'all','negative','positive'});xlim([0.5 3.5])
ylabel('proportion of cases with significant correlations');
%% shuffle 
ntrials = 1000;aph = 0.01;%99% CI
spk_dur_corr_rand = [];spk_dur_pval_rand=[];
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
        
        spktms = cell(size(seqons,1),1);%spike times for each trial relative to target syll 
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
%             r = xcorr(smooth_spiketrains(:,burstst:burstend)',0,'coeff');
%             r = reshape(r,[size(smooth_spiketrains,1) size(smooth_spiketrains,1)]);
%             r = r(find(triu(r,1)));
%             varburst1 = nanmean(r);%average pairwise correlation of spike trains 
%             %varburst1 = (nanstd(cell2mat(cellfun(@(x) (x(find(x>=tb(burstst)&x<tb(burstend))))',spktms,'un',0))));%variability of spiketimes in burst aligned by on2
% 
%             seqoffs_alignedon2 = seqoffs-seqons(:,seqlen/2+1);
%             anchor=seqoffs_alignedon2(:,seqlen/2);
%             spktms_off1 = arrayfun(@(x) spktms{x}-anchor(x),1:length(spktms),'un',0);%realign spike times in each trial by off1
%             seqst2 = ceil(abs(min([spktms_off1{:}])));
%             seqend2 = ceil(abs(max([spktms_off1{:}])));
%             smooth_spiketrains_off1 = zeros(length(dur_id),seqst2+seqend2+1);
%             for m = 1:length(dur_id)
%                 temp = zeros(1,seqst2+seqend2+1);
%                 spktimes = round(spktms_off1{m})+seqst2+1;
%                 temp(spktimes) = 1;
%                 smooth_spiketrains_off1(m,:) = conv(temp,win,'same');
%             end  
%             tb2 = [-seqst2:seqend2];
%             PSTH_mn_off1 = mean(smooth_spiketrains_off1,1).*1000;
%             [pks2, locs2,w2,~,wc2] = findpeaks2(PSTH_mn_off1,'MinPeakHeight',50,...
%                 'MinPeakDistance',20,'MinPeakWidth',10,'Annotate','extents');
%             if ~isempty(locs2)
%                 wc2 = round(wc2);
%                 [xy,ix] = min(abs(tb2(locs2)-(tb(locs(pkid(ixx)))-mean(anchor))));
%                 burstend2 = wc2(ix,2);%find burst border
%                 burstst2 = wc2(ix,1);
%                 r = xcorr(smooth_spiketrains_off1(:,burstst2:burstend2)',0,'coeff');
%                 r = reshape(r,[size(smooth_spiketrains_off1,1) size(smooth_spiketrains_off1,1)]);
%                 r = r(find(triu(r,1)));
%                 varburst2 = nanmean(r);
%                 %varburst2 = (nanstd(cell2mat(cellfun(@(x) (x(find(x>=tb2(burstst2)&x<tb2(burstend2)))),spktms_off1,'un',0))));%variability of spiketimes in burst aligned by off1
%                 
%                 if varburst1 < varburst2
%                     alignby=2;%off1
%                     wth=w2(ix);
%                     npks_burst = cellfun(@(x) length(find(x>=tb2(burstst2)&x<tb2(burstend2))),spktms_off1);%extract nspks in each trial
%                 else
%                     alignby=1;%on2
%                     wth=w(pkid(ixx));
%                     npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms);%extract nspks in each trial
%                 end
%             else
%                 alignby=1;
%                 wth=w(pkid(ixx));
%                 npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms);%extract nspks in each trial
%             end
            alignby=1;
            wth=w(pkid(ixx));
            npks_burst = cellfun(@(x) length(find(x>=tb(burstst)&x<tb(burstend))),spktms);%extract nspks in each trial
            [~,permmat] = sort(rand(ntrials,length(npks_burst)),2);
            npks_rand = npks_burst(permmat');
            [r p] = corrcoef([npks_rand,dur_id]);
            r = r(1:end-1,end);
            p = p(1:end-1,end);
            spk_dur_corr_rand = [spk_dur_corr_rand r];
            spk_dur_pval_rand = [spk_dur_pval_rand p];
        end
    end
end
randnumsignificant = sum(spk_dur_pval_rand<=0.05,2);    
randpropsignificant = randnumsignificant/size(spk_dur_pval_rand,2);
randpropsignificant_sorted = sort(randpropsignificant);
randpropsignificant_lo = randpropsignificant_sorted(floor(aph*ntrials/2));
randpropsignificant_hi = randpropsignificant_sorted(ceil(ntrials-(aph*ntrials/2)));

randnumsignificantnegcorr = sum((spk_dur_pval_rand<=0.05).*(spk_dur_corr_rand<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(spk_dur_pval_rand,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_lo = randpropsignificantnegcorr_sorted(floor(aph*ntrials/2));
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));

randnumsignificantposcorr = sum((spk_dur_pval_rand<=0.05).*(spk_dur_corr_rand>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(spk_dur_pval_rand,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_lo = randpropsignificantposcorr_sorted(floor(aph*ntrials/2));
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));

disp(['shuffled proportion of cases that are significant (99% CI):',num2str(randpropsignificant_lo),'-',num2str(randpropsignificant_hi)]);%0.034295, 0.06703
disp(['shuffled proportion of cases that are significantly negative corr (99% CI):',num2str(randpropsignificantnegcorr_lo),'-',num2str(randpropsignificantnegcorr_hi)]);%0.014809, 0.037412
disp(['shuffled proportion of cases that are significantly positive corr (99% CI):',num2str(randpropsignificantposcorr_lo),'-',num2str(randpropsignificantposcorr_hi)]);%0.01403, 0.036633

figure;hold on;[n b] = hist(randpropsignificant,[0:0.001:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificant_hi,y(1),'k^','markersize',8);hold on;
plot(randpropsignificant_lo,y(1),'k^','markersize',8);hold on;
plot(numsignificant/numcases,y(1),'k^','markersize',8,'markerfacecolor','k');hold on;
title('shuffled RA activity vs syll duration correlations');
xlabel('proportion of significant correlations');ylabel('probability');set(gca,'fontweight','bold');

figure;hold on;[n b] = hist(randpropsignificantnegcorr,[0:0.001:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantnegcorr_hi,y(1),'b^','markersize',8);hold on;
plot(randpropsignificantnegcorr_lo,y(1),'b^','markersize',8);hold on;
plot(length(negcorr)/numcases,y(1),'b^','markersize',8,'markerfacecolor','b');hold on;
title('shuffled RA activity vs syll duration correlations');
xlabel('proportion of significantly negative correlations');ylabel('probability');set(gca,'fontweight','bold');

figure;hold on;[n b] = hist(randpropsignificantposcorr,[0:0.001:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantposcorr_lo,y(1),'r^','markersize',8);hold on;
plot(randpropsignificantposcorr_hi,y(1),'r^','markersize',8);hold on;
plot(length(poscorr)/numcases,y(1),'r^','markersize',8,'markerfacecolor','r');hold on;
title('shuffled RA activity vs syll duration correlations');
xlabel('proportion of significantly positive correlations');ylabel('probability');set(gca,'fontweight','bold');
