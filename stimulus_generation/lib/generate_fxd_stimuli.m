function stimset = generate_fxd_stimuli(wf, fs, frequency_steps, time_steps, tag)

tagon = false;
if nargin < 3
    frequency_steps = [.7:.1:1.3];
end
if nargin < 4
    time_steps = [.7:.1:1.3];
end
if nargin > 4
    tagon = true;
end


% initialize structure
stimset = struct;
stimset.samprate = fs;
stimset.numstims = length(frequency_steps) * length(time_steps);
stimset.stims(1).signal = zeros(length(wf),1);
stimset.stims(1:stimset.numstims) = stimset.stims(1);
stimset.total_length_est = 0;
stimcount = 0;
% 
% % add regular version of song
% stimcount = stimcount + 1;
% stimset.stims(stimcount).p_frequency = 1;
% stimset.stims(stimcount).p_time = 1;
% stimset.stims(stimcount).signal = wf;
% stimset.stims(stimcount).type = 'regular_song';
% stimset.stims(stimcount).tag = tag;
% stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
% stimset.stims(stimcount).onset = 0;
% stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% stimset.total_length_est = stimset.total_length_est + stimset.stims(stimcount).length/fs + 4;

% itterate through parameter space
for kfreq = 1:length(frequency_steps)
    for ktime = 1:length(time_steps)
        stimcount = stimcount + 1;
        stimset.stims(stimcount).p_frequency = frequency_steps(kfreq);
        stimset.stims(stimcount).p_time = time_steps(ktime);
        stimset.stims(stimcount).signal = song_shift(wf, time_steps(ktime), frequency_steps(kfreq));
        stimset.stims(stimcount).type = 'dilated_song';
        stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
        stimset.stims(stimcount).onset = 0;
        stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
        if tagon
            stimset.stims(stimcount).tag = tag;
        end
        stimset.stims(stimcount).name = [stimset.stims(stimcount).type, '_t', num2str(time_steps(ktime)), '_f', num2str(frequency_steps(kfreq))];
        stimset.total_length_est = stimset.total_length_est + stimset.stims(stimcount).length/fs + 2;
    end
end

stimset.numstims = length(stimset.stims);


