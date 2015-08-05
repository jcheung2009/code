function [outmtx] = mTetrode_diffMtx(tetstruct)
%
% function [outmtx] = mTetrode_diffMtx(tetstruct,)
%
% computes squared euclidean distance matrix for all spikes in tetstruct, each is regarded as 4-d vector 
%
% tetstruct.times
%          .waveform
%          .peak
%          .trough
%          .width
% measurements in seconds, except width which is in milliseconds. all are scalar except waveform, which is a
% vector
%
%
% one element of outstruct for each channel: outstruct(1) =
% channel 1, outstruct(2) = channel 2, etc
%

numspikes = length(tetstruct(1).times);
outmtx = zeros(numspikes,numspikes);

wavesize = size(tetstruct(1).waveform);
wavesize = wavesize(2);

spikeMtx1 = zeros(4,wavesize);
spikeMtx2 = zeros(4,wavesize);

for i=1:numspikes % each spike
    spikeMtx1 = vertcat(smooth(tetstruct(1).waveform(i,round(.3*wavesize):(wavesize)),5),smooth(tetstruct(2).waveform(i,round(.3*wavesize):(wavesize)),5),smooth(tetstruct(3).waveform(i,round(.3*wavesize):(wavesize)),5),smooth(tetstruct(4).waveform(i,round(.3*wavesize):(wavesize)),5));
    for j=1:numspikes % each spike again
        spikeMtx2 = vertcat(smooth(tetstruct(1).waveform(j,round(.3*wavesize):(wavesize)),5),smooth(tetstruct(2).waveform(j,round(.3*wavesize):(wavesize)),5),smooth(tetstruct(3).waveform(j,round(.3*wavesize):(wavesize)),5),smooth(tetstruct(4).waveform(j,round(.3*wavesize):(wavesize)),5));
        eucdist = sum((spikeMtx1-spikeMtx2).^2).^0.5;
        outmtx(i,j) = sum(eucdist);
    end    
end