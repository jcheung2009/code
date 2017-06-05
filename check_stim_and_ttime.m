function [numtrig numstim] = check_stim_and_ttime(batch);
%check that there was actually ttl output from stimbox when evtaf sends
%trigger 
%ttl output from stimbox is recorded in second channel of cbin 


numtrig = 0;numstim = 0;
ff = load_batchf(batch);
for i = 1:length(ff)
    rd = readrecf(ff(i).name);
    if isempty(rd)
        continue
    end
    
    [dat fs] = evsoundin('',ff(i).name,'obs1');
    bdat = imbinarize(dat,1e4);
    stimtimes = (find(diff(bdat)==1))./fs;
    stimtimes = stimtimes(find(stimtimes>=rd.tbefore));
    numstim = numstim+length(stimtimes);
    if isfield(rd,'catch') & ~isempty(rd.catch)
        numtrig = numtrig+length(find(rd.catch==0));
        if length(stimtimes)~= length(find(rd.catch==0))
            disp(ff(i).name);
        end
    else
        continue
    end
end

    
    