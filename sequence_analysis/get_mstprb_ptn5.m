function mstprbptns = get_mstprb_ptn5(prb,ptns,syls)

%initialize the structure
mstprbptn(1).ptns
for l = 1:length(syls)
    mstprbptn(1).ptns{l} = char(syls(l));
    mstprbptn(5).prbs(l) = 0;
    mstprbptn(1).prbs(l) = 1;
end

for i = 1:prb(end).nmbunqptns
    crntnote = char(prb(i).cndnt);
    syl_loc = strfind(char(syls),char(crntnote));
    if ~isempty(syl_loc)
        if mstprbptn(5).prbs(syl_loc) < prb(i).prob
            mstprbptn(5).prbs(syl_loc) = prb(i).prob;
            mstprbptn(5).ptns{syl_loc} = char(prb(i).ptn);
            cndnote_loc = strfind(char(prb(end).cndnt_vect),char(crntnote));
            mstprbptns(5).entrpy(syl_loc) = prb(end).S_cndvect(cndnote_loc);
        end
    end
end
