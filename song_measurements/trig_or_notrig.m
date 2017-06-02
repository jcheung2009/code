function [TRIG ISCATCH trigtime] = trig_or_notrig(rd,ton,toff);
%function determine if trigger occurred during target time
%rd is structure read from recfile 
%ton and toff are onset and offset time of target
%TRIG=1,ISCATCH=1 for catch; 
%TRIG=1,ISCATCH=-1/0 for detect/hit; 
%TRIG=-1,ISCATCH=-1 for escape; 
%TRIG=0,ISCATCH=-1 for escape

if (isfield(rd,'ttimes'))
    trigindtmp=find((rd.ttimes>=ton)&(rd.ttimes<=toff));%find trigger time for syllable
    if (length(trigindtmp)>0)%if exist trigger time for syllable...
        TRIG=1;%hits
        trigtime = rd.ttimes(trigindtmp);
        if (isfield(rd,'catch'))
            ISCATCH=rd.catch(trigindtmp);%determine whether trigger time was hit or catch
        else
            ISCATCH=-1;%hits
        end
    else
        TRIG=-1;%escapes and misses
        ISCATCH=-1;
        trigtime = [];
    end
else
    TRIG=0;%escapes and misses
    ISCATCH=-1;
    trigtime = [];
end