function [vals,spec] = evtafsim(rsong,fs,templates);
% [vals,spec] = evtafsim(rsong,fs,templates);
% returns the threshold in case it was set in the program
% simtaf with the clocks and multiple templates put in
% templates is a matrix with each column is one template
% written by Evren Tumer Brainard Lab UCSF
%   adapated from code by written by other members of the lab
%
blen = size(templates,1);
nfft = blen*2;
hammy  = hamming(2*blen);

ntempl = size(templates,2);
nrep = floor(length(rsong)/nfft)-1;

vals = zeros([nrep,ntempl]);
spec = zeros([nrep,blen]);

% templates are normalized
for jj = 1:ntempl
        templates(:,jj) = templates(:,jj)-min(templates(:,jj));
        templates(:,jj) = templates(:,jj)./max(templates(:,jj));
end

for ii = 1:nrep
	ind1 = (ii-1)*nfft+ 1;
	ind2 = ind1 + nfft - 1;
	datchunk = rsong(ind1:ind2) - mean(rsong(ind1:ind2));
	fdatchunk = abs(fft(hammy.*datchunk));

	sp = abs(fdatchunk(1:blen));
    	sp(1:6)=0.0;
    	sp = sp-min(sp);
    	sp = sp./max(sp);
    	for jj = 1:ntempl
            vals(ii,jj) = (sp-templates(:,jj)).'*(sp-templates(:,jj));
        end
    	spec(ii,:) = sp.';
end
return;
