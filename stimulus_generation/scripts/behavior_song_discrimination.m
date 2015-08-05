close all; clear all; clc;

% load data
pathdata = path_localsettings(); % get local path data
data = open([pathdata.stim_path, 'CurrentTutors65dB.mat']);
original_stimset = data.stimset;


ksong_to_pick = 6;
stimset_a = original_stimset;
stimset_a.stims = stimset_a.stims(ksong_to_pick);
stimset_a.numstims = length(stimset_a.stims);

stimset_b = original_stimset;
stimset_b.stims = stimset_b.stims((1:stimset_b.numstims)~= ksong_to_pick);
stimset_b.numstims = length(stimset_b.stims);

probe_stimset = original_stimset;
for kstim=1:length(probe_stimset.stims)
    if kstim == ksong_to_pick
        probe_stimset.stims(kstim).correctans = 'a';
    else
        probe_stimset.stims(kstim).correctans = 'b';
    end
end

save_hop_stimuli(stimset_a,pathdata.stim_path, 'songdiscrim_v1_stimset_a')
save_hop_stimuli(stimset_b,pathdata.stim_path, 'songdiscrim_v1_stimset_b')
stimset_b_5 = stimset_b;
stimset_b_5.stims = stimset_b_5.stims(1:5);
stimset_b_5.numstims = 5;
save_hop_stimuli(stimset_b_5,pathdata.stim_path, 'songdiscrim_v1_stimset_b_5')

stimset_b_2 = stimset_b;
stimset_b_2.stims = stimset_b.stims(1:2);
stimset_b_2.numstims = 2;
save_hop_stimuli(stimset_b_2,pathdata.stim_path, 'songdiscrim_v1_stimset_b_2')



save_hop_stimuli(probe_stimset, pathdata.stim_path, 'songdiscrim_v1_probeset')




