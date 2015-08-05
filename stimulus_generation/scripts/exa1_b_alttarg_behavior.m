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
    489 490 494;...
    498 499 500;...
    506 507 508;...
    509 514 515;...
    516 517 520;... 
    523 524 525;...
    526 527 528;...
    530 532 533;...
    535 541 543;...
    548 551 554;...
    563 564 565;...
    566 567 568;...
    569 570 573;...
    574 575 576;...
    578 579 581;...
    584 585 586;...
    587 588 589;...
    590 591 592;...
    596 597 599;...
    600 601 605;...
    608 610 611;...
    612 613 616;...
    617 618 619;...
    621 622 623;];

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
stimset.stims(stimcount).signal = all_songs{2};
stimset.stims(stimcount).type = 'song';
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).name = ['exa1_song_b_1'];
stimset.numstims = stimcount;
stimset_a = stimset;
clear stimset
if save
    %save_hop_stimuli(stimset_a,pathdata.stim_path, 'motif_stimset_a');
    save_boc_stimuli(stimset_a,pathdata.stim_path, 'exa1_alttarg_motif_stimset_a','db',75)
end
% make stimset B
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

for ksong = [3:length(all_songs)]
    % add song1
    stimcount = stimcount + 1;
    stimset.stims(stimcount).signal = all_songs{ksong};
    stimset.stims(stimcount).type = 'song';
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).name = ['exa1_song_b_', num2str(stimcount)];
    stimset.numstims = stimcount;
end
if save
    %save_hop_stimuli(stimset_a,pathdata.stim_path, 'motif_stimset_a');
    save_boc_stimuli(stimset,pathdata.stim_path, 'exa1_alttarg_motif_stimset_b','db',75)
end