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


%plot cases that were significantly positive with fr 
poscorr_fr = find(gap_singlefr.pkactivity>=activitythresh & ...
    [gap_singlefr.durcorr{:,2}]'<=0.05 & [gap_singlefr.durcorr{:,1}]'>0);
poscorr_fr = gap_singlefr(poscorr_fr,{'unitid','seqid','burstid','durcorr'});

id = [];
for i = 1:size(poscorr_fr,1)
    [~,ind] = intersect(gap_singleifr(:,{'unitid','seqid'}),poscorr_fr(i,{'unitid','seqid'}));
    if isempty(ind)
        continue
    end
    id = [id;ind];
end
x = gap_singleifr(id,{'unitid','seqid','burstid'});
RA_correlate_gapdur_plot('singleunits',x,-40,'burst','gap')

%% multi vs single
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
plot(corrtable{sigcorr,{'bgactivity'}},[corrtable{sigcorr,{'durcorr'}}{:,1}],'r.')
figure;hold on;
plot(corrtable{sigcorr,{'latency'}}(:,1),[corrtable{sigcorr,{'durcorr'}}{:,1}],'r.')


x = table(corrtable{negcorr,{'trialbytrialcorr'}},corrtable{negcorr,{'ntrials'}},...
    corrtable{negcorr,{'pct_error'}},[corrtable{negcorr,{'durcorr'}}{:,1}]',...
    'VariableNames',{'trialbytrialcorr','ntrials','pct_error','corrval'});


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
plot(corrtable{sigcorr,{'trialbytrialcorr'}},[corrtable{sigcorr,{'durcorr'}}{:,1}],'k.')
figure;hold on;
plot(corrtable{negcorr,{'trialbytrialcorr'}},[corrtable{negcorr,{'durcorr'}}{:,1}],'k.')
[r p] = corrcoef(corrtable{negcorr,{'trialbytrialcorr'}},[corrtable{negcorr,{'durcorr'}}{:,1}])
figure;hold on;
plot(corrtable{poscorr,{'trialbytrialcorr'}},[corrtable{poscorr,{'durcorr'}}{:,1}],'k.')
[r p] = corrcoef(corrtable{poscorr,{'trialbytrialcorr'}},[corrtable{poscorr,{'durcorr'}}{:,1}])



x = [x; table(corrtable{negcorr,{'trialbytrialcorr'}},corrtable{negcorr,{'ntrials'}},...
    corrtable{negcorr,{'pct_error'}},[corrtable{negcorr,{'durcorr'}}{:,1}]',...
    'VariableNames',{'trialbytrialcorr','ntrials','pct_error','corrval'})];

formula = 'corrval ~ pct_error + ntrials';
mdl = fitlme(x,formula)
