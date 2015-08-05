function [histout] = ff_hist_batch(batch,bins)
%
% [histout] = ff_hist_batch(batch, bins)
% returns histogram of rolling fund freq values for files in batch
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
   
    [ff ffconf fftime] = rolling_ff(fn); 
    filtff = mfffilt(ff,ffconf);
    
    [ffhist] = hist(filtff,bins);
    histout = histout + ffhist;
    
    waitbar(index/numfiles,waithandle,'working...');
    index = index+1;
end
close(waithandle);
fclose(fid);

pdfout = histout / sum(histout); % covert to prob. density function
histout = pdfout;

return;