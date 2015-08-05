% generate some cf stimuli for hop
close all; clear all; clc
pathdata = path_localsettings;
% set parameters
fs = 24414;
phi = 0;
period = 4;
t = 0:(1/fs):period;

% initialize structure
stimset = struct;
stimset.samprate = fs;
stimset.total_length_est = 0;
stimcount = 0;

frequency_set = 500:1e3:9.5e3;

for kfreq=1:length(frequency_set)
    f = frequency_set(kfreq);
    
    % generate signal
    x = sin(t*(2*pi*f) + phi);
    
    % filter signal
    wf = apply_hop_filters(x(:), fs, 'db', 85);
    
    
    stimcount = stimcount + 1;
    stimset.stims(stimcount).signal = wf;
    stimset.stims(stimcount).type = 'cf_tone';
    stimset.stims(stimcount).frequency = f; 
    stimset.stims(stimcount).name = ['cf_tone_', num2str(f)];
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
end
stimset.numstims = length(stimset.stims);

save([pathdata.stim_path, 'cf_hop_tuning.mat'], 'stimset') 
save_hop_stimuli(stimset, pathdata.stim_path, 'cf_hop_tuning');
