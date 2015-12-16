ff = load_batchf('batch2');
fviem = struct();

syllables = {'A','B','C'};
trialcnt = 0;
for i = 1:2:length(ff)
    for ii = 1:length(syllables)
        trialcnt = trialcnt+1;
        load(['analysis/data_structures/fv_syll',syllables{ii},'_',ff(i).name]);
        load(['analysis/data_structures/fv_syll',syllables{ii},'_',ff(i+1).name]);
        fv1 = ['fv_syll',syllables{ii},'_',ff(i).name];
        fv2 = ['fv_syll',syllables{ii},'_',ff(i+1).name];
        [fviem(trialcnt).fv fviem(trialcnt).vol fviem(trialcnt).ent ...
            fviem(trialcnt).pcv] = jc_plotfvsummary2(eval(fv1),eval(fv2),'ro','r',3.5);
        clearvars -except ff fviem syllables trialcnt i 
    end
end


% syllables = {'A','B','C','J'};
% trialcnt = 0;
% for i = 1:length(ff) %1:2:length(ff)
%     for ii = 1:length(syllables)
%         trialcnt = trialcnt+1;
%         load(['analysis/data_structures/fv_syll',syllables{ii},'_',ff(i).name]);
%         %load(['analysis/data_structures/fv_syll',syllables{ii},'_',ff(i+1).name]);
%         fv1 = ['fv_syll',syllables{ii},'_',ff(i).name,'_morn'];
%         fv2 = ['fv_syll',syllables{ii},'_',ff(i).name,'_noon'];
%         %fv1 = ['fv_syll',syllables{ii},'_',ff(i).name];
%         %fv2 = ['fv_syll',syllables{ii},'_',ff(i+1).name];
%         [fviem(trialcnt).fv fviem(trialcnt).vol fviem(trialcnt).ent ...
%             fviem(trialcnt).pcv] = jc_plotfvsummary(eval(fv1),eval(fv2),'k.','k',0,'n');
%         clearvars -except ff fviem syllables trialcnt i 
%     end
% end
