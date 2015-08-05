function [meanscores clustscores] = mTetrode_oneSilScore(dataMtx,gmobj,numclusts,plotit)
%
% [meanscores clustscores] = mTetrode_oneSilScore(dataMtx,gmobj,numclusts,plotit)
% 
% returns silhouette scores for data points clustered with numclusts
% components via gaussian mixture model, specified in gmobj. 
% 
% silhoutte score for data point in dataMtx = (b-a) / max(a,b)
% a = mean distance between data point and other data points in a's cluster
% b = mean distance between data point and data points in nearest other
% cluster.
% 
% silhouette scores range between -1 and 1. Scores near 1 reflect
% appropriate clustering, scores near 0 indicate datum is on border between
% clusters, and scores near -1 indicate datum should be assigned to a
% different cluster.
%
% gmobj is a gaussian mixture model object created by gmdistribution.fit
%

datasize = size(dataMtx);
numpnts = datasize(1);
numdims = datasize(2);

clustdist = zeros(1,numpnts);
%clustmtx = zeros(maxclusts-1,numpnts);
othermtx = zeros(numclusts,numpnts);
silscores = zeros(numclusts,numpnts);

[distvect distmtx] = mTetrode_clustDist(dataMtx,gmobj,numclusts);
clustids = cluster(gmobj,dataMtx); 

for i=1:1:numpnts
    clustdist(i) = distmtx(i,clustids(i)); % distance to assigned cluster
    sameclustids = find(clustids==clustids(i));
    samedists = pdist2(dataMtx(i,:),dataMtx(sameclustids,:)); % distances to points in same cluster
    thedistvect = distmtx(i,:); % distances between data point and each cluster center
    tempdistvect = thedistvect;
    tempdistvect(find(thedistvect == clustdist(i))) = []; % remove data point's assigned cluster from this vector
    theotherdist = min(tempdistvect);
    nearestclust = find(thedistvect == theotherdist); % find the next nearest cluster ID
    %otherdists(i) = min(thedistvect);
    otherclustids = find(clustids==nearestclust);
    otherdists = pdist2(dataMtx(i,:),dataMtx(otherclustids,:)); % distances from data point to points in nearest other cluster
    clustmtx(numclusts,i) = mean(samedists);
    othermtx(numclusts,i) = mean(otherdists);
    silscores(numclusts,i) = (mean(otherdists)-mean(samedists)) / max(mean(otherdists),mean(samedists));
end

clustscores = silscores; % silhouette scores for each point
meanscores = mean(clustscores');

if(plotit)
    % generate distinct colors for each cluster
    cmap = brighten(colormap(jet),.5);
    colorvect = zeros(numclusts,3);
    colorvect(1,:) = cmap(1,:);
    for i=2:1:length(colorvect);
        coloridx = i*floor(length(cmap)/length(colorvect));
        colorvect(i,:) = cmap(coloridx,:);
    end
    figure();hold on;
    pickup = 1;
    for i=1:numclusts % silhouette scores within each cluster for the best number of clusters
        plot([pickup:pickup+length(find(clustids==i))-1],sort(silscores(numclusts,find(clustids==i)),'descend'),'o','Color',colorvect(i,:));
        pickup = pickup +length(find(clustids==i));
    end
    ylim([-1 1]); ylabel('Silhouette Score');xlabel('data points sorted by cluster and Silhouette Score');
    zeroline = [length(silscores(i,:))/25:length(silscores(i,:))];
    plot(zeroline,0,'r-.');
    hold off;     
end
