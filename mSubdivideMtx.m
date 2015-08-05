function [outmtx1 outmtx2] = mSubdivideMtx(dataMtx,fraction)
%
% function [fracmtx othermtx] = mSubdivideMtx(dataMtx,fraction)
%
% subdivides dataMtx into outmtx1 and outmtx2 composed of randomly chosen
% elements (without replacement) of dataMtx. outmtx1's size is 'fraction' percent
% of dataMtx, i.e. fraction=.75 will yield outmtx1 that is .75 the size of
% dataMtx, and outmtx2 that is .25 the size of dataMtx
%
% if dataMtx has multiple rows they will be preserved. 
%
% useful function for creating random training/testing sets for
% cross-validation or bootstrapping
%

datasize = size(dataMtx);
datalength = datasize(1);

randidx = randsample(datalength,round(fraction*datalength));
out1idx = zeros(1,round(datalength*fraction));
out2idx = zeros(1,(datalength-length(out1idx)));

j=1;
k=1;
for i=1:1:datalength
   if(find(randidx==i))
       out1idx(j) = i;
       j=j+1;
   else
       out2idx(k) = i;
       k=k+1;
   end      
end

outmtx1 = dataMtx(out1idx,:);
outmtx2 = dataMtx(out2idx,:);
