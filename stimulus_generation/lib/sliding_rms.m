function rms_out = sliding_rms(wf,window)

rms_out = zeros(size(wf));
for k = 1:length(wf)-window
    rms_out(k) = rms(wf(k:k+window));
end
    