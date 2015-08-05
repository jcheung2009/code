function pcstruct = jc_getpc(fv)
%fv is structure from jc_findwnote5

[maxlength ind] = max(arrayfun(@(x) length(x.pitchcontour),fv));
pcstruct.tm = fv(ind).pitchcontour(:,1);
pc = [];
for ii = 1:length(fv)
    pad = maxlength - length(fv(ii).pitchcontour);
    pitchcontour = [fv(ii).pitchcontour;NaN(pad,2)];
    pc = [pc pitchcontour];
end
pcstruct.pc = pc(:,2:2:end);
    