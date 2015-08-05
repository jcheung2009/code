function Vout = smooth_inhouse(Vin, Kern)
% function Vout = smooth(Vin, Kern)

[rv,cv] = size(Vin);
if cv ~= 1
  error('Vin must be a column vector');
end
[rk,ck] = size(Kern);
if ck ~= 1
  error('Kern must be a column vector');
end
llim = fix(rk/2) + 1;
ulim = llim + rv - 1;
PreVout = conv(Vin, Kern);
Vout = PreVout(llim:ulim,1);
