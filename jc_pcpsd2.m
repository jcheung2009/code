function [ psd_pre psd_post f] = jc_pcpsd2(pc_pre, pc_post, tm, timebins,norm_y_n)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% select pitch contour segment containing timebins

downsamplesize = 5;
seg = find(tm>timebins(1) & tm<timebins(2));
seg = downsample(seg,downsamplesize);

for i = 1:length(pc_pre)
    pc_pre{i} = pc_pre{i}(seg,:);
end

for i = 1:length(pc_post)
    pc_post{i} = pc_post{i}(seg,:);
end

%% normalize amplitude zscore, keeping difference in variance between pre and post by normalizing with pre std

if strcmp(norm_y_n,'y') == 1
    std_p = mean(cell2mat(cellfun(@(x) nanstd(x,0,2),pc_pre,'UniformOutput',false)),2);%column vector of mean std for each row of timebins
      
    for i = 1:length(pc_pre)
        pc_pre{i} = detrend(pc_pre{i}','constant')'; %mean subtract each row
        pc_pre{i} = pc_pre{i}./repmat(std_p,1,size(pc_pre{i},2));%divide column vector of stdp from each row 
    end
    
    for i = 1:length(pc_post)
        pc_post{i} = detrend(pc_post{i}','constant')';
        pc_post{i} = pc_post{i}./repmat(std_p,1,size(pc_post{i},2));
    end 
end

%% Determine nfft length: smallest number of renditions from both conditions

nfft = min([min(cellfun(@(x) size(x,2),pc_pre)), min(cellfun(@(x) size(x,2), pc_post))]);
if mod(nfft,2) == 1
    nfft = nfft - 1;
end

%% welch's psd 
window = nfft;
noverlap = nfft/2; % 50% overlap 
fs = 1; %1 sample per rendition
for i = 1:length(pc_pre)
    [px f] = jc_psd(pc_pre{i},window,noverlap,nfft,fs);
    psd_pre{i} = px;
end

for i = 1:length(pc_post)
    [px f] = jc_psd(pc_post{i},window,noverlap,nfft,fs);
    psd_post{i} = px;
end

    

end

