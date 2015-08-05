function wf = set_rms_for_krank(wf, db)

% % normalize song by rms so that rms = 1
% wf = wf./rms(wf);

% normalize by factor to bring to 85 db
% 85 db rms = 997 rms, so 85 = 20*log10(997 / pref) % from previous stimuli
% 997/ pref = 10^(85/20) 
pref = 997 / 10^(85/20);
krank_factor = pref * 10^(db/20);
wf = wf * krank_factor;


