function [hiconf loconf mn] = mBootstrapCI(invect,varargin)
%
%
% function [hiConf loConf] = mBootstrapConfInt(invect,alpha)
% 
% returns high and low confidence intervals based on bootstrapping inVect 
% alpha = 0.95 by default
%
% uses samples of 20 for length(invect)>40, or samples of 5
% uses 1000 iterations with replacement.
%

if(isempty(varargin))
    alpha = 0.95;
else
    alpha = varargin{1};
end

hithresh = alpha;
lothresh = 1-alpha;

if ~isempty(find(isnan(invect)))
    removeind = find(isnan(invect));
    invect(removeind) = [];
end

if(length(invect)<40)
    numsamps = 5;
else
    numsamps = length(invect);
end

numreps = 1000;
shuffvect = zeros(1,numreps);

for i=1:numreps
    thesamp = invect(randi(length(invect),1,length(invect)));
    shuffvect(i) = mean(thesamp);    
end

shuffvect = sort(shuffvect);


hiconf = shuffvect(fix(length(shuffvect) * hithresh));
loconf = shuffvect(fix(length(shuffvect) * lothresh));
mn = mean(shuffvect);
