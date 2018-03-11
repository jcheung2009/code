function [trans_per_song time_per_song] = jc_cnt_truncated_motifs(batchfile,motif);
%extracts a vector of 1's and 0's for each song, 1 being occurence of full
%motif and 0 being occurrence of truncated motif (common syllable is first
%syllable of full motif) 
%also outputs vector of timestamps for when motifs occurred 

%get all the labels
[all_syllables time_syl] = db_get_labels(batchfile);

%loop through each song and count when full or truncated motifs occurred
commonsyl = motif(1);
for i = 1:length(all_syllables)
    [st ed] = regexp(all_syllables{i},[commonsyl,'\w*']);
    trans_per_song{i} = ed-st+1 == length(motif);
    time_per_song{i} = time_syl{i}(st);
end