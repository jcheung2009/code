ff = load_batchf('batch_probe4_naspm');
motifsal = struct();

trialcnt = 0;
for i = 1:2:length(ff)
    trialcnt = trialcnt+1;
    load(['analysis/data_structures/bout_',ff(i).name]);
    load(['analysis/data_structures/bout_',ff(i+1).name]);
    motif1 = ['bout_',ff(i).name];
    motif2 = ['bout_',ff(i+1).name];
    jc_plotboutsummary2(eval(motif1),eval(motif2),'ro','r',3.5);
end
