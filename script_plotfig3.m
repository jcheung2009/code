
%plotting for different naspm conditions, tempo measurements for 
%each trial has pre-day, treat-day, post-day (matched to time window
%of treat-day) 

ff = load_batchf('batchnaspm2');
load('analysis/data_structures/apvpitchcvlatency.mat');
load('analysis/data_structures/apvnaspmlatency.mat')
load('analysis/data_structures/naspmpitchcvlatency.mat');
load('analysis/data_structures/naspmapvlatency.mat');
syllables = {'A1','A2','B1','B2','G1','G2'};
spc = 0.15; 
nstd = 4;
daycnt = 1;
figure;hold on
for i = 1:3:length(ff)
    cmd1 = ['load(''analysis/data_structures/motif_aabb_',ff(i).name,''')'];
    cmd2 = ['load(''analysis/data_structures/motif_aabb_',ff(i+1).name,''')'];
    if ~isempty(ff(i+2).name)
        cmd3 = ['load(''analysis/data_structures/motif_aabb_',ff(i+2).name,''')'];
        eval(cmd3);
    end
    eval(cmd1);
    eval(cmd2);
    
    cmd1 = ['tb_sal = jc_tb([motif_aabb_',ff(i).name,'(:).datenm]'',7,0);'];
    cmd2 = ['tb_cond1 = jc_tb([motif_aabb_',ff(i+1).name,'(:).datenm]'',7,0);'];
    if ~isempty(ff(i+2).name)
     cmd3 = ['tb_cond2 = jc_tb([motif_aabb_',ff(i+2).name,'(:).datenm]'',7,0);'];
     eval(cmd3);
    end
    eval(cmd1);
    eval(cmd2);
    
    if ~isempty(strfind(ff(i+1).name,'apvnaspm')) 
        drugtime = apvnaspmlatency.(['tr_',ff(i+1).name]).treattime;
    elseif ~isempty(strfind(ff(i+1).name,'naspm'))
        drugtime = naspmpitchcvlatency.(['tr_',ff(i+1).name]).treattime;
    elseif ~isempty(strfind(ff(i+1).name,'apv'))
        drugtime = apvpitchcvlatency.(['tr_',ff(i+1).name]).treattime;
    end
    startpt = (drugtime+0.61)*3600;%change latency time!
    ind = find(tb_cond1 >= startpt);

    if ~isempty(ff(i+2).name)
        if ~isempty(strfind(ff(i+2).name,'naspmapv'))
            drugtime2 = naspmapvlatency.(['tr_',ff(i+2).name]).treattime;
        elseif ~isempty(strfind(ff(i+2).name,'apvnaspm'))
            drugtime2 = apvnaspmlatency.(['tr_',ff(i+2).name]).treattime;
        end
        startpt2 = (drugtime2+0.61)*3600;
        ind2 = find(tb_cond2 >= startpt2);
        tb_cond2 = tb_cond2(ind2);
    else %single drug condiiton
        startpt2 = (drugtime+4)*3600;
        ind2 = find(tb_cond1 > startpt2);
        tb_cond2 = tb_cond1(ind2);
    end    
    tb_cond1 = tb_cond1(ind);
    
    acorr_sal = eval(['[motif_aabb_',ff(i).name,'(:).firstpeakdistance]''']);
    acorr_sal = jc_removeoutliers(acorr_sal,nstd);
    [hi lo mn] = mBootstrapCI(acorr_sal);
    plot(gca,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
    plot(gca,daycnt,mn,'ok','MarkerSize',8);hold on;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
     if ~isempty(strfind(ff(i+1).name,'naspm'))
        mrk = 'or';
        mcolor = 'r';
     end
    
    acorr2 = 
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