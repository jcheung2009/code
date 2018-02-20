%% gap and syll correlation analysis #1 (IFR within burst-pct error)
[corrtable dattable]=RA_correlate_gapdur('singleunits',6,25,6,-40,0,0,'n','burst',1,'gap');
save('gap_correlation_analysis_singleunits_ifr','corrtable','dattable');

[corrtable dattable]=RA_correlate_gapdur('singleunits',5,25,6,-40,0,0,'n','burst',1,'syll');
save('dur_correlation_analysis_singleunits_ifr','corrtable','dattable');

[corrtable dattable]=RA_correlate_gapdur('multiunits',6,25,6,-40,0,0,'y+','burst',1,'gap');
save('gap_correlation_analysis_multiunits_ifr','corrtable','dattable');

[corrtable dattable]=RA_correlate_gapdur('multiunits',5,25,6,-40,0,0,'n','burst',1,'syll');
save('dur_correlation_analysis_multiunits_ifr','corrtable','dattable');

%% gap and syll correlation analysis (spike cnt within burst-pct error)
[corrtable dattable]=RA_correlate_gapdur('multiunits',6,25,6,-40,0,0,'n','burst',0,'gap');
save('gap_correlation_analysis_multiunits_fr','corrtable','dattable');

[corrtable dattable]=RA_correlate_gapdur('multiunits',5,25,6,-40,0,0,'n','burst',0,'syll');
save('dur_correlation_analysis_multiunits_fr','corrtable','dattable');

[corrtable dattable]=RA_correlate_gapdur('singleunits',6,25,6,-40,0,0,'n','burst',0,'gap');
save('gap_correlation_analysis_singleunits_fr','corrtable','dattable');

[corrtable dattable]=RA_correlate_gapdur('singleunits',5,25,6,-40,0,0,'n','burst',0,'syll');
save('dur_correlation_analysis_singleunits_fr','corrtable','dattable');

%% gap and syll correlation analysis (IFR within burst-spk posterior)
[corrtable dattable]=RA_correlate_gapdur('singleunits_spkpost',6,25,6,-40,0,0,'n','burst',1,'gap');
save('gap_correlation_analysis_singleunits_spkpost','corrtable','dattable');

[corrtable dattable]=RA_correlate_gapdur('singleunits_spkpost',5,25,6,-40,0,0,'n','burst',1,'syll');
save('dur_correlation_analysis_singleunits_spkpost','corrtable','dattable');

[corrtable dattable]=RA_correlate_gapdur('multiunits_spkpost',6,25,6,-40,0,0,'n','burst',1,'gap');
save('gap_correlation_analysis_multiunits_spkpost','corrtable','dattable');

[corrtable dattable]=RA_correlate_gapdur('multiunits_spkpost',5,25,6,-40,0,0,'n','burst',1,'syll');
save('dur_correlation_analysis_multiunits_spkpost','corrtable','dattable');

%% gap and syll correlation analysis (IFR within burst-spk posterior+pcterror)
[corrtable dattable]=RA_correlate_gapdur('singleunits_spkpost_pcterror',6,25,6,-40,0,0,'n','burst',1,'gap');
save('gap_correlation_analysis_singleunits_spkpost_pcterror','corrtable','dattable');

[corrtable dattable]=RA_correlate_gapdur('singleunits_spkpost_pcterror',5,25,6,-40,0,0,'n','burst',1,'syll');
save('dur_correlation_analysis_singleunits_spkpost_pcterror','corrtable','dattable');

[corrtable dattable]=RA_correlate_gapdur('multiunits_spkpost_pcterror',6,25,6,-40,0,0,'n','burst',1,'gap');
save('gap_correlation_analysis_multiunits_spkpost_pcterror','corrtable','dattable');

[corrtable dattable]=RA_correlate_gapdur('multiunits_spkpost_pcterror',5,25,6,-40,0,0,'n','burst',1,'syll');
save('dur_correlation_analysis_multiunits_spkpost_pcterror','corrtable','dattable');


%%
[corrmat case_name data] = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','n','burst',1,'gap','n');
corrmat_shuff = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','y','burst',1,'gap','n');
corrmat_shuffsu = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','ysu','burst',1,'gap','n');
nextcorrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,0,1,'n','n','burst',1,'gap');
prevcorrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,0,-1,'n','n','burst',1,'gap');
nextactivity_corrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,1,0,'n','n','burst',1,'gap');
prevactivity_corrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,-1,0,'n','n','burst',1,'gap');
[corrmat case_name data] = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','n','burst',1,'gap');

save('gap_correlation_analysis1','corrmat','case_name','data','corrmat_shuff','corrmat_shuffsu',...
    'nextcorrmat','prevcorrmat','nextactivity_corrmat','prevactivity_corrmat');

[crosscorr_su,crosscorr_lags, crosscorr_shuff_su] = RA_crosscorrelate_gapdur('batchfile',...
    6,25,6,[-300 300],0,1,'burst','gap',1);
[crosscorr,~, crosscorr_shuff] = RA_crosscorrelate_gapdur('batchfile',...
    6,25,6,[-300 300],0,0,'burst','gap',1);
save('gap_correlation_analysis1','crosscorr_su','crosscorr_lags',...
    'crosscorr_shuff_su','crosscorr','crosscorr_shuff','-append');

%syll correlation analysis #1 (IFR within burst)
[corrmat case_name data] = RA_correlate_gapdur('batchfile',5,25,6,-40,0,0,'n','n','burst',1,'syll');
corrmat_shuff = RA_correlate_gapdur('batchfile',5,25,6,-40,0,0,'n','y','burst',1,'syll');
corrmat_shuffsu = RA_correlate_gapdur('batchfile',5,25,6,-40,0,0,'n','ysu','burst',1,'syll');
nextcorrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,0,1,'n','n','burst',1,'syll');
prevcorrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,0,-1,'n','n','burst',1,'syll');
nextactivity_corrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,1,0,'n','n','burst',1,'syll');
prevactivity_corrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,-1,0,'n','n','burst',1,'syll');
save('dur_correlation_analysis1','corrmat','case_name','data','corrmat_shuff','corrmat_shuffsu',...
    'nextcorrmat','prevcorrmat','nextactivity_corrmat','prevactivity_corrmat');

[crosscorr_su,crosscorr_lags, crosscorr_shuff_su] = RA_crosscorrelate_gapdur('batchfile',...
    5,25,6,[-300 300],0,1,'burst','syll',1);
[crosscorr,~, crosscorr_shuff] = RA_crosscorrelate_gapdur('batchfile',...
    5,25,6,[-300 300],0,0,'burst','syll',1);
save('dur_correlation_analysis1','crosscorr_su','crosscorr_lags','crosscorr_shuff_su',...
    'crosscorr','crosscorr_shuff','-append');


%% gap correlation analysis #1a (spikes within burst)
[corrmat case_name data] = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','n','burst',0,'gap','n');
corrmat_shuff = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','y','burst',0,'gap','n');
corrmat_shuffsu = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','ysu','burst',0,'gap','n');
nextcorrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,0,1,'n','n','burst',0,'gap');
prevcorrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,0,-1,'n','n','burst',0,'gap');
nextactivity_corrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,1,0,'n','n','burst',0,'gap');
prevactivity_corrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,-1,0,'n','n','burst',0,'gap');
save('gap_correlation_analysis1a','corrmat','case_name','data','corrmat_shuff','corrmat_shuffsu',...
    'nextcorrmat','prevcorrmat','nextactivity_corrmat','prevactivity_corrmat');


[crosscorr_su,crosscorr_lags, crosscorr_shuff_su] = RA_crosscorrelate_gapdur('batchfile',...
    6,25,6,[-300 300],0,1,'burst','gap',0);
[crosscorr,~, crosscorr_shuff] = RA_crosscorrelate_gapdur('batchfile',...
    6,25,6,[-300 300],0,0,'burst','gap',0);
save('gap_correlation_analysis1a','crosscorr_su','crosscorr_lags',...
    'crosscorr_shuff_su','crosscorr','crosscorr_shuff','-append');


%syll correlation analysis #1a (spikes within burst)
[corrmat case_name data] = RA_correlate_gapdur('batchfile',5,25,6,-40,0,0,'n','n','burst',0,'syll');
corrmat_shuff = RA_correlate_gapdur('batchfile',5,25,6,-40,0,0,'n','y','burst',0,'syll');
corrmat_shuffsu = RA_correlate_gapdur('batchfile',5,25,6,-40,0,0,'n','ysu','burst',0,'syll');
nextcorrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,0,1,'n','n','burst',0,'syll');
prevcorrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,0,-1,'n','n','burst',0,'syll');
nextactivity_corrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,1,0,'n','n','burst',0,'syll');
prevactivity_corrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,-1,0,'n','n','burst',0,'syll');
save('dur_correlation_analysis1a','corrmat','case_name','data','corrmat_shuff','corrmat_shuffsu',...
    'nextcorrmat','prevcorrmat','nextactivity_corrmat','prevactivity_corrmat');

[crosscorr_su,crosscorr_lags, crosscorr_shuff_su] = RA_crosscorrelate_gapdur('batchfile',...
    5,25,6,[-300 300],0,1,'burst','syll',0);
[crosscorr,~, crosscorr_shuff] = RA_crosscorrelate_gapdur('batchfile',...
    5,25,6,[-300 300],0,0,'burst','syll',0);
save('dur_correlation_analysis1a','crosscorr_su','crosscorr_lags','crosscorr_shuff_su',...
    'crosscorr','crosscorr_shuff','-append');



%% gap correlation analysis #2 (spikes within 40 ms fixed window)
[corrmat case_name data] = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','n','spikes',0,'gap');
corrmat_shuff = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','y','spikes',0,'gap');
corrmat_shuffsu = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','ysu','spikes',0,'gap');
nextcorrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,0,1,'n','n','spikes',0,'gap');
prevcorrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,0,-1,'n','n','spikes',0,'gap');
nextactivity_corrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,1,0,'n','n','spikes',0,'gap');
prevactivity_corrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,-1,0,'n','n','spikes',0,'gap');
save('gap_correlation_analysis2','corrmat','case_name','data','corrmat_shuff','corrmat_shuffsu',...
    'nextcorrmat','prevcorrmat','nextactivity_corrmat','prevactivity_corrmat');

[crosscorr_su,crosscorr_lags, crosscorr_shuff_su] = RA_crosscorrelate_gapdur('batchfile',...
    6,25,6,[-300 300],0,1,'spikes','gap',0);
[crosscorr,~, crosscorr_shuff] = RA_crosscorrelate_gapdur('batchfile',...
    6,25,6,[-300 300],0,0,'spikes','gap',0);
save('gap_correlation_analysis2','crosscorr_su','crosscorr_lags',...
    'crosscorr_shuff_su','crosscorr','crosscorr_shuff','-append');

%dur correlation analysis #2 (spikes within 40 ms fixed window)
[corrmat case_name data] = RA_correlate_gapdur('batchfile',5,25,6,-40,0,0,'n','n','spikes',0,'syll');
corrmat_shuff = RA_correlate_gapdur('batchfile',5,25,6,-40,0,0,'n','y','spikes',0,'syll');
corrmat_shuffsu = RA_correlate_gapdur('batchfile',5,25,6,-40,0,0,'n','ysu','spikes',0,'syll');
nextcorrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,0,1,'n','n','spikes',0,'syll');
prevcorrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,0,-1,'n','n','spikes',0,'syll');
nextactivity_corrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,1,0,'n','n','spikes',0,'syll');
prevactivity_corrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,-1,0,'n','n','spikes',0,'syll');
save('dur_correlation_analysis2','corrmat','case_name','data','corrmat_shuff','corrmat_shuffsu',...
    'nextcorrmat','prevcorrmat','nextactivity_corrmat','prevactivity_corrmat');

[crosscorr_su,crosscorr_lags, crosscorr_shuff_su] = RA_crosscorrelate_gapdur('batchfile',...
    5,25,6,[-300 300],0,1,'spikes','syll',0);
[crosscorr,~, crosscorr_shuff] = RA_crosscorrelate_gapdur('batchfile',...
    5,25,6,[-300 300],0,0,'spikes','syll',0);
save('dur_correlation_analysis2','crosscorr_su','crosscorr_lags',...
    'crosscorr_shuff_su','crosscorr','crosscorr_shuff','-append');

%% gap correlation analysis #2a (IFR within 40 ms fixed window)
[corrmat case_name data] = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'y+su','n','spikes',1,'gap');
corrmat_shuff = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','y','spikes',1,'gap');
corrmat_shuffsu = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','ysu','spikes',1,'gap');
nextcorrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,0,1,'n','n','spikes',1,'gap');
prevcorrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,0,-1,'n','n','spikes',1,'gap');
nextactivity_corrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,1,0,'n','n','spikes',1,'gap');
prevactivity_corrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,-1,0,'n','n','spikes',1,'gap');
save('gap_correlation_analysis2a','corrmat','case_name','data','corrmat_shuff','corrmat_shuffsu',...
    'nextcorrmat','prevcorrmat','nextactivity_corrmat','prevactivity_corrmat');

[crosscorr_su,crosscorr_lags, crosscorr_shuff_su] = RA_crosscorrelate_gapdur('batchfile',...
    6,25,6,[-300 300],0,1,'spikes','gap',1);
[crosscorr,~, crosscorr_shuff] = RA_crosscorrelate_gapdur('batchfile',...
    6,25,6,[-300 300],0,0,'spikes','gap',1);
save('gap_correlation_analysis2a','crosscorr_su','crosscorr_lags',...
    'crosscorr_shuff_su','crosscorr','crosscorr_shuff','-append');

%dur correlation analysis #2a (IFR within 40 ms fixed window)
[corrmat case_name data] = RA_correlate_gapdur('batchfile',5,25,6,-40,0,0,'n','n','spikes',1,'syll');
corrmat_shuff = RA_correlate_gapdur('batchfile',5,25,6,-40,0,0,'n','y','spikes',1,'syll');
corrmat_shuffsu = RA_correlate_gapdur('batchfile',5,25,6,-40,0,0,'n','ysu','spikes',1,'syll');
nextcorrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,0,1,'n','n','spikes',1,'syll');
prevcorrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,0,-1,'n','n','spikes',1,'syll');
nextactivity_corrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,1,0,'n','n','spikes',1,'syll');
prevactivity_corrmat = RA_correlate_gapdur('batchfile',5,25,6,-40,-1,0,'n','n','spikes',1,'syll');
save('dur_correlation_analysis2a','corrmat','case_name','data','corrmat_shuff','corrmat_shuffsu',...
    'nextcorrmat','prevcorrmat','nextactivity_corrmat','prevactivity_corrmat');

[crosscorr_su,crosscorr_lags, crosscorr_shuff_su] = RA_crosscorrelate_gapdur('batchfile',...
    5,25,6,[-300 300],0,1,'spikes','syll',1);
[crosscorr,~, crosscorr_shuff] = RA_crosscorrelate_gapdur('batchfile',...
    5,25,6,[-300 300],0,0,'spikes','syll',1);
save('dur_correlation_analysis2a','crosscorr_su','crosscorr_lags',...
    'crosscorr_shuff_su','crosscorr','crosscorr_shuff','-append');


%% repeat analysis 1 (IFR)
[bursttable mmtable] = RA_correlate_rep('singleunits',6,20,'y',1);
save('rep_correlation1','bursttable','mmtable');

%% correlate with volume for bursts before target gap or syllable (IFR) for single units (correlation coefficients)
[corrmat case_name data] = RA_correlate_vol('singleunits',6,25,6,-40,'n','n','burst',1,'gap');
corrmat_shuff = RA_correlate_vol('singleunits',6,25,6,-40,'n','y','burst',1,'gap');
save('vol_correlation1','corrmat','case_name','corrmat_shuff');

%% correlate volume1, volume2, and duration to IFR for single units (IFR) (betas)
[corrmat case_name data] = RA_correlate_gapvol('singleunits',6,25,6,-40,'n','n','burst',1,'gap',{'volume1','volume2','dur'});
corrmat_shuff = RA_correlate_gapvol('singleunits',6,25,6,-40,'n','y','burst',1,'gap',{'volume1','volume2','dur'});
save('vol1regression','corrmat','case_name','data','corrmat_shuff');
save('gapvolmultipleregression','corrmat','case_name','data','corrmat_shuff');

%% correlate volume1 with IFR for single units (IFR) (betas) (betas)
[corrmat case_name data] = RA_correlate_gapvol('singleunits',6,25,6,-40,'n','n','burst',1,'gap',{'volume1'});
corrmat_shuff = RA_correlate_gapvol('singleunits',6,25,6,-40,'n','y','burst',1,'gap',{'volume1'});
save('vol1regression','corrmat','case_name','data','corrmat_shuff');

%% correlate volume2 with IFR for single units (IFR) (betas) (betas)
[corrmat case_name data] = RA_correlate_gapvol('singleunits',6,25,6,-40,'n','n','burst',1,'gap',{'volume2'});
corrmat_shuff = RA_correlate_gapvol('singleunits',6,25,6,-40,'n','y','burst',1,'gap',{'volume2'});
save('vol2regression','corrmat','case_name','data','corrmat_shuff');

%% correlate gapdur with IFR for single units (IFR) (betas) (betas)
[corrmat case_name data] = RA_correlate_gapvol('singleunits',6,25,6,-40,'n','n','burst',1,'gap',{'dur'});
corrmat_shuff = RA_correlate_gapvol('singleunits',6,25,6,-40,'n','y','burst',1,'gap',{'dur'});
save('gapdurregression','corrmat','case_name','data','corrmat_shuff');