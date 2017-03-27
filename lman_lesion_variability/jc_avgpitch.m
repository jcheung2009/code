function [pre_avg post_avg] = jc_avgpitch(pre_cell, post_cell)

pre_avg = [];
post_avg = [];

for i = 1:length(pre_cell)
    pre = mean(pre_cell{i}(:,2));
    pre_avg = cat(1,pre_avg,pre);
end

for i = 1:length(post_cell)
    post = mean(post_cell{i}(:,2));
    post_avg = cat(1,post_avg,post);
end
