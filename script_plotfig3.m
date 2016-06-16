
%plotting for different naspm conditions, tempo measurements for ,motif 
%abcdeeer each trial has pre-day, treat-day, post-day (matched to time window
%of treat-day) 

ff = load_batchf('batchnaspm');
load('analysis/data_structures/naspmpitchlatency.mat');
daycnt = 1;
figure;hold on
for i = 1:2:length(ff)
%     if ~isempty(strfind(ff(i).name,'saline'))
%         mcolor = 'k';
%         mrk = 'ok';
%     else
%         mcolor = 'r';
%         mrk = 'or';
%     end
    spc = 0.15; 
    
    cmd1 = ['load(''analysis/data_structures/motif_aabb_',ff(i).name,''')'];
    cmd3 = ['load(''analysis/data_structures/motif_aabb_',ff(i+1).name,''')'];
%     cmd4 = ['load(''analysis/data_structures/motif_aabb_',ff(i+3).name,''')'];
    eval(cmd1);
    eval(cmd3);
%     eval(cmd4);
    
    %cmd1 = ['tb_sal = jc_tb([motif_aabb_',ff(i).name,'(:).datenm]'',7,0);'];
    cmd2 = ['tb_cond = jc_tb([motif_aabb_',ff(i+1).name,'(:).datenm]'',7,0);'];
%     cmd3 = ['tb_sal2 = jc_tb([motif_aabb_',ff(i+3).name,'(:).datenm]'',7,0);'];
    %eval(cmd1);
    eval(cmd2);
%     eval(cmd3);
    drugtime = naspmpitchlatency.(['tr_',ff(i+1).name]).treattime;
    startpt = (drugtime+0.97)*3600;
    ind = find(tb_cond >= startpt);

%     ind = find(tb_sal >= tb_cond(1) & tb_sal <= tb_cond(end));
%     ind2 = find(tb_sal2 >= tb_cond(1) & tb_sal2 <= tb_cond(end));
    
    cmd2 = ['mBootstrapCI([motif_aabb_',ff(i).name,'(:).firstpeakdistance])'];
    [hi lo mn] = eval(cmd2);
    plot(gca,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
    plot(gca,daycnt,mn,'ok','MarkerSize',8);hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
     if ~isempty(strfind(ff(i+1).name,'naspm'))
        mrk = 'or';
        mcolor = 'r';
    elseif ~isempty(strfind(ff(i+1).name,'iem'))
        mrk = 'om';
        mcolor = 'm';
     end
    
    cmd2 = ['mBootstrapCI([motif_aabb_',ff(i+1).name,'(ind).firstpeakdistance])'];
    [hi lo mn] = eval(cmd2);
    plot(gca,[daycnt+spc daycnt+spc],[hi lo],mcolor,'linewidth',2);hold on;
    plot(gca,daycnt+spc,mn,mrk,'MarkerSize',8);hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     cmd2 = ['mBootstrapCI([motif_aabb_',ff(i+3).name,'(:).firstpeakdistance])'];
%     [hi lo mn] = eval(cmd2);
%     plot(gca,[daycnt+spc*2 daycnt+spc*2],[hi lo],'k','linewidth',2);hold on;
%     plot(gca,daycnt+spc*2,mn,'ok','MarkerSize',8);hold on;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    daycnt = daycnt+1;
end
title('Motif tempo mean + CI');
ylabel('Average duration between syllables (s)');
xlabel('Day');
set(gca,'fontweight','bold');