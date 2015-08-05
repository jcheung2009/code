function [spec t f] = plotspect(rawsong,fs,plotit)
%
%  [spec t f] = plotspect(rawsong,fs,plotit)
%
%
%

rawsong = rawsong * 1e3;

[smoothed spec t f] = evsmooth(rawsong,fs,2,256,0.85,2.5);

if(plotit)
    %figure();
    imagesc(t,f,log(abs(spec)));
    syn;ylim([0,1e4]);
    colormap('jet');
end