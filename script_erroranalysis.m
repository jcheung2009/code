ff = load_batchf('batchsaleveryother');
salerror = struct();

syllables = {'A1','A2','B1','B3'};
trialcnt = 0;
for i = 1:2:length(ff)
    for ii = 1:4
        trialcnt = trialcnt + 1;
        load(['analysis/data_structures/fv_syll',syllables{ii},'_',ff(i).name]);
        load(['analysis/data_structures/fv_syll',syllables{ii},'_',ff(i+1).name]);
        fv_syll_sal1 = ['fv_syll',syllables{ii},'_',ff(i).name];
        fv_syll_sal2 = ['fv_syll',syllables{ii},'_',ff(i+1).name];
        [salerror(trialcnt).pitch salerror(trialcnt).vol salerror(trialcnt).ent ...
            salerror(trialcnt).pcv salerror(trialcnt).timebins] = ...
            jc_erroranalysis(eval(fv_syll_sal1),eval(fv_syll_sal2),'k.','k');
        clearvars -except ff salerror syllables trialcnt i 
    end
end
