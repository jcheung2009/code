function [avgpitch] = avgpitchfn(vlsor)

[b m] = unique(vlsor(:,1));
m = [0; m];
for i = 1:length(m)-1
    avgpitch = mean(vlsor(m(i)+1:m(i+1),2));
end


