ff = load_batchf('batchsal');
motifsal = struct();

trialcnt = 0;
for i = 1:2:length(ff)
    trialcnt = trialcnt+1;
    load(['analysis/data_structures/motif_aqwerrry_',ff(i).name]);
    load(['analysis/data_structures/motif_aqwerrry_',ff(i+1).name]);
    motif1 = ['motif_aqwerrry_',ff(i).name];
    motif2 = ['motif_aqwerrry_',ff(i+1).name];
    [motifsal(trialcnt).mdur motifsal(trialcnt).sdur ...
        motifsal(trialcnt).gdur motifsal(trialcnt).mcv] = jc_plotmotifsummary(...
        eval(motif1),eval(motif2),'k.','k',0,'n');
end
