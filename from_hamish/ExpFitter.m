function [Amp Tau Plot]=ExpFitter(x,y)

f = @(p,x)p(1)*1./exp(x/p(2));
%f = @(p,x)(p(1)*1./exp(x/p(2)));

p = nlinfit(x,y,f,[x(1) x(end)])
Amp=p(1);
Tau=p(2);
Plot=f(p,x);


