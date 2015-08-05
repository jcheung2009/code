function [] = mTetrode_PlotClusts(tetstruct)
% function [] = mTetrode_plotClusts(tetstruct)
%
% plots peak1 vs peak2 vs peak3, peak1 vs peak3 vs peak4, peak2 vs peak3 vs
% peak4 for each channel. 
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
figure();title('peaks')%subplot(1,3,1);
plot3(tetstruct(1).peak,tetstruct(2).peak,tetstruct(3).peak,'ro','MarkerFaceColor','w','MarkerSize',4);
figure();title('peaks')%subplot(1,3,2);
plot3(tetstruct(1).peak,tetstruct(3).peak,tetstruct(4).peak,'ro','MarkerFaceColor','w','MarkerSize',4);
figure();title('peaks')%subplot(1,3,3);
plot3(tetstruct(2).peak,tetstruct(3).peak,tetstruct(4).peak,'ro','MarkerFaceColor','w','MarkerSize',4);


% troughs
%figure();hold on;title('troughs')
figure();title('troughs');%subplot(1,3,1);
plot3(tetstruct(1).trough,tetstruct(2).trough,tetstruct(3).trough,'bo','MarkerFaceColor','w','MarkerSize',4);
figure();title('troughs');%subplot(1,3,2);
plot3(tetstruct(1).trough,tetstruct(3).trough,tetstruct(4).trough,'bo','MarkerFaceColor','w','MarkerSize',4);
figure();title('troughs');%subplot(1,3,3);
plot3(tetstruct(2).trough,tetstruct(3).trough,tetstruct(4).trough,'bo','MarkerFaceColor','w','MarkerSize',4);


% widths
%figure();hold on;title('widths')
figure();title('widths');%subplot(1,3,1);
plot3(tetstruct(1).width,tetstruct(2).width,tetstruct(3).width,'ko','MarkerFaceColor','w','MarkerSize',4);
figure();title('widths');%subplot(1,3,2);
plot3(tetstruct(1).width,tetstruct(3).width,tetstruct(4).width,'ko','MarkerFaceColor','w','MarkerSize',4);
figure();title('widths');%subplot(1,3,3);
plot3(tetstruct(2).width,tetstruct(3).width,tetstruct(4).width,'ko','MarkerFaceColor','w','MarkerSize',4);

    
    
    
    
