function pcum= BBN(trns_strct, seq)

%get the indices of the elements in seq
for i = 1:length(seq)
    idx(i) = strfind(trns_strct.lbls,seq(i));
end

%now run through the transistions and integrate probs
p = 0;
for k =1:length(seq)-1
    p = [p trns_strct.mtrx(idx(k),idx(k+1))];
end
pcum = cumsum(p);