function [outsong] = mSynth(sylls,onsets,gapdurs)
%
%  [outsong] = mSynth(sylls,onsets,gapdurs)
%
% creates new song of sylls syllables separates by gaps of gapdurs duration, in pnts 
%

totallength=0;
i=1;
for i=1:length(sylls);
    totallength = totallength + length(sylls{i});
end;

totallength = totallength+1000;

outsong = zeros(1,totallength)';

for i=1:length(sylls)
    outsong(onsets(i)+1:(onsets(i)+length(sylls{i}))) = sylls{i};
end;