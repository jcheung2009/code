%% o52o51 summary analysis
%plotting for different naspm conditions, tempo measurements for repeat
%A,B,D, each trial has pre-day, treat-day, post-day (matched to time window
%of treat-day) 

ff = load_batchf('batch');
load('analysis/data_structures/naspmpitchlatency.mat');
daycnt = 1;
figure;hold on;
h = subtightplot(3,1,1,0.07,0.08,0.15);hold on;
h2 = subtightplot(3,1,2,0.07,0.08,0.15);hold on;
% h3 = subtightplot(3,1,3,0.07,0.08,0.15);hold on;
for i = 1:2:length(ff)
%     if ~isempty(strfind(ff(i).name,'saline'))
%         mcolor = 'k';
%         mrk = 'ok';
%     else
%         mcolor = 'r';
%         mrk = 'or';
%     end
    spc = 0.15; 
    
    cmd1 = ['load(''analysis/data_structures/fv_repA_',ff(i).name,''')'];
    cmd3 = ['load(''analysis/data_structures/fv_repA_',ff(i+1).name,''')'];
%     cmd4 = ['load(''analysis/data_structures/fv_repQ_',ff(i+3).name,''')'];
    eval(cmd1);
    eval(cmd3);
%     eval(cmd4);
    
   % cmd1 = ['tb_sal = jc_tb([fv_repA_',ff(i).name,'(:).datenm]'',7,0);'];
    cmd2 = ['tb_cond = jc_tb([fv_repA_',ff(i+1).name,'(:).datenm]'',7,0);'];
%     cmd3 = ['tb_sal2 = jc_tb([fv_repQ_',ff(i+3).name,'(:).datenm]'',7,0);'];
    %eval(cmd1);
    eval(cmd2);
%     eval(cmd3);
    drugtime = naspmpitchlatency.(['tr_',ff(i+1).name]).treattime;
    startpt = (drugtime+1.4)*3600;
    ind = find(tb_cond >= startpt);

%     ind = find(tb_sal >= tb_cond(1) & tb_sal <= tb_cond(end));
%     ind2 = find(tb_sal2 >= tb_cond(1) & tb_sal2 <= tb_cond(end));
    
    cmd1 = ['firstpeakdistance = [fv_repA_',ff(i).name,'(:).firstpeakdistance]'';'];
    cmd2 = ['firstpeakdistance = firstpeakdistance(~isnan(firstpeakdistance));'];
    eval(cmd1);
    eval(cmd2);
   
    cmd2 = ['mBootstrapCI([firstpeakdistance])'];
    [hi lo mn] = eval(cmd2);
    plot(h,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
    plot(h,daycnt,mn,'ok','MarkerSize',8);hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    if ~isempty(strfind(ff(i+1).name,'naspm'))
        mrk = 'or';
        mcolor = 'r';
    elseif ~isempty(strfind(ff(i+1).name,'IEM'))
        mrk = 'om';
        mcolor = 'm';
    end
     
    cmd1 = ['firstpeakdistance = [fv_repA_',ff(i+1).name,'(ind).firstpeakdistance]'';'];
    cmd2 = ['firstpeakdistance = firstpeakdistance(~isnan(firstpeakdistance));'];
    eval(cmd1);
    eval(cmd2);
    
    cmd2 = ['mBootstrapCI([firstpeakdistance])'];
    [hi lo mn] = eval(cmd2);
    plot(h,[daycnt+spc daycnt+spc],[hi lo],mcolor,'linewidth',2);hold on;
    plot(h,daycnt+spc,mn,mrk,'MarkerSize',8);hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     cmd1 = ['firstpeakdistance = [fv_repQ_',ff(i+3).name,'(:).firstpeakdistance]'';'];
%     cmd2 = ['firstpeakdistance = firstpeakdistance(~isnan(firstpeakdistance));'];
%     eval(cmd1);
%     eval(cmd2);
%     
%     cmd2 = ['mBootstrapCI([firstpeakdistance])'];
%     [hi lo mn] = eval(cmd2);
%     plot([daycnt+spc*2 daycnt+spc*2],[hi lo],'k','linewidth',2);hold on;
%     plot(daycnt+spc*2,mn,'ok','MarkerSize',8);hold on;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     cmd1 = ['load(''analysis/data_structures/fv_repB_',ff(i).name,''')'];
     cmd3 = ['load(''analysis/data_structures/fv_repB_',ff(i+1).name,''')'];
%     cmd4 = ['load(''analysis/data_structures/fv_repQ_',ff(i+3).name,''')'];
     eval(cmd1);
     eval(cmd3);
%     eval(cmd4);
%     
%     cmd1 = ['tb_sal = jc_tb([fv_repQ_',ff(i).name,'(:).datenm]'',7,0);'];
     cmd2 = ['tb_cond = jc_tb([fv_repB_',ff(i+1).name,'(:).datenm]'',7,0);'];
%     cmd3 = ['tb_sal2 = jc_tb([fv_repQ_',ff(i+3).name,'(:).datenm]'',7,0);'];
%     eval(cmd1);
     eval(cmd2);
%     eval(cmd3);
     ind = find(tb_cond >= startpt);

%     ind = find(tb_sal >= tb_cond(1) & tb_sal <= tb_cond(end));
%     ind2 = find(tb_sal2 >= tb_cond(1) & tb_sal2 <= tb_cond(end));
%     
     cmd1 = ['firstpeakdistance = [fv_repB_',ff(i).name,'(:).firstpeakdistance]'';'];
     cmd2 = ['firstpeakdistance = firstpeakdistance(~isnan(firstpeakdistance));'];
     eval(cmd1);
     eval(cmd2);
%     
     cmd2 = ['mBootstrapCI([firstpeakdistance])'];
     [hi lo mn] = eval(cmd2);
     plot(h2,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
     plot(h2,daycnt,mn,'ok','MarkerSize',8);hold on;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
     cmd1 = ['firstpeakdistance = [fv_repB_',ff(i+1).name,'(ind).firstpeakdistance]'';'];
     cmd2 = ['firstpeakdistance = firstpeakdistance(~isnan(firstpeakdistance));'];
     eval(cmd1);
     eval(cmd2);
%     
    cmd2 = ['mBootstrapCI([firstpeakdistance])'];
    [hi lo mn] = eval(cmd2);
    plot(h2,[daycnt+spc daycnt+spc],[hi lo],mcolor,'linewidth',2);hold on;
    plot(h2,daycnt+spc,mn,mrk,'MarkerSize',8);hold on;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     cmd1 = ['firstpeakdistance = [fv_repQ_',ff(i+3).name,'(ind2).firstpeakdistance]'';'];
%     cmd2 = ['firstpeakdistance = firstpeakdistance(~isnan(firstpeakdistance));'];
%     eval(cmd1);
%     eval(cmd2);
%     
%     cmd2 = ['mBootstrapCI([firstpeakdistance])'];
%     [hi lo mn] = eval(cmd2);
%     plot(h2,[daycnt+spc*2 daycnt+spc*2],[hi lo],'k','linewidth',2);hold on;
%     plot(h2,daycnt+spc*2,mn,'ok','MarkerSize',8);hold on;
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       cmd1 = ['load(''analysis/data_structures/fv_repD_',ff(i).name,''')'];
%     cmd3 = ['load(''analysis/data_structures/fv_repD_',ff(i+2).name,''')'];
%     cmd4 = ['load(''analysis/data_structures/fv_repD_',ff(i+3).name,''')'];
%     eval(cmd1);
%     eval(cmd3);
%     eval(cmd4);
%     
%     cmd1 = ['tb_sal = jc_tb([fv_repD_',ff(i).name,'(:).datenm]'',7,0);'];
%     cmd2 = ['tb_cond = jc_tb([fv_repD_',ff(i+2).name,'(:).datenm]'',7,0);'];
%     cmd3 = ['tb_sal2 = jc_tb([fv_repD_',ff(i+3).name,'(:).datenm]'',7,0);'];
%     eval(cmd1);
%     eval(cmd2);
%     eval(cmd3);
%     ind = find(tb_sal >= tb_cond(1) & tb_sal <= tb_cond(end));
%     ind2 = find(tb_sal2 >= tb_cond(1) & tb_sal2 <= tb_cond(end));
%     
%     cmd1 = ['firstpeakdistance = [fv_repD_',ff(i).name,'(ind).firstpeakdistance]'';'];
%     cmd2 = ['firstpeakdistance = firstpeakdistance(~isnan(firstpeakdistance));'];
%     eval(cmd1);
%     eval(cmd2);
%     
%       cmd2 = ['mBootstrapCI([firstpeakdistance])'];
%     [hi lo mn] = eval(cmd2);
%     plot(h3,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
%     plot(h3,daycnt,mn,'ok','MarkerSize',8);hold on;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%     cmd1 = ['firstpeakdistance = [fv_repD_',ff(i+2).name,'(:).firstpeakdistance]'';'];
%     cmd2 = ['firstpeakdistance = firstpeakdistance(~isnan(firstpeakdistance));'];
%     eval(cmd1);
%     eval(cmd2);
%     
%     cmd2 = ['mBootstrapCI([firstpeakdistance])'];
%     [hi lo mn] = eval(cmd2);
%     plot(h3,[daycnt+spc daycnt+spc],[hi lo],'r','linewidth',2);hold on;
%     plot(h3,daycnt+spc,mn,'or','MarkerSize',8);hold on;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     cmd1 = ['firstpeakdistance = [fv_repD_',ff(i+3).name,'(ind2).firstpeakdistance]'';'];
%     cmd2 = ['firstpeakdistance = firstpeakdistance(~isnan(firstpeakdistance));'];
%     eval(cmd1);
%     eval(cmd2);
%     cmd2 = ['mBootstrapCI([firstpeakdistance])'];
%     [hi lo mn] = eval(cmd2);
%     plot(h3,[daycnt+spc*2 daycnt+spc*2],[hi lo],'k','linewidth',2);hold on;
%     plot(h3,daycnt+spc*2,mn,'ok','MarkerSize',8);hold on;
    
    daycnt = daycnt+1;
end
% title('Repeat Q tempo mean + CI');
% ylabel('Duration (s)');
% xlabel('Day');

title(h,'Repeat A tempo mean + CI');
ylabel(h,'Duration (s)');
xlabel('Days');
set(h,'fontweight','bold');


title(h2,'Repeat B tempo mean + CI');
ylabel(h2,'Duration (s)');
xlabel('Days');
set(h2,'fontweight','bold');
% title(h3,'Repeat D tempo mean + CI');
% xlabel(h3,'Day');
% ylabel(h3,'Duration (s)');