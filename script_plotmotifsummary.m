ff = load_batchf('batch2');
motifsal = struct();

trialcnt = 0;
for i = 1:2:length(ff)
    trialcnt = trialcnt+1;
    load(['analysis/data_structures/motif_cab_',ff(i).name]);
    load(['analysis/data_structures/motif_cab_',ff(i+1).name]);
    motif1 = ['motif_cab_',ff(i).name];
    motif2 = ['motif_cab_',ff(i+1).name];
    jc_plotmotifsummary3b(eval(motif1),eval(motif2),'ro','r',3.5);
%     [motifsal(trialcnt).mdur motifsal(trialcnt).sdur ...
%         motifsal(trialcnt).gdur motifsal(trialcnt).mcv] = jc_plotmotifsummary3b(...
%         eval(motif1),eval(motif2),'ro','r',3.5);
end
