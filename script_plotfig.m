
%plotting for different naspm conditions, spectral measurements for syllJble
%each trial has pre-day, treat-day, post-day (matched to time window
%of treat-day) 

ff = load_batchf('batchnaspm');
load('analysis/data_structures/naspmlatency.mat');

syllables = {'A1','A2','B1','B2'};
spc = 0.15;
nstd = 4;
for ii = 1:length(syllables)
    figure;
    h = subtightplot(3,1,1,0.07,0.08,0.15);hold on;
    h2 = subtightplot(3,1,2,0.07,0.08,0.15);hold on;
    h3 = subtightplot(3,1,3,0.07,0.08,0.15);hold on;
    daycnt = 1;
    for i = 1:2:length(ff)
        cmd1 = ['load(''analysis/data_structures/fv_syll',syllables{ii},'_',ff(i).name,''')'];
        cmd2 = ['load(''analysis/data_structures/fv_syll',syllables{ii},'_',ff(i+1).name,''')'];
        eval(cmd1);
        eval(cmd2);
        cmd1 = ['tb_sal = jc_tb([fv_syll',syllables{ii},'_',ff(i).name,'(:).datenm]'',7,0);'];
        cmd2 = ['tb_cond = jc_tb([fv_syll',syllables{ii},'_',ff(i+1).name,'(:).datenm]'',7,0);'];
        eval(cmd1);
        eval(cmd2);

        drugtime = naspmlatency.(['tr_',ff(i+1).name]).treattime;
        startpt = (drugtime+0.6)*3600;%change latency time!
        ind = find(tb_cond >= startpt);
        %indsal = find(tb_sal >= tb_cond(1) & tb_sal <= tb_cond(end));
        indsal = 1:length(tb_sal);

        pitch = eval(['[fv_syll',syllables{ii},'_',ff(i).name,'(:).mxvals]''']);
        pitch = jc_removeoutliers(pitch,nstd);
        [hi lo mn] = mBootstrapCI(pitch);
        plot(h,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
        plot(h,daycnt,mn,'ok','MarkerSize',8);hold on;
        
        vol = eval(['log([fv_syll',syllables{ii},'_',ff(i).name,'(:).maxvol]'')']);
        vol = jc_removeoutliers(vol,nstd);
        [hi lo mn] = mBootstrapCI(vol);
        plot(h2,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
        plot(h2,daycnt,mn,'ok','MarkerSize',8);hold on;
        
        [mn hi lo] = mBootstrapCI_CV(pitch);
        plot(h3,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
        plot(h3,daycnt,mn,'ok','MarkerSize',8);hold on;

        if ~isempty(strfind(ff(i+1).name,'naspm'))
            mrk = 'or';
            mcolor = 'r';
        elseif ~isempty(strfind(ff(i+1).name,'IEM'))
            mrk = 'or';
            mcolor = 'r';
        elseif ~isempty(strfind(ff(i+1).name,'APV'))
            mrk = 'og';
            mcolor = 'g';
        else
            mrk = 'ok';
            mcolor = 'k';
        end

        pitch2 = eval(['[fv_syll',syllables{ii},'_',ff(i+1).name,'(ind).mxvals]''']);
        pitch2 = jc_removeoutliers(pitch2,nstd);
        [hi lo mn] = mBootstrapCI(pitch2);
        plot(h,[daycnt+spc daycnt+spc],[hi lo],mcolor,'linewidth',2);hold on;
        plot(h,daycnt+spc,mn,mrk,'MarkerSize',8);hold on;

        vol2 = eval(['[fv_syll',syllables{ii},'_',ff(i+1).name,'(ind).maxvol]''']);
        vol2 = jc_removeoutliers(vol2,nstd);
        [hi lo mn] = mBootstrapCI(vol2);
        plot(h2,[daycnt+spc daycnt+spc],[hi lo],mcolor,'linewidth',2);hold on;
        plot(h2,daycnt+spc,mn,mrk,'MarkerSize',8);hold on;

        [mn hi lo] = mBootstrapCI_CV(pitch2);
        plot(h3,[daycnt+spc daycnt+spc],[hi lo],mcolor,'linewidth',2);hold on;
        plot(h3,daycnt+spc,mn,mrk,'MarkerSize',8);hold on;

        daycnt = daycnt+1;
    end
    title(h,['syllable ',syllables{ii},' Mean pitch with CI']);
    ylabel(h,'Frequency (Hz)');
    set(h,'fontweight','bold','xlim',[0.5 daycnt-0.5],'xtick',[1:daycnt-1]);

    title(h2,'Mean volume with CI');
    ylabel(h2,'Amplitude');
    set(h2,'fontweight','bold','xlim',[0.5 daycnt-0.5],'xtick',[1:daycnt-1]);

    title(h3,'Mean pitch CV with CI');
    xlabel(h3,'Day');
    ylabel(h3,'CV');
    set(h3,'fontweight','bold','xlim',[0.5 daycnt-0.5],'xtick',[1:daycnt-1]);
end




