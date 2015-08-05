clear all; close all; clc

pathdata = path_localsettings;
% make stimset A
stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = 44100;
stimcount = 0;
for kfreq = [500 1000 2000 4000 6000 12000]
    stimcount = stimcount + 1;
    stimset.stims(stimcount).signal = vas(kfreq, 2, .1);
    stimset.stims(stimcount).type = 'song';
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).name = ['tone_', num2str(kfreq), 'hz'];
    stimset.numstims = stimcount;
    stimset = stimset;
end
save_boc_stimuli(stimset, pathdata.stim_path, 'boc_tuning_80db','db',80)
save_boc_stimuli(stimset, pathdata.stim_path, 'boc_tuning_70db','db',70)
save_boc_stimuli(stimset, pathdata.stim_path, 'boc_tuning_60db','db',60)
save_boc_stimuli(stimset, pathdata.stim_path, 'boc_tuning_50db','db',50)