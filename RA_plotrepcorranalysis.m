%params and input
load('rep_correlation1.mat');
activitythresh = 6;%zscore from shuffled

%indices for multi units with detected activity above activitythresh that have
%significant correlations
numcases = length(find(spk_rep_corr(:,6)>=activitythresh & spk_rep_corr(:,8) > 0.01));
numsignificant = length(find(spk_rep_corr(:,6)>=activitythresh & spk_rep_corr(:,2)<=0.05 & spk_rep_corr(:,8) > 0.01));
negcorr = find(spk_rep_corr(:,6)>=activitythresh & spk_rep_corr(:,8) > 0.01 & spk_rep_corr(:,2)<= 0.05 & spk_rep_corr(:,1)<0);
poscorr = find(spk_rep_corr(:,6)>=activitythresh & spk_rep_corr(:,8) > 0.01 & spk_rep_corr(:,2)<= 0.05 & spk_rep_corr(:,1)>0);
sigcorr = find(spk_rep_corr(:,6)>=activitythresh & spk_rep_corr(:,8) > 0.01 & spk_rep_corr(:,2)<= 0.05);
notsigcorr = find(spk_rep_corr(:,6)>=activitythresh & spk_rep_corr(:,8) > 0.01 & spk_rep_corr(:,2)> 0.05);


%indices for single units based on pct_error<=0.01 and above activitythresh that have significant
%correlations
numcases_su = length(find(spk_rep_corr(:,8)<=0.01 & spk_rep_corr(:,6) >= activitythresh));
numsignificant_su = length(find(spk_rep_corr(:,8)<=0.01 & spk_rep_corr(:,2)<=0.05 & spk_rep_corr(:,6) >= activitythresh));
negcorr_su = find(spk_rep_corr(:,8)<=0.01 & spk_rep_corr(:,6) >= activitythresh & spk_rep_corr(:,2)<= 0.05 & spk_rep_corr(:,1)<0);
poscorr_su = find(spk_rep_corr(:,8)<=0.01 & spk_rep_corr(:,6) >= activitythresh & spk_rep_corr(:,2)<= 0.05 & spk_rep_corr(:,1)>0);
sigcorr_su = find(spk_rep_corr(:,8)<=0.01 & spk_rep_corr(:,6) >= activitythresh & spk_rep_corr(:,2)<= 0.05);
notsigcorr_su = find(spk_rep_corr(:,8)<=0.01 & spk_rep_corr(:,6) >= activitythresh & spk_rep_corr(:,2)> 0.05);

singleiind = find(spk_rep_corr(:,8)<=0.01 & spk_rep_corr(:,6) >= activitythresh);
multiind = find(spk_rep_corr(:,6)>=activitythresh & spk_rep_corr(:,8) > 0.01);

%% number of unique active units and birds that went into analysis
case_id = case_name(1:2:end);
case_singleunit_id = unique(case_id(singleiind));
ix = cellfun(@(x) regexp(x,'_'),case_singleunit_id,'un',0);
case_singleunit_birdid = unique(cellfun(@(x,y) x(1:y(1)-1),case_singleunit_id,ix,'un',0));
disp([num2str(length(case_singleunit_id)),' single units in ',...
    num2str(length(case_singleunit_birdid)),' birds'])
case_multiunit_id = unique(case_id(multiind));
ix = cellfun(@(x) regexp(x,'_'),case_multiunit_id,'un',0);
case_multiunit_birdid = unique(cellfun(@(x,y) x(1:y(1)-1),case_multiunit_id,ix,'un',0));
disp([num2str(length(case_multiunit_id)),' multi units in ',...
    num2str(length(case_multiunit_birdid)),' birds'])

%% percentage significant correlations in shuffled (single units)
aph = 0.01;ntrials=1000;
shuffcorr = spk_rep_corr_shuffsu(:,1:3:end);
shuffpval = spk_rep_corr_shuffsu(:,2:3:end);

randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randpropsignificant_lo = randpropsignificant_sorted(floor(aph*ntrials/2));
randpropsignificant_hi = randpropsignificant_sorted(ceil(ntrials-(aph*ntrials/2)));

randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_lo = randpropsignificantnegcorr_sorted(floor(aph*ntrials/2));
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));

randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_lo = randpropsignificantposcorr_sorted(floor(aph*ntrials/2));
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));

figure;subplot(1,3,1);hold on;
[n b] = hist(randpropsignificant,[0:0.005:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificant_hi,y(1),'k^','markersize',8);hold on;
plot(randpropsignificant_lo,y(1),'k^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(spk_rep_corr(singleiind,2)<=0.05);
plot(mn,y(1),'k^','markersize',8,'markerfacecolor','k');hold on;
plot([lo  hi],[y(1) y(1)],'color',[0.5 0.5 0.5],'linewidth',4)
title('shuffled vs empirical single units');
xlabel('proportion of significant correlations');ylabel('probability');set(gca,'fontweight','bold');

subplot(1,3,2);hold on;
[n b] = hist(randpropsignificantnegcorr,[0:0.005:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantnegcorr_hi,y(1),'b^','markersize',8);hold on;
plot(randpropsignificantnegcorr_lo,y(1),'b^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(spk_rep_corr(singleiind,2)<=0.05 & spk_rep_corr(singleiind,1)<0);
plot(mn,y(1),'b^','markersize',8,'markerfacecolor','b');hold on;
plot([lo  hi],[y(1) y(1)],'b','linewidth',4)
title('shuffled vs empirical single units');
xlabel('proportion of significantly negative correlations');ylabel('probability');set(gca,'fontweight','bold');

subplot(1,3,3);hold on;
[n b] = hist(randpropsignificantposcorr,[0:0.005:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantposcorr_lo,y(1),'r^','markersize',8);hold on;
plot(randpropsignificantposcorr_hi,y(1),'r^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(spk_rep_corr(singleiind,2)<=0.05 & spk_rep_corr(singleiind,1)>0);
plot(mn,y(1),'r^','markersize',8,'markerfacecolor','r');hold on;
plot([lo  hi],[y(1) y(1)],'r','linewidth',4)
title('shuffled vs empirical single units');
xlabel('proportion of significantly positive correlations');ylabel('probability');set(gca,'fontweight','bold');

%% percentage significant correlations in shuffled (multi units)
aph = 0.01;ntrials=1000;
shuffcorr = spk_rep_corr_shuff(:,1:3:end);
shuffpval = spk_rep_corr_shuff(:,2:3:end);

randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randpropsignificant_lo = randpropsignificant_sorted(floor(aph*ntrials/2));
randpropsignificant_hi = randpropsignificant_sorted(ceil(ntrials-(aph*ntrials/2)));

randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_lo = randpropsignificantnegcorr_sorted(floor(aph*ntrials/2));
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));

randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_lo = randpropsignificantposcorr_sorted(floor(aph*ntrials/2));
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));

figure;subplot(1,3,1);hold on;
[n b] = hist(randpropsignificant,[0:0.005:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificant_hi,y(1),'k^','markersize',8);hold on;
plot(randpropsignificant_lo,y(1),'k^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(spk_rep_corr(multiind,2)<=0.05);
plot(mn,y(1),'k^','markersize',8,'markerfacecolor','k');hold on;
plot([lo  hi],[y(1) y(1)],'color',[0.5 0.5 0.5],'linewidth',4)
title('shuffled vs empirical multi units');
xlabel('proportion of significant correlations');ylabel('probability');set(gca,'fontweight','bold');

subplot(1,3,2);hold on;
[n b] = hist(randpropsignificantnegcorr,[0:0.005:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantnegcorr_hi,y(1),'b^','markersize',8);hold on;
plot(randpropsignificantnegcorr_lo,y(1),'b^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(spk_rep_corr(multiind,2)<=0.05 & spk_rep_corr(multiind,1)<0);
plot(mn,y(1),'b^','markersize',8,'markerfacecolor','b');hold on;
plot([lo  hi],[y(1) y(1)],'b','linewidth',4)
title('shuffled vs empirical multi units');
xlabel('proportion of significantly negative correlations');ylabel('probability');set(gca,'fontweight','bold');

subplot(1,3,3);hold on;
[n b] = hist(randpropsignificantposcorr,[0:0.005:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantposcorr_lo,y(1),'r^','markersize',8);hold on;
plot(randpropsignificantposcorr_hi,y(1),'r^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(spk_rep_corr(multiind,2)<=0.05 & spk_rep_corr(multiind,1)>0);
plot(mn,y(1),'r^','markersize',8,'markerfacecolor','r');hold on;
plot([lo  hi],[y(1) y(1)],'r','linewidth',4)
title('shuffled vs empirical multi units');
xlabel('proportion of significantly positive correlations');ylabel('probability');set(gca,'fontweight','bold');



