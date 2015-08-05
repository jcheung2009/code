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
            120 152 600;
            460 554 465;... % c songs
            476 499 517;...
            529 535 552;...
            541 503 495;...
            525 486 464;];
all_idxs = [base_idxs(1:3)'; sub_idxs(:)];

count = 0;
for ksong = [1 2 8];
    count = count + 1;
    songs(count,:) = base_idxs;
    songs(count,4:6) = sub_idxs(ksong,:);
end

%         normalize all the syllables ahead of time       
for ksyl = 1:length(data.syllables)
    % normalize rms to 1
    data.syllables(ksyl).wf = normalize_rms_to_one(data.syllables(ksyl).wf);
end
  
string_length = 500;
n_occurance = 3;
n_strings = 15;



stimset = struct;
stimset.total_length_est = 0;
stimset.samprate = data.fs;
stimcount = 0;
for kstring = 1:n_strings
    rand_idxs = randi([1 800],string_length,1);
    % sub in single syllables
    for ksyl=1:length(all_idxs)
        for ksub = 1:n_occurance
            sub_idx = randi([1, string_length],1,1);
            rand_idxs(sub_idx) = all_idxs(ksyl);
        end
    end
    for ksong = 1:size(songs,1)
        for ksub = 1:n_occurance
            for ksyl = 4:6
                for korder = 1:3
                    sub_idx = randi([1, string_length-6],1,1);
                    rand_idxs(sub_idx:sub_idx+korder) = songs(ksong,ksyl-korder:ksyl);
                end
            end
        end
    end
    syllables = data.syllables(rand_idxs);
    [wf onsets] = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 50e-3);
    
    stimcount = stimcount + 1;
    stimset.stims(stimcount).signal = wf;
    stimset.stims(stimcount).type = 'syllable_string';
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).name = ['exa1_syllable_string_', num2str(kstring)];
    stimset.stims(stimcount).syllable_onsets = onsets;
    stimset.stims(stimcount).syllable_durs = [syllables(:).dur];
    stimset.stims(stimcount).syllable_ids = rand_idxs;  
    stimset.numstims = stimcount;
end

if savetest
    stimset_out = save_krank_stimuli(stimset, pathdata.stim_path, 'exa1_syllable_strings', 'zero_pad_length',0,'add_null',0);
end
    
