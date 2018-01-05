%gap correlation analysis #1
[corrmat case_name data] = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'y++','n');
corrmat_shuff = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','y');
corrmat_shuffsu = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','ysu');
nextcorrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,0,1,'n','n');
prevcorrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,0,-1,'n','n');
nextactivity_corrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,1,0,'n','n');
prevactivity_corrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,-1,0,'n','n');
save('gap_correlation_analysis_test','corrmat','case_name','data','corrmat_shuff','corrmat_shuffsu',...
    'nextcorrmat','prevcorrmat','nextactivity_corrmat','prevactivity_corrmat');

[crosscorr_su,crosscorr_lags, crosscorr_shuff_su] = RA_crosscorrelate_gapdur('batchfile',...
    6,25,6,[-300 300],0,1);
[crosscorr,~, crosscorr_shuff] = RA_crosscorrelate_gapdur('batchfile',...
    6,25,6,[-300 300],0,0);
save('gap_correlation_analysis1','crosscorr','crosscorr_shuff','-append');

[corrmat_all corrmat_all_shuff] = RA_correlate_allgapdur('batchfile',6,25,6,...
    -40,0,0);
[corrmat_all_su corrmat_all_shuff_su] = RA_correlate_allgapdur('batchfile',6,25,6,...
    -40,1,0);
save('gap_correlation_analysis1','corrmat_all','corrmat_all_shuff','corrmat_all_su',...
    'corrmat_all_shuff_su','-append');

%syll correlation analysis #1
[corrmat case_name data] = RA_correlate_sylldur('batchfile',5,25,6,-40,0,0,'n','n');
corrmat_shuff = RA_correlate_sylldur('batchfile',5,25,6,-40,0,0,'n','y');
corrmat_shuffsu = RA_correlate_sylldur('batchfile',5,25,6,-40,0,0,'n','ysu');
nextcorrmat = RA_correlate_sylldur('batchfile',5,25,6,-40,0,1,'n','n');
prevcorrmat = RA_correlate_sylldur('batchfile',5,25,6,-40,0,-1,'n','n');
nextactivity_corrmat = RA_correlate_sylldur('batchfile',5,25,6,-40,1,0,'n','n');
prevactivity_corrmat = RA_correlate_sylldur('batchfile',5,25,6,-40,-1,0,'n','n');
save('dur_correlation_analysis1','corrmat','case_name','data','corrmat_shuff','corrmat_shuffsu',...
    'nextcorrmat','prevcorrmat','nextactivity_corrmat','prevactivity_corrmat');

[crosscorr_su,crosscorr_lags, crosscorr_shuff_su] = RA_crosscorrelate_dur('batchfile',...
    5,25,6,[-300 300],0,1);
[crosscorr,~, crosscorr_shuff] = RA_crosscorrelate_dur('batchfile',...
    5,25,6,[-300 300],0,0);
save('dur_correlation_analysis1','crosscorr','crosscorr_shuff','-append');
