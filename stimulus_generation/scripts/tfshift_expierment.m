% Stimulus display
close all; clear all; clc

% this script generates stimuli for the tf motif shift experiment 
pathdata = path_localsettings;
% load data
song_data = open('/data/doupe_lab/stimuli/songs.mat');

% set parameters
fs = song_data.Fs;
max_range = 1e4;
sound = false;

% use milti motif song
[wf_full, wf_motif1, wf_motif2, fs] = generate_multi_motif_song();

frequency_steps = [.9, .98, 1, 1.02, 1.1];
time_steps =      [.6, .9, 1, 1.1, 1.4];

stimset1 = generate_fxd_stimuli(wf_motif1, fs, frequency_steps, time_steps, 'motif1');
stimset2 = generate_fxd_stimuli(wf_motif2, fs, frequency_steps, time_steps, 'motif2');


stimset = stimset1;
stimset.stims = [stimset1.stims, stimset2.stims];
stimset.nstims = length(stimset.stims);

save_krank_stimuli(stimset, pathdata.stim_path, 'tfshift')
return


% plot stimuli
for kstim = 1:stimset.nstims
    stimset.stims(kstim)
    fig(kstim) = generate_song_plot(stimset.stims(kstim).signal, stimset.samprate, 'sound', false);
end
tilefigs

