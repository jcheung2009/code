function wf = normalize_rms_to_one(wf)


rms_over_time = sliding_rms(wf/rms(wf), 100);
active_idxs = rms_over_time > .2;
% plot(wf/rms(wf));
% hold on;
% plot(active_idxs,'r');
wf = wf / rms(wf(active_idxs));