function [filtvect] = mremovezeros(thevect)
%
%
%   function [filtvect] = mremovezeros(thevect)
%   replaces zeros with []
%
%   
%

invect = thevect(:,2);

killpnts = [];

for j=1:size(invect,1) %each point
    if(invect(j) == 0)
        killpnts = [killpnts j];
    end
end
  
filtvect = thevect;
filtvect(killpnts,:) = [];