function [filtvect, killpnts] = mremovenans(invect)
%
%
%   function [filtvect,killpnts] = mremovenans(thevect)
%   replaces nans with [], killpnts are indices of nans
%
%   


killpnts = [];

for j=1:length(invect) %each point
    if(isnan(j))
        killpnts = [killpnts j];
    end
end
  
filtvect = invect;
filtvect(killpnts,:) = [];