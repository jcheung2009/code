close all; clear all; clc

pathdata = path_localsettings;

data = load(fullfile(pathdata.stim_path, 'syllable_database.mat'));
data = data.data;

% pick out syllables to utilize
good_syls = [];
hist([data.syllables(:).dur])
for ksyl = 486:length(data.syllables)
    disp(ksyl)
    disp(data.syllables(ksyl).dur)
    wf = data.syllables(ksyl).wf;
    wf = zero_pad(wf,data.fs,50e-3,50e-3);
    fig = generate_song_plot(wf,data.fs);
    play_song(wf,data.fs)
    pause
    close(fig)
    
%     
%     x = input('1 = good syllable, 2 = bad syllable');
%     close(fig)
%     
% %     if x == 1
% %         good_syls = [good_syls ksyl];
% %     end
end

