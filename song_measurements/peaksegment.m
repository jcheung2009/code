function [sm_ons sm_offs] = peaksegment(smtemp,fs,varargin);
%performs segmentation using halfwidth of findpeaks
%returns time in seconds into smtemp that corresponds to onsets and offsets

sm = log(evsmooth(smtemp,fs,'','','',10));
[pks,locs,w,~,wc] = findpeaks2(sm,'MinPeakDistance',0.03*fs,...
    'MinPeakWidth',0.02*fs,'Annotate','extents');

if ~isempty(varargin)
    [ons offs] = dtw_segment(smtemp,varargin{1},fs);
    ons = ons*fs;
    offs = offs*fs;
    sm_offs=NaN(length(ons),1);
    sm_ons = NaN(length(offs),1);
    for i = 1:length(ons)
        [~,id] = min(abs(wc(:,1)-ons(i)));
        sm_ons(i) = wc(id,1);
        [~,id] = min(abs(wc(:,2)-offs(i)));
        sm_offs(i)=wc(id,2);
    end
    sm_ons = sm_ons./fs;
    sm_offs = sm_offs./fs;
else
    sm_ons = wc(:,1)./fs;
    sm_offs = wc(:,2)./fs;
end


