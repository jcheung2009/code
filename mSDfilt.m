function [filtvect] = mSDfilt(invect,thresh,range)
%
%
% [filtvect] = mSDfilt(invect,thresh,range)
%
% removes elements of inVect with z-scores > thresh.
%
% range is 2-pnt vector containing start and stop points, i.e. [200 800] 
%

if(isempty(range))
   range = [1 length(invect)];   
end

subvect = invect(range(1):range(2),:);
sdplus = mean(subvect') + (thresh.*(std(subvect')));
sdneg = mean(subvect') - (thresh.*(std(subvect')));

[rows cols] = size(invect);
killpnts = [];

for i=1:cols %each trace
    for j=1:size(subvect,1) %each point
        if(subvect(j,i) > sdplus(j) | subvect(j,i) < sdneg(j))
            killpnts = [killpnts i];
        end
        
        
    end
end

filtvect = invect;
filtvect(:,killpnts) = [];