function [hiconf loconf mn] = jc_BootstrapCI_r(invect,varargin)
%finds 95% confidence interval for correlation coefficient r 
%invect = 2 column matrix (x vs y)

if(isempty(varargin))
    alpha = 0.95;
else
    alpha = varargin{1};
end

hithresh = alpha;
lothresh = 1-alpha;

numreps = 1000;
shuffvect = zeros(1,numreps);

for i = 1:numreps
    thesamp = invect(randi(size(invect,1),1,size(invect,1)),:);
    [c p] = corrcoef(thesamp(:,1),thesamp(:,2));
    shuffvect(i) = c(2);
end
shuffvect = sort(shuffvect);

hiconf = shuffvect(fix(length(shuffvect)*hithresh));
loconf = shuffvect(fix(length(shuffvect)*lothresh));
mn = mean(shuffvect);
