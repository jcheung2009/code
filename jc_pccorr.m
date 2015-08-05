function [pc_corr] = jc_pccorr(pc,tm,timebins,maxlag)
%cross correlation of pitch contour at specified time bins for all renditions 
%correlation coefficient of each column in matrix with lag
%pitch contour: time bin within syllable x renditions 
tic
downsamplesize = 5;
seg = find(tm>timebins(1) & tm<timebins(2));
seg = downsample(seg,downsamplesize);
pc = pc(seg,:);


pc_corr = NaN(maxlag+1,1);%NaN(size(pc,2),1);
for i = 1:maxlag+1 %size(pc,2)
    %nobs = size(pc,2);
    c = mean(diag(jc_corrcoef(pc(:,i:end),pc(:,1:end-i+1))));%nobs-(i-1) used to normalize the covariance matrix (number of observations - lag)
    pc_corr(i) = c;
end


% %shuffle columns of pitch contour
% numboot = 10;
% shuffcorr = NaN(maxlag+1,numboot);%NaN(size(pc,2),numboot);
% for i = 1:numboot
%     shuffpc = pc(:,randperm(size(pc,2)));
%     shuffcorr2 = NaN(maxlag+1,1);%NaN(size(shuffpc,2),1);
%     for ii = 1:maxlag+1 %size(shuffpc,2)
%         c = mean(diag(corrcoef2(shuffpc(:,ii:end),shuffpc(:,1:end-ii+1))));
%         shuffcorr2(ii) = c;
%     end
%     shuffcorr(:,i) = shuffcorr2;
% end
% 
% toc    