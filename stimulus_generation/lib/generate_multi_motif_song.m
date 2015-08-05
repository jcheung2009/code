function [wf, wf_motif1, wf_motif2, fs] = generate_multi_motif_song()

% load data
song_data = open('/data/doupe_lab/stimuli/songs.mat');

% set parameters
fs = song_data.Fs;
song_length = 2.5; % song length in seconds
motif1_start = 0.1;
motif2_start = 1.25;
PLOT = false;
sound = false;
% preallocate
wf = zeros(song_length*fs, 1);

close all
% cut out first motif from song 1 and add it to the wf
song = set_rms_for_krank(song_data.song1, 85);
wf_cut = cut_segment(song, fs, .05, .85);
wf_motif1 = wf_cut;
wf(floor(motif1_start*fs):floor(motif1_start*fs) + length(wf_cut)-1) = wf(floor(motif1_start*fs):floor(motif1_start*fs) + length(wf_cut)-1) + wf_cut;
if PLOT
    generate_song_plot(song, fs, 'sound',sound);
    generate_song_plot(wf_cut, fs, 'sound', sound)
end

% cut out first motif from song 3
song = set_rms_for_krank(song_data.song4, 85);
wf_cut = cut_segment(song, fs, 1.45, 2.6);
wf_motif2 = wf_cut;
wf(floor(motif2_start*fs):floor(motif2_start*fs) + length(wf_cut)-1) = wf(floor(motif2_start*fs):floor(motif2_start*fs) + length(wf_cut)-1) + wf_cut;
if PLOT
    generate_song_plot(song, fs, 'sound',sound);
    generate_song_plot(wf_cut, fs, 'sound', sound)
end

% add noise
wf = wf + set_rms_for_krank(randn(size(wf)), 5);

% final plot
if PLOT
    generate_song_plot(wf, fs, 'sound', sound)
    tilefigs
end