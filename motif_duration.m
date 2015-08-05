function [motif_dur motif_onsets motif_offsets] = motif_duration(batch,motif)

fid=fopen(batch,'r');
files=[];cnt=0;
while (1)
       fn=fgetl(fid);
       if (~ischar(fn))
               break;
       end
       cnt=cnt+1;
       files(cnt).fn=fn;
end
fclose(fid);

motif_length = length(motif)-1;
motif_dur = [];
motif_onsets = [];
motif_offsets = [];
for i = 1:length(files);
    if exist([files(i).fn,'.not.mat'],'file') == 0
        continue
    else
     load(strcat(files(i).fn,'.not.mat'));   
     a = strfind(labels, motif);
    end
   for ii = 1:length(a)
    motif_onset = onsets(a(ii));
    motif_offset = offsets(a(ii)+motif_length);
    motifduration = motif_offset - motif_onset;
    motif_dur = cat(2,motif_dur, motifduration);
    motif_onsets = cat(1,motif_onsets,motif_onset);
    motif_offsets = cat(1,motif_offsets,motif_offset);
    end
end
