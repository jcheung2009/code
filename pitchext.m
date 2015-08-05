function p = pitchext(fv_rep,el)
    if numel(fv_rep.pitchest) >= el
        p = [fv_rep.datenm fv_rep.pitchest(el)];
    else
        p = [NaN NaN];
    end