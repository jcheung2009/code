function [TRIG ISCATCH trigtime] = trig_or_notrig(rd,ton,toff,varargin);
%function determine if trigger occurred during target time
%rd is structure read from recfile 
%ton and toff are onset and offset time of target
%fb_dur is duration of fb. consider syllable triggered if trig onset + fb
%duration is within 40 ms premotor window
%also consider syllable triggered if ton occurs within ton and toff
%TRIG=1,ISCATCH=1 for catch; 
%TRIG=1,ISCATCH=-1/0 for detect/hit; 
%TRIG=-1,ISCATCH=-1 for escape; 
%TRIG=0,ISCATCH=-1 for escape

if ~isempty(varargin)
    fb_dur = varargin{1};
else
    fb_dur = '';
end

if (isfield(rd,'ttimes'))
    if ~isempty(fb_dur)
        trigindtmp = find((ton-rd.ttimes)>=0 & (ton-rd.ttimes)<=fb_dur+40);
        if isempty(trigindtmp)
            trigindtmp = find((rd.ttimes>=ton)&(rd.ttimes<=toff));
        end
    else
        trigindtmp=find((rd.ttimes>=ton)&(rd.ttimes<=toff));%find trigger time for syllable
    end
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