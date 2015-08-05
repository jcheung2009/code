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
return
% motif times - manually set to extract motif from each of the song
% segments
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

for ksong = 6%:length(motif_times)
    motif_wf = cut_segment(original_stimset.stims(ksong).signal, fs, ...
        motif_times{ksong}(1), motif_times{ksong}(2));
    
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
    
    save_krank_stimuli(full_stimset, pathdata.stim_path, ['cm_tfshift_song' num2str(ksong)])
    
    
end
return
