function fvals = jc_getfvals2(fv,varargin)
%use with jc_findwnote5
%specify fields desired in varargin
%last three inputs for pitch contour parameters
%varargin = 'fv','evtafv','hc','pc','vol'
pltit = 1;

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
  fvals.pc = jc_getpc(fv);
end

if ~isempty(strmatch('spec',varargin))
    fvals.spec = jc_getspec(fv);
end

if ~isempty(strmatch('vol',varargin))
    fvals.vol = jc_getvols(fv);
end

% if pltit == 1
%     figure;hold on;
%     imagesc(fvals.spec.tm,fvals.spec.f,log(abs(fvals.spec.spec)));syn()
%     hold on;
%     plot(fvals.pc.tm,nanmean(fvals.pc.pc,2),'k');
% end
