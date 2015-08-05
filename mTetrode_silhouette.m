function [meanscores clustscores] = mTetrode_silhouette(dataMtx,gmobj,maxclusts,plotit)
%
% [distvect clustmtx] =  mTetrode_silhouette(dataMtx,gmobj,maxclusts,plotit)
%
% returns silhouette scores of each point (clustscore) and mean silhouette scores (meanscores) of
% each cluster value (2-maxclusts).
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
clustmtx = zeros(maxclusts-1,numpnts);
othermtx = zeros(maxclusts-1,numpnts);
silscores = zeros(maxclusts-1,numpnts);

for theclust=2:1:maxclusts
    [distvect distmtx] = mTetrode_clustDist(dataMtx,gmobj{theclust},theclust);
    clustids = cluster(gmobj{theclust},dataMtx);    
    %otherdists = zeros(1,numpnts);
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
        clustmtx(theclust-1,i) = mean(samedists);
        othermtx(theclust-1,i) = mean(otherdists);
        silscores(theclust-1,i) = (mean(otherdists)-mean(samedists)) / max(mean(otherdists),mean(samedists));
        if(silscores(theclust-1,i)==0)
            disp()
        end
    end
    
end

clustscores = silscores; % silhouette scores for each point
meanscores = mean(clustscores');

[themax maxloc] = max(meanscores);
bestclustscores = zeros(1,maxloc);  % best number of clusters = maxloc + 1
clustids = cluster(gmobj{maxloc+1},dataMtx);

if(plotit)
    % generate distinct colors for each cluster
    cmap = brighten(colormap(jet),.5);
    colorvect = zeros(maxloc+1,3);
    colorvect(1,:) = cmap(1,:);
    for i=2:1:length(colorvect);
        coloridx = i*floor(length(cmap)/length(colorvect));
        colorvect(i,:) = cmap(coloridx,:);
    end
    figure();subplot(2,1,2);hold on;
    pickup = 1;
    for i=1:maxloc+1 % silhouette scores within each cluster for the best number of clusters
        plot([pickup:pickup+length(find(clustids==i))-1],sort(silscores(maxloc+1,find(clustids==i)),'descend'),'o','Color',colorvect(i,:));
        pickup = pickup +length(find(clustids==i));
    end
    ylim([-1 1]); ylabel('Silhouette Score');xlabel('data points sorted by cluster and Silhouette Score');
    zeroline = [length(silscores(i,:))/25:length(silscores(i,:))];
    plot(zeroline,0,'r-.');
    hold off;
    
    subplot(2,1,1);title('Silhouette Scores for Range of Clusters Tested')
    plot([2:1:maxclusts],mean(clustscores'),'ro');hold on
    [hi lo] = mBootstrapCI_mtx(clustscores,.95);
    plot([2:1:maxclusts],hi,'r.');
    plot([2:1:maxclusts],lo,'r.');
    xlabel('number of clusters');
    ylabel('mean silhouette score');
    xlim([1 maxclusts+1]);
    hold off;    
end
