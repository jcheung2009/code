function bout = jc_findbout2(batch,fvrep,CHANSPEC)
%define bout by each song file 
%fvrep from jc_findrepeat
%CHANSPEC = 'obs0';

ff = load_batchf(batch);
bout_cnt = 0;
for i = 1:length(ff)
    fn = ff(i).name;
    fnn=[fn,'.not.mat'];
    if (~exist(fnn,'file'))
        continue;
    end
    load(fnn);
     %load rec file
    rd = readrecf(fn);
     %load raw song data
    [pthstr,tnm,ext] = fileparts(fn);
    if (strcmp(CHANSPEC,'w'))
            [dat,fs] = audioread(fn);
    elseif (strcmp(ext,'.ebin'))
        [dat,fs]=readevtaf(fn,CHANSPEC);
    else
        [dat,fs]=evsoundin('',fn,CHANSPEC);
    end
    if (isempty(dat))
        disp(['hey no data!']);
        continue;
    end
    
    %number of motifs 
    ind = find(arrayfun(@(x) strcmp(x.fn,ff(i).name),fvrep));
    if isempty(ind)
        continue
    end
    numrepsinbout = length(ind);
    
    bout_cnt = bout_cnt+1;
    bout(bout_cnt).filename = fn;
    bout(bout_cnt).datenm = fvrep(ind(1)).datenm;
    bout(bout_cnt).nummotifs = numrepsinbout;
    
end
    