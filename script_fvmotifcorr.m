ff = load_batchf('batch_sal');
load('analysis/data_structures/naspmvolumelatency');

fvmotif = struct();

trialcnt = 0;
for i = 1:2:length(ff)
    trialcnt = trialcnt+1;
    load(['analysis/data_structures/motif_bcd_',ff(i).name]);
    load(['analysis/data_structures/motif_bcd_',ff(i+1).name]);
    
    motif1 = ['motif_bcd_',ff(i).name];
    motif2 = ['motif_bcd_',ff(i+1).name];
    
    if ~isempty(strfind(ff(i+1).name,'sal'))
            startpt = '';
    else
        drugtime = naspmvolumelatency.(['tr_',ff(i+1).name]).treattime;
        startpt = (drugtime+1.13)*3600;%change latency time
    end

    [fvmotif(trialcnt).fv_syll fvmotif(trialcnt).fv_gap0 fvmotif(trialcnt).fv_gap1...
    fvmotif(trialcnt).vol_syll fvmotif(trialcnt).vol_gap0 fvmotif(trialcnt).vol_gap1] = jc_fvmotifcorr(...
    eval(motif1),eval(motif2),0,startpt,'','bcd',{'b','d'});

end
