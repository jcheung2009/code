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

stimset.name = 'bsd_probe_v2';
stimset.date = '2013_10_31';
stimset.samprate = original_stimset.samprate;
stimset.numstims = 0;
stimset.stims = original_stimset.stims(ksong_to_pick);
stimset.stims(1).name = 'song_a';


for ksong=1
    count = length(stimset.stims);
    stimset.stims(count+1) = stimset_b.stims(ksong);
    stimset.stims(count+1).name = ['song_b_', num2str(ksong)];
end
count1 = 0;
for ksong = 6
    count = length(stimset.stims);
    count1 = count1 + 1;
    stimset.stims(count+1) = stimset_b.stims(ksong);
    stimset.stims(count+1).name = ['control_', num2str(count1)];
    
end

for stimcount = 1:length(stimset.stims)
    stimset.stims(stimcount).type = 'song';
    stimset.stims(stimcount).tag = stimset.stims(stimcount).name;
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
end

stimset.numstims = length(stimset.stims);
save_krank_stimuli(stimset, pathdata.stim_path, 'bsd_probe_v2', 'zero_pad_length',4, 'add_null',true)
return


