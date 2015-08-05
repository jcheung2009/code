function [ccpvar,ccpmean,nccp] = calc_ccpstats(data,ccut)
% Compute the center clipped peak amplitude statistics

data_len = length(data);
ccpvar = 0;
ccpmean = 0;
nccp = 0;
for i=2:data_len-1
  if (data(i) > ccut & data(i) > data(i-1) & ...
	data(i) > data(i+1)) | ...
	(data(i) < -ccut & data(i) < data(i-1) & ...
	data(i) < data(i+1)) 
    ccpvar = ccpvar + data(i)^2;
    ccpmean = ccpmean + data(i);
    nccp = nccp + 1;
  end  
end
ccpvar = ccpvar/nccp;
ccpmean = ccpmean/nccp;
