close all; clear all; clc;

save = true;

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

song_names = {'song_a_1', 'song_b_1','song_b_2','song_b_3','song_b_4','song_b_5','song_b_6'};


%generate all the songs
for ksub = 1:length(song_names)
    stimset = struct;
    stimset.total_length_est = 0;
    stimset.samprate = data.fs;
    stimcount = 0;
    
    syllable_idxs = base_idxs;
    syllable_idxs(4:6) = sub_idxs(ksub,:);
    
    % add regular motif
    motif = generate_motif_with_even_gaps(data.syllables(syllable_idxs), data.fs, 50e-3, 250e-3);
    stimcount = stimcount + 1;
    stimset.stims(stimcount).signal = motif;
    stimset.stims(stimcount).type = 'full_motif';
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).name = 'full_motif';
    
    % drop each syllable
    for ksyl = 1:length(syllable_idxs)
        syllables = data.syllables(syllable_idxs);
        syllables(ksyl).wf = zeros(size(syllables(ksyl).wf));
        motif = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 250e-3);
        stimcount = stimcount + 1;
        stimset.stims(stimcount).signal = motif;
        stimset.stims(stimcount).type = 'missing_syll';
        stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
        stimset.stims(stimcount).onset = 0;
        stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
        stimset.stims(stimcount).name = ['motif_minus_syl_', num2str(ksyl)];
    end
    
    % drop first 3
    syllables = data.syllables(syllable_idxs);
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
    stimset.stims(stimcount).name = ['motif_minus_first_3'];
    
    % drop last 3
    syllables = data.syllables(syllable_idxs);
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
    stimset.stims(stimcount).name = ['motif_minus_last_3'];
    
    % drop last 2
    syllables = data.syllables(syllable_idxs);
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
    stimset.stims(stimcount).name = ['motif_minus_last_2'];
    stimset.numstims = stimcount;
    
    
    save_krank_stimuli(stimset, pathdata.stim_path, ['sylsong_decompose_', song_names{ksub}], 'zero_pad_length',2,'add_null',true)
%     for kstim = 1:length(stimset.stims)
%         generate_song_plot(stimset.stims(kstim).signal, data.fs)
%     end
%     tilefigs;

end


