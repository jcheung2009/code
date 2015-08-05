function [pre_corr post_corr pre_lag post_lag shuffpre shuffpost] = jc_pitchcorr(pre_cell,  post_cell);
%autocorrelation without interpolating data, based on sample points
    
%% autocorrelation 
for i = 1:length(pre_cell)
    [corr lag_pre] = xcov(pre_cell{i}(:,2),pre_cell{i}(:,2),'unbiased');
    precorr{i} = [lag_pre' corr];%change lag from points to time
end

for i = 1:length(post_cell)
    [corr lag_post] = xcov(post_cell{i}(:,2),post_cell{i}(:,2),'unbiased');
    postcorr{i} = [lag_post' corr];
end


% nlag_pre = min(cellfun(@length,pre_cell));%determine smallest vector length of interpolated data and use that as maxlag
% pre_corr = [];
% for i = 1:length(pre_cell)
%     [corr lag_pre] = xcorr(pre_cell{i}(:,2),nlag_pre,'coeff');
%     pre_corr(:,i) = corr;
% end
% 
% nlag_post = min(cellfun(@length,post_cell));
% post_corr = [];
% for i = 1:length(post_cell)
%     [corr lag_post] = xcorr(post_cell{i}(:,2),nlag_post,'coeff');
%     post_corr(:,i) = corr;
% end

%% pad start and ends of pre_corr with NaNs to make vector lengths same
[maxlength ind] = max(cellfun(@length, precorr,'UniformOutput',true));
pre_lag = precorr{ind}(:,1);
pre_corr = zeros(maxlength,length(precorr));
for i = 1:length(precorr)
    numpad = (maxlength - length(precorr{i}))/2;
    pre_corr(:,i) = [NaN(numpad,1); precorr{i}(:,2); NaN(numpad,1)];
end

[maxlength ind] = max(cellfun(@length, postcorr,'UniformOutput', true));
post_lag = postcorr{ind}(:,1);
post_corr = zeros(maxlength,length(postcorr));
for i = 1:length(postcorr)
    numpad = (maxlength - length(postcorr{i}))/2;
    post_corr(:,i) = [NaN(numpad,1); postcorr{i}(:,2); NaN(numpad,1)];
end

%% bootstrap on shuffled data 
numbootstraps = 1000;
shuff_precorravg = zeros(length(pre_lag),numbootstraps);
shuff_postcorravg = zeros(length(post_lag),numbootstraps);
for i = 1:numbootstraps
 
    for ii = 1:length(pre_cell)
        shuff = pre_cell{ii}((randi(length(pre_cell{ii}),1,length(pre_cell{ii}))),2);
        [corr lag] = xcov(shuff,shuff,'unbiased');
        numpad = (length(pre_lag) - length(corr))/2;
        shuffprecorr(:,ii) = [NaN(numpad,1); corr; NaN(numpad,1)];
    end
    
    shuff_precorravg(:,i) = nanmean(shuffprecorr,2);
    
    for iii = 1:length(post_cell)
        shuff = post_cell{iii}((randi(length(post_cell{iii}),1,length(post_cell{iii}))),2);
        [corr lag] = xcov(shuff,shuff,'unbiased');
        numpad = (length(post_lag) - length(corr))/2;
        shuffpostcorr(:,iii) = [NaN(numpad,1); corr; NaN(numpad,1)];
    end
    
    shuff_postcorravg(:,i) = nanmean(shuffpostcorr,2);
    
end

shuffpre = sort(shuff_precorravg,2);
shuffpost = sort(shuff_postcorravg,2);

