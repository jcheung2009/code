function specstruct = jc_getspec(fv)
%fv is structure from jc_findwnote5

[maxlength ind] = max(arrayfun(@(x) length(x.spec.tm),fv));
freqlength = max(arrayfun(@(x) length(x.spec.f),fv));

spec = zeros(freqlength,maxlength);
for ii = 1:length(fv)
    pad = maxlength-length(fv(ii).spec.tm);
    spec = spec + [fv(ii).spec.sp,zeros(size(fv(ii).spec.sp,1),pad)];
end
spec = spec./length(fv);
specstruct.spec = spec;
specstruct.f = fv(ind).spec.f;
specstruct.tm = fv(ind).spec.tm;
