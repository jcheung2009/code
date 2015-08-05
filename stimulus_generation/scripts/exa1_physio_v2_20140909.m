close all; clc; clear

savetest = true;

pathdata = path_localsettings;

data = load(fullfile(pathdata.stim_path, 'syllable_database'));
data = data.data;

%% this is genreating a 3 motif repete song with A-B-C-X-E where X is one of several syllables


base_idxs = [1 8 9 0 0 0];...
sub_idxs = [12 17 18;... %songa
    19 20 21;...  songb...
    63 64 22;...
    70 80 370;...
    81 90 420;...
    105 110 510;...
    120 152 600;... % end song b
    460 554 465;... % c songs
    476 499 517;...
    529 535 552;...
    541 503 495;...
    525 486 464;
    ];
%generate all the songs
for ksub = 1:length(sub_idxs)
    syllable_idxs = base_idxs;
    syllable_idxs(4:6) = sub_idxs(ksub,:);
    syllables = data.syllables(syllable_idxs);
    for ksyl = 1:length(syllables)
        % normalize rms to 1
        syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
    end
    wf = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
    all_songs{ksub} = wf;
    % genreate plots
    %     generate_song_plot(wf,data.fs)
    %     play_song(wf,data.fs)
end

% make stimset A
stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = data.fs;
stimcount = 0;
% add song1
stimcount = stimcount + 1;
stimset.stims(stimcount).signal = all_songs{1};
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_a_1'];
stimset.numstims = stimcount;

% add stimset B
bcount = 0;
for ksong = 2:7
    bcount = bcount+1;
    % add song1
    stimcount = stimcount + 1;
    stimset.stims(stimcount).signal = all_songs{ksong};
    stimset.stims(stimcount).type = 'song';
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).name = ['exa1_song_b_', num2str(bcount)];
    stimset.numstims = stimcount;
end

% add control songs
ccount = 0;
for ksong = 8:12
    ccount = ccount +1;
    % add song1
    stimcount = stimcount + 1;
    stimset.stims(stimcount).signal = all_songs{ksong};
    stimset.stims(stimcount).type = 'song';
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).name = ['exa1_song_c_', num2str(ccount)];
    stimset.numstims = stimcount;
end





%%%%%%%%%%%%%%%%%%%%%%
%% probes
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
%% different intro -> song b_1
syllable_idxs(1:3) = [107 122 124];
syllable_idxs(4:6) = sub_idxs(2,:);
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
stimset.stims(stimcount).name = ['exa1_song_b_1_abc2xyz'];

%% different intro -> song b_2
syllable_idxs(1:3) = [107 122 124];
syllable_idxs(4:6) = sub_idxs(3,:);
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
stimset.stims(stimcount).name = ['exa1_song_b_2_abc2xyz'];
%% different intro -> song b_3
syllable_idxs(1:3) = [107 122 124];
syllable_idxs(4:6) = sub_idxs(4,:);
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
stimset.stims(stimcount).name = ['exa1_song_b_3_abc2xyz'];

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

%%
%%%%%%%%%%%%%%%%%% syllables
syl_idxs = [base_idxs(1:3); sub_idxs; [107 122 124]];
syl_idxs = syl_idxs(:);
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



%% save
if savetest
    stimset_out = save_krank_stimuli(stimset, pathdata.stim_path, 'exa1_physio_v2', 'zero_pad_length',1,'add_null',true);
else
    plot_stimset(stimset)
end




%     for kstim = 1:length(stimset.stims)
%         generate_song_plot(stimset.stims(kstim).signal, data.fs)
%     end
%     tilefigs;







