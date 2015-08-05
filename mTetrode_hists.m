function [] = mTetrode_hists(tetstruct)
%
% function [] = mTetrode_hists(tetstruct)
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

fig=figure();title('peaks amp');hold on;
for i=1:1:structsize(2)
   [histdat histbins] = hist(tetstruct(i).peak,100); 
   subplot(structsize(2),1,i);
   plot(histbins,histdat);    
end
hold off;

fig=figure();title('trough amp');hold on;
for i=1:1:structsize(2)
   [histdat histbins] = hist(tetstruct(i).trough,100); 
   subplot(structsize(2),1,i);
   plot(histbins,histdat);    
end
hold off;

fig=figure();hold on;title('spike width')
for i=1:1:structsize(2)
   [histdat histbins] = hist(tetstruct(i).width,100); 
   subplot(structsize(2),1,i);
   plot(histbins,histdat);    
end
hold off;

