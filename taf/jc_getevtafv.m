function [evtafv trigtime] = jc_getevtafv(fv)
%fv is structure from jc_findwnote4
%extracts evtaf pitch estimates and trigger times from rec file  

if ~isfield(fv,'evtaf')
    disp('no evtafv')
else
    evtafv = struct('hit',[],'esc',[]);trigtime = [];
    for i = 1:length(fv)
        if isempty(fv(i).evtaf) 
            continue
        end
        
        if fv(i).TRIG == -1
            evtafv.esc = [evtafv.esc; [fv(i).datenm fv(i).evtaf]];
        else 
            evtafv.hit = [evtafv.hit; [fv(i).datenm fv(i).evtaf]];
            trigtime = [trigtime; fv(i).TRIG];
        end
    end
end


