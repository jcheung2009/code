function [] = get_all_patterns(batchprdcd,name)

ptn = ['$'];
for i  = 1:10
    ptn = ['*' ptn];
    ptnstrct = get_pattern_fnx(batchprdcd,ptn);
    [patrnstrct{i}.lkl,temp] = prob_of_patterns(ptnstrct,'last');
    [patrnstrct{i}.prb,temp] = prob_of_patterns(ptnstrct,'first');
    patrnstrct{i}.ptns = temp(i);
end

name = [name '.allptn_strct.mat']

save(char(name),'patrnstrct')
