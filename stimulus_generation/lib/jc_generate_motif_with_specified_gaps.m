function [wf, onsets] = jc_generate_motif_with_specified_gaps(syllables, fs, gaps, zp_length)
%gaps and zp_length are in seconds
n_syllables = length(syllables);
wf = zeros(round(zp_length*fs),1);
onsets = [];
for ksyl = 1:n_syllables
    onsets = [onsets length(wf)/fs];
    if ksyl == n_syllables
        wf = vertcat(wf, syllables(ksyl).wf(:));
    else
        wf = vertcat(wf, syllables(ksyl).wf(:), zeros(round(gaps(ksyl)*fs),1));
    end
end
wf = vertcat(wf,zeros(round(zp_length*fs),1));

