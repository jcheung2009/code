%% o52o51 and o73pu40 summary analysis (error)
%plotting for different naspm conditions, morning pitch measurements for syllable
%each trial has pre-day and post-day 

ff = load_batchf('batch_allnaspm');
daycnt = 1;
figure;
h = subtightplot(3,1,1,0.07,0.08,0.15);hold on;
h2 = subtightplot(3,1,2,0.07,0.08,0.15);hold on;
h3 = subtightplot(3,1,3,0.07,0.08,0.15);hold on;
for i = 1:4:length(ff)
    spc = 0.1; 
    
    cmd1 = ['load(''analysis/data_structures/fv_syllA_',ff(i).name,''')'];
    cmd4 = ['load(''analysis/data_structures/fv_syllA_',ff(i+3).name,''')'];
    eval(cmd1);
    eval(cmd4);
    
    cmd1 = ['tb_sal = jc_tb([fv_syllA_',ff(i).name,'(:).datenm]'',7,0);'];
    cmd3 = ['tb_sal2 = jc_tb([fv_syllA_',ff(i+3).name,'(:).datenm]'',7,0);'];
    eval(cmd1);
    eval(cmd2);
    eval(cmd3);
    ind = find(tb_sal <= 12*3600);
    ind2 = find(tb_sal2 <= 12*3600);
    
    cmd2 = ['mBootstrapCI([fv_syllA_',ff(i).name,'(ind).mxvals])'];
    [hi lo mn1] = eval(cmd2);
    plot(h,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
    plot(h,daycnt,mn1,'ok','MarkerSize',8);hold on;
   
    cmd2 = ['mBootstrapCI([fv_syllA_',ff(i+3).name,'(ind2).mxvals])'];
    [hi lo mn2] = eval(cmd2);
    plot(h,[daycnt+spc*2 daycnt+spc*2],[hi lo],'k','linewidth',2);hold on;
    plot(h,daycnt+spc*2,mn2,'ok','MarkerSize',8);hold on;
   
    plot(h,[daycnt daycnt+spc*2],[mn1 mn2],'k','linewidth',2);hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cmd1 = ['load(''analysis/data_structures/fv_syllB_',ff(i).name,''')'];
    cmd4 = ['load(''analysis/data_structures/fv_syllB_',ff(i+3).name,''')'];
    eval(cmd1);
    eval(cmd4);
    
    cmd1 = ['tb_sal = jc_tb([fv_syllB_',ff(i).name,'(:).datenm]'',7,0);'];
    cmd3 = ['tb_sal2 = jc_tb([fv_syllB_',ff(i+3).name,'(:).datenm]'',7,0);'];
    eval(cmd1);
    eval(cmd3);
    ind = find(tb_sal <= 12*3600);
    ind2 = find(tb_sal2 <= 12*3600);
    
    cmd2 = ['mBootstrapCI([fv_syllB_',ff(i).name,'(ind).mxvals])'];
    [hi lo mn1] = eval(cmd2);
    plot(h2,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
    plot(h2,daycnt,mn1,'ok','MarkerSize',8);hold on;

    cmd2 = ['mBootstrapCI([fv_syllB_',ff(i+3).name,'(ind2).mxvals])'];
    [hi lo mn2] = eval(cmd2);
    plot(h2,[daycnt+spc*2 daycnt+spc*2],[hi lo],'k','linewidth',2);hold on;
    plot(h2,daycnt+spc*2,mn2,'ok','MarkerSize',8);hold on;
    
    plot(h2,[daycnt daycnt+spc*2],[mn1 mn2],'k','linewidth',2);hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cmd1 = ['load(''analysis/data_structures/fv_syllC_',ff(i).name,''')'];
    cmd4 = ['load(''analysis/data_structures/fv_syllC_',ff(i+3).name,''')'];
    eval(cmd1);
    eval(cmd4);
    
    cmd1 = ['tb_sal = jc_tb([fv_syllC_',ff(i).name,'(:).datenm]'',7,0);'];
    cmd3 = ['tb_sal2 = jc_tb([fv_syllC_',ff(i+3).name,'(:).datenm]'',7,0);'];
    eval(cmd1);
    eval(cmd3);
    ind = find(tb_sal <= 12*3600);
    ind2 = find(tb_sal2 <= 12*3600);
    
    cmd2 = ['mBootstrapCI([fv_syllC_',ff(i).name,'(ind).mxvals])'];
    [hi lo mn1] = eval(cmd2);
    plot(h3,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
    plot(h3,daycnt,mn1,'ok','MarkerSize',8);hold on;

    cmd2 = ['mBootstrapCI([fv_syllC_',ff(i+3).name,'(ind2).mxvals])'];
    [hi lo mn2] = eval(cmd2);
    plot(h3,[daycnt+spc*2 daycnt+spc*2],[hi lo],'k','linewidth',2);hold on;
    plot(h3,daycnt+spc*2,mn2,'ok','MarkerSize',8);hold on;
    
    plot(h3,[daycnt daycnt+spc*2],[mn1 mn2],'k','linewidth',2);hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    daycnt = daycnt+1;
end
title(h,'Morning pitch for syllable A mean + CI');
ylabel(h,'Frequency (Hz)');

title(h2,'Morning pitch for syllable B mean + CI');
ylabel(h2,'Frequency (Hz)');

title(h3,'Morning pitch for syllable C mean + CI');
xlabel(h3,'Day');
ylabel(h3,'Frequency (Hz)');
