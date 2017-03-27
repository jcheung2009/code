function hitcount = jc_gethits(fv)

%fv is structure from jc_findwnote4
%extract datenum and whether syllable is hit or escape/miss

hitcount = [];
for ii = 1:length(fv)
    dn = fv(ii).datenm;
    if fv(ii).TRIG == -1
        hitcount = [hitcount; [dn 0]];
    else
        hitcount = [hitcount; [dn 1]];
    end
end
