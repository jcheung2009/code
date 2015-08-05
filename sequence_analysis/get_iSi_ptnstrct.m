function [isiStrct] = get_iSi_ptnstrct(patternstruct,lbls,name)

%iSiM = get_iSi_ptnstrct(ptnstrct,lbls,name)
% returns a mtrx of the inter-sylable intervals (iSi) of the notes in a
% found pattern
% <ptnstrct>: a patternstrct from get_pattern
% <trns_strct>: a transition structure
% <name>: name of output file


isiM = nan(length(lbls),length(lbls),1000);cntrM = zeros(length(lbls),length(lbls));
for i = 1:length(patternstruct)-1
    if ~isempty(patternstruct(i).ptnlbls)
        for k = 1:length(patternstruct(i).ptnlbls)
            %identify syllables row = Si, column = Si+1
            R = strfind(lbls,patternstruct(i).ptnlbls{k}(1));C = strfind(lbls,patternstruct(i).ptnlbls{k}(2));
            cntrM(C,R) = cntrM(C,R)+1;
            isiM(C,R,cntrM(C,R)) = patternstruct(i).ptnons{k}(2)-patternstruct(i).ptnoffs{k}(1);
        end
    end
end



name = [name '.isiStrct.mat'];
isiStrct.cntrM = cntrM;
isiStrct.lbls = lbls; 
isiStrct.vals = isiM;
[l,p] = find(isiStrct.vals==0);isiStrct.vals(l,p) = nan;


save(char(name),'isiStrct')