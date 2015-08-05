function syntax_anal_fwrd(batchnotmats,name,syls)

name = [char(name) '.fwrd'];
%get single syl probabilities of occurance
patternstrct1 = get_pattern_fnx(char(batchnotmats),'*$');
p_strct= prob_of_patterns(patternstrct1,'first');
save(char([char(name) '.p_strct.mat']),'p_strct');

patternstrct = get_pattern_fnx_2(char(batchnotmats),'**$',1,name);


%get the doublets
patternstrct = get_pattern_fnx_2(char(batchnotmats),'**$',1,name);
ptnprobstrct = prob_of_patterns(patternstrct,'first');
trns_strct = make_trns_strct(ptnprobstrct,char(syls),'first','null',0,1,char(name));
%check for autotransitions
trnsmtrx = trns_strct.mtrx;
%initialize rptstrct
rptstrct.lbls{1} = 0;
rptstrct.prms(1,:) = [0 0];
rptstrct.prbdist{1} = 0;

for i = 1:length(trnsmtrx)
    if trnsmtrx(i,i) ~= 0
         rpt_ptn = ['[' char(trns_strct.lbls(i)) ']$'];
         patternstruct = get_pattern_fnx_2(char(batchnotmats),char(rpt_ptn),1,name);
         rptstrct = count_repeats(patternstruct,rptstrct,0,char(trns_strct.lbls(i)));
     end
 end
 
 if ~isempty(rptstrct.lbls)
     save(char([char(name) '.rptstrct.mat']),'rptstrct')
 end
