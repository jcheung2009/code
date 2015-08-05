close all; clc; clear

savetest = true;

pathdata = path_localsettings;

data = load(fullfile(pathdata.stim_path, 'syllable_database'));
data = data.data;

%% this is genreating a 3 motif repete song with A-B-C-X-E where X is one of several syllables
base_idxs = [1 8 9 0 0 0];
sub_idxs = [12 17 18;...
    19 20 21;...
    63 64 22;...
    70 80 370;...
    81 90 420;...
    105 110 510;...
    120 152 600;...
    ];
% %generate all the songs
% for ksub = 1:length(sub_idxs)
%     syllable_idxs = base_idxs;
%     syllable_idxs(4:6) = sub_idxs(ksub,:);
%     syllables = data.syllables(syllable_idxs);
%     for ksyl = 1:length(syllables)
%         % normalize rms to 1
%         syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
%     end
%     wf = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
%     all_songs{ksub} = wf;
%     % genreate plots
%     %     generate_song_plot(wf,data.fs)
%     %     play_song(wf,data.fs)
% end

stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = data.fs;
stimcount = 0;
syllable_idxs = base_idxs;
syllable_idxs(4:6) = sub_idxs(1,:);
%% drop first 3
syllables = data.syllables(syllable_idxs);
for ksyl = 1:length(syllables)
    % normalize rms to 1
    syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 1:3
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = motif;
stimset.stims(stimcount).type = 'drop_first_3';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_1_minus_abc'];

%% drop last 3
syllables = data.syllables(syllable_idxs);
for ksyl = 1:length(syllables)
    % normalize rms to 1
    syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 4:6
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = motif;
stimset.stims(stimcount).type = 'drop_last_3';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_1_minus_xyz'];
%% drop YZ
syllables = data.syllables(syllable_idxs);
for ksyl = 1:length(syllables)
    % normalize rms to 1
    syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 5:6
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = motif;
stimset.stims(stimcount).type = 'drop_last_2';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_1_minus_yz'];
stimset.numstims = stimcount;
%% drop x
syllables = data.syllables(syllable_idxs);
for ksyl = 1:length(syllables)
    % normalize rms to 1
    syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 4
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = motif;
stimset.stims(stimcount).type = 'drop_syl';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_1_minus_x'];
stimset.numstims = stimcount;
%% drop Y
syllables = data.syllables(syllable_idxs);
for ksyl = 1:length(syllables)
    % normalize rms to 1
    syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 5
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = motif;
stimset.stims(stimcount).type = 'drop_2';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_1_minus_y'];
stimset.numstims = stimcount;
%% drop Z
syllables = data.syllables(syllable_idxs);
for ksyl = 1:length(syllables)
    % normalize rms to 1
    syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 6
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = motif;
stimset.stims(stimcount).type = 'cutoff';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_1_minus_z'];
stimset.numstims = stimcount;
%% drop c
syllables = data.syllables(syllable_idxs);
for ksyl = 1:length(syllables)
    % normalize rms to 1
    syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 3
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = motif;
stimset.stims(stimcount).type = 'cutoff';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_1_minus_c'];
%% drop b
syllables = data.syllables(syllable_idxs);
for ksyl = 1:length(syllables)
    % normalize rms to 1
    syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
for ksyl = 2
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
end
motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = motif;
stimset.stims(stimcount).type = 'cutoff';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_1_minus_b'];
stimset.numstims = stimcount;


%% substitute b 
syllable_idxs_temp = syllable_idxs; 
syllable_idxs_temp(2) = 122; 
syllables = data.syllables(syllable_idxs_temp);
for ksyl = 1:length(syllables)
    % normalize rms to 1
    syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = motif;
stimset.stims(stimcount).type = 'cutoff';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_1_novel_b'];
stimset.numstims = stimcount;

%% substitute c 
syllable_idxs_temp = syllable_idxs; 
syllable_idxs_temp(3) = 124; 
syllables = data.syllables(syllable_idxs_temp);
for ksyl = 1:length(syllables)
    % normalize rms to 1
    syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = motif;
stimset.stims(stimcount).type = 'cutoff';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_1_novel_c'];
stimset.numstims = stimcount;


%% substitute x  
syllable_idxs_temp = syllable_idxs; 
syllable_idxs_temp(4) = sub_idxs(2,1); 
syllables = data.syllables(syllable_idxs_temp);
for ksyl = 1:length(syllables)
    % normalize rms to 1
    syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = motif;
stimset.stims(stimcount).type = 'cutoff';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_1_xfromb1'];
stimset.numstims = stimcount;

%% substitute y  
syllable_idxs_temp = syllable_idxs; 
syllable_idxs_temp(5) = sub_idxs(2,2);
syllables = data.syllables(syllable_idxs_temp);
for ksyl = 1:length(syllables)
    % normalize rms to 1
    syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = motif;
stimset.stims(stimcount).type = 'cutoff';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_1_yfromb1'];
stimset.numstims = stimcount;

%% substitute z  
syllable_idxs_temp = syllable_idxs; 
syllable_idxs_temp(6) = sub_idxs(2,3);
syllables = data.syllables(syllable_idxs_temp);
for ksyl = 1:length(syllables)
    % normalize rms to 1
    syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
end
motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = motif;
stimset.stims(stimcount).type = 'cutoff';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_1_zfromb1'];
stimset.numstims = stimcount;


%% different intro -> song a
syllable_idxs(1:3) = [107 122 124];
syllable_idxs(4:6) = sub_idxs(1,:);
% drop each syllable
syllables = data.syllables(syllable_idxs);
for knorm = 1:length(syllables)
    % normalize rms to 1
    syllables(knorm).wf = normalize_rms_to_one(syllables(knorm).wf);
end
motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = motif;
stimset.stims(stimcount).type = 'substituted_syllable';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_abc2xyz'];
stimset.numstims = length(stimset.stims);



%% save
if savetest
    save_boc_stimuli(stimset, pathdata.stim_path, ['exa1_decomposition_probes_v2'], 'db', 75)
else
    plot_stimset(stimset)
end

%     for kstim = 1:length(stimset.stims)
%         generate_song_plot(stimset.stims(kstim).signal, data.fs)
%     end
%     tilefigs;







