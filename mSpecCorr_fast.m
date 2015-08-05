function corrMtx = mSpecCorr_fast(file1,file2)
%
% function corrMtx = mSpecCorr_fast(song1,song2)
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

mtxsize = min(size(sm1,2),size(sm2,2));
corrMtx = zeros(mtxsize);

sm1norm = bsxfun(@minus,sm1,mean(sm1,1));
sm2norm = bsxfun(@minus,sm2,mean(sm2,1));

sm1L2norm = bsxfun(@times,sm1norm,1./sqrt(sum(sm1norm.^2,1)));
sm2L2norm = bsxfun(@times,sm2norm,1./sqrt(sum(sm2norm.^2,1)));

%corrMtx = sum(sm1L2norm.*sm2L2norm,1);
for i=1:mtxsize
    for j=1:mtxsize
        corrMtx(i,j) = sum(sm1L2norm(:,i).*sm2L2norm(:,j),1);
    end
end


return;