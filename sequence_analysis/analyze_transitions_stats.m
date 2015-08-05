function [ptnprobstrct] = analyze_transitions_stats(batchnotmat,length,name,grph)

if nargin <3, name = 'test'; grph=0; end


ptn = repmat('*',1,length);
patternstrct = get_pattern_fnx(batchnotmat,[ptn '$']);
[ptnprobstrct,uniqueptnsvect] = prob_of_patterns(patternstrct);
if length ==2
    [trns_strct] = make_trns_mtrx(ptnprobstrct,ptnprobstrct(end).cndnt_vect,'null',grph,1,name);
end
