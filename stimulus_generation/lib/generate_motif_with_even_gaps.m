function [wf, onsets] = generate_motif_with_even_gaps(syllables, fs, gap_length, zp_length)

n_syllables = length(syllables);
wf = zeros(round(zp_length*fs),1);
gap = zeros(round(gap_length*fs),1);
onsets = [];
for ksyl = 1:n_syllables
    onsets = [onsets length(wf)/fs];
    wf = vertcat(wf, syllables(ksyl).wf(:), gap);
end
wf = vertcat(wf,zeros(round(zp_length*fs),1));



