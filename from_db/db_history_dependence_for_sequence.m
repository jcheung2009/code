function [ history_dependence shuffled_history_dependence trans_per_song] = db_history_dependence_for_sequence( batchfile, motifs, number_bootstraps )
%db_history_dependence Calculates history dependence and shuffled history
%dependence for a given batchfile (or single song). 
%  HD = abs( p(ab|ab) - p(ab|ac) )
%   Detailed explanation goes here

%% Checks number of arguments. If number_bootstraps not specified, default is 10,000
if nargin < 3
    number_bootstraps = 10000;
end

%% Run db_transition_probability for trans probs per song and to see if it is
%convergent or divergent (but does not do bootstrap procedure)
%gets all the labels for the day in batchfile
try
    [all_syllables, time_syl] = db_get_labels(batchfile);
catch err
    try
        %if there was an error running db_get_labels as if it were a batch
        %file, it runs it as if it were a single song
        [all_syllables, time_syl] = db_get_labels(batchfile,'y');
    catch err
        display('Something is wrong with you batchfile')
        return
    end
end

[trans_per_song] = db_transition_probability_calculation(all_syllables, motifs, 'n');
% [trans_per_song] = db_transition_probability_for_sequence(batchfile, motifs, 'n');

%% Runs db_history_dependence_calculation to get history dependence for songs sung that day

history_dependence = db_history_dependence_calculation(trans_per_song, motifs, number_bootstraps);

%% Calculates shuffled history dependence (by shuffling syllables within each song)

for i = 1:number_bootstraps
    
    for j = 1:length(trans_per_song)
        shuffled_per_song{j} = trans_per_song{j}(randperm(length(trans_per_song{j})));
    end
    
    shuffled_history_dep = db_history_dependence_calculation(shuffled_per_song, motifs, 1);
    
    for k = 1:length(motifs)
        shuffled_history_dependence.(motifs{k})(i) = shuffled_history_dep.(motifs{k});
    end
    
    clear shuffled_history_dep
end



end

