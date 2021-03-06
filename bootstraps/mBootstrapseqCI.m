function [meanshuff hiconf loconf shuffvect] = mBootstrapseqCI(invect,syll,alpha)
%%invect is string, dominant syll in transition 

if(isempty(alpha))
    alpha = 0.95;
end

hithresh = alpha;
lothresh = 1-alpha;

numreps = 5000;
shuffvect = zeros(1,numreps);
a = ismember(invect,syll);


for i = 1:numreps
    thesamp = a(randi(length(invect),1,length(invect)));
    shuffvect(i) = mean(thesamp);
end

meanshuff = mean(shuffvect);
hiconf = prctile(shuffvect,alpha*100);
loconf = prctile(shuffvect,(1-alpha)*100);