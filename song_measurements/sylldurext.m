function p = sylldurext(fv_rep,el)
    if numel(fv_rep.sylldurations) >= el
        p = [fv_rep.datenm fv_rep.sylldurations(el)];
    else
        p = [NaN NaN];
    end