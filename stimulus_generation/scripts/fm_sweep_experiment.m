% Stimulus display
close all; clear all; clc

% this script generates stimuli for the tf motif shift experiment 
pathdata = path_localsettings;
% % load data
song_data = open([pathdata.stim_path, 'songs.mat']);
[wf_full, wf_motif1, wf_motif2, fs] = generate_multi_motif_song();
leedin(1).wf = cut_segment(wf_motif1, fs, 0.01, .4);
leedin(1).wf = leedin(1).wf./max(leedin(1).wf);
leedin(2).wf = cut_segment(wf_motif2, fs, 0.01, .4);
leedin(2).wf = leedin(2).wf./max(leedin(2).wf);

% set parameters
fs = 40e3;
sound = false;

% set static sweep paramaters 
stimgen_params.Fs = fs;
stimgen_params.DUR = .2;
stimgen_params.sweeptype = 'lfm';
stimgen_params.nharm = 3;

fi_steps = [300:800:2700];
ft_steps = [2700:-800:300];

% initialize structure
stimset = struct;
stimset.samprate = fs;
stimset.numstims = length(fi_steps);
%stimset.stims(1).signal = zeros(length(wf),1);
%stimset.stims(1:stimset.numstims) = stimset.stims(1);
stimset.total_length_est = 0;
stimcount = 0;

% itterate through parameter space
for kfi = 1:length(fi_steps)
    for kleedin = 1:length(leedin)
        % set variable stimgen_params
        stimgen_params.f1i = fi_steps(kfi);
        stimgen_params.f1t = ft_steps(kfi);
        
        % set stims
        stimcount = stimcount + 1;
        stimset.stims(stimcount).p_fi = fi_steps(kfi);
        stimset.stims(stimcount).p_ft = ft_steps(kfi);
        stimset.stims(stimcount).p_leedin = kleedin;
        stimset.stims(stimcount).p_sweeprate = (ft_steps(kfi)-fi_steps(kfi))/stimgen_params.DUR;
        stimset.stims(stimcount).signal = vertcat(set_rms_for_krank(leedin(kleedin).wf, 75), set_rms_for_krank(pulsegen(stimgen_params),70));
        stimset.stims(stimcount).type = 'lfm_sweep';
        stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
        stimset.stims(stimcount).onset = 0;
        stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
        stimset.stims(stimcount).tag = ['leedin', num2str(kleedin)];
        stimset.stims(stimcount).name = [stimset.stims(stimcount).type, num2str(stimset.stims(stimcount).p_sweeprate), 'hzps'];
        stimset.total_length_est = stimset.total_length_est + stimset.stims(stimcount).length/fs + 2;
        generate_song_plot(stimset.stims(stimcount).signal, fs)
        play_song(stimset.stims(stimcount).signal, fs)
    end
end
stimset.numstims = length(stimset.stims);
save_krank_stimuli(stimset, pathdata.stim_path, 'fmsweep_experiment')





