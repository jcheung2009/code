function p = entext(fv_rep,el)
    if numel(fv_rep.ent) >= el
        p = [fv_rep.datenm fv_rep.ent(el)];
    else
        p = [NaN NaN];
    end