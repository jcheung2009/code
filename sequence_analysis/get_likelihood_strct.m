function lklhd_strct = get_likelihood_strct(intgtm_strct_med,intgtm_strct,batchnotmat)






%each syllable
for n = 1:length(intgtm_strct)
    stridx = strfind(char(intgtm_strct(n).ptns),'*');
    slshidx = strfind(char(intgtm_strct(n).ptns),'/');
    %each length
    for p = 1:length(stridx)
        pattern = 
            patternstrct = get_pattern_fnx(batchnotmat,sequence);
            [ptnprobstrct,uniqueptnsvect] = prob_of_patterns(patternstrct,'last');
    end
    %extract likelihoods for individual sequences
          sequence = char(intgtm_strct(n).ptns(stridx(p)+1:slshidx(p+1)-1));
    
    
    
end



