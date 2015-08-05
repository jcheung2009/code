close all; clc; clear

save = true;

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
stimset_a = stimset;
clear stimset
if save
    %save_hop_stimuli(stimset_a,pathdata.stim_path, 'motif_stimset_a');
    save_boc_stimuli(stimset_a,pathdata.stim_path, 'exa1_motif_stimset_a','db',75)
end

% make stimset B
stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = data.fs;
stimcount = 0;
for ksong = 2:length(all_songs)
    % add song1
    stimcount = stimcount + 1;
    stimset.stims(stimcount).signal = all_songs{ksong};
    stimset.stims(stimcount).type = 'song';
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).name = ['exa1_song_b_', num2str(stimcount)];
    stimset.numstims = stimcount;
    if save
        if stimcount == 2
            %save_hop_stimuli(stimset,pathdata.stim_path, 'syl_discrim_v1_stimset_b_2');
            save_boc_stimuli(stimset,pathdata.stim_path, 'exa1_motif_stimset_b_2', 'db',75);
        elseif stimcount == 4
            %save_hop_stimuli(stimset,pathdata.stim_path, 'syl_discrim_v1_stimset_b_4');
            save_boc_stimuli(stimset,pathdata.stim_path, 'exa1_motif_stimset_b_4','db',75);
        elseif stimcount == 6
            %save_hop_stimuli(stimset,pathdata.stim_path, 'syl_discrim_v1_stimset_b_6');
            save_boc_stimuli(stimset,pathdata.stim_path, 'exa1_motif_stimset_b_6','db',75);
        end
    end
end




%% make probe stimset v1
stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = data.fs;
stimcount = 0;
stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = data.fs;
stimcount = 0;

syllable_idxs = base_idxs;
syllable_idxs(4:6) = sub_idxs(1,:);
% drop each syllable
for ksyl = 1:length(syllable_idxs)
    syllables = data.syllables(syllable_idxs);
    for ksyl = 1:length(syllables)
        % normalize rms to 1
        syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
    end
    syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
    motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
    stimcount = stimcount + 1;
    stimset.stims(stimcount).signal = motif;
    stimset.stims(stimcount).type = 'missing_syll';
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).name = ['song_a_minus_syl_', num2str(ksyl)];
end
% drop first 3
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
stimset.stims(stimcount).name = ['song_a_minus_abc'];
% drop last 3
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
stimset.stims(stimcount).name = ['song_a_minus_xyz'];
% drop last 2
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
stimset.stims(stimcount).name = ['song_a_minus_yz'];
stimset.numstims = stimcount;
save_boc_stimuli(stimset, pathdata.stim_path, ['exa1_song_a_decomp_probes'], 'db', 75)




syllable_idxs = base_idxs;
syllable_idxs(4:6) = sub_idxs(2,:);
% drop each syllable
for ksyl = 4:length(syllable_idxs)
    syllables = data.syllables(syllable_idxs);
    syllables(ksyl).wf = data.syllables(1,sub_idxs(1,ksyl-3)).wf;
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
    stimset.stims(stimcount).name = ['exa1_probe_song_b1_sub_syl_a', num2str(ksyl)];
end
syllable_idxs = base_idxs;
syllable_idxs(4:6) = sub_idxs(3,:);
% drop each syllable
for ksyl = 4:length(syllable_idxs)
    syllables = data.syllables(syllable_idxs);
    syllables(ksyl).wf = data.syllables(sub_idxs(1,ksyl-3)).wf;
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
    stimset.stims(stimcount).name = ['exa1_probe_song_b1_sub_syl_a', num2str(ksyl)];
end
stimset.numstims = stimcount;
save_boc_stimuli(stimset, pathdata.stim_path, ['exa1_all_probes'], 'db', 75)

%     for kstim = 1:length(stimset.stims)
%         generate_song_plot(stimset.stims(kstim).signal, data.fs)
%     end
%     tilefigs;


%% make s probe stimset

stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = data.fs;
stimcount = 0;
syllable_idxs = base_idxs;
syllable_idxs(4:6) = sub_idxs(1,:);
% drop first 3
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
stimset.stims(stimcount).name = ['exa1_song_a_minus_abc'];

% drop last 3
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
stimset.stims(stimcount).name = ['a_minus_xyz'];
% drop last 2
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
stimset.stims(stimcount).name = ['a_minus_yz'];
stimset.numstims = stimcount;
% drop Ya
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
stimset.stims(stimcount).type = 'drop_last_2';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['a_minus_y'];
stimset.numstims = stimcount;
% drop Za
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
stimset.stims(stimcount).name = ['song_a_minus_z'];
stimset.numstims = stimcount;




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
stimset.stims(stimcount).name = ['abc2_song_b_1', num2str(ksyl)];

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
stimset.stims(stimcount).name = ['abc2_song_b_2', num2str(ksyl)];

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
stimset.stims(stimcount).name = ['abc2_song_b_3', num2str(ksyl)];

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
stimset.stims(stimcount).name = ['abc2_song_a', num2str(ksyl)];

stimset.numstims = length(stimset.stims);
save_boc_stimuli(stimset, pathdata.stim_path, ['exa1_revised_probes'], 'db', 75)

%     for kstim = 1:length(stimset.stims)
%         generate_song_plot(stimset.stims(kstim).signal, data.fs)
%     end
%     tilefigs;






