function [p]=SigFitter(x,y)

f = @(p,x) p(1) + ((p(2)-p(1)) ./ (1 + exp(-(x-p(3))/p(4))));

p = nlinfit(x,y,f,[-120 50 -1 1])

% disp('a')
% figure;
% plot(x,f(p,x));

