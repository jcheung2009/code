%% song generation examples
close all; clear all; clc
pathdata = path_localsettings;


data = load(fullfile(pathdata.stim_path, 'syllable_database'));
data = data.data;

%% this is genreating a 3 motif repete song with A-B-C-X-E where X is one of several syllables
base_idxs = [1 8 9 0 0 0];
sub_idxs = [12 17 18;...
    19 20 21;...
    63 64 22;...
    70 80 370;...
    81 90 420;...
    105 110 510;...
    120 152 600];

%generate all the songs
syllable_idxs = base_idxs;
syllable_idxs(4:6) = sub_idxs(ksub,:);
wf = generate_motif_with_even_gaps(data.syllables(syllable_idxs), data.fs, 50e-3, 250e-3);
wf = vertcat(wf,wf,wf);
generate_song_plot(wf,data.fs,'sound',true)

wf = generate_motif_with_even_spacing(data.syllables(syllable_idxs), data.fs, 250e-3, 250e-3);
wf = vertcat(wf,wf,wf);
generate_song_plot(wf,data.fs,'sound',true)
