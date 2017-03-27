function [meandiff hiconf loconf] = jc_testSkew(invect1,invect2,alpha)
%bootstrap difference in absolute skewness

if isempty(alpha)
    alpha = 0.95;
end

hithresh = alpha;
lothresh = 1-alpha;

numreps = 5000;
shuffvect = zeros(1,numreps);

for i = 1:numreps
    samp1 = invect1(randi(length(invect1),length(invect1),1));
    samp2 = invect2(randi(length(invect2),length(invect2),1));
    skew1 = skewness(samp1,0);
    skew2 = skewness(samp2,0);
    shuffvect(i) = skew1-skew2;
end

shuffvect = sort(shuffvect);

meandiff = mean(shuffvect);
hiconf = shuffvect(fix(length(shuffvect) * hithresh));
loconf = shuffvect(fix(length(shuffvect) * lothresh));
    