function [id cnts] = find_uniquelbls(stringvect,seqlen,mincnt);
%given string vector, find unique sequences of length seqlen and minimum
%occurence (mincnt), eliminates full repeats and sequences containing
%non-alpha characters

N = length(stringvect);
[id, ~, nn] = unique(stringvect(bsxfun(@plus,1:seqlen,(0:N-seqlen)')),'rows');
cnts = sum(bsxfun(@(x,y)x==y,1:size(id,1),nn))';
removeind = [];
for ii = 1:size(id,1)
    if length(unique(id(ii,:)))==1 | sum(~isletter(id(ii,:))) > 0 %remove repeats and sequences with non-alpha
        removeind = [removeind;ii];
    end
end
cnts(removeind) = [];id(removeind,:) = [];
ind = find(cnts >= mincnt);%only sequences that occur more than 25 times 
id = id(ind,:);cnts = cnts(ind);
id = mat2cell(id,repmat(1,size(id,1),1))';