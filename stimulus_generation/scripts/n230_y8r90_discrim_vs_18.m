% Stimulus display
close all; clear all; clc

% this script generates stimuli for the tf motif shift experiment
pathdata = path_localsettings;
DIR = dir(fullfile(pathdata.stim_path,'n230_TUT_y9r90'));
count = 0;
fs = 44100;
for kfile = 1:length(DIR)
    if DIR(kfile).bytes>500000
        count = count+1;
        song(count).wf = ReadDataFile(fullfile(pathdata.stim_path,'n230_TUT_y9r90',DIR(kfile).name));
        %         plot((1:length(song(count).wf))/fs, song(count).wf)
        %         ap=audioplayer(song(count).wf,44100);
        %         ap.play()
        %         pause
        %
    end
end


wf_song = cut_segment(song(4).wf, fs, 1, 8.5);


% load probesongs stimset
stimset = load(fullfile(pathdata.stim_path,'18_probe_songs','18_probe_songs_stimset.mat'));
stimset = stimset.stimset;

% resample song to fit stimset
fs = round(fs); 
fs_out = round(stimset.samprate);
div = gcd(fs, fs_out);
p = fs/div;
q = fs_out/div;
wf_song = resample(wf_song, q, p);


% plot(wf_song)

% replace song 1 with the father's song
stimcount = 1;
stimset.stims(stimcount).signal = wf_song;
stimset.stims(stimcount).type = 'fathers song (yellow9red90)';
stimset.stims(stimcount).tag = ['song 1'];
stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
stimset.stims(stimcount).onset = 0;
stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
stimset.total_length_est = stimset.total_length_est + stimset.stims(stimcount).length/fs + 4;


stimset.stims=stimset.stims(1:18);
stimset.numstims = length(stimset.stims);
save_krank_stimuli(stimset, pathdata.stim_path, 'n230_y9r90_discrim_vs_18')
