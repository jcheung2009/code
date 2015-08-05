function [] = mTetrode_clusts(tetstruct)
%
% function [] = mTetrode_clusts(tetstruct)
%
% plots spikes by peak vs trough vs width on each channel of tetstruct
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

structsize = size(tetstruct);

for i=1:1:structsize(2) % each channel
    titlestr = ['Channel ' num2str(i)];
    figure();hold on;plot3(tetstruct(i).peak,tetstruct(i).trough,tetstruct(i).width,'ro','MarkerFaceColor','w');
    title(titlestr);hold off;    
end