function []= intg_fnx_stats(syls,patrnstrct,intgtm_mst,intgtm_med,name)
%intg_fnx_stats(patrnstrct,intgtm_mst,intgtm_med)
%
%goes through all patterns of length 1:10 and pulls out the counts
%associated with the patterns found in intgtm structs
%

load (char(patrnstrct));

%get the max local transition/likelihood
cnt = 0;
for i = 1:length(patrnstrct{1}.lkl)
    syl = patrnstrct{1}.lkl(i).ptn;
    if ~isempty(strfind(syls,syl))
        cnt = cnt+1;
        maxprb = 0;maxidxP = 0;maxlkl = 0;maxidxL = 0;
        ptrns = patrnstrct{2}.ptns.vect;
        brks = strfind(ptrns,'$');
        idxs = strfind(char(ptrns),[char(syl) '$']);
        for j = 1:length(idxs)
            sylidxs = find(brks == (idxs(j)+1));
            if patrnstrct{2}.prb(sylidxs).prob > maxprb
                maxprb =  patrnstrct{2}.prb(sylidxs).prob;
                maxidxP = sylidxs;
            end
            if patrnstrct{2}.lkl(sylidxs).prob > maxlkl
                maxlkl=  patrnstrct{2}.lkl(sylidxs).prob;
                maxidxL = sylidxs;
            end
        end
        seq_stat.Mst.maxP.prb(cnt) =maxprb; seq_stat.Mst.maxP.lkl(cnt) =maxlkl;
        seq_stat.Mst.maxP.Pptrn{cnt} = patrnstrct{2}.prb(maxidxP).ptn;
        seq_stat.Mst.maxP.Lptrn{cnt} = patrnstrct{2}.lkl(maxidxL).ptn;
    end
end

%%%GET THE MOST COMMON LENGTH 10 PATERN...AND calculate evidence for
%%%it..also get sequence for most
maxcnt = 0;maxidx = 0;
for i = 1:length(patrnstrct{10}.lkl)-1
    if patrnstrct{10}.lkl(i).cnt >maxcnt
        maxcnt = patrnstrct{10}.lkl(i).cnt;
        maxidx = i;
    end
    seq_stat.Mst.max_ptrn.ptrn = patrnstrct{10}.lkl(maxidx).ptn;
end

for i = 1:9
    ptrn =  seq_stat.Mst.max_ptrn.ptrn(i:i+1);
    brks = strfind(patrnstrct{2}.ptns.vect,'$');
    idxs = strfind(patrnstrct{2}.ptns.vect,ptrn);idxs = find(brks == idxs+2);
    seq_stat.Mst.max_ptrn.L(i) = patrnstrct{2}.lkl(idxs).prob;
    seq_stat.Mst.max_ptrn.P(i) = patrnstrct{2}.prb(idxs).prob;
end




%do the most probable patterns
load (char(intgtm_mst));
for i = 1:length(intgtm_strct)
    brks = strfind(intgtm_strct(i).ptns,'/');
    for k = 1:length(brks)-1
        ptrn = intgtm_strct(i).ptns(brks(k)+2:brks(k+1)-1); ptrnlng = length(ptrn);
        ptrnidx = strfind(patrnstrct{ptrnlng}.ptns.vect,char(ptrn));
        ptrnidx = find([strfind(patrnstrct{ptrnlng}.ptns.vect,'$')] == ptrnidx+k);
        seq_stat.Mst.Lcnts(i,ptrnlng) = patrnstrct{ptrnlng}.lkl(ptrnidx).cnt;
        seq_stat.Mst.Lptrn(i).ptrn{ptrnlng} = ptrn;
    end
    ten_ptrn =  intgtm_strct(i).ptns(end-10:end-1);
    for l = 1:10
        ptrnidx = strfind(patrnstrct{l}.ptns.vect,char(ten_ptrn(1:l)));
        ptrnidx = find([strfind(patrnstrct{l}.ptns.vect,'$')] == ptrnidx+l);
        seq_stat.Mst.Pcnts(i,l) = patrnstrct{l}.prb(ptrnidx).cnt;
        seq_stat.Mst.Pptrn(i).ptrn{l} = ten_ptrn(1:l);
    end
end

for i = 1:length(intgtm_strct)
    brks = strfind(intgtm_strct(i).ptns,'/');
    ptrns = intgtm_strct(i).ptns(brks(end-1)+2:brks(end)-1);
    for k = 1:9
        twoptrn = ptrns(10-k:11-k);
        ptrnidx = strfind(patrnstrct{2}.ptns.vect,char(twoptrn));
        ptrnidx = find([strfind(patrnstrct{2}.ptns.vect,'$')] == ptrnidx+2);
        seq_stat.Mst.lkl(i,k) = patrnstrct{2}.lkl(ptrnidx).prob;
        seq_stat.Mst.prb(i,k) = patrnstrct{2}.prb(ptrnidx).prob;
        seq_stat.Mst.dub(i).ptrn{k} = twoptrn;
    end
end



%now for the med probable patterns
load (char(intgtm_med));
for i = 1:length(intgtm_strct)
    brks = strfind(intgtm_strct(i).ptns,'/');
    for k = 1:length(brks)-1
        crntptrn = intgtm_strct(i).ptns(1+(k-1)*11:10+(k-1)*11);
        for j = 1:10
            ptrn = crntptrn(end-(j-1):end);
            ptrnidx = strfind(patrnstrct{j}.ptns.vect,char(ptrn));
            ptrnidx = find([strfind(patrnstrct{j}.ptns.vect,'$')] == ptrnidx+j);
            if patrnstrct{j}.lkl(ptrnidx).ptn == ptrn
                tempL(k,j) = patrnstrct{j}.lkl(ptrnidx).cnt;
            else break; end
            ptrn = crntptrn(1:j);
            ptrnidx = strfind(patrnstrct{j}.ptns.vect,char(ptrn));
            ptrnidx = find([strfind(patrnstrct{j}.ptns.vect,'$')] == ptrnidx+j);
            if patrnstrct{j}.lkl(ptrnidx).ptn == ptrn
                tempP(k,j) = patrnstrct{j}.prb(ptrnidx).cnt;
            else break; end
        end
    end
    seq_stat.Med.Lcnts(i,:)= round(mean(tempL));
    seq_stat.Med.Pcnts(i,:)= round(mean(tempP));
    tempP =[]; tempL = [];
end


for i = 1:length(intgtm_strct)
    brks = strfind(intgtm_strct(i).ptns,'/');
    for k = 1:length(brks)-1
        crntptrn = intgtm_strct(i).ptns(1+(k-1)*11:10+(k-1)*11);
        for j = 1:9
            twoptrn = crntptrn(10-j:11-j);
            ptrnidx = strfind(patrnstrct{2}.ptns.vect,char(twoptrn));
            ptrnidx = find([strfind(patrnstrct{2}.ptns.vect,'$')] == ptrnidx+2);
            if patrnstrct{2}.lkl(ptrnidx).ptn == twoptrn
                tempL(k,j) = patrnstrct{2}.lkl(ptrnidx).prob;
                tempP(k,j) = patrnstrct{2}.prb(ptrnidx).prob;
            else break; end
        end
    end
    seq_stat.Med.lkl(i,:) = mean(tempL);
    seq_stat.Med.prb(i,:) = mean(tempP);
    tempP =[]; tempL = [];
end



name = [name '.seqstats.mat'];
save(name,'seq_stat')



