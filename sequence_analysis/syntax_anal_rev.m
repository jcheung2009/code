function syntax_anal_rev(batchnotmats,name,syls)

name = [char(name) '.rev'];
%get the doublets
patternstrct = get_pattern_fnx_2(char(batchnotmats),'**$',1,name);
ptnprobstrct = prob_of_patterns(patternstrct);
trns_strct = make_trns_strct(ptnprobstrct,syls,'last','null',0,1,name);
%check for autotransitions
trnsmtrx = trns_strct.mtrx;
%initialize rptstrct
rptstrct.lbls{1} = 0;
rptstrct.prms(1,:) = [0 0];
rptstrct.prbdist{1} = 0;

for i = 1:length(trnsmtrx)
    if trnsmtrx(i,i) ~= 0
        rpt_ptn = char(['[' char(trns_strct.lbls(i)) ']$']);
         patternstruct = get_pattern_fnx_2(char(batchnotmats),char(rpt_ptn),0,name);
         rptstrct = count_repeats(patternstruct,rptstrct,0,char(trns_strct.lbls(i)));
     end
 end
 
 if rptstrct.prbdist{1} ~= 0
     save(char([char(name) '.rptstrct.mat']),'rptstrct')
 end