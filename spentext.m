function p = spentext(fv_rep,el)
    if numel(fv_rep.entsp) >= el
        p = [fv_rep.datenm fv_rep.entsp(el)];
    else
        p = [NaN NaN];
    end