function [shuffpcpre_psd shuffpcpost_psd freq] = jc_shuffpcpsd(pc_pre, pc_post, tm, timebins, norm_y_n)
%1000 reiterations shuffling raw pitch contours in pre and post cells and
%computing average fft 


%% Determine nfft length: smallest number of renditions from both conditions

nfft = min([min(cellfun(@(x) size(x,2),pc_pre)), min(cellfun(@(x) size(x,2), pc_post))]);
if mod(nfft,2) == 1
    nfft = nfft - 1;
end


%% shuffle pitch contours and compute psd

numboot = 1000;
shuffpcpre_psd = zeros(nfft/2+1,numboot);
shuffpcpost_psd = zeros(nfft/2+1,numboot);
for i = 1:numboot
    for ii = 1:length(pc_pre)
        shuffpcpre{ii} = pc_pre{ii}(:,randperm(size(pc_pre{ii},2)));
    end
    for iii = 1:length(pc_post)
        shuffpcpost{iii} = pc_post{iii}(:,randperm(size(pc_post{iii},2)));
    end
    [shuffpcprepsd shuffpcpostpsd freq] = jc_pcpsd(shuffpcpre, shuffpcpost, tm, timebins, norm_y_n);
    shuffpcpre_psd(:,i) = mean(shuffpcprepsd,2);
    shuffpcpost_psd(:,i) = mean(shuffpcpostpsd,2);
end

shuffpcpre_psd = sort(shuffpcpre_psd,2);
shuffpcpost_psd = sort(shuffpcpost_psd,2);



    
    
    
    
    
    