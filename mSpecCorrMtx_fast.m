function corrMtx = mSpecCorrMtx_fast(mtx1,mtx2)
%
% function corrMtx = mSpecCorrMtx_fast(mtx1,mtx2)
% 
% computes spectral correlation matrix between matrices mtx1 & mtx2.
%
%

mtxsize = min(size(mtx1,2),size(mtx2,2));
corrMtx = zeros(mtxsize);

sm1norm = bsxfun(@minus,mtx1,mean(mtx1,1));
sm2norm = bsxfun(@minus,mtx2,mean(mtx2,1));

sm1L2norm = bsxfun(@times,sm1norm,1./sqrt(sum(sm1norm.^2,1)));
sm2L2norm = bsxfun(@times,sm2norm,1./sqrt(sum(sm2norm.^2,1)));

%corrMtx = sum(sm1L2norm.*sm2L2norm,1);
for i=1:mtxsize
    for j=1:mtxsize
        corrMtx(i,j) = sum(sm1L2norm(:,i).*sm2L2norm(:,j),1);
    end
end


return;