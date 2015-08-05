function [vals] = getents(fv)
%
% function [entvect] = getents(fv)
%
% returns overall spectral entropy for each syllable/entry in fv
%
%

vals=zeros([length(fv),2]);
for ii = 1:length(fv)
    fdat = fv(ii).fdat / sum(fv(ii).fdat);
    ent = (fdat .* log2(fdat)) / log2(length(fdat));
    ent = -sum(ent);
    %vals(:,ii) = ent;
    dn=fn2datenum(fv(ii).fn);
    vals(ii,:)=[dn,ent];
    
end

return;