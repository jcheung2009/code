function [ pccorr ] = jc_pccorr2(pc,tm, timebins,maxlag)
%UNTITLED4 Summary of this function goes here
%  takes corr coef across rows instead of columns in pitch contour


downsamplesize = 5;
seg = find(tm>timebins(1) & tm<timebins(2));
seg = downsample(seg,downsamplesize);
pc = pc(seg,:);

pccorr = NaN(size(pc,1),maxlag+1);
for i = 1:size(pc,1)
    pccorr(i,:) = jc_pitchcorr5(pc(i,:),maxlag);
end




