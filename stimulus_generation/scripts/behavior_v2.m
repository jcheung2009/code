close all; clear all; clc;

% load data
pathdata = path_localsettings(); % get local path data
data = load([pathdata.stim_path, 'blk12training.mat'], 'stimset');
original_stimset = data.stimset;
fs = original_stimset.samprate;
wf_song = original_stimset.stims(1).signal;



timegroup_stimset_b = generate_fxd_stimuli(wf_song, fs, [.8, .96, 1.04, 1.2], [1.1, 1.4]);
save_hop_stimuli(timegroup_stimset_b,pathdata.stim_path, 'jk2_timegroup_stimset_b')

timegroup_stimset_a = generate_fxd_stimuli(wf_song, fs, [.8, .96, 1.04, 1.2], [.6, .9]);
save_hop_stimuli(timegroup_stimset_a,pathdata.stim_path, 'jk2_timegroup_stimset_a')

freqgroup_stimset_a = generate_fxd_stimuli(wf_song, fs, [.8, .96], [.6, .9, 1.1, 1.4]);
save_hop_stimuli(freqgroup_stimset_a,pathdata.stim_path, 'jk2_freqgroup_stimset_a')

freqgroup_stimset_b = generate_fxd_stimuli(wf_song, fs, [1.04, 1.2], [.6, .9, 1.1, 1.4]);
save_hop_stimuli(freqgroup_stimset_b,pathdata.stim_path, 'jk2_freqgroup_stimset_b')

probe_stimset = generate_fxd_stimuli(wf_song, fs, [.94, 1.06], [.6, .9, 1.1, 1.4]);
probe_stimset2 = generate_fxd_stimuli(wf_song, fs, [.9, .98, 1.02, 1.1], [.75, .25]);
probe_stimset.stims = [probe_stimset.stims, probe_stimset2.stims];
probe_stimset.numstims = length(probe_stimset.stims);
for kstim = 1:probe_stimset.numstims
    probe_stimset.stims(kstim).correctans = 1;
end
save_hop_stimuli(probe_stimset,pathdata.stim_path, 'jk2_probe_stimset')



