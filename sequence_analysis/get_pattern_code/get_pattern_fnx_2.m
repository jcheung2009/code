function patternstruct = get_pattern_fnx_2(batch,ptn,dosave,name)


%  get_pattern_fnx:    searches through a string of notes for a variable pattern
%  function patternstruct = get_pattern_fnx(batch,ptn)
%  inputs: 
%   <batch>: the name of a batch file containing .not.mat files
%   <ptn>: the pattern to search for
%   
%     SYNTAX FOR PATTERN:
%       i)the symbol "$", the terminus marker, must occur at the end of
%         the pattern, but is not considered in the search...it is just a parsing tool.        
%
%       ii)all notes that must occur in a specific order a particular
%           number of times are simply listed
%           eg. aab$  will return all occurances of 'aab'
%
%       ii)inclose all notes that must occur at least once
%           but that may occur and arbitrary number of times in "[" "]",
%           the  repeat markers
%           eg.  [abc]$ would return strings such as 'abc', 'abcabcabc...'
%
%        iii)inclose all definite sequence of notes (i.e. cant have other markers) 
%           that are to be included as part of the pattern if they do occur, 
%           but not necessary for a string to be a match to the pattern in "{" "}", 
%           the optional markers
%           eg. a{b}c$ will find all strings 'ac' and 'abc'           
%
%        iv)to indicate that you want a pattern to not be precedded or 
%           followed by a note or a defined sequence of notes, surround it
%           with "~" "~",the not markers (can only occur at the beginging
%           and end of pattern)
%           eg. ~a~[b]~d~$ will return 'b','bbbbbbb....', but only if not
%           precedded by an 'a' nor followed by a 'b'
%         
%        vi)the symbol "*" is used to indicate that any note can fill that
%           one spot in a pattern.  Can be used to search for all strings
%           of a particular length.
%           eg. '****$' will return all strings of length 4, irrespective
%           of syllable identitiy
%           eg. 'a*$' will return all pairs of strings beginning with an 'a'
%           eg. 'a**$' will return all triplets begining with an 'a'
%           eg. 'a*b$' will return all triplets begining with an 'a' and
%           ending with 'b'
%           
%
%            A long, over complicated example: the pattern '~a~[{i}]a{b}a[c][de{f}]h~qk~$' 
%            will return all strings
%            begining with a variable number of 'i's (including 0) followed by 'a',an optional 'b',
%            an 'a', some variable number of 'c' s, some variable number of 'd e f' s with 
%            the 'f' being optional, terminating in an 'h', and only the
%            those not followed by an occurance of 'q k', nor preceded by an 'a'
%                   e.g.  iiabacccdefdeh and iaacdedeh would be matched
%                   to this pattern, as well as many other strings, but
%                   strings such as aiiaaccdefh or iabaccccccdedeghqk,
%                   will not be considered as matching. 
%       
%  outputs:  a data structure containing:
%      a listing of the found strings matching the pattern, 
%      the onsets of the first note and the offsets of last note in each matched pattern  
%      the location in the song of the first and last notes (as well as in the batch) 
%      the songnames  
%      the last element of patternstruct is not a song, but has a field
%      with the the total number of found patterns


pattern = char(ptn);

%is the syntax appropriate??

TM = strfind(pattern,'$');
if length(TM) ~= 1 | TM ~= length(pattern)
    error('Must include a terminus marker, $, and it must be at the end of the pattern')
end

N_M = strfind(pattern,'~'); 
if ~isempty(N_M) 
    if mod(length(N_M),2) ~= 0 
        error('Not markers must come in pairs')
    end
end

SM = strfind(pattern,'*');

RMb = strfind(pattern,'[');
RMe = strfind(pattern,']');
if length(RMb) == length(RMe)
    for i = 1:length(RMb)-1
        if RMb(i+1)<RMe(i)
            error('Repeat markers are not properly paired up...can not have repeats with in repeats')
        end
    end
else error('There must be an equal number of left and right repeat markers')
end

OMb = strfind(pattern,'{');
OMe = strfind(pattern,'}');
if length(OMb) == length(OMe)
    for i = 1:length(OMb)-1
        if OMb(i+1)<OMe(i)
            error('Optional markers are not properly paired up...can not have optionals within optionals')
        end
    end
else error('There must be an equal number of left and right optional markers')
end   

% if pattern is syntactically correct, parse into parts   
[part, total] = pattern_parser(pattern,TM,N_M,RMb,RMe,OMb,OMe);

%  use notestats to get the string of labels with associated onsets and
%  offsets from a batch of .not.mat
[labels, ons, offs, fname] = get_notes_ptn_fnx(batch);

labels = labels';

patternstruct = part_matcher(part,labels,ons,offs,total,fname);

%patternstruct

%save the strct??
if dosave
    pattern = pattern(1:end-1);
    sv_name = [char(name),'.',char(pattern),'.ptnstrct.mat'];
    save(char(sv_name), 'patternstruct');
end
    
    
    
