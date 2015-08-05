close all; clc; clear

save = true;

pathdata = path_localsettings;


data = load(fullfile(pathdata.stim_path, 'syllable_database'));
data = data.data;



syl_idxs = [500:509 511:550];

% make stimset A
stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = data.fs;
stimcount = 0;
% add song1

for ksyl = syl_idxs
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = normalize_rms_to_one(data.syllables(ksyl).wf);
stimset.stims(stimcount).type = 'syllable';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['syllable_', num2str(ksyl)];
end
stimset.numstims = stimcount;

save_boc_stimuli(stimset,pathdata.stim_path,'pretraining_syllables')
