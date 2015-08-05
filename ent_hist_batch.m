function [histout] = ent_hist_batch(batch,bins)
%
% [histout] = ent_hist_batch(batch, bins)
% returns histogram of rolling entropy for files in batch
%

fid=fopen(batch,'r');
disp(['working...']);

histout = zeros(size(bins));

numfiles = mcountfilelines(batch);
waithandle = waitbar(0,'starting...');
index=0;
while (1)
    fn=fgetl(fid);
    if (~ischar(fn))
        break;
    end
    if (~exist(fn,'file'))
        continue;
    end
    
    %disp(fn);
    [filepath,fn,ext]=fileparts(fn);
    if (strcmp(ext,'.ebin'))
        [dat,fs]=readevtaf(fn,'0r');
    elseif(strcmp(ext,'.cbin'))
        [dat,fs]=ReadCbinFile(fn);
    elseif(strcmp(ext,'.wav'))
        [dat,fs]=wavread(fn);
    end
    
    [thespect] = plotspect(dat,fs,0);
    ent = rolling_ent(thespect);
    filtent = ent.*(ent<.99);
    filtent = mzeros2nan(filtent);
    
    [enthist] = hist(filtent,bins);
    histout = histout + enthist;
    
    waitbar(index/numfiles,waithandle,'working...');
    index = index+1;
end
close(waithandle);
fclose(fid);

pdfout = histout / sum(histout); % covert to prob. density function
histout = pdfout;

return;