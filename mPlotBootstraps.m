function mPlotBootstraps(invect1,invect2,alpha)
%
% function mPlotBootstraps(invect1,invect2,alpha)
% 
% Plots mean and bootstrapped 95% confidence intervals of invects 1 & 2, and CV +/- 95% confidence intervals of
% invects 1 & 2
% 
% alpha = 0.95 by default
%
% uses samples of length(invect) for bootstrapping
% uses 10000 iterations with replacement.
%

if(isempty(alpha))
    alpha = 0.95;
end

[hiFF1 loFF1] = mBootstrapCI(invect1,alpha);
[hiFF2 loFF2] = mBootstrapCI(invect2,alpha);

FF1 = mean(invect1);
FF2 = mean(invect2);

[cv1 hiCV1 loCV1] = mBootstrapCI_CV(invect1,alpha);
[cv2 hiCV2 loCV2] = mBootstrapCI_CV(invect2,alpha);

FFplot=figure();errorbar(1,FF1,abs(FF1-loFF1),abs(FF1-hiFF1),'ko','MarkerFaceColor','w','MarkerSize',8);
figure(FFplot);hold on;errorbar(2,FF2,abs(FF2-loFF2),abs(FF2-hiFF2),'ro','MarkerFaceColor','w','MarkerSize',8);
title('mean');hold off;

CVplot=figure();errorbar(1,cv1,abs(cv1-loCV1),abs(cv1-hiCV1),'ko','MarkerFaceColor','w','MarkerSize',8);
figure(CVplot);hold on;;errorbar(2,cv2,abs(cv2-loCV2),abs(cv2-hiCV2),'ro','MarkerFaceColor','w','MarkerSize',8);
title('CV');hold off;