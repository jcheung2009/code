function [stddev]=binomsb(n,p);

%calculate standard deviation assuming binomial distribution with n observations, prob
% std error expressed 

[m,v]=binostat(n,p);
stddev=sqrt(v);
stddev=stddev/n;




