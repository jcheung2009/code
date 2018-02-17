%% differences between IFR vs FR single units for gaps
%plot cases that were active with fr but not with ifr 
activitythresh = 6;
load('gap_correlation_analysis_singleunits_ifr.mat');
gap_singleifr = corrtable; 
load('gap_correlation_analysis_singleunits_fr.mat');
gap_singlefr = corrtable; 

activecases_ifr = find(gap_singleifr.pkactivity>=activitythresh);
activecases_ifr = gap_singleifr(activecases_ifr,{'unitid','seqid','durcorr','burstid','pkactivity'});

activecases_fr = find(gap_singlefr.pkactivity>=activitythresh);
activecases_fr = gap_singlefr(activecases_fr,{'unitid','seqid','durcorr','burstid','pkactivity'});

[x ix] = setdiff(activecases_fr(:,{'unitid','seqid'}),activecases_ifr(:,{'unitid','seqid'}));
x = activecases_fr(ix,{'unitid','seqid','burstid'});

RA_correlate_gapdur_plot('singleunits',x,-40,'burst','gap')


%plot cases that were significantly positive with either FR or IFR 
poscorr_fr = find(gap_singlefr.pkactivity>=activitythresh & ...
    [gap_singlefr.durcorr{:,2}]'<=0.05 & [gap_singlefr.durcorr{:,1}]'>0);
poscorr_fr = gap_singlefr(poscorr_fr,{'unitid','seqid','burstid','durcorr'});

poscorr_ifr = find(gap_singleifr.pkactivity>=activitythresh & ...
    [gap_singleifr.durcorr{:,2}]'<=0.05 & [gap_singleifr.durcorr{:,1}]'>0);
poscorr_ifr = gap_singleifr(poscorr_ifr,{'unitid','seqid','burstid','durcorr'});
[~,ia,ib] = setxor(poscorr_ifr(:,{'unitid','seqid'}),poscorr_fr(:,{'unitid','seqid'}));

x = [poscorr_ifr(ia,{'unitid','seqid','burstid'});poscorr_fr(ib,{'unitid','seqid','burstid'})];
RA_correlate_gapdur_plot('singleunits',x,-40,'burst','gap')

%plot cases that were significantly negative with ifr 
negcorr_ifr = find(gap_singleifr.pkactivity>=activitythresh & ...
    [gap_singleifr.durcorr{:,2}]'<=0.05 & [gap_singleifr.durcorr{:,1}]'<0);
negcorr_ifr = gap_singleifr(negcorr_ifr,{'unitid','seqid','burstid','durcorr'});

negcorr_fr = find(gap_singlefr.pkactivity>=activitythresh & ...
    [gap_singlefr.durcorr{:,2}]'<=0.05 & [gap_singlefr.durcorr{:,1}]'<0);
negcorr_fr = gap_singlefr(negcorr_fr,{'unitid','seqid','burstid','durcorr'});

[~,ia,ib] = setxor(negcorr_ifr(:,{'unitid','seqid'}),negcorr_fr(:,{'unitid','seqid'}));

x = [negcorr_ifr(ia,{'unitid','seqid','burstid'});negcorr_fr(ib,{'unitid','seqid','burstid'})];
RA_correlate_gapdur_plot('singleunits',negcorr_fr,-40,'burst','gap')


%% multi vs single
%plot distribution of percent error
ff = load_batchf('batchfile');
clustererr = [];
for i = 1:length(ff)
    load(ff(i).name);
    clustererr = [clustererr; mean(pct_error) pct_ISIs_leq_1ms(end)];
end
[n b] = hist(clustererr(:,1),[0:0.005:0.16]);
figure;hold on;
stairs(b,n,'k');hold on;
xlabel('cluster error');ylabel('counts');
mdl = fitgmdist(clustererr(:,1),2);
classes = cluster(mdl,clustererr(:,1));
[n b] = hist(clustererr(classes==1,1),[0:0.005:0.16]);hold on;
stairs(b,n,'r');hold on;
[n b] = hist(clustererr(classes==2,1),[0:0.005:0.16]);hold on;
stairs(b,n,'b');hold on;

%plot distribution of average trial by trial variability for gap single vs
%multi unit bursts
load('gap_correlation_analysis_singleunits_ifr.mat');
singleunits = corrtable;
load('gap_correlation_analysis_multiunits_ifr.mat');
multiunits = corrtable;
allunits = [singleunits;multiunits];
[n b] = hist(allunits.trialbytrialcorr,[0:0.02:1]);
figure;hold on;
stairs(b,n/sum(n),'k');hold on;
[n b] = hist(singleunits.trialbytrialcorr,[0:0.02:1]);
stairs(b,n/sum(n),'r');hold on;
[n b] = hist(multiunits.trialbytrialcorr,[0:0.02:1]);
stairs(b,n/sum(n),'b');hold on;
xlabel('average trial by trial correlation');ylabel('probability');
title('gap bursts');

load('dur_correlation_analysis_singleunits_ifr.mat');
singleunits = corrtable;
load('dur_correlation_analysis_multiunits_ifr.mat');
multiunits = corrtable;
allunits = [singleunits;multiunits];
[n b] = hist(allunits.trialbytrialcorr,[0:0.05:1]);
figure;hold on;
stairs(b,n/sum(n),'k');hold on;
[n b] = hist(singleunits.trialbytrialcorr,[0:0.05:1]);
stairs(b,n/sum(n),'r');hold on;
[n b] = hist(multiunits.trialbytrialcorr,[0:0.05:1]);
stairs(b,n/sum(n),'b');hold on;
xlabel('average trial by trial correlation');ylabel('probability');
title('syll bursts');




%plot average pairwise trial variability vs correlation
load('gap_correlation_analysis_multiunits_ifr.mat');
activecases = find(corrtable.pkactivity>=activitythresh);
sigcorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05);
negcorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'<0);
poscorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'>0);
figure;hold on;
plot(corrtable{activecases,{'trialbytrialcorr'}},[corrtable{activecases,{'durcorr'}}{:,1}],'k.')
figure;hold on;
plot(corrtable{sigcorr,{'trialbytrialcorr'}},[corrtable{sigcorr,{'durcorr'}}{:,1}],'k.')
figure;hold on;
plot(corrtable{negcorr,{'trialbytrialcorr'}},[corrtable{negcorr,{'durcorr'}}{:,1}],'k.')
[r p] = corrcoef(corrtable{negcorr,{'trialbytrialcorr'}},[corrtable{negcorr,{'durcorr'}}{:,1}])
figure;hold on;
plot(corrtable{poscorr,{'trialbytrialcorr'}},[corrtable{poscorr,{'durcorr'}}{:,1}],'k.')
[r p] = corrcoef(corrtable{poscorr,{'trialbytrialcorr'}},[corrtable{poscorr,{'durcorr'}}{:,1}])
figure;hold on;
plot(corrtable{negcorr,{'pct_error'}},[corrtable{negcorr,{'durcorr'}}{:,1}],'k.')
[r p] = corrcoef(corrtable{negcorr,{'pct_error'}},[corrtable{negcorr,{'durcorr'}}{:,1}])
figure;hold on;
plot(corrtable{sigcorr,{'bgactivity'}},[corrtable{sigcorr,{'durcorr'}}{:,1}],'k.')
figure;hold on;
plot(corrtable{sigcorr,{'latency'}}(:,1),[corrtable{sigcorr,{'durcorr'}}{:,1}],'r.')


x = table(corrtable{negcorr,{'trialbytrialcorr'}},corrtable{negcorr,{'ntrials'}},...
    corrtable{negcorr,{'pct_error'}},corrtable{negcorr,{'bgactivity'}},...
    [corrtable{negcorr,{'latency'}}(:,1)],[corrtable{negcorr,{'durcorr'}}{:,1}]',...
    'VariableNames',{'trialbytrialcorr','ntrials','pct_error','bgactivity',...
    'latency','corrval'});


load('gap_correlation_analysis_singleunits_ifr.mat');
activecases = find(corrtable.pkactivity>=activitythresh);
sigcorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05);
negcorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'<0);
poscorr = find(corrtable.pkactivity>=activitythresh & ...
    [corrtable.durcorr{:,2}]'<=0.05 & [corrtable.durcorr{:,1}]'>0);
figure;hold on;
plot(corrtable{activecases,{'trialbytrialcorr'}},[corrtable{activecases,{'durcorr'}}{:,1}],'k.')
figure;hold on;
plot(corrtable{sigcorr,{'trialbytrialcorr'}},[corrtable{sigcorr,{'durcorr'}}{:,1}],'r.')
figure;hold on;
plot(corrtable{negcorr,{'trialbytrialcorr'}},[corrtable{negcorr,{'durcorr'}}{:,1}],'r.')
[r p] = corrcoef(corrtable{negcorr,{'trialbytrialcorr'}},[corrtable{negcorr,{'durcorr'}}{:,1}])
figure;hold on;
plot(corrtable{poscorr,{'trialbytrialcorr'}},[corrtable{poscorr,{'durcorr'}}{:,1}],'k.')
[r p] = corrcoef(corrtable{poscorr,{'trialbytrialcorr'}},[corrtable{poscorr,{'durcorr'}}{:,1}])



x = [x; table(corrtable{negcorr,{'trialbytrialcorr'}},corrtable{negcorr,{'ntrials'}},...
    corrtable{negcorr,{'pct_error'}},corrtable{negcorr,{'bgactivity'}},...
    [corrtable{negcorr,{'latency'}}(:,1)],[corrtable{negcorr,{'durcorr'}}{:,1}]',...
    'VariableNames',{'trialbytrialcorr','ntrials','pct_error','bgactivity',...
    'latency','corrval'})];

formula = 'corrval ~ pct_error + ntrials + trialbytrialcorr + bgactivity + latency';
mdl = fitlme(x,formula)


load('gap_correlation_analysis_multiunits_ifr.mat');
activecases = find(corrtable.pkactivity>=activitythresh);
multigap = corrtable(activecases,:);
load('gap_correlation_analysis_singleunits_ifr.mat');
activecases = find(corrtable.pkactivity>=activitythresh);
singlegap = corrtable(activecases,:);

[h p] = ttest2(multigap.bgactivity,singlegap.bgactivity)
figure;hold on;
[n b] = hist([multigap{:,{'bgactivity'}}],[-14:0.5:0]);
stairs(b,n/sum(n),'k');hold on;
[n b] = hist([singlegap{:,{'bgactivity'}}],[-14:0.5:0]);
stairs(b,n/sum(n),'r')


[h p] = ttest2(multigap.trialbytrialcorr,singlegap.trialbytrialcorr)
figure;hold on;
[n b] = hist([multigap{:,{'trialbytrialcorr'}}],[0:0.02:1]);
stairs(b,n,'k');hold on;
[n b] = hist([singlegap{:,{'trialbytrialcorr'}}],[0:0.02:1]);
stairs(b,n,'r')

load('gap_correlation_analysis_multiunits_ifr.mat');
activecases = find(corrtable.pkactivity>=activitythresh & corrtable.trialbytrialcorr>=0.85);
multigap = corrtable(activecases,:);
load('gap_correlation_analysis_singleunits_ifr.mat');
activecases = find(corrtable.pkactivity>=activitythresh & corrtable.trialbytrialcorr>=0.85);
singlegap = corrtable(activecases,:);

corrtable = [multigap;singlegap];

