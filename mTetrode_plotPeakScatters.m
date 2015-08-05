function [] = mTetrode_plotPeakScatters(tetstruct)
% function [] = mTetrode_plotPeakvTrough(tetstruct)
%
% plots peak1 vs peak2, peak1 vs peak3, peak2 vs peak3, etc
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

h=figure();hold on
subplot(3,2,1);plot(tetstruct(1).peak,tetstruct(2).peak,'ro','MarkerSize',2);
subplot(3,2,2);plot(tetstruct(1).peak,tetstruct(3).peak,'ro','MarkerSize',2);
subplot(3,2,3);plot(tetstruct(1).peak,tetstruct(4).peak,'ro','MarkerSize',2);
subplot(3,2,4);plot(tetstruct(2).peak,tetstruct(3).peak,'bo','MarkerSize',2);
subplot(3,2,5);plot(tetstruct(2).peak,tetstruct(4).peak,'bo','MarkerSize',2);
subplot(3,2,6);plot(tetstruct(3).peak,tetstruct(4).peak,'ko','MarkerSize',2);
hold off;
tightfig(h);