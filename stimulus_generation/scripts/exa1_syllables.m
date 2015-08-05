close all; clear all; clc;
save = true;
pathdata = path_localsettings;
data = load(fullfile(pathdata.stim_path, 'syllable_database'));
data = data.data;
% this is genreating a 3 motif repete song with A-B-C-X-E where X is one of several syllables
syl_idxs = [1 8 9;...
            12 17 18;... %songa
            19 20 21;...  songb...
            63 64 22;...
            70 80 370;...
            81 90 420;...
            105 110 510;...
            120 152 600;... % end song b
            460 554 465;... % c songs
            476 499 517;...
            529 535 552;...
            541 503 495;...
            525 486 464;...
            107 122 124; % alternate abc
            ];
 
syl_idxs = syl_idxs(:);
% add song1
stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = data.fs;
stimcount = 0;
for ksyl = 1:length(syl_idxs)
    % add song1
    stimcount = stimcount + 1;
    wf = normalize_rms_to_one(data.syllables(syl_idxs(ksyl)).wf);
    stimset.stims(stimcount).signal = wf;
    stimset.stims(stimcount).type = 'syllable';
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).name = ['syllable_', num2str(syl_idxs(ksyl))];
end
stimset.numstims = stimcount;
save_krank_stimuli(stimset, pathdata.stim_path, 'exa1_syllables_20140416', 'zero_pad_length',0.5,'add_null',true)