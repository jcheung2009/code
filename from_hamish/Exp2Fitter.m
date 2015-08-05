function [p, plotout]=Exp2Fitter(x,y)

f = @(p,x) p(1)*1./exp(x/p(2)) + p(3)*1./exp(x/p(4));

p = nlinfit(x,y,f,[-120 50 -1 1])

% disp('a')
% figure;
 plotout=f(p,x);

