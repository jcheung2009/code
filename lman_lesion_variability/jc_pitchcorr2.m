function [interp_pre interp_post pre_corr post_corr pre_lag post_lag shuff_precorravg shuff_postcorravg] = jc_pitchcorr2(pre_cell, tb_pre,  post_cell, tb_post);
%pre_cell contains vectors for all pre lesion days
%post cell contains vectors for all post lesion days
%tb_pre and tb_post are cells containing time vectors for each day in
%pre_cell and post_cell, in seconds 
%interp_pre and interp_post are cells with interpolated pitch data 
%pre_corr and post_corr = autocovariance of pitch data, NaN padded to
%equalize lengths of vectors
%pre_lag and post_lag are shifts for corr transformed to seconds
%shuffprecorravg is bootstrapped average correlation of shuffled pitch data

%% use one sampling rate for interpolation

%determine mean sampling rate for interpolation
fs_pre = cellfun(@(x) size(x,1)/(x(end)-x(1)), tb_pre,'UniformOutput',false);
fs_pre = cell2mat(fs_pre);
fs_pre = mean(fs_pre);

fs_post = cellfun(@(x) size(x,1)/(x(end)-x(1)), tb_post,'UniformOutput',false);
fs_post = cell2mat(fs_post);
fs_post = mean(fs_post);

%interpolate with mean sampling rate
for i = 1:length(tb_pre)
    xi = ceil(tb_pre{i}(1)):1/fs_pre:floor(tb_pre{i}(end));%vector of uniformly spaced time points 
    v = interp1(tb_pre{i},pre_cell{i}(:,2),xi);
    interp_pre{i} = [xi' v'];
end

for i = 1:length(tb_post)
    xi = ceil(tb_post{i}(1)):1/fs_post:floor(tb_post{i}(end));
    v = interp1(tb_post{i},post_cell{i}(:,2),xi);
    interp_post{i} = [xi' v'];
end
    
%% use different sampling rates for each vector in cell to keep same number
% of points
% for i = 1:length(tb_pre)
%     fs = size(tb_pre{i},1)/(tb_pre{i}(end)-tb_pre{i}(1)); %points/second
%     xi = ceil(tb_pre{i}(1)):1/fs:floor(tb_pre{i}(end));%vector of uniformly spaced time points 
%     v = interp1(tb_pre{i},pre_cell{i}(:,2),xi);
%     interp_pre{i} = [xi' v'];
%     fs_pre(i) = fs;
% end
% 
% 
% for i = 1:length(tb_post)
%     fs = size(tb_post{i},1)/(tb_post{i}(end)-tb_post{i}(1)); %points/second
%     xi = ceil(tb_post{i}(1)):1/fs:floor(tb_post{i}(end));
%     v = interp1(tb_post{i},post_cell{i}(:,2),xi);
%     interp_post{i} = [xi' v'];
%     fs_post(i) = fs;
% end

%% autocovariance (uses mean subtracted data)
for i = 1:length(interp_pre)
    [corr lag_pre] = xcov(interp_pre{i}(:,2),'coeff');
    precorr{i} = [lag_pre'*(1/fs_pre) corr];%change lag from points to time
end

for i = 1:length(interp_post)
    [corr lag_post] = xcov(interp_post{i}(:,2),'coeff');
    postcorr{i} = [lag_post'*(1/fs_post) corr];
end

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
        xi = ceil(tb_pre{ii}(1)):1/fs_pre:floor(tb_pre{ii}(end));
        v = interp1(tb_pre{ii}, shuff, xi);
        [corr lag] = xcov(v,'coeff');
        numpad = (length(pre_lag) - length(corr))/2;
        shuffprecorr(:,ii) = [NaN(numpad,1); corr'; NaN(numpad,1)];
    end
    
    shuff_precorravg(:,i) = nanmean(shuffprecorr,2);
    
    for iii = 1:length(post_cell)
        shuff = post_cell{iii}((randi(length(post_cell{iii}),1,length(post_cell{iii}))),2);
        xi = ceil(tb_post{iii}(1)):1/fs_post:floor(tb_post{iii}(end));
        v = interp1(tb_post{iii}, shuff, xi);
        [corr lag] = xcov(v,'coeff');
        numpad = (length(post_lag) - length(corr))/2;
        shuffpostcorr(:,iii) = [NaN(numpad,1); corr'; NaN(numpad,1)];
    end
    
    shuff_postcorravg(:,i) = nanmean(shuffpostcorr,2);
    
end

shuff_precorravg = sort(shuff_precorravg,2);
shuff_postcorravg = sort(shuff_postcorravg,2);


