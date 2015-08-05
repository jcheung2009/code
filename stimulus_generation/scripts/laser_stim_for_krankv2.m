close all; clear all; clc
pathdata = path_localsettings;


fs = 40e3;
%% preallocate stimset
stimset = struct; 
stimcount = 0;
stimset.samprate = fs;
period = 4;

%% generate stimuli wfs

t = 0:1/fs:period;


for pulselen = [5 10 20 50 100 200 500] % in ms
    wf = zeros(size(t));
    wf(1:round(fs*pulselen/1e3)) = 1;  
    stimcount = stimcount + 1;
    stimset.stims(stimcount).signal = wf;
    stimset.stims(stimcount).type = 'pulse_train';
    stimset.stims(stimcount).pulse_length = pulselen;
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).name = ['laser_stim_pl' num2str(pulselen) '_per' num2str(period)];  
end
stimset.numstims = length(stimset.stims);
save_krank_stimuli_laser(stimset,pathdata.stim_path, 'krank_laser_stim_020915v2', 'zero_pad_length', 0,'add_null',true)




% for freq = [.5]
%     for duty = [.025 1 10 20 25]
%         wf = (square(t*2*pi*freq,duty)+1)/2;
%         stimcount = stimcount + 1; 
%         stimset.stims(stimcount).signal = wf;
%         stimset.stims(stimcount).type = 'pulse_train';
%         stimset.stims(stimcount).freq = freq;
%         stimset.stims(stimcount).duty = duty;  
%         stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
%         stimset.stims(stimcount).onset = 0;
%         stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
%         stimset.stims(stimcount).name = ['laser_stim_f' num2str(freq) '_d' num2str(duty)];
%         fig = figure;
%         plot(t,wf); 
%     end
% end
% stimset.numstims = length(stimset.stims);
% %save_krank_stimuli_laser(stimset,pathdata.stim_path, 'krank_laser_stim_020915', 'zero_pad_length', 1)
