function [segment_wf] = cut_segment(wf, fs, start_time, stop_time)

roll_time = 10e-3; % roll time 

wf = wf(:);
% calcualte indicies
start_idx = round(start_time * fs);
stop_idx = min(round(stop_time * fs), length(wf));
start_idx = min(stop_idx,round(start_time * fs));
start_idx = max(start_idx,1); 
% cut segment
segment_wf = wf(start_idx:stop_idx);

% add roll on
expsize = round(roll_time * fs);
xtscale=segment_wf(1:expsize).*exp(-((expsize:-1:1)-1)/(expsize/5))';
segment_wf(1:expsize)=xtscale;

% add roll off
xtscale=segment_wf(end-expsize+1:end).*exp(-((1:expsize)-1)/(expsize/5))';
segment_wf(end-expsize+1:end)=xtscale;
