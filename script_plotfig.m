
%plotting for different naspm conditions, spectral measurements for syllJble
%each trial has pre-day, treat-day, post-day (matched to time window
%of treat-day) 

ff = load_batchf('batchnaspm');
load('analysis/data_structures/naspmpitchlatency.mat');
daycnt = 1;
fignum = input('figure number:');
if isnumeric(fignum)
    figure(fignum);hold on;
    h = get(gcf,'children');
    h2 = h(2);
    h3 = h(1);
    h = h(3);
else
    figure;
    h = subtightplot(3,1,1,0.07,0.08,0.15);hold on;
    h2 = subtightplot(3,1,2,0.07,0.08,0.15);hold on;
    h3 = subtightplot(3,1,3,0.07,0.08,0.15);hold on;
end
mcolor = 'r';
mrk = 'or';
for i = 1:2:length(ff)
    spc = 0.15; 
    
    cmd1 = ['load(''analysis/data_structures/fv_syllR_',ff(i).name,''')'];
    cmd3 = ['load(''analysis/data_structures/fv_syllR_',ff(i+1).name,''')'];
    %cmd4 = ['load(''analysis/data_structures/fv_syllJ_',ff(i+3).name,''')'];
    eval(cmd1);
    eval(cmd3);
    %eval(cmd4);
    
    %cmd1 = ['tb_sal = jc_tb([fv_syllJ_',ff(i).name,'(:).datenm]'',7,0);'];
    cmd2 = ['tb_cond = jc_tb([fv_syllR_',ff(i+1).name,'(:).datenm]'',7,0);'];
    %cmd3 = ['tb_sal2 = jc_tb([fv_syllJ_',ff(i+3).name,'(:).datenm]'',7,0);'];
    %eval(cmd1);
    eval(cmd2);
    %eval(cmd3);
    
    drugtime = naspmpitchlatency.(['tr_',ff(i+1).name]).treattime;
    startpt = (drugtime+0.97)*3600;%change latency time!
    ind = find(tb_cond >= startpt);

%     ind = find(tb_sal >= tb_cond(1) & tb_sal <= tb_cond(end));
%     ind2 = find(tb_sal2 >= tb_cond(1) & tb_sal2 <= tb_cond(end));
    
    cmd2 = ['mBootstrapCI([fv_syllR_',ff(i).name,'(:).mxvals])'];
    [hi lo mn] = eval(cmd2);
    plot(h,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
    plot(h,daycnt,mn,'ok','MarkerSize',8);hold on;
    
    cmd3 = ['mBootstrapCI([fv_syllR_',ff(i).name,'(:).maxvol])'];
    [hi lo mn] = eval(cmd3);
    plot(h2,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
    plot(h2,daycnt,mn,'ok','MarkerSize',8);hold on;
    
    cmd4 = ['mBootstrapCI_CV([fv_syllR_',ff(i).name,'(:).mxvals])'];
     [mn hi lo] = eval(cmd4);
    plot(h3,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
    plot(h3,daycnt,mn,'ok','MarkerSize',8);hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(strfind(ff(i+1).name,'naspm'))
        mrk = 'or';
        mcolor = 'r';
    elseif ~isempty(strfind(ff(i+1).name,'iem'))
        mrk = 'om';
        mcolor = 'm';
    end
    
    cmd2 = ['mBootstrapCI([fv_syllR_',ff(i+1).name,'(ind).mxvals])'];
    [hi lo mn] = eval(cmd2);
    plot(h,[daycnt+spc daycnt+spc],[hi lo],mcolor,'linewidth',2);hold on;
    plot(h,daycnt+spc,mn,mrk,'MarkerSize',8);hold on;
    
    cmd3 = ['mBootstrapCI([fv_syllR_',ff(i+1).name,'(ind).maxvol])'];
    [hi lo mn] = eval(cmd3);
    plot(h2,[daycnt+spc daycnt+spc],[hi lo],mcolor,'linewidth',2);hold on;
    plot(h2,daycnt+spc,mn,mrk,'MarkerSize',8);hold on;
    
    cmd4 = ['mBootstrapCI_CV([fv_syllR_',ff(i+1).name,'(ind).mxvals])'];
     [mn hi lo] = eval(cmd4);
    plot(h3,[daycnt+spc daycnt+spc],[hi lo],mcolor,'linewidth',2);hold on;
    plot(h3,daycnt+spc,mn,mrk,'MarkerSize',8);hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     cmd2 = ['mBootstrapCI([fv_syllJ_',ff(i+3).name,'(:).mxvals])'];
%     [hi lo mn] = eval(cmd2);
%     plot(h,[daycnt+spc*2 daycnt+spc*2],[hi lo],'k','linewidth',2);hold on;
%     plot(h,daycnt+spc*2,mn,'ok','MarkerSize',8);hold on;
%     
%     cmd3 = ['mBootstrapCI([fv_syllJ_',ff(i+3).name,'(:).maxvol])'];
%     [hi lo mn] = eval(cmd3);
%     plot(h2,[daycnt+spc*2 daycnt+spc*2],[hi lo],'k','linewidth',2);hold on;
%     plot(h2,daycnt+spc*2,mn,'ok','MarkerSize',8);hold on;
%     
%     cmd4 = ['mBootstrapCI_CV([fv_syllJ_',ff(i+3).name,'(:).mxvals])'];
%      [mn hi lo] = eval(cmd4);
%     plot(h3,[daycnt+spc*2 daycnt+spc*2],[hi lo],'k','linewidth',2);hold on;
%     plot(h3,daycnt+spc*2,mn,'ok','MarkerSize',8);hold on;
    
    daycnt = daycnt+1;
end
title(h,'syllable B1 Mean pitch with CI');
ylabel(h,'Frequency (Hz)');
set(h,'fontweight','bold');

title(h2,'Mean volume with CI');
ylabel(h2,'Amplitude');
set(h2,'fontweight','bold');

title(h3,'Mean pitch CV with CI');
xlabel(h3,'Day');
ylabel(h3,'CV');
set(h3,'fontweight','bold');



