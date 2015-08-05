function [diffdist,critvals,thediff] = mPermTestCV(samp1,samp2,alpha)
%
%
% [diffdist,critvals,thediff] = mPermTestCV(samp1,samp2,alpha)
%
% permutation test for significance of differences in CV of samp1 and samp2
% 
% alpha is significance level from 0 to 1
%
% samples length(dist1) and length(dist2) with replacement 
%
% performs 10000 iterations by default
% alpha is split between 2 tails
% 
% if thediff<critvals(1) or thediff>critvals(2), difference is significant 

if(size(samp1,1)>1);
    samp1 = samp1';
end
if(size(samp2,1)>1);
    samp2 = samp2';
end

numreps = 10000;

hithresh = 1-(alpha/2);
lothresh = (alpha/2);

nulldist = [samp1, samp2];
nullCVdist = mBootstrapCV(nulldist);

diffdist = zeros(1,numreps);

for i=1:numreps;
   subsamp1 = nullCVdist(randi(length(nullCVdist),1,length(samp1)));
   subsamp2 = nullCVdist(randi(length(nullCVdist),1,length(samp2))); 
   diffdist(i) = mean(subsamp1) - mean(subsamp2);    
end

diffdist = sort(diffdist);

hip = diffdist(length(diffdist) * hithresh);
lop = diffdist(length(diffdist) * lothresh);

critvals = [lop,hip];
thediff = cv_median(samp1) - cv_median(samp2);

if(thediff<lop || thediff>hip)
    dispstr = ['critical values: ',num2str(critvals(1)),' to ',num2str(critvals(2)),'. ','Measured difference: ',num2str(thediff),'. ','Difference is significant at p < ',num2str(alpha)];
else
    dispstr = ['critical values: ',num2str(critvals(1)),' to ',num2str(critvals(2)),'. ','Measured difference: ',num2str(thediff),'. ','Difference is not significant'];
end
disp(dispstr);

% plotting null distribution of differences and the measured difference
% between samp1 and samp2:
[diffhist,histbins] = hist(diffdist,100);
diffhist = diffhist/sum(diffhist);
figure();plot(histbins,diffhist,'k','LineWidth',2);hold on;
found = find(histbins<lop);found=max(found);
plot(lop,diffhist(found),'ko','MarkerSize',8,'MarkerFaceColor','w');
found = find(histbins<hip);found=max(found);
plot(hip,diffhist(found),'ko','MarkerSize',8,'MarkerFaceColor','w');
if(thediff<min(histbins) || thediff>max(histbins))
    plot(thediff,0,'ro','MarkerSize',8,'MarkerFaceColor','w');hold off;
else
    found = find(histbins<thediff);
    found = max(found);
    plot(thediff,diffhist(found),'ro','MarkerSize',8,'MarkerFaceColor','w');hold off;
end

