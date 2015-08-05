function [fvals] = jc_evtaffv(batch,nfft,fvalbnd)
%measures pitch at timebin before trig 
%nfft = 256 = 8 ms = what evtaf uses 
%fvalbnd = frequency range to look for max power in fft = [lo hi]

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

fvals = [];
for i = 1:length(files)
    recdata = readrecf(files(i).fn,'');
    if isempty(recdata.ttimes)
        continue
    end
    
    [rawsong fs] = evsoundin('',files(i).fn,'obs0');
    
    for ii = 1:length(recdata.ttimes)
        ind1 = 1+((floor(recdata.ttimes(ii)/1000*fs/nfft)-1)*nfft); %find time bin right before detection 
        ind2 = ind1 + nfft - 1;
        datchunk = rawsong(ind1:ind2);
        fdatchunk = abs(fft(hamming(nfft).*datchunk));
        fv = [0:nfft/2]*fs/nfft;
        fdatchunk = fdatchunk(1:nfft/2-1);
        tmpind = find(fv >= fvalbnd(1) & fv <= fvalbnd(2));
        [tmp pf] = max(fdatchunk(tmpind));
        pf = pf + tmpind(1) - 1;
        fvals = cat(1,fvals,fv(pf));
    end
end

        
    
    
    

        