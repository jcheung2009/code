function p = volext(fv_rep,el)
    if numel(fv_rep.amp) >= el
        p = [fv_rep.datenm fv_rep.amp(el)];
    else
        p = [NaN NaN];
    end