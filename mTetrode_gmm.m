function [clustscores,gmmobj,dataMtx,kidx] = mTetrode_gmm(tetstruct,numclusts,maxclusts,fs,plotit)
% [] = mTetrode_gmm(tetstruct,numclusts,fs,plotit)
%
% Gaussian Mixture Model clustering of extracted spike data (peak, trough, width) in
% tetstruct
%
% generate tetstruct with mTetrode_analyzeCbin()
%
% set numclusts to 0 if you want function to iteratively estimate number of clusters,
% fewer than maxclust. Setting maxclusts > 100 will make this take
% forever, unless you don't have many spikes in tetstruct
%
% tetstruct.times
%          .waveform
%          .peak
%          .trough
%          .width
% measurements in seconds except width which is in milliseconds. all are scalar except waveform, which is a
% vector
% 
% one element of outstruct for each channel: outstruct(1) =
% channel 1, outstruct(2) = channel 2, etc
%
%

disttype = 'euclidean';
nummeasures = 2; % number of measurements in tetstruct, default is 3 (peak, trough, width)

structsize = size(tetstruct);
structsize = structsize(2); % number of channels
spikecount = length(tetstruct(1).peak); % number of spikes/measurements 

% assemble data matrix for clustering
dataMtx = zeros(spikecount,structsize*nummeasures);
for i=1:1:structsize % each channel
    dataMtx(:,i) = tetstruct(i).peak;
    dataMtx(:,i+structsize) = tetstruct(i).trough;
    %dataMtx(:,i+(structsize*2)) = abs(tetstruct(i).width);    
end

%dataMtx = zscore(dataMtx); % normalize in case gmdistrubution has problems with differences in scale
% [pcacoeff pcascores pcaeigen] = princomp(dataMtx); % PCA
% dataMtx = pcascores(:,1:5);

if(numclusts)
    gmmobj = gmdistribution.fit(dataMtx,numclusts,'Replicates',100,'CovType','full','SharedCov',logical(1));    
    kidx = cluster(gmmobj,dataMtx);
    postProb = posterior(gmmobj,dataMtx);
    [meanscores clustscores] = mTetrode_oneSilScore(dataMtx,gmmobj,numclusts,1);   
    AICvect = [];
else % use cross-validation to determine number of clusters
    %[AICvect AICobj weightedclusts unweightedclusts]=mTetrode_AIC(dataMtx,maxclusts); % Akaike Info Criterium for comparing models with different cluster numbers
    %numclusts = weightedclusts;
    %gmmobj = gmdistribution.fit(dataMtx,numclusts,'Replicates',5,'CovType','full');    
    %[metaclusts kidx gmmobj] = mTetrode_xval(dataMtx,maxclusts,0); % cross-validation to determine number of clusters
    %numclusts = max(kidx);
    %numclusts = mode(metaclusts);
    gmmobj = mTetrode_makeGmmObj(dataMtx,maxclusts);
    %[meanscores clustscores] = mTetrode_clustDist2(dataMtx,gmmobj,maxclusts,1); % score clusters with sillhouette-like scores to determine good number of clusters
    [meanscores clustscores] = mTetrode_silhouette(dataMtx,gmmobj,maxclusts,1); % silhouette scores for each cluster number
    [themax maxloc] = max(meanscores);
    numclusts = maxloc+1;   
    gmmobj = gmmobj{numclusts};
    kidx = cluster(gmmobj,dataMtx);
    postProb =  posterior(gmmobj,dataMtx); 
end

if(plotit)
   mTetrode_plotKmeans(tetstruct,kidx,fs,1);   
   %mTetrode_plotPCA(tetstruct,dataMtx,kidx,fs,1);
end