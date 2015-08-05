clear all; close all; clc;


DIR = '/data/doupe_lab/stimuli/source_songs/wht24org20/';
wf = read_raw_file(fullfile(DIR, 'dir.20050913.0002'),'int16');

wf = wf/max(abs(wf));
ap = audioplayer(wf,44100);
plot(wf)
ap.play()