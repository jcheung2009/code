function [meandiff hiconf loconf ] = mBoostrapdiff(invect1,invect2,alpha)

if(isempty(alpha))
    alpha = 0.95;
end

hithresh = alpha;
lothresh = 1-alpha;

if(length(invect1)<40 | length(invect2) <40)
    numsamps = 20;
else
    numsamps = 5;
end

numreps = 5000;
shuffvect = zeros(1,numreps);


for i=1:numreps
    thesamp1 = invect1(randi(length(invect1),1,length(invect1)));
    thesamp2 = invect2(randi(length(invect2),1,length(invect2)));
    shuffvect(i) = mean(thesamp2)-mean(thesamp1);    
end

shuffvect = sort(shuffvect);

meandiff = mean(shuffvect);
hiconf = shuffvect(fix(length(shuffvect) * hithresh));
loconf = shuffvect(fix(length(shuffvect) * lothresh));