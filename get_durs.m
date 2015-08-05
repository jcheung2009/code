function [notedurs,intdurs] = get_durs(onsets, offsets, labels, notes)

% function [notedurs,intdurs] = get_durs(onsets, offsets, labels, notes)
%
% returns durations for the notes in the input string 'notes'
% if no note string is provided, returns all durations in the
% vector NOTEDURS.  Also returns the interval durations INTDURS.
%
% Written by M. S. Brainard.
% Modified 9/13/02 : A. K. Schenk

notedurs = [];
intdurs = [];

%if no notes are provided returns all notedurs
if nargin <= 3
  notedurs = offsets - onsets; 
  
  shiftoffsets = [offsets(1);offsets(1:length(offsets)-1)];
  intdurs = onsets-shiftoffsets;
  intdurs = intdurs(2:length(intdurs));
  
else
   for i = 1:length(notes)
    if ~isempty(labels)  
     index = find(notes(i) == labels);
     new_durs = offsets(index) - onsets(index); 
     notedurs = [notedurs; new_durs];
     
     shiftoffsets = [offsets(1);offsets(1:length(offsets)-1)];
     new_intdurs = onsets(index)-shiftoffsets(index);
     new_intdurs = new_intdurs(2:length(new_intdurs));
     
     intdurs = [intdurs;new_intdurs];
    end 
  end
end  
