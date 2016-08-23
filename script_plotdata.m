ff = load_batchf('batchmusc');

for i = 1:length(ff)
    load(['analysis/data_structures/fv_syllA_',ff(i).name]);
    load(['analysis/data_structures/fv_syllB_',ff(i).name]);
    load(['analysis/data_structures/fv_syllC_',ff(i).name]);
    load(['analysis/data_structures/fv_syllJ_',ff(i).name]);
%     load(['analysis/data_structures/fv_syllW2_',ff(i).name]);
%     load(['analysis/data_structures/motif_abcdeeerww_',ff(i).name]);
%    load(['analysis/data_structures/bout_',ff(i).name]);
    %load(['analysis/data_structures/fv_repQ_',ff(i).name]);
%     load(['analysis/data_structures/fv_repA_',ff(i).name]);
%     load(['analysis/data_structures/fv_repB_',ff(i).name]);

    display(['plotting ',ff(i).name]);
    %tbshft = '';
    tbshft = input('tbshift = ');
    
    if ~isempty(strfind(ff(i).name,'apv')) & ~isempty(strfind(ff(i).name,'iem'))
        mrk = 'g.';
    elseif ~isempty(strfind(ff(i).name,'naspm'))
        mrk = 'r.';
    elseif ~isempty(strfind(ff(i).name,'IEM'))
        mrk = 'r.';
    elseif ~isempty(strfind(ff(i).name,'APV'))
        mrk = 'g.';    
    elseif ~isempty(strfind(ff(i).name,'musc'))
        mrk = 'c.';
    else
        mrk = 'k.';
    end
    
    fignum1 = 21;
    fignum2 = 22;
    fignum3 = 23;
    fignum4 = 24;
    fignum5 = 25;
    fignum6 = 26;
    fignum7 = 27;
    fignum8 = 28;
    fignum9 = 29;
    fignum10 = 30;
    fignum11 = 31;
    fignum12 = 32;
        jc_plotrawdata(eval(['fv_syllA_',ff(i).name]),mrk,tbshft,fignum1,'y');
        jc_plotrawdata(eval(['fv_syllB_',ff(i).name]),mrk,tbshft,fignum2,'y');
        jc_plotrawdata(eval(['fv_syllC_',ff(i).name]),mrk,tbshft,fignum3,'y');
        jc_plotrawdata(eval(['fv_syllJ_',ff(i).name]),mrk,tbshft,fignum4,'y');
%         jc_plotrawdata(eval(['fv_syllW2_',ff(i).name]),mrk,tbshft,fignum5,'y');
%         jc_plotmotifvals2(eval(['motif_abcdeeerww_',ff(i).name]),mrk,tbshft,fignum9,fignum10,'y');
      % jc_plotrepeatvals(eval(['fv_repQ_',ff(i).name]),mrk,tbshft,fignum11,fignum12,'y');
%       jc_plotrepeatvals(eval(['fv_repA_',ff(i).name]),mrk,0);
%       jc_plotrepeatvals(eval(['fv_repB_',ff(i).name]),mrk,0);
%       jc_plotboutvals(eval(['bout_',ff(i).name]),mrk,'k',tbshft,'aabb');
        
%     display(['plotting ',ff(i+1).name]);
%     %tbshft = input('tbshift = ');
%      if ~isempty(strfind(ff(i+1).name,'naspm'))
%         mrk = 'r.';
%     elseif ~isempty(strfind(ff(i+1).name,'iem'))
%         mrk = 'm.';
%     elseif ~isempty(strfind(ff(i+1).name,'apv'))
%         mrk = 'b.';
%     else
%         mrk = 'k.';
%     end
%        jc_plotrawdata(eval(['fv_syllA1_',ff(i+1).name]),mrk,tbshft);
%        jc_plotrawdata(eval(['fv_syllA2_',ff(i+1).name]),mrk,tbshft);
%        jc_plotrawdata(eval(['fv_syllB_',ff(i+1).name]),mrk,tbshft);
%        jc_plotrawdata(eval(['fv_syllC1_',ff(i+1).name]),mrk,tbshft);
%        jc_plotrawdata(eval(['fv_syllC2_',ff(i+1).name]),mrk,tbshft);
%        jc_plotrawdata(eval(['fv_syllD1_',ff(i+1).name]),mrk,tbshft);
%        jc_plotrawdata(eval(['fv_syllD2_',ff(i+1).name]),mrk,tbshft);
%        jc_plotrawdata(eval(['fv_syllE_',ff(i+1).name]),mrk,tbshft);
% %      jc_plotrawdata(eval(['fv_syllW2_',ff(i+1).name]),mrk,0);
%        jc_plotmotifvals2(eval(['motif_abccdde_',ff(i+1).name]),mrk,tbshft);
%      jc_plotrepeatvals(eval(['fv_repR_',ff(i).name]),mrk,0);
%      jc_plotrepeatvals(eval(['fv_repA_',ff(i+1).name]),mrk,0);
%      jc_plotrepeatvals(eval(['fv_repB_',ff(i+1).name]),mrk,0);
%      jc_plotboutvals(eval(['bout_',ff(i+1).name]),mrk,'r',tbshft,'aabb');

       % jc_plotrawdata(eval(['fv_syllA_',ff(i).name]),'g.',0);
       % jc_plotrawdata(eval(['fv_syllD_',ff(i+2).name]),mrk,0);
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

    