function wf = make_even_song(syllables, syllable_length, fs)

nsyl = length(syllables);

wf = zeros(fs*(nsyl+1)*syllable_length,1);
for ksyl = 1:nsyl
    idx1 = ((ksyl-1)*syllable_length*fs)+1;
    idx2 = idx1 + length(syllables{ksyl})-1;
    wf(idx1:idx2) = wf(idx1:idx2) + syllables{ksyl};
end


generate_song_plot(wf,fs);