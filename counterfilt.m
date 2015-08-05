function [filtered,minvect] = counterfilt(rawtrigs,mincount)
%
% mnmn, 19 april 2009
%

filtered = zeros(length(rawtrigs),1);
minvect = zeros(length(rawtrigs),1);
maxvect = zeros(length(rawtrigs),1);

for index=1:length(rawtrigs)-mincount;
    min = index + mincount-1;
    minvect(index) = sum(rawtrigs(index:min));
    
    if (rawtrigs(index)==1 && sum(rawtrigs(index:min)) == mincount); % && sum(rawtrigs(index:max)) <= maxcount
        filtered(index) = 1;
    end

end



