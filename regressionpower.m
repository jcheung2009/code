function c = regressionpower(zalpha,zbeta,samplesize)
%normal to use zalpha = 0.05 (false positive rate), zbeta = 0.20 (false
%negative rate); returns minimum correlation coefficient that can be
%detected at each sample size 
zalpha = norminv(1-zalpha/2);%2 tailed 
zbeta = norminv(1-zbeta);

c = ((exp((zalpha+zbeta)./(0.5*sqrt(samplesize-3)))-1)./(1+exp((zalpha+zbeta)./(0.5*sqrt(samplesize-3)))));
