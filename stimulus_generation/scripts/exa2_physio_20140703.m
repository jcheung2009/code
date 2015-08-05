close all; clc; clear

save = true;
plottest = true;
pathdata = path_localsettings;
data = load(fullfile(pathdata.stim_path, 'syllable_database'));
data = data.data;

%%

abc_a = [1 8 9];
abc_b = [12 17 18];
xyz_a = [63 64 22];
xyz_b = [70 80 370];
abc_c1 = [19 20 21];
abc_c2 = [81 90 420];
abc_c3 = [120 152 600];

syl_idxs = [abc_a, abc_b, xyz_a, xyz_b, abc_c1, abc_c2, abc_c3];

%% make main stimset 
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
% add song ABCbXYZa
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
% add song ABCaXYZb
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
% add song ABCc1XYZa
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCc1XYZa'];
syllables = data.syllables([abc_c1, xyz_a]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% add song ABCc1XYZb
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCc1XYZb'];
syllables = data.syllables([abc_c1, xyz_b]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% add song ABCc2XYZa
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCc2XYZa'];
syllables = data.syllables([abc_c2, xyz_a]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% add song ABCc2XYZb
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCc2XYZb'];
syllables = data.syllables([abc_c2, xyz_b]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% add song ABCc3XYZa
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCc3XYZa'];
syllables = data.syllables([abc_c3, xyz_a]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% add song ABCc3XYZb
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCc3XYZb'];
syllables = data.syllables([abc_c3, xyz_b]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% add song ABCc1ABCc2
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCc1ABCc2'];
syllables = data.syllables([abc_c1, abc_c2]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% add song ABCc2ABCc3
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCc2ABCc3'];
syllables = data.syllables([abc_c2, abc_c3]);
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

%% decompositions
% add song ABCaXYZb_minus X
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCaXYZb_minus_x'];
syllables = data.syllables([abc_a, xyz_b]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 4
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% add song ABCaXYZa_minus X
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCaXYZa_minus_x'];
syllables = data.syllables([abc_a, xyz_a]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 4
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% add song ABCaXYZa_minus_c
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCaXYZa_minus_c'];
syllables = data.syllables([abc_a, xyz_a]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 3
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% add song ABCaXYZb_minus_c
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCaXYZb_minus_c'];
syllables = data.syllables([abc_a, xyz_b]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 3
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% add song ABCaXYZb_minus_bc
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCaXYZb_minus_bc'];
syllables = data.syllables([abc_a, xyz_b]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 2:3
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% add song ABCaXYZa_minus_bc
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCaXYZa_minus_bc'];
syllables = data.syllables([abc_a, xyz_a]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 2:3
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% add song ABCaXYZa_minus_xy
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCaXYZa_minus_xy'];
syllables = data.syllables([abc_a, xyz_a]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 4:5
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% add song ABCaXYZb_minus_xy
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_song_ABCaXYZb_minus_xy'];
syllables = data.syllables([abc_a, xyz_b]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 4:5
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);

% XYZb
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_XYZb'];
syllables = data.syllables([xyz_b]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 3
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
% XYZa
stimcount = stimcount + 1;
stimset.stims(stimcount).name = ['exa2_XYZa'];
syllables = data.syllables([xyz_a]);
for ksyl = 1:length(syllables)
   % normalize rms to 1
   syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 3
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
stimset.stims(stimcount).signal = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.numstims = stimcount;
% add each syllable
for ksyl = 1:length(syl_idxs)
    % add song1
    stimcount = stimcount + 1;
    wf = normalize_rms_to_one(data.syllables(syl_idxs(ksyl)).wf);
    stimset.stims(stimcount).signal = wf;
    stimset.stims(stimcount).type = 'syllable';
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).name = ['syllable_', num2str(syl_idxs(ksyl))];
end
stimset.numstims = stimcount;

if save
    save_krank_stimuli(stimset, pathdata.stim_path, 'exa2_physio_complete', 'zero_pad_length',1,'add_null',true)
end
% add song ABCc1XYZb



