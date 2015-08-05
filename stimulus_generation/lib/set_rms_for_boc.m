function matchsig = set_rms_for_boc(signal, dB)
%% assumes that rms(wf)=1;  normalization is not performed here

lref = 100;
pref = 1/ 10^(lref/20);  % refrence for 120dB
boc_factor = pref * 10^(dB/20);
matchsig = boc_factor*signal;

