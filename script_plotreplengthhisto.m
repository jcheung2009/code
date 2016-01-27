repeats = {'A','B'};

ff = load_batchf('batchnaspm2');
load('analysis/data_structures/naspmpitchlatency');

for i = 1:2:length(ff);
    for ii = 1:length(repeats)
        figure;hold on;
        h = gca;
        cmd1 = ['load(''analysis/data_structures/fv_rep',repeats{ii},'_',ff(i).name,''')'];
        cmd2 = ['load(''analysis/data_structures/fv_rep',repeats{ii},'_',ff(i+1).name,''')'];
        eval(cmd1);
        eval(cmd2)
        
        cmd3 = ['tb_cond = jc_tb([fv_rep',repeats{ii},'_',ff(i+1).name,'(:).datenm]'',7,0);'];
        eval(cmd3);
        
         if ~isempty(strfind(ff(i+1).name,'sal'))
            startpt = '';
        else
            drugtime = naspmpitchlatency.(['tr_',ff(i+1).name]).treattime;
            startpt = (drugtime+1.4)*3600;
         end
        ind = find(tb_cond >= startpt);
        
        cmd4 = ['jc_plotrepeatlengthhistogram(fv_rep',syllables{ii},'_',ff(i).name,',fv_rep',syllables{ii},'_',ff(i+1).name,'(ind),''n'',h);'];
        eval(cmd4);
        title(h,['fv_rep',repeats{ii},'_',ff(i+1).name],'interpreter','none');
        hold(h,'off');
    end
end