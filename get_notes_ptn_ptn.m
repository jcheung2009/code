function [b_labels, b_onsets, b_offsets, fname] = get_notes_ptn_ptn(batch)

%[b_labels, b_onsets, b_offsets] = notestats
%
%   reads a series of notefiles
%   returns the number of distinct notes,
%        a matrix containng note durations, one row per disitnct note
%        a string representing all song labels


%until the end of file, load the fiels and concatenate onsets offsets and labels
% into  single column vectors with '/' separating each input vector in label column


%get name of metafile containing notefile names

%meta_fid = -1;
metafile = char(batch);
%    disp('select batchfile');
%    [metafile, pathname]=uigetfile('*','select batchfile')
%    meta_fid=fopen([pathname, metafile]);
%    if meta_fid == -1 | metafile == 0
%       disp('cannot open file' )
%       disp (metafile)
%    end
meta_fid=fopen(['', metafile]);

%the special symbol '/' is used to separate songs

b_onsets=[0];
b_offsets=[0];
b_labels=['/'];

i = 0;
while 1
   %get notefile name
     notefile = fscanf(meta_fid,'%s',1);
     %end when there are no more notefiles 
     if isempty(notefile)
        disp('End of notefiles')
        break
     end
     i = i+1;
     fname{i} = notefile;
     
   %if notefile exists, get it
     if exist([pathname, notefile])   
       load([pathname, notefile]);
     else
       disp(['cannot find ', notefile])
     end
    labelstemp = labels;
     
   %make sure labels is a column vector
   [x,y]=size(labelstemp);
   if y > x
      labelstemp=labelstemp';
   end 
   
    [x,y]=size(onsets);
    if y>x
        onsets = onsets';
    end
    [x,y] = size(offsets);
    if y>x
        offsets = offsets';
    end

   %append input strings to batch strings and terminate with '/'
     b_onsets = [b_onsets; onsets; 0];
     b_offsets = [b_offsets; offsets; 0];
     b_labels = [b_labels; labelstemp; '/'];
     
end
