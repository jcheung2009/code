function [onsets, offsets]=segment_syllables(smooth, Fs, min_int, min_dur, threshold)

% segment takes smoothed filtered song and returns vectors of note onsets and offsets
% values are in seconds

%threshold input
notetimes=smooth>threshold;
notetimes = double(notetimes);
%extract index values for note onsets and offsets
h=[1 -1];
trans=conv(h,notetimes);
onsets=find(trans>0);
offsets=find(trans<0);
if (length(onsets) ~= length(offsets))
    disp('number of note onsets and offsets do not match')
else         
    %eliminate short intervals
    temp_int=(onsets(2:length(onsets))-offsets(1:length(offsets)-1))/Fs;
    real_ints=temp_int>min_int;
    onsets=[onsets(1); nonzeros(onsets(2:length(onsets)).*real_ints)];
    offsets=[nonzeros(offsets(1:length(offsets)-1).*real_ints); offsets(length(offsets))];
    
    %eliminate short notes
    temp_dur=(offsets-onsets)/Fs;
    real_durs=temp_dur>min_dur;
    onsets=[nonzeros((onsets).*real_durs)];
    offsets=[nonzeros((offsets).*real_durs)];
    
    %convert to ms: peculiarities here are to prevent rounding problem
    % if t_ons is simply replaced with onsets, everything gets rounded
    onsets = onsets/Fs;
    offsets = offsets/Fs;
  
end

