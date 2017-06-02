function smstruct = jc_getsm(fv)
%fv is structure from jc_findwnote5

[maxlength ind] = max(arrayfun(@(x) length(x.sm),fv));
smstruct.tm = [0:maxlength-1];
sm = [];
for ii = 1:length(fv)
    pad = maxlength - length(fv(ii).sm);
    contour = [fv(ii).sm;NaN(pad,1)];
    sm = [sm contour];
end
smstruct.sm = sm;