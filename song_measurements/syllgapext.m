function p = syllgapext(fv_rep,el)
    if numel(fv_rep.syllgaps) >= el
        p = [fv_rep.datenm fv_rep.syllgaps(el)];
    else
        p = [NaN NaN];
    end