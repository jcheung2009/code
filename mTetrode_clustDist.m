function [distvect distmtx] = mTetrode_clustDist(dataMtx,gmobj,numclusts)
%
% [distvect clustMtx] = mMakeClustIDMtx(dataMtx,gmobj,numclusts)
%
% calculates distance between elements in dataMtx and their closest cluster
% specified by clustIDs
% 
% gmobj is a gaussian mixture model object created by gmdistribution.fit 
%
% if dataMtx is N x M, clustIDs should be N x 1
%

datasize = size(dataMtx);
datasize = datasize(1);


%clustMtx = zeros(size(dataMtx));
distmtx = zeros(datasize,numclusts);

for clustnum=1:1:numclusts % each cluster
    %clustcoords = gmobj.mu(clustnum,:);
    for i=1:1:datasize % compute distance from each data point to each cluster center
        distmtx(i,clustnum) = pdist2(dataMtx(i,:),gmobj.mu(clustnum,:),'euclidean');        
    end
    
%     theclust = clustIDs(i);
%     clustcoords = gmobj.mu(theclust,:);
%     clustMtx(i,:) = clustcoords;    
end

% distmtx = pdist2(dataMtx,clustMtx);
distvect = min(distmtx'); % distance to nearest cluster center