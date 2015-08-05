function [probStr pattStr] = mprobscript(batch,syllStr,order)
%
% Wrapper for Kris' transition probabilty functions
%
% Batch = batch file of .not.mats
% 
% syllStr = syllable(s) to find transition probability. Has to end with $.
% See help file on get_pattern_fnx() for details.
% 
% order = first or last, i.e. probability of branchpoints vs converge 
%

getStruct = get_pattern_fnx(batch,syllStr);
[unqOut probOut] = prob_of_patterns(getStruct,order);

pattStr = probOut(2).vect

probStr = unqOut.prob;

unqOut.prob