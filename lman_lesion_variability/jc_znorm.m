function [pre_znorm post_znorm] = jc_znorm(pre,post)
%z scores for pre and post lman lesion cell arrays

mean_std = mean(cellfun(@(x) mean(x(:,2)),pre));
pre_znorm = cellfun(@(x) [x(:,1) (x(:,2)-mean(x(:,2)))/mean_std],pre,'UniformOutput',false);
post_znorm = cellfun(@(x) [x(:,1) (x(:,2)-mean(x(:,2)))/mean_std],post,'UniformOutput',false);
