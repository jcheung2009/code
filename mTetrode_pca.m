function [pcacoefs pcascores pcavar pcat2] = mTetrode_pca(tetstruct,plotit)
%
% function [pca coeff pcavar pcascores pcac2] = mTetrode_pca(tetstruct,plotit)
% principal component analysis of tetrode peak, trough, width data. 12
% dimensions total
%
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

tetstruct_size = size(tetstruct(1).peak);
tetstruct_size = tetstruct_size(1);

rawMtx = zeros(tetstruct_size,12);

Mtxi = 0;
for i=1:1:4; 
    rawMtx(:,i+Mtxi) = tetstruct(i).peak;
    rawMtx(:,Mtxi+i+1) = tetstruct(i).trough;
    rawMtx(:,Mtxi+i+2) = tetstruct(i).width;
    Mtxi = Mtxi + 2;
end

stdr = std(rawMtx);
zmtx = rawMtx./repmat(stdr,tetstruct_size,1); % data matrix normalized to zscores

[pcacoefs pcascores pcavar pact2] = princomp(zmtx);
pcavar_explained = 100*pcavar/sum(pcavar);

if(plotit)
   figure();
   plot(pcavar_explained,'ko-','MarkerSize',7,'MarkerFaceColor','k');
   figure();plot3(pcascores(:,1),pcascores(:,2),pcascores(:,3),'bo','MarkerSize',4,'MarkerFaceColor','w');
    
end

