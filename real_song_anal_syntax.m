function real_song_anal_syntax(batchnotmats,name)

patternstruct =get_pattern_fnx(char(batchnotmats),'*$');
[ptnprobstrct,uniqueptnsvect] = prob_of_patterns(patternstruct,1);
[idx,syls] = find(uniqueptnsvect(1).vect ~= '$');
syls = uniqueptnsvect(1).vect(syls) 
%first do the entropy_anal
cndentropy_lngth_2rev(batchnotmats,5,syls,1,name);
cndentropy_lngth_2fwrd(batchnotmats,5,syls,1,name);


%second do syntax_anal
syntax_anal_rev(batchnotmats,name,syls);
syntax_anal_fwrd(batchnotmats,name,syls);


%finally, examine the intersyllable intervals
patternstruct =get_pattern_fnx(char(batchnotmats),'**$');
[isiStrct] = get_iSi_ptnstrct(patternstruct,syls,name)