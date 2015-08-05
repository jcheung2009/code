close all; clear all; clc;

% load data
pathdata = path_localsettings(); % get local path data
data = open([pathdata.stim_path, 'CurrentTutors65dB.mat']);
original_stimset = data.stimset;
fs = original_stimset.samprate;

ksong_to_pick = 6;
stimset_a = original_stimset;
stimset_a.stims = stimset_a.stims(ksong_to_pick);
stimset_a.numstims = length(stimset_a.stims);

stimset_b = original_stimset;
stimset_b.stims = stimset_b.stims((1:stimset_b.numstims)~= ksong_to_pick);
stimset_b.numstims = length(stimset_b.stims);

stimset.name = 'behavior_discrim_physio_v2';
stimset.date = '2013_10_31';
stimset.samprate = original_stimset.samprate;
stimset.numstims = 0;
stimset.stims = original_stimset.stims(ksong_to_pick);
stimset.stims(1).name = 'song_a';


for ksong=1:5
    count = length(stimset.stims);
    stimset.stims(count+1) = stimset_b.stims(ksong);
    stimset.stims(count+1).name = ['song_b_', num2str(ksong)];
end
count1 = 0;
for ksong = 6:10
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

original_stimset = stimset;
clear stimset;



motif_times{2} = [4.8 6.1];
motif_times{3} = [1.4 2.75];
motif_times{4} = [2 3.1];
motif_times{5} = [2.1 3.05];
motif_times{6} = [.85 1.9];
motif_times{1} = [2.8 3.8];
motif_times{7} = [.55 1.45];
motif_times{8} = [1.15 2.25];
motif_times{9} = [1.9 3.14];
motif_times{10} = [1.72 2.62];
% motif_times{11} = [2 2.5];
% motif_times{12} = [1.86 3.04];
% motif_times{13} = [2 2.9];
% motif_times{14} = [2.75 4.04];
% motif_times{15} = [3.4 5.2];
% motif_times{16} = [3.1 3.9];
% motif_times{17} = [1.85 2.7];
% motif_times{18} = [2.6 3.3];




for ksong = 1:length(motif_times)
    motif_wf = cut_segment(original_stimset.stims(ksong).signal, fs, ...
        motif_times{ksong}(1), motif_times{ksong}(2));
%     spectrogram(motif_wf,256,250,256,fs,'yaxis');
%     pause
    % motif1
    frequency_steps = [.9, .98, 1, 1.02, 1.1];
    time_steps = [1];
    stimset(1) = generate_fxd_stimuli(motif_wf, fs, frequency_steps, time_steps, 'motif1');
    frequency_steps = [1];
    time_steps = [.6, .9, 1, 1.1, 1.4];
    stimset(2) = generate_fxd_stimuli(motif_wf, fs, frequency_steps, time_steps, 'motif1');
    frequency_steps = [.9];
    time_steps = [.6, 1.4];
    stimset(3) = generate_fxd_stimuli(motif_wf, fs, frequency_steps, time_steps, 'motif1');
    frequency_steps = [1.1];
    time_steps = [.6, 1.4];
    stimset(4) = generate_fxd_stimuli(motif_wf, fs, frequency_steps, time_steps, 'motif1');
    
    full_stimset = stimset(1);
    full_stimset.stims = [stimset(:).stims];
    full_stimset.nstims = length(full_stimset.stims);
    full_stimset.total_length_est = sum([stimset(:).total_length_est]);
    
    save_krank_stimuli(full_stimset, pathdata.stim_path, ['bsd_tfshift_' original_stimset.stims(ksong).name], 'zero_pad_length', .5)
    
    
end
return
