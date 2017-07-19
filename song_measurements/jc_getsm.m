function smstruct = jc_getsm(fv,varargin)
%fv is structure from jc_findwnote5
if ~isfield(fv,'sm') 
    sm = arrayfun(@(x) evsmooth(x.smtmp,varargin{1},'','','',5),fv,'unif',0);
    [fv(:).sm] = deal(sm{:});
end
[maxlength ind] = max(arrayfun(@(x) length(x.sm),fv));
smstruct.tm = [0:maxlength-1];
sm = [];
for ii = 1:length(fv)
    pad = maxlength - length(fv(ii).sm);
    contour = [fv(ii).sm;NaN(pad,1)];
    sm = [sm contour];
end
smstruct.sm = sm;