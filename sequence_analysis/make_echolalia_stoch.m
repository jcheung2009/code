function [] = make_echolalia_stoch(batchnotmats,name,spctstrct)

load(spctstrct);
for i = 1:length(spct_strct)
    syls(i) = spct_strct{i}.lbl;
    sylSpct = interp2(spct_strct{i}.proto,3);%interpolate to make larger
    sylSpct = uint16(((2^16)-1)*(sylSpct./max(max(sylSpct))));%convert to uint16
    imwrite(sylSpct,[char(syls(i)) '.png'],'png','BitDepth',16,'Background',0);
    maxA(i) = max(abs(spct_strct{i}.p_wvfrm));
end

maxA = maxA./max(maxA);

for i = 1;length(syls)
    wavwrite(.99*maxA(i)*spct_strct{i}.p_wvfrm./max(abs(spct_strct{i}.p_wvfrm)),32e3,16,[char(syls(i)) '.wav']);
end


%get the doublets
patternstrct = get_pattern_fnx_2(char(batchnotmats),'**$',1,name);
ptnprobstrct = prob_of_patterns(patternstrct,'first');
trns_strct = make_trns_strct(ptnprobstrct,char(syls),'first','null',0);
trns_mtrx = trns_strct.mtrx;
%initialize rptstrct
rptstrct.lbls{1} = 0;
rptstrct.prms(1,:) = [0 0];
rptstrct.prbdist{1} = 0;
cntr = 0;
for i = 1:length(syls)
    if trns_mtrx(i,i) ~= 0
        cntr = cntr+1;
        rpt_ptn = ['[' char(trns_strct.lbls(i)) ']$'];
        patternstruct = get_pattern_fnx_2(char(batchnotmats),char(rpt_ptn),1,name);
        rptstrct = count_repeats(patternstruct,rptstrct,0,char(trns_strct.lbls(i)));
        rpt{i} = rptstrct.prbdist{cntr};
        lngrpt(i) = length(rptstrct.prbdist{cntr});
    else
        rpt{i} = 0;
        lngrpt(i) = 1;
    end
end

rpt_mtrx = zeros(length(syls),max(lngrpt));

for i=1:length(syls)
     rpt_mtrx(i,1:lngrpt(i)) = rpt{i};
end  

[isiStrct] = get_iSi_ptnstrct(patternstrct,trns_strct,name);
isi_mtrx = isiStrct.mumtrx;

save trns_mtrx.txt trns_mtrx -ASCII -TABS
save rpt_mtrx.txt rpt_mtrx -ASCII -TABS
save isi_mtrx.txt isi_mtrx -ASCII -TABS
save syls.txt syls -ASCII -TABS
