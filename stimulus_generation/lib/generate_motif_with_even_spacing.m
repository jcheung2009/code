function wf = generate_motif_with_even_spacing(syllables, fs, isi_length, zp_length)


n_syllables = length(syllables);
duration = isi_length*n_syllables + zp_length*2;
wf = zeros(round(duration*fs),1);

for ksyl = 1:n_syllables
    if length(syllables(ksyl).wf)/fs > isi_length
        warning(['Syllable ' num2str(ksyl) ' is longer than the isi_length'])
    end
    start_idx = round((zp_length + isi_length*(ksyl-1))*fs);
    stop_idx = start_idx + length(syllables(ksyl).wf)-1;
    wf(start_idx:stop_idx) = wf(start_idx:stop_idx) + syllables(ksyl).wf;
end




