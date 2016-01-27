function jc_cleanoutliers(batch);

ff = load_batchf(batch);

figure;hold on;
for i = 1:length(ff)
    cmd1 = ['load(''analysis/data_structures/motif_cab_',ff(i).name,''')'];
    eval(cmd1);
    
    cmd1 = ['tb_sal = jc_tb([motif_cab_',ff(i).name,'(:).datenm]'',7,0);'];
    eval(cmd1);
    cmd1 = ['invect = [motif_cab_',ff(i).name,'(:).firstpeakdistance]'';'];
    eval(cmd1);
    
    plot(tb_sal,invect,'k.');hold on;
    removeoutliers = input('remove outliers:','s');
    while removeoutliers == 'y'
        cla;
        nstd = input('nstd:');
        removeind = jc_findoutliers(invect,nstd);
        invect(removeind) = NaN;
        tb_sal(removeind) = NaN;
        cmd = ['[motif_cab_',ff(i).name,'(removeind).firstpeakdistance] = deal(NaN);'];
        eval(cmd);
        plot(tb_sal,invect,'k.');
        removeoutliers = input('remove outliers (y/n):','s');
    end
    cla;
    varname = ['''motif_cab_',ff(i).name,''''];
    cd analysis/data_structures
    cmd1 = ['save(',varname,',',varname,',','''-v7.3'')'];
    eval(cmd1);
    cd ../../
    clearvars -except ff
end

  