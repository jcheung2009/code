%plot pitch contours of all syllables in trial

syllables = {'A1','A2','B1','B2'};

ff = load_batchf('batchnaspm');
load('analysis/data_structures/naspmpitchlatency');

for i = 1:2:length(ff);
    figure;hold on;
    for ii = 1:length(syllables)
        h = subtightplot(2,length(syllables),ii,0.07,0.1,0.08);
        h2 = subtightplot(2,length(syllables),ii+length(syllables),0.07,0.1,0.08);
        hold off;
        cmd1 = ['load(''analysis/data_structures/fv_syll',syllables{ii},'_',ff(i).name,''')'];
        cmd2 = ['load(''analysis/data_structures/fv_syll',syllables{ii},'_',ff(i+1).name,''')'];
        eval(cmd1);
        eval(cmd2);
        
        cmd3 = ['tb_cond = jc_tb([fv_syll',syllables{ii},'_',ff(i+1).name,'(:).datenm]'',7,0);'];
        eval(cmd3);
        
         if ~isempty(strfind(ff(i+1).name,'sal'))
            startpt = '';
        else
            drugtime = naspmpitchlatency.(['tr_',ff(i+1).name]).treattime;
            startpt = (drugtime+1.5)*3600;
         end
        ind = find(tb_cond >= startpt);
        
        cmd4 = ['jc_avnspec(fv_syll',syllables{ii},'_',ff(i).name,',fv_syll',syllables{ii},'_',ff(i+1).name,'(ind),''y'',h,h2);'];
        eval(cmd4);
        title(h,['fv_syll',syllables{ii},'_',ff(i+1).name],'interpreter','none');
        hold(h,'off');
    end
end

        
        
      
        
        
         