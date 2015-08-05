% Stimulus display
close all; clear all; clc

% this script generates stimuli for the tf motif shift experiment 
pathdata = path_localsettings;
% load data
song_data = open([pathdata.stim_path, 'songs.mat']);

% set parameters
fs = song_data.Fs;
max_range = 1e4;
sound = false;

% use milti motif song
[wf_full, wf_motif1, wf_motif2, fs] = generate_multi_motif_song();
return
% motif1
frequency_steps = [.9, .98, 1, 1.02, 1.1];
time_steps = [1];
stimset(1) = generate_fxd_stimuli(wf_motif1, fs, frequency_steps, time_steps, 'motif1');
frequency_steps = [1];
time_steps = [.6, .9, 1, 1.1, 1.4];
stimset(2) = generate_fxd_stimuli(wf_motif1, fs, frequency_steps, time_steps, 'motif1');
frequency_steps = [.9];
time_steps = [.6, 1.4];
stimset(3) = generate_fxd_stimuli(wf_motif1, fs, frequency_steps, time_steps, 'motif1');
frequency_steps = [1.1];
time_steps = [.6, 1.4];
stimset(4) = generate_fxd_stimuli(wf_motif1, fs, frequency_steps, time_steps, 'motif1');

% motif 2
frequency_steps = [.9, .98, 1, 1.02, 1.1];
time_steps = [1];
stimset(5) = generate_fxd_stimuli(wf_motif2, fs, frequency_steps, time_steps, 'motif2');

frequency_steps = [1];
time_steps = [.6, .9, 1, 1.1, 1.4];
stimset(6) = generate_fxd_stimuli(wf_motif2, fs, frequency_steps, time_steps, 'motif2');

frequency_steps = [.9];
time_steps = [.6, 1.4];
stimset(7) = generate_fxd_stimuli(wf_motif2, fs, frequency_steps, time_steps, 'motif2');

frequency_steps = [1.1];
time_steps = [.6, 1.4];
stimset(8) = generate_fxd_stimuli(wf_motif2, fs, frequency_steps, time_steps, 'motif2');


full_stimset = stimset(1);
full_stimset.stims = [stimset(:).stims];
full_stimset.nstims = length(full_stimset.stims);
full_stimset.total_length_est = sum([stimset(:).total_length_est]);

save_krank_stimuli(full_stimset, pathdata.stim_path, 'tfshift_sparse2')
return


% plot stimuli
for kstim = 1:full_stimset.nstims
    full_stimset.stims(kstim)
    fig(kstim) = generate_song_plot(full_stimset.stims(kstim).signal, full_stimset.samprate, 'sound', false);
end
tilefigs

