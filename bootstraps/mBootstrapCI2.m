function [hiconf loconf mn] = mBootstrapCI2(inmat,varargin)
% returns high and low confidence intervals for the meean based on bootstrapping inmat 
% alpha = 0.95 by default
% uses 1000 iterations with replacement.


if(isempty(varargin))
    alpha = 0.95;
else
    alpha = varargin{1};
end

hithresh = alpha;
lothresh = 1-alpha;


numreps = 1000;
shuffmat = zeros(numreps,size(inmat,2));

for ii = 1:size(inmat,2)
    for i=1:numreps
        thesamp = inmat(randi(size(inmat,1),1,size(inmat,1)),ii);
        shuffmat(i,ii) = mean(thesamp);
    end
end

shuffmat = sort(shuffmat);


hiconf = shuffmat(fix(numreps * hithresh),:);
loconf = shuffmat(fix(numreps * lothresh),:);
mn = mean(shuffmat);