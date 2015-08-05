function mstprbptns = get_mstprb_ptn(prb,ptns,syls,lng,mstprbptns)

for i = 1:prb(end).nmbunqptns
    crntnote = char(prb(i).cndnt);
    syl_loc = strfind(char(syls),char(crntnote));
    if ~isempty(syl_loc)
        if mstprbptns(lng).prbs(syl_loc) < prb(i).prob
            mstprbptns(lng).prbs(syl_loc) = prb(i).prob;
            fndptn = char(prb(i).ptn);
            mstprbptns(lng).ptns{syl_loc} = char(fndptn);
            cndnote_loc = strfind(char(prb(end).cndnt_vect),char(crntnote));
            mstprbptns(lng).entrpy(syl_loc) = prb(end).S_cndvect(cndnote_loc);
        end
    end
end
