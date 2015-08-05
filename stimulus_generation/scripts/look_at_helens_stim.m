close all; clear all; clc

pathdata = path_localsettings;
stimfile = 'motifChunks75sec-T02.raw';
stimfile = fullfile(pathdata.stim_path, stimfile);

fidstim = fopen(stimfile,'r','b');
[data, stimlength] = fread(fidstim,inf,'int16');
fclose(fidstim);

plot_bird_spectrogram(data(1:4e4),40e3)