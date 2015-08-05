close all; clc; clear

save = true;
plottest = true;
pathdata = path_localsettings;


data = load(fullfile(pathdata.stim_path, 'syllable_database'));
data = data.data;

%%
base_idxs = [1 8 9 0 0 0];

abc_a = [1 8 9];
abc_b = [12 17 18];
xyz_a = [63 64 22];
xyz_b = [70 80 370];



%% make stimset A
stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = data.fs;
stimcount = 0;
% add song ABCaXYZa
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCaXYZa'];
syllables = data.syllables([abc_a, xyz_a]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.numstims = stimcount;
if save
    %save_hop_stimuli(stimset_a,pathdata.stim_path, 'motif_stimset_a');
    save_boc_stimuli(stimset,pathdata.stim_path, 'exa2_stimset_single_song_aa','db',75)
end
% add song ABCbXYZb
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCbXYZb'];
syllables = data.syllables([abc_b, xyz_b]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.numstims = stimcount;
if save
    %save_hop_stimuli(stimset_a,pathdata.stim_path, 'motif_stimset_a');
    save_boc_stimuli(stimset,pathdata.stim_path, 'exa2_stimset_a','db',75)
end
stimset.stims = stimset.stims(2);
stimset.numstims = 1;
if save
    %save_hop_stimuli(stimset_a,pathdata.stim_path, 'motif_stimset_a');
    save_boc_stimuli(stimset,pathdata.stim_path, 'exa2_stimset_sinlge_song_bb','db',75)
end
if plottest
    for k=1:length(stimset.stims)
        fig = figure('color','w');
        plot_bird_spectrogram(stimset.stims(k).signal, stimset.samprate)
    end
end

%% make stimset B
% add song ABCaXYZa
stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = data.fs;
stimcount = 0;
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCbXYZa'];
syllables = data.syllables([abc_b, xyz_a]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.numstims = stimcount;
if save
    %save_hop_stimuli(stimset_a,pathdata.stim_path, 'motif_stimset_a');
    save_boc_stimuli(stimset,pathdata.stim_path, 'exa2_stimset_single_song_ba','db',75)
end
% add song ABCbXYZb
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCaXYZb'];
syllables = data.syllables([abc_a, xyz_b]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.numstims = stimcount;
if save
    %save_hop_stimuli(stimset_a,pathdata.stim_path, 'motif_stimset_a');
    save_boc_stimuli(stimset,pathdata.stim_path, 'exa2_stimset_b','db',75)
end
stimset.stims = stimset.stims(2);
stimset.numstims = 1;
if save
    %save_hop_stimuli(stimset_a,pathdata.stim_path, 'motif_stimset_a');
    save_boc_stimuli(stimset,pathdata.stim_path, 'exa2_stimset_sinlge_song_ab','db',75)
end

if plottest
    for k=1:length(stimset.stims)
        fig = figure('color','w');
        plot_bird_spectrogram(stimset.stims(k).signal, stimset.samprate)
    end
end
