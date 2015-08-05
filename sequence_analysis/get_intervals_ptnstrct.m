function [mu,med,sigma] = get_intervals_ptnstrct(ptnstrct)

%function intv_mtrx = get_intervals_ptnstrct(ptnstrct)
% returns a matrix of the inter-sylable intervals (iSi) of the notes in a
% found pattern
% <ptnstrct>: a patternstrct from get_pattern
% <mtrx>: option for output to be in matrix format or in strcture format
% if the patterns in the structure are of different lengths, then it must
% be the case that mtrx = 0, else program will crash
% mtrx defaults to 1

isivect =[]
for i =1:length(ptnstrct)-1
    for j=1:ptnstrct(i).totptnsng
        isivect = [isivect ptnstrct(i).ptnons{j}(2)-ptnstrct(i).ptnoffs{j}(1)];
    end
end


mu = mean(isivect); sigma = std(isivect); med = median(isivect);
figure; hist(isivect,30); 