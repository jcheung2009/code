% Stimulus display
close all; clear all; clc

% this script generates stimuli for the tf motif shift experiment
pathdata = path_localsettings;
% load data
original_stimset = open([pathdata.stim_path, 'CurrentTutors65dB.mat']);
original_stimset = original_stimset.stimset;
% set parameters
fs = original_stimset.samprate;
sound = false;

stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = fs;
stimcount = 0;

motif_times{1} = [4.8 6.1];
motif_times{2} = [1.4 2.75];
motif_times{3} = [2 3.1];
motif_times{4} = [2.1 3.05];
motif_times{5} = [.85 1.9];
motif_times{6} = [2.8 3.8];
motif_times{7} = [.55 1.45];
motif_times{8} = [1.15 2.25];
motif_times{9} = [1.9 3.14];
motif_times{10} = [1.72 2.62];
motif_times{11} = [2 2.5];
motif_times{12} = [1.86 3.04];
motif_times{13} = [2 2.9];
motif_times{14} = [2.75 4.04];
motif_times{15} = [3.4 5.2];
motif_times{16} = [3.1 3.9];
motif_times{17} = [1.85 2.7];
motif_times{18} = [2.6 3.3];

for ksong = 1:18
%     wf_song = cut_segment(original_stimset.stims(ksong).signal, fs, ...
%     motif_times{ksong}(1), motif_times{ksong}(2));
    wf_song = original_stimset.stims(ksong).signal;
    % add song1
    stimcount = stimcount + 1;
    stimset.stims(stimcount).signal = wf_song;
    stimset.stims(stimcount).type = 'song';
    stimset.stims(stimcount).tag = ['song' num2str(ksong)];
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
    stimset.total_length_est = stimset.total_length_est + stimset.stims(stimcount).length/fs + 4;
end
stimset.numstims = length(stimset.stims);
save_krank_stimuli(stimset, pathdata.stim_path, '18_probe_songs')
