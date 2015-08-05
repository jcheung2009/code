function [prb,seq] = get_syl_prbs(ptnprobstrct,uniqueptnsvect,syl,dir)


if dir == 'fwd'
    ptn = ['$' syl];
else
    ptn = [syl '$'];
end

[id] = strfind(uniqueptnsvect(length(ptnprobstrct(1).ptn)).vect,ptn);


%%check for first syl in unique

if ptn(1) == '$'
    id =(id./(length(ptnprobstrct(1).ptn)+1))+1;
else
    id =((id+1)./(length(ptnprobstrct(1).ptn)+1));
end

for o = 1:length(id)
    prb(o) = ptnprobstrct(id(o)).prob;
    seq{o} = ptnprobstrct(id(o)).ptn;
end


[id] = strfind(uniqueptnsvect(length(ptnprobstrct(1).ptn)).vect,syl);

if ptn(1) == '$'
    if id(1) == 1
        prb(end+1) = ptrprobstrct(1).prob;
        seq{end+1} = ptrprobstrct(1).ptn;
    end
end