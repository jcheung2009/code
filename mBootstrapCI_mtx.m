function [hiconf loconf] = mBootstrapCI_mtx(inMtx,alpha)
%
% [hiconf loconf] = mBootstrapCI_mtx(inMtx,alpha)
%
% returns high and low confidence intervals for each column of matrix inMtx
%
% each output is a vector
%
% bootsrapping uses samples of 20 for length(invect)>40, or else samples of 5
% uses 5000 iterations with replacement.

datasize = size(inMtx);
datasize = datasize(1);

hiconf = zeros(1,datasize);
loconf = zeros(1,datasize);

for i=1:1:datasize
   [thehi thelow] = mBootstrapCI(inMtx(i,:),alpha);
   hiconf(i) = thehi;
   loconf(i) = thelow;   
end
