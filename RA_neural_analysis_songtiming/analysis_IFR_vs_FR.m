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


