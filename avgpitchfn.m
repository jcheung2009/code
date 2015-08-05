function [avgpitch,b] = avgpitchfn(vlsor)

[b m] = unique(vlsor(:,1));
m = [0; m];
avgpitch = [];
for i = 1:length(m)-1
    a = mean(vlsor(m(i)+1:m(i+1),2));
    avgpitch = [avgpitch; a] ;
end


