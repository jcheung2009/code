function [filtvect killpnts] = mSDfilt_vect(thevect,thresh)
%
%
% [filtvect] = mSDfilt_vect(threshvect,thresh,invect)
%
% removes elements of invect where z-score of invect > thresh.
% 
% dim = dimension, use 2 to filter by pitch values returned by
% findwnote4()
%

invect = thevect(:,2);
sdplus = mean(invect) + (thresh.*(std(invect)));
sdneg = mean(invect) - (thresh.*(std(invect)));

killpnts = [];

for j=1:size(invect,1) %each point
    if(invect(j) > sdplus | invect(j) < sdneg)
        killpnts = [killpnts j];
    end
end
  
filtvect = thevect;
filtvect(killpnts,:) = [];