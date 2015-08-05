function [meanscores clustscores] = mTetrode_clustDist2(dataMtx,gmobj,maxclusts,plotit)
%
% [meanscores clustmtx] = mTetrode_clustDist2(dataMtx,gmobj,maxclusts,plotit)
%
% returns distance of data points in dataMtx to cluster centers specified
% by gmobj, and silhouette-like scores of each point (in clustscores) and
% avg score for each cluster (2-maxclusts, in meanscores). Score is
% (b-a)/a, where a = distance between assigned cluster center and data point and b =
% distance between data point and nearest non-assigned cluster center. So
% high scores (which are better) reflect combination of proximity of data to cluster centers
% (clustering captures data) and sufficient distance between assigned
% clusters and nearby clusters.
%
%
% gmobj is a gaussian mixture model object created by gmdistribution.fit 
%
% 
%

datasize = size(dataMtx);
numpnts = datasize(1);
numdims = datasize(2);

clustdist = zeros(1,numpnts);
clustmtx = zeros(maxclusts-1,numpnts);
othermtx = zeros(maxclusts-1,numpnts);

for theclust=2:1:maxclusts
    [distvect distmtx] = mTetrode_clustDist(dataMtx,gmobj{theclust},theclust);
    clustids = cluster(gmobj{theclust},dataMtx);    
    otherdists = zeros(1,numpnts);
    for i=1:1:numpnts        
        clustdist(i) = distmtx(i,clustids(i)); % distance to assigned cluster
        thedistvect = distmtx(i,:);
        thedistvect(find(thedistvect == clustdist(i))) = [];
        otherdists(i) = min(thedistvect);
        %otherdists(i) = min(distmtx(i,(find(distmtx(i,:)>clustdist(i))))); % distance to nearest non-assigned cluster
        clustmtx(theclust-1,i) = clustdist(i);
        othermtx(theclust-1,i) = otherdists(i);
    end
    
end

clustscores = (othermtx-clustmtx) ./ clustmtx; % similar to silhouette score
meanscores = mean(clustscores');

if(plotit)
    figure();
    plot([2:1:maxclusts],mean(clustscores'),'ro');hold on
    [hi lo] = mBootstrapCI_mtx(clustscores,.95);
    plot([2:1:maxclusts],hi,'r.');
    plot([2:1:maxclusts],lo,'r.');
    xlabel('number of clusters');
    ylabel('mean cluster score');
    hold off;
end