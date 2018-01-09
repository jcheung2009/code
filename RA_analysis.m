%gap correlation analysis #1 (spikes within burst border)
[corrmat case_name data] = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','n','burst');
corrmat_shuff = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','y','burst');
corrmat_shuffsu = RA_correlate_gapdur('batchfile',6,25,6,-40,0,0,'n','ysu','burst');
nextcorrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,0,1,'n','n','burst');
prevcorrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,0,-1,'n','n','burst');
nextactivity_corrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,1,0,'n','n','burst');
prevactivity_corrmat = RA_correlate_gapdur('batchfile',6,25,6,-40,-1,0,'n','n','burst');
save('gap_correlation_analysis1','corrmat','case_name','data','corrmat_shuff','corrmat_shuffsu',...
    'nextcorrmat','prevcorrmat','nextactivity_corrmat','prevactivity_corrmat');

[crosscorr_su,crosscorr_lags, crosscorr_shuff_su] = RA_crosscorrelate_gapdur('batchfile',...
    6,25,6,[-300 300],0,1,'burst');
[crosscorr,~, crosscorr_shuff] = RA_crosscorrelate_gapdur('batchfile',...
    6,25,6,[-300 300],0,0,'burst');
save('gap_correlation_analysis1','crosscorr_su','crosscorr_lags',...
    'crosscorr_shuff_su','crosscorr','crosscorr_shuff','-append');

% [corrmat_all corrmat_all_shuff] = RA_correlate_allgapdur('batchfile',6,25,6,...
%     -40,0,0);
% [corrmat_all_su corrmat_all_shuff_su] = RA_correlate_allgapdur('batchfile',6,25,6,...
%     -40,1,0);
% save('gap_correlation_analysis1','corrmat_all','corrmat_all_shuff','corrmat_all_su',...
%     'corrmat_all_shuff_su','-append');

%syll correlation analysis #1 
[corrmat case_name data] = RA_correlate_sylldur('batchfile',5,25,6,-40,0,0,'n','n','burst');
corrmat_shuff = RA_correlate_sylldur('batchfile',5,25,6,-40,0,0,'n','y','burst');
corrmat_shuffsu = RA_correlate_sylldur('batchfile',5,25,6,-40,0,0,'n','ysu','burst');
nextcorrmat = RA_correlate_sylldur('batchfile',5,25,6,-40,0,1,'n','n','burst');
prevcorrmat = RA_correlate_sylldur('batchfile',5,25,6,-40,0,-1,'n','n','burst');
nextactivity_corrmat = RA_correlate_sylldur('batchfile',5,25,6,-40,1,0,'n','n','burst');
prevactivity_corrmat = RA_correlate_sylldur('batchfile',5,25,6,-40,-1,0,'n','n','burst');
save('dur_correlation_analysis_burst','corrmat','case_name','data','corrmat_shuff','corrmat_shuffsu',...
    'nextcorrmat','prevcorrmat','nextactivity_corrmat','prevactivity_corrmat');

[crosscorr_su,crosscorr_lags, crosscorr_shuff_su] = RA_crosscorrelate_dur('batchfile',...
    5,25,6,[-300 300],1,1,'burst');
[crosscorr,~, crosscorr_shuff] = RA_crosscorrelate_dur('batchfile',...
    5,25,6,[-300 300],0,0);
save('dur_correlation_analysis1','crosscorr','crosscorr_shuff','-append');


%gap correlation analysis #2 (spikes within 40 ms fixed window)
[corrmat case_name data] = RA_correlate_gapdur('batchfile',6,25,1,-40,0,0,'n','n','spikes');
corrmat_shuff = RA_correlate_gapdur('batchfile',6,25,1,-40,0,0,'n','y','spikes');
corrmat_shuffsu = RA_correlate_gapdur('batchfile',6,25,1,-40,0,0,'n','ysu','spikes');
nextcorrmat = RA_correlate_gapdur('batchfile',6,25,1,-40,0,1,'n','n','spikes');
prevcorrmat = RA_correlate_gapdur('batchfile',6,25,1,-40,0,-1,'n','n','spikes');
nextactivity_corrmat = RA_correlate_gapdur('batchfile',6,25,1,-40,1,0,'n','n','spikes');
prevactivity_corrmat = RA_correlate_gapdur('batchfile',6,25,1,-40,-1,0,'n','n','spikes');
save('gap_correlation_analysis2','corrmat','case_name','data','corrmat_shuff','corrmat_shuffsu',...
    'nextcorrmat','prevcorrmat','nextactivity_corrmat','prevactivity_corrmat');

[crosscorr_su,crosscorr_lags, crosscorr_shuff_su] = RA_crosscorrelate_gapdur('batchfile',...
    6,25,1,[-300 300],0,1,'spikes');
[crosscorr,~, crosscorr_shuff] = RA_crosscorrelate_gapdur('batchfile',...
    6,25,1,[-300 300],0,0,'spikes');
save('gap_correlation_analysis2','crosscorr_su','crosscorr_lags',...
    'crosscorr_shuff_su','crosscorr','crosscorr_shuff','-append');

%dur correlation analysis #2 (spikes within 40 ms fixed window)
[corrmat case_name data] = RA_correlate_sylldur('batchfile',5,25,1,-40,0,0,'n','n','spikes');
corrmat_shuff = RA_correlate_sylldur('batchfile',5,25,1,-40,0,0,'n','y','spikes');
corrmat_shuffsu = RA_correlate_sylldur('batchfile',5,25,1,-40,0,0,'n','ysu','spikes');
nextcorrmat = RA_correlate_sylldur('batchfile',5,25,1,-40,0,1,'n','n','spikes');
prevcorrmat = RA_correlate_sylldur('batchfile',5,25,1,-40,0,-1,'n','n','spikes');
nextactivity_corrmat = RA_correlate_sylldur('batchfile',5,25,1,-40,1,0,'n','n','spikes');
prevactivity_corrmat = RA_correlate_sylldur('batchfile',5,25,1,-40,-1,0,'n','n','spikes');
save('dur_correlation_analysis2','corrmat','case_name','data','corrmat_shuff','corrmat_shuffsu',...
    'nextcorrmat','prevcorrmat','nextactivity_corrmat','prevactivity_corrmat');

tic
[crosscorr_su,crosscorr_lags, crosscorr_shuff_su] = RA_crosscorrelate_dur('batchfile',...
    5,25,1,[-300 300],0,1,'spikes');
[crosscorr,~, crosscorr_shuff] = RA_crosscorrelate_dur('batchfile',...
    5,25,1,[-300 300],0,0,'spikes');
save('dur_correlation_analysis12','crosscorr_su','crosscorr_lags',...
    'crosscorr_shuff_su','crosscorr','crosscorr_shuff','-append');
toc