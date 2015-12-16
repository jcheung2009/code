ff = load_batchf('batch2');
repiem = struct();

trialcnt = 0;
for i = 1:2:length(ff)
    trialcnt = trialcnt+1;
    load(['analysis/data_structures/fv_repB_',ff(i).name]);
    load(['analysis/data_structures/fv_repB_',ff(i+1).name]);
    rep1 = ['fv_repB_',ff(i).name];
    rep2 = ['fv_repB_',ff(i+1).name];
%     [repiem(trialcnt).rep repiem(trialcnt).sdur ...
%         repiem(trialcnt).gdur] = jc_plotrepeatsummary2(...
%         eval(rep1),eval(rep2),'or','r',0.5);
    jc_plotrepeatsummary2(...
        eval(rep1),eval(rep2),'or','r',3.5);
end
