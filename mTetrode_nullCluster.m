function [metaclusts] = mTetrode_nullCluster(dataMtx,maxclusts);
%
% function [] = mTetrode_nullCluster(dataMtx);
%
% creates null distribution of distances between points in dataMtx & random
% cluster centroids from 2 to maxclusts clusters.
%
%

metaiter = 100; %
metaclusts = zeros(1,metaiter);
metahi = zeros(metaiter,maxclusts-2);
metalow = zeros(metaiter,maxclusts-2);

datasize = size(dataMtx);
datasize = datasize(1);
distmtx = zeros(datasize,maxclusts);

for metai=1:1:metaiter;
    centroids = mRandFromDist(dataMtx,maxclusts); % random cluster centroids
    for theclust=1:1:maxclusts        
        for i=1:1:datasize % compute distance from each data point to each cluster center
            distmtx(i,theclust) = pdist2(dataMtx(i,:),centroids(theclust,:),'euclidean');
        end
    end
    metaclusts(metai) = mean(min(distmtx'));
end