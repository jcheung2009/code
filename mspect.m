function [sp] = mspect(inMtx,fs)
%
%
% plots spectrogram of data in inMtx
%
%
bnds = [1/fs (length(inMtx)*(1/fs))];

inMtx=ceil(inMtx(bnds(1)*fs:bnds(2)*fs));
[sm,sp,t,f]=evsmooth(inMtx,fs,50);

imagesc(t,f,log(abs(inMtx)));syn;ylim([0,1e4]);
hold on;
colormap('hot');
hold off;
