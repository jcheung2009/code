function [newstruct,allkillidx] = mTetrode_killClusts(tetstruct,clustIDs,killclusts)
%
% [newstruct] = mTetrode_killClusts(tetstruct,clustIDs,killclusts)
%
% sets elements of tetstruct associated with clusters in killclusts to []
%
% so if you decide that clusters 3,6, and 7 are not good units, set
% killclusts = [3 6 7] and this function will return a new tetstruct
% with those elements = []
%
% tetstruct.times
%          .waveform
%          .peak
%          .trough
%          .width
% measurements in seconds except width which is in milliseconds. all are scalar except waveform, which is a
% vector
%

allkillidx = [];

for i=1:length(killclusts)
    allkillidx = vertcat(allkillidx,find(clustIDs==i));    
end

newstruct = tetstruct;
structsize = size(tetstruct);
numchannels = structsize(2); % number of channels

for i=1:numchannels
    newstruct(i).waveform(allkillidx,:) = [];
    newstruct(i).peak(allkillidx) = [];
    newstruct(i).trough(allkillidx) = [];
    newstruct(i).width(allkillidx) = [];
end