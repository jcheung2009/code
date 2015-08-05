function prbstrct = get_prbstrct(batchnotmat,maxlng,syls,name)

prbstrct(length(syls)+1).lng =[]; prbstrct(length(syls)+1).syls = syls;

for i=1:length(syls)
    ptrn = [syls(i) '$'];
    for j=1:maxlng-1
        patrnstrct = get_pattern_fnx(batchnotmat,char(['*' ptrn]));
        [ptnprobstrct,uniqueptnsvect] = prob_of_patterns(patrnstrct);
        for l = 1:length(ptnprobstrct)-1
            prbstrct(i).lng(j).ptn{l} = ptnprobstrct(l).ptn;
            prbstrct(i).lng(j).prbs(l) = ptnprobstrct(l).prob;
        end
            prbstrct(i).lng(j).ent = ptnprobstrct(end).S_tot;
    end
end

save([char(name) '.prbstrct.' num2str(maxlng) '.' char(syls) '.mat'],'prbstrct');