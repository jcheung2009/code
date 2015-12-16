ff = load_batchf('batch_naspm');

for i = 1:length(ff)
    load(['analysis/data_structures/fv_syllA_',ff(i).name]);
    load(['analysis/data_structures/fv_syllB_',ff(i).name]);
    load(['analysis/data_structures/fv_syllD_',ff(i).name]);
    load(['analysis/data_structures/motif_bcd_',ff(i).name]);
    load(['analysis/data_structures/bout_',ff(i).name]);
    load(['analysis/data_structures/fv_repA_',ff(i).name]);
    load(['analysis/data_structures/fv_repB_',ff(i).name]);
    load(['analysis/data_structures/fv_repD_',ff(i).name]);
    if i == 1
        jc_plotrawdata(eval(['fv_syllA_',ff(i).name]),'k.',-1);
        jc_plotrawdata(eval(['fv_syllB_',ff(i).name]),'k.',-1);
        jc_plotrawdata(eval(['fv_syllD_',ff(i).name]),'k.',-1);
        jc_plotmotifvals2(eval(['motif_bcd_',ff(i).name]),'k.',-1);
        jc_plotrepeatvals(eval(['fv_repA_',ff(i).name]),'k.',-1);
        jc_plotrepeatvals(eval(['fv_repB_',ff(i).name]),'k.',-1);
        jc_plotrepeatvals(eval(['fv_repD_',ff(i).name]),'k.',-1);
        jc_plotboutvals(eval(['bout_',ff(i).name]),'k.','k',-1);
        
    elseif i == 2
        jc_plotrawdata(eval(['fv_syllA_',ff(i).name]),'k.',0);
        jc_plotrawdata(eval(['fv_syllB_',ff(i).name]),'k.',0);
        jc_plotrawdata(eval(['fv_syllD_',ff(i).name]),'k.',0);
        jc_plotmotifvals2(eval(['motif_bcd_',ff(i).name]),'k.',0);
        jc_plotrepeatvals(eval(['fv_repA_',ff(i).name]),'k.',0);
        jc_plotrepeatvals(eval(['fv_repB_',ff(i).name]),'k.',0);
        jc_plotrepeatvals(eval(['fv_repD_',ff(i).name]),'k.',0);
        jc_plotboutvals(eval(['bout_',ff(i).name]),'k.','k',0);
    elseif i == 3
        jc_plotrawdata(eval(['fv_syllA_',ff(i).name]),'r.',0);
        jc_plotrawdata(eval(['fv_syllB_',ff(i).name]),'r.',0);
        jc_plotrawdata(eval(['fv_syllD_',ff(i).name]),'r.',0);
        jc_plotmotifvals2(eval(['motif_bcd_',ff(i).name]),'r.',0);
        jc_plotrepeatvals(eval(['fv_repA_',ff(i).name]),'r.',0);
        jc_plotrepeatvals(eval(['fv_repB_',ff(i).name]),'r.',0);
        jc_plotrepeatvals(eval(['fv_repD_',ff(i).name]),'r.',0);
        jc_plotboutvals(eval(['bout_',ff(i).name]),'r.','r',0);
    elseif i == 4
        jc_plotrawdata(eval(['fv_syllA_',ff(i).name]),'k.',1);
        jc_plotrawdata(eval(['fv_syllB_',ff(i).name]),'k.',1);
        jc_plotrawdata(eval(['fv_syllD_',ff(i).name]),'k.',1);
        jc_plotmotifvals2(eval(['motif_bcd_',ff(i).name]),'k.',1);
        jc_plotrepeatvals(eval(['fv_repA_',ff(i).name]),'k.',1);
        jc_plotrepeatvals(eval(['fv_repB_',ff(i).name]),'k.',1);
        jc_plotrepeatvals(eval(['fv_repD_',ff(i).name]),'k.',1);
        jc_plotboutvals(eval(['bout_',ff(i).name]),'k.','k',1);
    end
    clearvars -except fvalbnd_syllA fvalbnd_syllB fvalbnd_syllD ff 
end

    