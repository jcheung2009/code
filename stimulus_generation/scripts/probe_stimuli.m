%% probe stimuli 

% Stimulus display
close all; clear; clc
pathdata = path_localsettings();
% this script generates stimuli for the tf motif shift experiment 

% load data
song_data = open([pathdata.stim_path, 'songs.mat']);
wf_song1 = song_data.song1;
wf_song2 = song_data.song3;
% set parameters
fs = song_data.Fs;
max_range = 1e4;
sound = false;

% initialize structure
stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = fs;
stimcount = 0;

% add song1
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = wf_song1;
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).tag = 'song1';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.total_length_est = stimset.total_length_est + stimset.stims(stimcount).length/fs + 4;

% add song2
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = wf_song2;
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).tag = 'song2';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.total_length_est = stimset.total_length_est + stimset.stims(stimcount).length/fs + 4;

% add song1flip
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = flipud(wf_song1);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).tag = 'song1flipped';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.total_length_est = stimset.total_length_est + stimset.stims(stimcount).length/fs + 4;


stimset.numstims = length(stimset.stims);

save_krank_stimuli(stimset, pathdata.stim_path, 'probe_songs')