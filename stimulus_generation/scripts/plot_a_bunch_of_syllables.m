close all; clc; clear

save = true;

pathdata = path_localsettings;


data = load(fullfile(pathdata.stim_path, 'syllable_database'));
data = data.data;

%% this is genreating a 3 motif repete song with A-B-C-X-E where X is one of several syllables
sub_idxs = [1 8 9;...
    12 17 18;...
    19 20 21;...
    63 64 22;...
    70 80 370;...
    81 90 420;...
    105 110 510;...
    120 152 600];
syl_idxs = sub_idxs(:);
syllables = data.syllables(syl_idxs);
for ksyl = 1:length(syllables)
    % normalize rms to 1
    syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
wf = generate_motif_with_even_gaps(syllables(1:14), data.fs, 100e-3, 200e-3);
wf1 = generate_motif_with_even_gaps(syllables(1:14), data.fs, 300e-3, 200e-3);
wf1 = apply_boc_filters(wf1,data.fs, 'db',75);
wavwrite(wf1, 44100, '~/Desktop/syllables.wav')
fig = figure('color','w')
plot_bird_spectrogram(wf,data.fs)