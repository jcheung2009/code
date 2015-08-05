function [filtstruct] = mTetrode_RemoveStructidx(tetstruct,killidx)
%
% function [filtstruct] = mTetrode_RemoveStructidx(tetstruct,killidx)
% 
% removes elements in killidx from tetstruct
%
% tetstruct.times
%          .waveform
%          .peak
%          .trough
%          .width
% measurements in seconds. all are scalar except waveform, which is a
% vector
% 
% one element of outstruct for each channel: outstruct(1) =
% channel 1, outstruct(2) = channel 2, etc
%

filtstruct = tetstruct;
structsize = size(tetstruct);
structsize = structsize(2);


for sidx=1:1:structsize
    filtstruct(sidx).waveform(killidx,:) = [];
    filtstruct(sidx).peak(killidx) = [];
    filtstruct(sidx).trough(killidx) = [];
    filtstruct(sidx).width(killidx) = [];    
end



