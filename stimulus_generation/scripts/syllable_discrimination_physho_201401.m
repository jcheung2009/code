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

%generate all the songs
for ksub = 1:length(sub_idxs)
    syllable_idxs = base_idxs;
    syllable_idxs(4:6) = sub_idxs(ksub,:);
    wf = generate_motif_with_even_gaps(data.syllables(syllable_idxs), data.fs, 50e-3, 250e-3);
    wf = vertcat(wf,wf,wf);
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
stimset.stims(stimcount).name = 'song_a_1';
bcount=0;
for ksong = 2:7
    bcount=bcount+1;
    % add song1
    stimcount = stimcount + 1;
    stimset.stims(stimcount).signal = all_songs{ksong};
    stimset.stims(stimcount).type = 'song';
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).name = ['song_b_', num2str(bcount)];
    
end
ccount=0;
for ksong = 8:length(all_songs)
    ccount=ccount+1;
    % add song1
    stimcount = stimcount + 1;
    stimset.stims(stimcount).signal = all_songs{ksong};
    stimset.stims(stimcount).type = 'song';
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).name = ['song_control_', num2str(ccount)];
    
end


stimset.numstims = stimcount;
save_krank_stimuli(stimset, pathdata.stim_path, 'sylsongdiscrimination_201401', 'zero_pad_length',2,'add_null',true)
return

