function matchsig = set_rms_for_hop(signal, RMS)
% matchsig = setRMS(signal, RMS)
% sets RMS power of a signal to desired value,
% assuming 5 (volts) = 100dB
target = 1e-5*10^(RMS/20);
matchsig = target*signal/std(signal);