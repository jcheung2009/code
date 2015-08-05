function patternstruct = get_pattern


%  get_pattern:    searches through a string of notes for a variable pattern
%  
%  inputs:   prompts the user for a batch file containing the names of
%  .not.mat files; also prompts for the pattern to be searched for
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
%        vi)the symbol "*" can be used to search for all strings containing
%           one or more of the other parts, can not co-occur with another instance of "*", 
%           by itself (i.e '*$' is not a valid search), nor with not-markers.  No good 
%           reason for this...i just didnt code it generally...(future work)
%           eg. 'a*$' will return all strings beginning with an 'a',
%           regardless of what comes after it.
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
%  outputs:  a data structure containing a listing of the found strings
%  matching the pattern, as well as the onsets and offsets associated with
%  the notes contained in a found string; and the songnames  


pattern = input('Enter syntax appropriate pattern: ');

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
if ~isempty(SM)
    if length(SM) ~= 1
        error('Pattern can only include one *')
    end
    if ~isempty(N_M)
        error('Can not include star (*) in patterns with nots (~ ~)....sorry.')
    end
    if length(pattern) ==1
        error('Star can not be the only thing in the pattern: must include some other part')
    end
end

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
[part, total] = pattern_parser(pattern,TM,N_M,RMb,RMe,OMb,OMe)

%  use notestats to get the string of labels with associated onsets and
%  offsets from a batch of .not.mat
[labels, ons, offs, fname] = notestats_gtptn;

labels = labels';

patternstruct = part_matcher_test(part,labels,ons,offs,total,fname);

patternstruct;










