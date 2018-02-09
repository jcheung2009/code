%params and input
load('gap_correlation_analysis_singleunits.mat');
activitythresh = 6;%zscore from shuffled
overlap = 0.02;%percent overlap threshold for single vs multi unit 

%indices for units with activity above activitythresh that have
%significant correlations
negcorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'<0);
poscorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'>0);
sigcorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05);
notsigcorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'>0.05);
activecases = find(corrtable.pkactivity>=activitythresh);
numcases = length(activecases);
numsignificant = length(find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05));

%% number of unique active units and birds that went into analysis
disp([num2str(length(unique(corrtable(activecases,:).unitid))),' single units in ',...
    num2str(length(unique(corrtable(activecases,:).birdid))),' birds']);

%% distribution of correlations 
aph = 0.01;ntrials=1000;
shuffcorr = [corrtable(activecases,:).durcorr{:,3}];
shuffpval = [corrtable(activecases,:).durcorr{:,4}];

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

randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);

figure;hold on;
[n b] = hist(shuffcorr(:),[-1:0.05:1]);
stairs(b,n/sum(n),'k','linewidth',2);
[n b] = hist([corrtable(activecases,:).durcorr{:,1}],[-1:0.05:1]);
stairs(b,n/sum(n),'r','linewidth',2);y=get(gca,'ylim');
plot(mean([corrtable(activecases,:).durcorr{:,1}]),y(1),'r^','markersize',8);hold on;
plot(mean(shuffcorr(:)),y(1),'k^','markersize',8);hold on;
xlabel('correlation coefficient');ylabel('probability');set(gca,'fontweight','bold');
[h p] = vartest2([corrtable(activecases,:).durcorr{:,1}],shuffcorr(:));
[h p2] = ttest2([corrtable(activecases,:).durcorr{:,1}],shuffcorr(:));
[h p3] = kstest2([corrtable(activecases,:).durcorr{:,1}],shuffcorr(:));
p4 = length(find(randdiffprop>=abs((length(negcorr)/numcases)-(length(poscorr)/numcases))))/ntrials;
p5 = length(find(randpropsignificant>=length(sigcorr)/numcases))/ntrials;
p6 = length(find(randpropsignificantposcorr>=length(poscorr)/numcases))/ntrials;
p7 = length(find(randpropsignificantnegcorr>=length(negcorr)/numcases))/ntrials;
text(0,1,{['total active cases:',num2str(numcases)];...
['proportion significant cases:',num2str(numsignificant/numcases)];...
['proportion significantly negative:',num2str(length(negcorr)/numcases)];...
['proportion significantly positive:',num2str(length(poscorr)/numcases)];...
['p(F)=',num2str(p)];['p(t)=',num2str(p2)];['p(ks)=',num2str(p3)];...
['p(sig)=',num2str(p5)];['p(neg)=',num2str(p7)];['p(pos)=',num2str(p6)];...
['p(neg-pos)=',num2str(p4)]},'units','normalized',...
'verticalalignment','top');

%% distribution of proportions 
figure;subplot(1,3,1);hold on;
[n b] = hist(randpropsignificant,[0:0.01:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificant_hi,y(1),'k^','markersize',8);hold on;
plot(randpropsignificant_lo,y(1),'k^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI([corrtable(activecases,:).durcorr{:,2}]'<=0.05);
plot(mn,y(1),'k^','markersize',8,'markerfacecolor','k');hold on;
plot([lo  hi],[y(1) y(1)],'color',[0.5 0.5 0.5],'linewidth',4)
title('shuffled vs empirical');
xlabel('proportion of significant correlations');ylabel('probability');
set(gca,'fontweight','bold');

subplot(1,3,2);hold on;
[n b] = hist(randpropsignificantnegcorr,[0:0.01:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantnegcorr_hi,y(1),'b^','markersize',8);hold on;
plot(randpropsignificantnegcorr_lo,y(1),'b^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI([corrtable(activecases,:).durcorr{:,2}]'<=0.05 & ...
    [corrtable(activecases,:).durcorr{:,1}]'<0);
plot(mn,y(1),'b^','markersize',8,'markerfacecolor','b');hold on;
plot([lo  hi],[y(1) y(1)],'b','linewidth',4)
title('shuffled vs empirical');
xlabel('proportion of significantly negative correlations');ylabel('probability');
set(gca,'fontweight','bold');

subplot(1,3,3);hold on;
[n b] = hist(randpropsignificantposcorr,[0:0.01:0.25]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(randpropsignificantposcorr_lo,y(1),'r^','markersize',8);hold on;
plot(randpropsignificantposcorr_hi,y(1),'r^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI([corrtable(activecases,:).durcorr{:,2}]'<=0.05 & ...
    [corrtable(activecases,:).durcorr{:,1}]'>0);
plot(mn,y(1),'r^','markersize',8,'markerfacecolor','r');hold on;
plot([lo  hi],[y(1) y(1)],'r','linewidth',4)
title('shuffled vs empirical');
xlabel('proportion of significantly positive correlations');ylabel('probability');
set(gca,'fontweight','bold');

%% comparing sample sizes for cases that are negative vs positively correlated 
%(regardless of significance)
negsampsize = corrtable([corrtable.durcorr{:,1}]'<0,:).ntrials;
possampsize = corrtable([corrtable.durcorr{:,1}]'>0,:).ntrials;activecases  = find(dattable.activity>=activitythresh);
maxsize = max([negsampsize;possampsize]);
figure;hold on;
[n b] = hist(negsampsize,[25:10:maxsize+5])
stairs(b,n/sum(n),'b','linewidth',2);hold on;
[n b] = hist(possampsize,[25:10:maxsize+5]);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
xlabel('sample size');ylabel('counts');
legend({'negative','positive'});
y = get(gca,'ylim');
plot(median(negsampsize),y(1),'b^');hold on;
plot(median(possampsize),y(1),'r^');hold on;
p = ranksum(negsampsize,possampsize);
text(0,1,{['p=',num2str(p)]},'units','normalized');
set(gca,'fontweight','bold');


%% mixed model IFR ~ DUR 
activecases  = find(dattable.activity>=activitythresh);
subset = dattable(activecases,:);
cases = unique(subset(:,{'unitid','seqid','burstid'}));
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    dur = subset(ind,:).dur;
    dur = (dur-mean(dur))/std(dur);
    subset(ind,:).dur = dur;
end

%test whether to add random effect of seqid on intercept. Yes
formula = 'spikes ~ dur + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>150);

%test whether to add random effect of seqid on slope. Yes (BIC is lower
%with independent estimation)
formula = 'spikes ~ dur + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on intercept. Yes 
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on slope. No 
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid) + (dur-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)


%final model, significant negative beta for dur 
formula = 'spikes ~ dur + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (1|unitid)';
mdl = fitlme(subset,formula,'exclude',i);
mdl.Rsquared

%% mixed model IFR ~ DUR + Vol1 + Vol2
activecases  = find(dattable.activity>=activitythresh);
subset = dattable(activecases,:);
cases = unique(subset(:,{'unitid','seqid','burstid'}));
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    dur = subset(ind,:).dur;
    dur = (dur-mean(dur))/std(dur);
    dur1 = subset(ind,:).dur1;
    dur1 = (dur1-mean(dur1))/std(dur1);
    dur2 = subset(ind,:).dur2;
    dur2 = (dur2-mean(dur2))/std(dur2);
    vol1 = subset(ind,:).vol1;
    vol1 = (vol1-mean(vol1))/std(vol1);
    vol2 = subset(ind,:).vol2;
    vol2 = (vol2-mean(vol2))/std(vol2);
    subset(ind,:).vol1 = vol1;
    subset(ind,:).vol2 = vol2;
    subset(ind,:).dur = dur;
    subset(ind,:).dur1 = dur1;
    subset(ind,:).dur2 = dur2;
end

%test whether to add random effect of seqid on intercept. Yes. CI for
%random effect on intercept is above 0 
%intercept
formula = 'spikes ~ dur + vol1 + vol2 + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>150);%outliers

%test whether to add random effect of seqid on dur slope. Yes. 
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on vol1 slope. Yes. BIC is lower when dur and vol are estimated together 
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on vol2 slope. Yes
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on intercept. Yes
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on dur slope. No
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid) + (dur-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on vol1 slope. No
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid) + (vol1-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on vol2 slope. Yes
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid) + (vol2-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%final model: dur is still negatively correlated, vol2 is positively
%correlated 
formula = 'spikes ~ dur + vol1 + vol2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid) + (vol2-1|unitid)';
mdl = fitlme(subset,formula,'exclude',i);
mdl.Rsquared

%% mixed model IFR ~ dur + dur1 + dur2
activecases  = find(dattable.activity>=activitythresh);
subset = dattable(activecases,:);
cases = unique(subset(:,{'unitid','seqid','burstid'}));
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    dur = subset(ind,:).dur;
    dur = (dur-mean(dur))/std(dur);
    dur1 = subset(ind,:).dur1;
    dur1 = (dur1-mean(dur1))/std(dur1);
    dur2 = subset(ind,:).dur2;
    dur2 = (dur2-mean(dur2))/std(dur2);
    vol1 = subset(ind,:).vol1;
    vol1 = (vol1-mean(vol1))/std(vol1);
    vol2 = subset(ind,:).vol2;
    vol2 = (vol2-mean(vol2))/std(vol2);
    subset(ind,:).vol1 = vol1;
    subset(ind,:).vol2 = vol2;
    subset(ind,:).dur = dur;
    subset(ind,:).dur1 = dur1;
    subset(ind,:).dur2 = dur2;
end

%test whether to add random effect of seqid on intercept. Yes.
%intercept
formula = 'spikes ~ dur + dur1 + dur2 + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>150);%outliers

%test whether to add random effect of seqid on dur slope. Yes. 
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on dur1 slope. Yes. 
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on dur2 slope. Yes. 
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on intercept. Yes. 
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on dur slope. No. 
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid) + (dur-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on dur1 slope. No. 
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid) + (dur1-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on dur2 slope. No. 
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid) + (dur2-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%final model: significant  negative correlation with dur but not with dur1
%or dur2
formula = 'spikes ~ dur + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid) + (dur1-1|unitid:seqid) + (dur2-1|unitid:seqid) + (1|unitid)';
mdl = fitlme(subset,formula,'exclude',i);
mdl.Rsquared

%% mixed model IFR ~ dur + vol1 + vol2 + dur1 + dur2
activecases  = find(dattable.activity>=activitythresh);
subset = dattable(activecases,:);
cases = unique(subset(:,{'unitid','seqid','burstid'}));
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    dur = subset(ind,:).dur;
    dur = (dur-mean(dur))/std(dur);
    dur1 = subset(ind,:).dur1;
    dur1 = (dur1-mean(dur1))/std(dur1);
    dur2 = subset(ind,:).dur2;
    dur2 = (dur2-mean(dur2))/std(dur2);
    vol1 = subset(ind,:).vol1;
    vol1 = (vol1-mean(vol1))/std(vol1);
    vol2 = subset(ind,:).vol2;
    vol2 = (vol2-mean(vol2))/std(vol2);
    subset(ind,:).vol1 = vol1;
    subset(ind,:).vol2 = vol2;
    subset(ind,:).dur = dur;
    subset(ind,:).dur1 = dur1;
    subset(ind,:).dur2 = dur2;
end

%test whether to add random effect of seqid on intercept. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>150);%outliers

%test whether to add random effect of seqid on dur slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on vol1 slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on vol2 slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on dur1 slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of seqid on dur2 slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on intercept. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on dur slope. No.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (dur-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on vol1 slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on vol2 slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1-1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on dur1 slope. No.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2-1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2+dur1-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on dur2 slope. Yes.
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2-1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2+dur2-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%final model: only dur is signficantly correlated
formula = 'spikes ~ dur + vol1 + vol2 + dur1 + dur2 + burstid + (1|unitid:seqid) + (dur+vol1+vol2+dur1+dur2-1|unitid:seqid) + (1|unitid) + (vol1+vol2+dur2-1|unitid)';
mdl = fitlme(subset,formula,'exclude',i);
mdl.Rsquared
figure;plotResiduals(mdl,'fitted')

%% mixed model IFR ~ vol1 
activecases  = find(dattable.activity>=activitythresh);
subset = dattable(activecases,:);
cases = unique(subset(:,{'unitid','seqid','burstid'}));
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    dur = subset(ind,:).dur;
    dur = (dur-mean(dur))/std(dur);
    dur1 = subset(ind,:).dur1;
    dur1 = (dur1-mean(dur1))/std(dur1);
    dur2 = subset(ind,:).dur2;
    dur2 = (dur2-mean(dur2))/std(dur2);
    vol1 = subset(ind,:).vol1;
    vol1 = (vol1-mean(vol1))/std(vol1);
    vol2 = subset(ind,:).vol2;
    vol2 = (vol2-mean(vol2))/std(vol2);
    subset(ind,:).vol1 = vol1;
    subset(ind,:).vol2 = vol2;
    subset(ind,:).dur = dur;
    subset(ind,:).dur1 = dur1;
    subset(ind,:).dur2 = dur2;
end

%test whether to add random effect of seqid on intercept. Yes
formula = 'spikes ~ vol1 + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>150);

%test whether to add random effect of seqid on vol1. Yes
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on intercept. Yes
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on vol1. Yes
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid) + (1|unitid) + (vol1-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%final model
formula = 'spikes ~ vol1 + burstid + (1|unitid:seqid) + (vol1-1|unitid:seqid) + (1|unitid) + (vol1-1|unitid)';
mdl = fitlme(subset,formula,'exclude',i)
mdl.Rsquared

%% %% mixed model IFR ~ vol2
activecases  = find(dattable.activity>=activitythresh);
subset = dattable(activecases,:);
cases = unique(subset(:,{'unitid','seqid','burstid'}));
for i = 1:size(cases,1)
    ind = find(strcmp(subset.unitid,cases(i,:).unitid) & strcmp(subset.seqid,cases(i,:).seqid) & subset.burstid==cases(i,:).burstid);
    dur = subset(ind,:).dur;
    dur = (dur-mean(dur))/std(dur);
    dur1 = subset(ind,:).dur1;
    dur1 = (dur1-mean(dur1))/std(dur1);
    dur2 = subset(ind,:).dur2;
    dur2 = (dur2-mean(dur2))/std(dur2);
    vol1 = subset(ind,:).vol1;
    vol1 = (vol1-mean(vol1))/std(vol1);
    vol2 = subset(ind,:).vol2;
    vol2 = (vol2-mean(vol2))/std(vol2);
    subset(ind,:).vol1 = vol1;
    subset(ind,:).vol2 = vol2;
    subset(ind,:).dur = dur;
    subset(ind,:).dur1 = dur1;
    subset(ind,:).dur2 = dur2;
end

%test whether to add random effect of seqid on intercept. Yes
formula = 'spikes ~ vol2 + burstid';
mdl1 = fitlme(subset,formula);
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid)';
mdl2 = fitlme(subset,formula);
compare(mdl1,mdl2,'CheckNesting',true)

figure;plotResiduals(mdl2,'fitted');
i = find(residuals(mdl2)>150);

%test whether to add random effect of seqid on vol1. Yes
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid) + (vol2-1|unitid:seqid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on intercept. Yes
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid) + (vol2-1|unitid:seqid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%test whether to add random effect of unitid on vol1. Yes
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid)';
mdl1 = fitlme(subset,formula,'exclude',i);
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid) + (vol2-1|unitid)';
mdl2 = fitlme(subset,formula,'exclude',i);
compare(mdl1,mdl2,'CheckNesting',true)

%final model
formula = 'spikes ~ vol2 + burstid + (1|unitid:seqid) + (vol2-1|unitid:seqid) + (1|unitid) + (vol2-1|unitid)';
mdl = fitlme(subset,formula,'exclude',i)
mdl.Rsquared