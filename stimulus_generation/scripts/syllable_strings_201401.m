close all; clear all; clc;

save = true;

pathdata = path_localsettings;


data = load(fullfile(pathdata.stim_path, 'syllable_database'));
data = data.data;

% this is genreating a 3 motif repete song with A-B-C-X-E where X is one of several syllables


base_idxs = [1 8 9 ];...
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

all_sylables = all_sylables;
%generate all the songs
for ksub = 1:length(sub_idxs)
    random_idxs = 
    syllable_idxs = 
    syllable_idxs() = sub_idxs(ksub,:);
    wf = generate_motif_with_even_gaps(data.syllables(syllable_idxs), data.fs, 50e-3, 250e-3);
    wf = vertcat(wf,wf,wf);
    all_songs{ksub} = wf;
    % genreate plots
    %     generate_song_plot(wf,data.fs)
    %     play_song(wf,data.fs)
end





