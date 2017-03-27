ff = load_batchf('batchsaleveryother');
saldurerror = struct();

trialcnt = 0;
for i = 1:2:length(ff)
    trialcnt = trialcnt + 1;
    load(['analysis/data_structures/motif_aabb_',ff(i).name]);
    load(['analysis/data_structures/motif_aabb_',ff(i+1).name]);
    fv_syll_sal1 = ['motif_aabb_',ff(i).name];
    fv_syll_sal2 = ['motif_aabb_',ff(i+1).name];
    [saldurerror(trialcnt).motifdur saldurerror(trialcnt).sylldur saldurerror(trialcnt).gapdur ...
        saldurerror(trialcnt).mcv saldurerror(trialcnt).timebins] = ...
        jc_erroranalysis2(eval(fv_syll_sal1),eval(fv_syll_sal2),'k.','k');
    clearvars -except ff saldurerror trialcnt i 
    
end
