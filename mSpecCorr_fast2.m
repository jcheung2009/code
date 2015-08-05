function [corrMtx t1] = mSpecCorr_fast2(file1,file2,plotit)
%
% function [corrMtx t] = mSpecCorr_fast(song1,song2,plotit)
% 
% computes spectral correlation matrix between sounds in file 1 and file 2
%
% t is time vector, plotit is boolean, use 1 to plot
%

[pth,nm,ext]=fileparts(file1);
if (strcmp(ext,'.ebin'))
    [dat1,fs1]=readevtaf(file1,'0r');
elseif(strcmp(ext,'.cbin'))
    [dat1,fs1]=ReadCbinFile(file1);
elseif(strcmp(ext,'.wav'))
    [dat1,fs1]=wavread(file1);
end

[pth,nm,ext]=fileparts(file2);
if (strcmp(ext,'.ebin'))
    [dat2,fs2]=readevtaf(file2,'0r');
elseif(strcmp(ext,'.cbin'))
    [dat2,fs2]=ReadCbinFile(file2);
elseif(strcmp(ext,'.wav'))
    [dat2,fs2]=wavread(file2);
end


[sm1 t1 f1] = plotspect(dat1,fs1,0);
[sm2 t2 f2] = plotspect(dat2,fs2,0);

inmtx = vertcat(abs(sm1),abs(sm2));

corrMtx = faster_corr_mtrx(inmtx);

if(plotit)
   figure();imagesc(t1,t1,corrMtx); 
end

return;