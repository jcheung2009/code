% Stimulus display
close all; clear all; clc

% this script generates stimuli for the tf motif shift experiment
pathdata = path_localsettings;
% load data
song_data = open([pathdata.stim_path, 'songs.mat']);

% set parameters
fs = song_data.Fs;
max_range = 1e4;
sound = false;

% use milti motif song
[wf_full, wf_motif1, wf_motif2, fs] = generate_multi_motif_song();

% cut motif 1 syllables
motif1.syllables{1} = cut_segment(wf_motif1,fs,.03,.11);
motif1.syllables{2} = cut_segment(wf_motif1,fs,.11,.25);
motif1.syllables{3} = cut_segment(wf_motif1,fs,.25,.34);
motif1.syllables{4} = cut_segment(wf_motif1,fs,.34,.43);
motif1.syllables{5} = cut_segment(wf_motif1,fs,.43,.55);

% cut motif 2 syllables
motif2.syllables{1} = cut_segment(wf_motif2,fs,.04,.12);
motif2.syllables{2} = cut_segment(wf_motif2,fs,.38,.56);

% initialize structure
stimset = struct;
stimset.samprate = fs;
%stimset.stims(1).signal = zeros(length(wf),1);
%stimset.stims(1:stimset.numstims) = stimset.stims(1);
stimset.total_length_est = 0;
stimcount = 0;


% add unchanged song
syllables = motif1.syllables;
stimcount = stimcount + 1;
stimset.stims(stimcount).p_switched = 0;
stimset.stims(stimcount).signal = vertcat(syllables{:});
stimset.stims(stimcount).type = 'shuffel';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).tag = 'normal';
stimset.stims(stimcount).name = 'shuffel_normal';
stimset.total_length_est = stimset.total_length_est + stimset.stims(stimcount).length/fs + 2;

% itterate through parameter space
for kmain = 1:length(motif1.syllables)
    for klop = 1:2
        syllables = motif1.syllables;
        syllables{kmain} = motif2.syllables{klop};
        % set stims
        stimcount = stimcount + 1;
        stimset.stims(stimcount).p_switched = kmain;
        stimset.stims(stimcount).p_interloper = klop;
        stimset.stims(stimcount).signal = vertcat(syllables{:});
        stimset.stims(stimcount).type = 'shuffel';
        stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
        stimset.stims(stimcount).onset = 0;
        stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
        stimset.stims(stimcount).tag = ['intlop', num2str(klop)];
        stimset.stims(stimcount).name = ['shuffel_', num2str(kmain), '_', num2str(klop)];
        stimset.total_length_est = stimset.total_length_est + stimset.stims(stimcount).length/fs + 2;
        
        syllable_lengths = cellfun(@length, syllables)/fs;
        stimset.stims(stimcount).p_syllable_times(1,:) = [0 syllable_lengths(1)];
        for ksyl = 2:length(syllable_lengths)
            stimset.stims(stimcount).p_syllable_times(ksyl,1) = stimset.stims(stimcount).p_syllable_times(ksyl-1,2);
            stimset.stims(stimcount).p_syllable_times(ksyl,2) = stimset.stims(stimcount).p_syllable_times(ksyl,1) + syllable_lengths(ksyl);
        end
        %generate_song_plot(stimset.stims(stimcount).signal, fs)
        %play_song(stimset.stims(stimcount).signal, fs)
    end
end
stimset.numstims = length(stimset.stims);
save_krank_stimuli(stimset, pathdata.stim_path, 'shuffle_experiment')


