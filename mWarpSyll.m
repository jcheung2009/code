function [linearWV warpF] = mWarpSyll(theSyll,targetLength)
%
%
% [warpedsyll warpfact] = mWarpSyll(theSyll,targetLength)
%
%
%

warpF = length(theSyll)/targetLength;

if abs(warpF - 1) > 1-.9858
    %wv = pvoc(PreTW.wvfrm{p},warpF(p),128);
    wv = pvoc(theSyll',warpF,128);
else
    %wv = PreTW.wvfrm{p};
    wv = theSyll;
end

warpF = length(wv)/targetLength;

linearWV = interp1(wv,[1:targetLength],'spline');
