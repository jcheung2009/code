function fvals = jc_getfvals(fv,varargin)
%use with jc_findwnote4
%specify fields desired in varargin
%last three inputs for pitch contour parameters
%varargin = 'fv','evtafv','hc','pc'
if ~isempty(strmatch('fv',varargin))
    fvals.fv = jc_getvals(fv,'');
end

if ~isempty(strmatch('evtafv',varargin))
    [fvals.evtafv fvals.trigtime] = jc_getevtafv(fv);
end

if ~isempty(strmatch('hc',varargin))
    fvals.hc = jc_gethits(fv);
end

if ~isempty(strmatch('pc',varargin))
    minlength = min(arrayfun(@(x) length(x.smtmp),fv));
    dat = cell2mat(arrayfun(@(x) x.smtmp(1:minlength),fv,'UniformOutput',false));
    result = input('FF range:');
    result2 = input('harms:');
    [fvals.pc.pc fvals.pc.timebins fvals.pc.f fvals.pc.sp] = jc_pitchcontourFV2(dat,512,510,1,result(1),...
        result(2),result2,'obs0');
end


    