function [pre post] = jc_sdnorm(pre,post)
% changes raw data into z scores, normalized by std of pre 

std_p = mean(cellfun(@(x) std(x(:,2)),pre));

for i = 1:length(pre)
    pre{i}(:,2) = (pre{i}(:,2)-mean(pre{i}(:,2)))./std_p;
end

for i = 1:length(post)
    post{i}(:,2) = (post{i}(:,2)-mean(post{i}(:,2)))./std_p;
end

