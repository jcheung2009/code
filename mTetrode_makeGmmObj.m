function [gmmodel] = mTetrode_makeGmmObj(dataMtx,maxclusts)
%
% function [gmmodel] = mTetrode_makeGmmObj(dataMtx,maxclusts)
%
% generates gaussian mixture model object via gmdistribution() for data in
% dataMtx. Generates models from 2-maxclusts gaussians
%
% gmmodel is a cell array of gmm objects
%

gmmodel = cell(1,maxclusts);
reps = 25; % number of fits to try for each cluster


for theclust=2:1:maxclusts
    gmmodel{theclust} = gmdistribution.fit(dataMtx,theclust,'Replicates',reps,'CovType','Full','SharedCov',logical(1));  
end

