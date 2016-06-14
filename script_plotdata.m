ff = load_batchf('batch');

for i = 28
    load(['analysis/data_structures/fv_syllA1_',ff(i).name]);
    load(['analysis/data_structures/fv_syllA2_',ff(i).name]);
    load(['analysis/data_structures/fv_syllB_',ff(i).name]);
    load(['analysis/data_structures/fv_syllC1_',ff(i).name]);
    load(['analysis/data_structures/fv_syllC2_',ff(i).name]);
    load(['analysis/data_structures/fv_syllD1_',ff(i).name]);
    load(['analysis/data_structures/fv_syllD2_',ff(i).name]);
    load(['analysis/data_structures/fv_syllE_',ff(i).name]);
    %load(['analysis/data_structures/motif_abccdde_',ff(i).name]);
%    load(['analysis/data_structures/bout_',ff(i).name]);
%     %load(['analysis/data_structures/fv_repR_',ff(i).name]);
%     load(['analysis/data_structures/fv_repA_',ff(i).name]);
%     load(['analysis/data_structures/fv_repB_',ff(i).name]);

    display(['plotting ',ff(i).name]);
    tbshft = '';
    %tbshft = input('tbshift = ');
    
    if ~isempty(strfind(ff(i).name,'apv')) & ~isempty(strfind(ff(i).name,'naspm'))
        mrk = 'g.';
    elseif ~isempty(strfind(ff(i).name,'naspm'))
        mrk = 'r.';
    elseif ~isempty(strfind(ff(i).name,'iem'))
        mrk = 'm.';
    elseif ~isempty(strfind(ff(i).name,'apv'))
        mrk = 'b.';    
    else
        mrk = 'k.';
    end
    
    fignum1 = 11;
    fignum2 = 12;
    fignum3 = 13;
    fignum4 = 14;
    fignum5 = 15;
    fignum6 = 16;
    fignum7 = 17;
    fignum8 = 18;
    fignum9 = 19;
    fignum10 = 20;
        jc_plotrawdata(eval(['fv_syllA1_',ff(i).name]),mrk,tbshft,fignum1,'n');
        jc_plotrawdata(eval(['fv_syllA2_',ff(i).name]),mrk,tbshft,fignum2,'n');
        jc_plotrawdata(eval(['fv_syllB_',ff(i).name]),mrk,tbshft,fignum3,'n');
        jc_plotrawdata(eval(['fv_syllC1_',ff(i).name]),mrk,tbshft,fignum4,'n');
        jc_plotrawdata(eval(['fv_syllC2_',ff(i).name]),mrk,tbshft,fignum5,'n');
        jc_plotrawdata(eval(['fv_syllD1_',ff(i).name]),mrk,tbshft,fignum6,'n');
        jc_plotrawdata(eval(['fv_syllD2_',ff(i).name]),mrk,tbshft,fignum7,'n');
        jc_plotrawdata(eval(['fv_syllE_',ff(i).name]),mrk,tbshft,fignum8,'n');
        %jc_plotrawdata(eval(['fv_syllW2_',ff(i).name]),mrk,0);
        %jc_plotmotifvals2(eval(['motif_abccdde_',ff(i).name]),mrk,tbshft,fignum9,fignum10,'n');
%       jc_plotrepeatvals(eval(['fv_repR_',ff(i).name]),mrk,0);
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

    