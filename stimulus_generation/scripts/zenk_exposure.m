close all; clear all; clc;

% load data
pathdata = path_localsettings(); % get local path data
data = load([pathdata.stim_path, 'blk12training.mat'], 'stimset');
original_stimset = data.stimset;
fs = original_stimset.samprate;
wf_song = original_stimset.stims(1).signal;


all_stims = {};
stimset_b = generate_fxd_stimuli(wf_song, fs, [.9, .98, 1.02, 1.1], [1.1, 1.4]);
stimset_a = generate_fxd_stimuli(wf_song, fs, [.9, .98, 1.02, 1.1], [.6, .9]);

for kstim = 1:length(stimset_a.stims)
    all_stims{end+1} = stimset_a.stims(kstim).signal;
end
for kstim = 1:length(stimset_b.stims)
    all_stims{end+1} = stimset_b.stims(kstim).signal;
end

stim_time = sum(cellfun(@length,all_stims))/fs; 
total_time = stim_time*3;
total_samples = round(total_time * fs);
wf = zeros(total_samples,1);

isi = round(total_samples / length(all_stims));
for kstim = 1:length(all_stims)
    onset_idx = (kstim-1) * isi+ 100;
    offset_idx = onset_idx + length(all_stims{kstim})-1;
    wf(onset_idx:offset_idx) = all_stims{kstim};
end

pathdata = path_localsettings;
if ~exist(fullfile(pathdata.stim_path, 'zenk_stim'))
    mkdir(fullfile(pathdata.stim_path, 'zenk_stim'))
end
wf = repmat(wf(:), 11, 1);
wf = wf / (1.1*max(wf));
wavwrite(wf(:), fs, fullfile(pathdata.stim_path, 'zenk_stim', 'stim1.wav'));
