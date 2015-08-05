function corrMtx = mSpecCorr(file1,file2)
%
% function corrMtx = mSpecCorr(song1,song2)
% 
% computes spectral correlation matrix between sounds in file 1 and file 2
%
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

mtxsize = min(size(sm1),size(sm2));
corrMtx = zeros(mtxsize(1),mtxsize(2));

waithandle = waitbar(0,'starting...');
for i=1:mtxsize(2) % each time slice
    waithandlej = waitbar(0,'Mtx 2 Starting');
    for j=1:mtxsize(2)
        corrMtx(i,j) = corr(sm1(:,i),sm2(:,j));
        waitbar(j/mtxsize(2),waithandlej,'Mtx2 working...');
    end
    close(waithandlej);
    waitbar(i/mtxsize(2),waithandle,'working...');
end
close(waithandle);
return;
