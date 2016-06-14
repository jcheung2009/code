
%plotting for different naspm conditions, spectral measurements for syllJble
%each trial has pre-day, treat-day, post-day (matched to time window
%of treat-day) 

ff = load_batchf('batchmusc');
load('analysis/data_structures/musclatency.mat');
syllables = {'A1','A2','B1','B2'};
spc = 0.15;

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

        drugtime = musclatency.(['tr_',ff(i+1).name]).treattime;
        startpt = (drugtime+0.4)*3600;%change latency time!
        ind = find(tb_cond >= startpt);
        indsal = find(tb_sal >= tb_cond(1) & tb_sal <= tb_cond(end));
        %ind2 = find(tb_sal2 >= tb_cond(1) & tb_sal2 <= tb_cond(end));

        cmd2 = ['mBootstrapCI([fv_syll',syllables{ii},'_',ff(i).name,'(:).mxvals])'];
        [hi lo mn] = eval(cmd2);
        plot(h,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
        plot(h,daycnt,mn,'ok','MarkerSize',8);hold on;

        cmd3 = ['mBootstrapCI([fv_syll',syllables{ii},'_',ff(i).name,'(:).maxvol])'];
        [hi lo mn] = eval(cmd3);
        plot(h2,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
        plot(h2,daycnt,mn,'ok','MarkerSize',8);hold on;

        cmd4 = ['mBootstrapCI_CV([fv_syll',syllables{ii},'_',ff(i).name,'(:).mxvals])'];
         [mn hi lo] = eval(cmd4);
        plot(h3,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
        plot(h3,daycnt,mn,'ok','MarkerSize',8);hold on;

        if ~isempty(strfind(ff(i+1).name,'naspm'))
            mrk = 'or';
            mcolor = 'r';
        elseif ~isempty(strfind(ff(i+1).name,'iem'))
            mrk = 'om';
            mcolor = 'm';
        elseif ~isempty(strfind(ff(i+1).name,'apv'))
            mrk = 'ob';
            mcolor = 'b';
        else
            mrk = 'ok';
            mcolor = 'k';
        end

        cmd2 = ['mBootstrapCI([fv_syll',syllables{ii},'_',ff(i+1).name,'(ind).mxvals])'];
        [hi lo mn] = eval(cmd2);
        plot(h,[daycnt+spc daycnt+spc],[hi lo],mcolor,'linewidth',2);hold on;
        plot(h,daycnt+spc,mn,mrk,'MarkerSize',8);hold on;

        cmd3 = ['mBootstrapCI([fv_syll',syllables{ii},'_',ff(i+1).name,'(ind).maxvol])'];
        [hi lo mn] = eval(cmd3);
        plot(h2,[daycnt+spc daycnt+spc],[hi lo],mcolor,'linewidth',2);hold on;
        plot(h2,daycnt+spc,mn,mrk,'MarkerSize',8);hold on;

        cmd4 = ['mBootstrapCI_CV([fv_syll',syllables{ii},'_',ff(i+1).name,'(ind).mxvals])'];
         [mn hi lo] = eval(cmd4);
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




