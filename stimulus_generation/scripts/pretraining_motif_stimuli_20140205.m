close all; clc; clear

save = true;

pathdata = path_localsettings;


data = load(fullfile(pathdata.stim_path, 'syllable_database'));
data = data.data;



syl_idxs = [500:509 511:580];
motif_idxs = zeros(40,5); for k=1:40; motif_idxs(k,:) = randsample(length(syl_idxs),5); end
% make stimset A
stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = data.fs;
stimcount = 0;
% add song1
for kmotif = 1:length(motif_idxs)
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(data.syllables(motif_idxs(kmotif,:)), data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).signal = normalize_rms_to_one(stimset.stims(stimcount).signal);
stimset.stims(stimcount).type = 'motif';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['motif_', num2str(kmotif)];
end
stimset.numstims = stimcount;

save_boc_stimuli(stimset,pathdata.stim_path,'pretraining_motifs')
