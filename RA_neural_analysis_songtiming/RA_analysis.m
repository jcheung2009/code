%analysis scripts for correlating RA activity and gap/syll durations with
%various different parameters 

%for paper, core analysis uses gap_multicorrelation_analysis_fr.mat and 
%dur_multicorrelation_analysis_fr.mat and using corrtable10 (10 ms conv
%window)

%% n-lag trial correlation and shifted-window correlation for gap analysis

[crosscorr crosscorr_lags crosscorr_shuff] = RA_crosscorrelate_gapdur('batchfile',6,25,50,[-300 300],0,'burst',0,10,'gap');
save('gap_multicorrelation_analysis_fr.mat','crosscorr','crosscorr_lags','crosscorr_shuff','-append');

[~,~,trialcorr]=RA_correlate_gapdur('singleunits_leq_1pctISI_2pcterr',6,25,50,-40,0,0,'n','burst',0,10,'gap','volume');
save('gap_multicorrelation_analysis_fr.mat','trialcorr','-append');


%% multiple regression controlling for volume of neighboring sylls for each individual case
%test different conv window size, IFR vs FR, burst vs spikes
[corrtable5 dattable5]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','burst',1,5,'gap','volume');
[corrtable10 dattable10]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','burst',1,10,'gap','volume');
[corrtable20 dattable20]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','burst',1,20,'gap','volume');
save('gap_multicorrelation_analysis_ifr','corrtable5','dattable5','corrtable10',...
    'dattable10','corrtable20','dattable20');

[corrtable5 dattable5]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','burst',1,5,'syll','volume');
[corrtable10 dattable10]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','burst',1,10,'syll','volume');
[corrtable20 dattable20]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','burst',1,20,'syll','volume');
save('dur_multicorrelation_analysis_ifr','corrtable5','dattable5','corrtable10',...
    'dattable10','corrtable20','dattable20');

[corrtable5 dattable5]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','spikes',1,5,'gap','volume');
[corrtable10 dattable10]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','spikes',1,10,'gap','volume');
[corrtable20 dattable20]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','spikes',1,20,'gap','volume');
save('gap_multicorrelation_analysis_ifr_spks','corrtable5','dattable5','corrtable10',...
    'dattable10','corrtable20','dattable20');


[corrtable5 dattable5]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','spikes',1,5,'syll','volume');
[corrtable10 dattable10]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','spikes',1,10,'syll','volume');
[corrtable20 dattable20]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','spikes',1,20,'syll','volume');
save('dur_multicorrelation_analysis_ifr_spks','corrtable5','dattable5','corrtable10',...
    'dattable10','corrtable20','dattable20');


[corrtable5 dattable5]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','burst',0,5,'gap','volume');
[corrtable10 dattable10]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','burst',0,10,'gap','volume');
[corrtable20 dattable20]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','burst',0,20,'gap','volume');
save('gap_multicorrelation_analysis_fr','corrtable5','dattable5','corrtable10',...
    'dattable10','corrtable20','dattable20');


[corrtable5 dattable5]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','burst',0,5,'syll','volume');
[corrtable10 dattable10]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','burst',0,10,'syll','volume');
[corrtable20 dattable20]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','burst',0,20,'syll','volume');
save('dur_multicorrelation_analysis_fr','corrtable5','dattable5','corrtable10',...
    'dattable10','corrtable20','dattable20');


[corrtable5 dattable5]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','spikes',0,5,'gap','volume');
[corrtable10 dattable10]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','spikes',0,10,'gap','volume');
[corrtable20 dattable20]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','spikes',0,20,'gap','volume');
save('gap_multicorrelation_analysis_fr_spks','corrtable5','dattable5','corrtable10',...
    'dattable10','corrtable20','dattable20');


[corrtable5 dattable5]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','spikes',0,5,'syll','volume');
[corrtable10 dattable10]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','spikes',0,10,'syll','volume');
[corrtable20 dattable20]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','spikes',0,20,'syll','volume');
save('dur_multicorrelation_analysis_fr_spks','corrtable5','dattable5','corrtable10',...
    'dattable10','corrtable20','dattable20');

%% gap and syll correlation analysis for multiple regression controlling for 
%duration of neighboring syllables
%params: 10 ms window, FR, bursts 

[corrtable10 dattable10,trialcorr]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','burst',0,10,'gap','duration');
save('gap_correlation_analysis_control_dur','corrtable10','dattable10','trialcorr');

[corrtable10 dattable10,trialcorr]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','burst',0,10,'syll','duration');
save('dur_correlation_analysis_control_dur','corrtable10','dattable10','trialcorr');

%% gap and syll correlation analysis for multiple regression controlling for 
%duration AND volume of neighboring syllables 
%params: 10 ms window, FR, bursts 

[corrtable10 dattable10,trialcorr]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','burst',0,10,'gap','duration', 'volume');
save('gap_correlation_analysis_control_dur_vol','corrtable10','dattable10','trialcorr');

[corrtable10 dattable10,trialcorr]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','burst',0,10,'syll','duration','volume');
save('dur_correlation_analysis_control_dur_vol','corrtable10','dattable10','trialcorr');

%% gap and syll correlation analysis for simple regression (activity vs target 
%element duration), 
%params: 10 ms window, FR, bursts 

[corrtable10 dattable10,trialcorr]=RA_correlate_gapdur('batchfile',6,25,50,-40,0,0,'n','burst',0,10,'gap');
save('gap_correlation_analysis','corrtable10','dattable10','trialcorr');

[corrtable10 dattable10,trialcorr]=RA_correlate_gapdur('batchfile',5,25,50,-40,0,0,'n','burst',0,10,'syll');
save('dur_correlation_analysis','corrtable10','dattable10','trialcorr');


%% repeat analysis 1 (IFR)
[bursttable mmtable] = RA_correlate_rep('singleunits',6,20,'y',1);
save('rep_correlation1','bursttable','mmtable');




