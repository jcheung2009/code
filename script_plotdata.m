ff = load_batchf('batchapv');

for i = 1:2:length(ff)
    load(['analysis/data_structures/fv_syllA_',ff(i).name]);
    load(['analysis/data_structures/fv_syllA_',ff(i+1).name]);
    load(['analysis/data_structures/fv_syllB_',ff(i).name]);
    load(['analysis/data_structures/fv_syllB_',ff(i+1).name]);
    load(['analysis/data_structures/fv_syllC_',ff(i).name]);
    load(['analysis/data_structures/fv_syllC_',ff(i+1).name]);
    load(['analysis/data_structures/fv_syllJ_',ff(i).name]);
    load(['analysis/data_structures/fv_syllJ_',ff(i+1).name]);
%     load(['analysis/data_structures/motif_ja_',ff(i).name]);
%     load(['analysis/data_structures/bout_',ff(i).name]);
%      load(['analysis/data_structures/bout_',ff(i+1).name]);
%      load(['analysis/data_structures/bout_',ff(i+2).name]);
%     %load(['analysis/data_structures/fv_repR_',ff(i).name]);
%     load(['analysis/data_structures/fv_repA_',ff(i).name]);
%     load(['analysis/data_structures/fv_repB_',ff(i).name]);

%        jc_plotrawdata(eval(['fv_syllA_',ff(i).name]),'k.',0);
         jc_plotrawdata(eval(['fv_syllB_',ff(i).name]),'k.',0);
%         jc_plotrawdata(eval(['fv_syllC_',ff(i).name]),'k.',0);
%         jc_plotrawdata(eval(['fv_syllJ_',ff(i).name]),'k.',0);
% %         jc_plotrawdata(eval(['fv_syllW2_',ff(i).name]),'k.',0);
%          jc_plotmotifvals2(eval(['motif_ja_',ff(i).name]),'k.',0);
%         %jc_plotrepeatvals(eval(['fv_repR_',ff(i).name]),'k.',0);
%         jc_plotrepeatvals(eval(['fv_repA_',ff(i).name]),'k.',0);
%         jc_plotrepeatvals(eval(['fv_repB_',ff(i).name]),'k.',0);
%         jc_plotboutvals(eval(['bout_',ff(i).name]),'k.','k',-1);
        

%       jc_plotrawdata(eval(['fv_syllA_',ff(i+1).name]),'b.',0);
        jc_plotrawdata(eval(['fv_syllB_',ff(i+1).name]),'b.',0);
%         jc_plotrawdata(eval(['fv_syllC_',ff(i+1).name]),'b.',0);
%          jc_plotrawdata(eval(['fv_syllJ_',ff(i+1).name]),'b.',0);
% %         jc_plotrawdata(eval(['fv_syllW2_',ff(i+1).name]),'r.',0);
%          jc_plotmotifvals2(eval(['motif_ja_',ff(i+1).name]),'r.',0);
%         %jc_plotrepeatvals(eval(['fv_repR_',ff(i).name]),'r.',0);
%          jc_plotrepeatvals(eval(['fv_repA_',ff(i+1).name]),'r.',0);
%         jc_plotrepeatvals(eval(['fv_repB_',ff(i+1).name]),'r.',0);
%         jc_plotboutvals(eval(['bout_',ff(i+1).name]),'k.','k',0);

       % jc_plotrawdata(eval(['fv_syllA_',ff(i).name]),'g.',0);
       % jc_plotrawdata(eval(['fv_syllD_',ff(i+2).name]),'r.',0);
%          jc_plotrawdata(eval(['fv_syllR_',ff(i).name]),'g.',0);
%          jc_plotrawdata(eval(['fv_syllW1_',ff(i).name]),'g.',0);
%         jc_plotrawdata(eval(['fv_syllW2_',ff(i).name]),'g.',0);
%          jc_plotmotifvals2(eval(['motif_abcdeeerww_',ff(i).name]),'g.',0);
%         jc_plotrepeatvals(eval(['fv_repQ_',ff(i).name]),'g.',0);
%         %jc_plotrepeatvals(eval(['fv_repB_',ff(i).name]),'r.',0);
%         %jc_plotrepeatvals(eval(['fv_repD_',ff(i).name]),'r.',0);
%         jc_plotboutvals(eval(['bout_',ff(i+2).name]),'r.','r',0);

% %         jc_plotrawdata(eval(['fv_syllA_',ff(i).name]),'k.',1);
      %  jc_plotrawdata(eval(['fv_syllD_',ff(i+3).name]),'k.',1);
% %         jc_plotrawdata(eval(['fv_syllC_',ff(i).name]),'k.',1);
%          jc_plotmotifvals2(eval(['motif_cab_',ff(i).name]),'k.',1);
%         %jc_plotrepeatvals(eval(['fv_repA_',ff(i).name]),'k.',1);
%         jc_plotrepeatvals(eval(['fv_repB_',ff(i).name]),'k.',1);
%         %jc_plotrepeatvals(eval(['fv_repD_',ff(i).name]),'k.',1);
%         jc_plotboutvals(eval(['bout_',ff(i).name]),'k.','k',1);
    
end

    