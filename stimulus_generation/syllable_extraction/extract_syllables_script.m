%% Script to extract syllables from all songs in a particular folder
close all; clc; clear


BIRDDIR{1} = '/data/doupe_lab/stimuli/source_songs/wht24org20/';



for kdir = 1:length(BIRDDIR)
    extract_and_save_syllables(BIRDDIR{kdir})
end