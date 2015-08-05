%% extract syllables all syllables from helen's data
close all; clear all; clc

pathdata = path_localsettings;

composit_stim = load(fullfile(pathdata.stim_path, 'composite65dB.mat'));

data = struct;
data.fs = composit_stim.stimset.samprate;
for kstim = 1:length(composit_stim.stimset.stims)
    syllables = extract_syllables_from_song(composit_stim.stimset.stims(kstim).signal, data.fs);
    if kstim == 1
        data.syllables = syllables;
    else
        data.syllables = [data.syllables syllables];
    end
    
    if 0
        x = vertcat(syllables(:).wf);
        fig=generate_song_plot(x, data.fs)
        ap = audioplayer(x,data.fs);
        ap.play();
        pause
        close(fig)
    end
end

% save(fullfile(pathdata.stim_path,'syllable_database.mat'),'data') %
% commented out to protect data