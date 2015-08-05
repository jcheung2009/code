function [] = mTetrode_plotPeakvTrough(tetstruct)
% function [] = mTetrode_plotPeakvTrough(tetstruct)
%
% plots peak1 vs trough2 vs trough3, etc
%
% does same for troughs & widths
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

structsize=size(tetstruct);

% peaks
%figure();hold on;title('peaks')
figure();%subplot(1,3,1);
plot3(tetstruct(1).peak,tetstruct(2).trough,tetstruct(3).width,'ro','MarkerFaceColor','w','MarkerSize',4);
figure();title('peaks')%subplot(1,3,2);
plot3(tetstruct(1).peak,tetstruct(3).trough,tetstruct(4).width,'ro','MarkerFaceColor','w','MarkerSize',4);
figure();title('peaks')%subplot(1,3,3);
plot3(tetstruct(2).peak,tetstruct(3).trough,tetstruct(4).width,'ro','MarkerFaceColor','w','MarkerSize',4);
