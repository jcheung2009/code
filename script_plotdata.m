ff = load_batchf('batch2');

for i = 1:length(ff)
    load(['analysis/data_structures/fv_syllA_',ff(i).name]);
    load(['analysis/data_structures/fv_syllB_',ff(i).name]);
    load(['analysis/data_structures/fv_syllC_',ff(i).name]);
     load(['analysis/data_structures/fv_syllJ_',ff(i).name]);
%     load(['analysis/data_structures/fv_syll_',ff(i).name]);
    load(['analysis/data_structures/motif_ja_',ff(i).name]);
    load(['analysis/data_structures/bout_',ff(i).name]);
    %load(['analysis/data_structures/fv_repR_',ff(i).name]);
    load(['analysis/data_structures/fv_repA_',ff(i).name]);
    load(['analysis/data_structures/fv_repB_',ff(i).name]);
    if i == 1
        jc_plotrawdata(eval(['fv_syllA_',ff(i).name]),'k.',0);
        jc_plotrawdata(eval(['fv_syllB_',ff(i).name]),'k.',0);
        jc_plotrawdata(eval(['fv_syllC_',ff(i).name]),'k.',0);
         jc_plotrawdata(eval(['fv_syllJ_',ff(i).name]),'k.',0);
%         jc_plotrawdata(eval(['fv_syllW2_',ff(i).name]),'k.',0);
         jc_plotmotifvals2(eval(['motif_ja_',ff(i).name]),'k.',0);
        %jc_plotrepeatvals(eval(['fv_repR_',ff(i).name]),'k.',0);
        jc_plotrepeatvals(eval(['fv_repA_',ff(i).name]),'k.',0);
        jc_plotrepeatvals(eval(['fv_repB_',ff(i).name]),'k.',0);
        jc_plotboutvals(eval(['bout_',ff(i).name]),'k.','k',0);
        
    elseif i == 2
        jc_plotrawdata(eval(['fv_syllA_',ff(i).name]),'r.',0);
        jc_plotrawdata(eval(['fv_syllB_',ff(i).name]),'r.',0);
        jc_plotrawdata(eval(['fv_syllC_',ff(i).name]),'r.',0);
         jc_plotrawdata(eval(['fv_syllJ_',ff(i).name]),'r.',0);
%         jc_plotrawdata(eval(['fv_syllW2_',ff(i).name]),'r.',0);
         jc_plotmotifvals2(eval(['motif_ja_',ff(i).name]),'r.',0);
        %jc_plotrepeatvals(eval(['fv_repR_',ff(i).name]),'r.',0);
         jc_plotrepeatvals(eval(['fv_repA_',ff(i).name]),'r.',0);
        jc_plotrepeatvals(eval(['fv_repB_',ff(i).name]),'r.',0);
        jc_plotboutvals(eval(['bout_',ff(i).name]),'r.','r',0);
    elseif i == 3
%         jc_plotrawdata(eval(['fv_syllA_',ff(i).name]),'g.',0);
%          jc_plotrawdata(eval(['fv_syllC_',ff(i).name]),'g.',0);
%          jc_plotrawdata(eval(['fv_syllR_',ff(i).name]),'g.',0);
%          jc_plotrawdata(eval(['fv_syllW1_',ff(i).name]),'g.',0);
%         jc_plotrawdata(eval(['fv_syllW2_',ff(i).name]),'g.',0);
%          jc_plotmotifvals2(eval(['motif_abcdeeerww_',ff(i).name]),'g.',0);
%         jc_plotrepeatvals(eval(['fv_repQ_',ff(i).name]),'g.',0);
%         %jc_plotrepeatvals(eval(['fv_repB_',ff(i).name]),'r.',0);
%         %jc_plotrepeatvals(eval(['fv_repD_',ff(i).name]),'r.',0);
%         jc_plotboutvals(eval(['bout_',ff(i).name]),'g.','g',0);
%     elseif i == 4
% %         jc_plotrawdata(eval(['fv_syllA_',ff(i).name]),'k.',1);
% %         jc_plotrawdata(eval(['fv_syllB_',ff(i).name]),'k.',1);
% %         jc_plotrawdata(eval(['fv_syllC_',ff(i).name]),'k.',1);
%          jc_plotmotifvals2(eval(['motif_cab_',ff(i).name]),'k.',1);
%         %jc_plotrepeatvals(eval(['fv_repA_',ff(i).name]),'k.',1);
%         jc_plotrepeatvals(eval(['fv_repB_',ff(i).name]),'k.',1);
%         %jc_plotrepeatvals(eval(['fv_repD_',ff(i).name]),'k.',1);
%         jc_plotboutvals(eval(['bout_',ff(i).name]),'k.','k',1);
    end
end

    