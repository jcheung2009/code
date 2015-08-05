function [filtidx] = mTetrode_filterClusts(tetstruct,postprob,thresh,plotit)
%
% function [filtidx] = mTetrode_filterClusts(tetstruct,postprob,thresh,plotit)
% 
% identifies spikes that have uncertain posterior probabilities of cluster
% membership, determined by thresh. If max posterior prob is < thresh, the
% spike's index in tetstruct is included in filtidx
%
% thresh should be between 0 and 1
%
% if plotit == 1, will plot peak vs peak of all spikes in blue and those
% that fall below prob threshold in red
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

filtidx = zeros(1,length(postprob));

filti = 1;
for i=1:1:length(postprob) % each spike
    if(max(postprob(i,:)) < thresh)
        filtidx(filti) = i;
        filti = filti + 1;
    end   
end

filtidx(find(filtidx==0)) = [];

if(plotit)
    h=figure();hold on
    subplot(3,2,1);plot(tetstruct(1).peak,tetstruct(2).peak,'ko','MarkerSize',2);hold on;
    plot(tetstruct(1).peak(filtidx),tetstruct(2).peak(filtidx),'ro','MarkerSize',2,'MarkerFaceColor','r');hold off;
    subplot(3,2,2);plot(tetstruct(1).peak,tetstruct(3).peak,'ko','MarkerSize',2);hold on;
    plot(tetstruct(1).peak(filtidx),tetstruct(3).peak(filtidx),'ro','MarkerSize',2,'MarkerFaceColor','r');hold off;
    subplot(3,2,3);plot(tetstruct(1).peak,tetstruct(4).peak,'ko','MarkerSize',2);hold on;
    plot(tetstruct(1).peak(filtidx),tetstruct(4).peak(filtidx),'ro','MarkerSize',2,'MarkerFaceColor','r');hold off;
    subplot(3,2,4);plot(tetstruct(2).peak,tetstruct(3).peak,'ko','MarkerSize',2);hold on;
    plot(tetstruct(2).peak(filtidx),tetstruct(3).peak(filtidx),'ro','MarkerSize',2,'MarkerFaceColor','r');hold off
    subplot(3,2,5);plot(tetstruct(2).peak,tetstruct(4).peak,'ko','MarkerSize',2);hold on
    plot(tetstruct(2).peak(filtidx),tetstruct(4).peak(filtidx),'ro','MarkerSize',2,'MarkerFaceColor','r');hold off;
    subplot(3,2,6);plot(tetstruct(3).peak,tetstruct(4).peak,'ko','MarkerSize',2); hold on;
    plot(tetstruct(3).peak(filtidx),tetstruct(4).peak(filtidx),'ro','MarkerSize',2,'MarkerFaceColor','r'); hold off;
    hold off;
    tightfig(h);    
end
