%plot spectral and temporal bout patterns

motif = 'efga';
ff = load_batchf('batch');

for i = 1:length(ff);

    cmd1 = ['load(''analysis/data_structures/bout_',ff(i).name,''')'];
    cmd2 = ['load(''analysis/data_structures/bout_',ff(i+1).name,''')'];
    eval(cmd1);
    eval(cmd2);
    
    if ~isempty(strfind(ff(i+1).name,'IEM')) & ~isempty(strfind(ff(i+1).name,'APV'))
        mcolor = 'g';
        mrk = 'go';
    elseif ~isempty(strfind(ff(i+1).name,'naspm'))
        mcolor = 'r';
        mrk = 'ro';
    elseif ~isempty(strfind(ff(i+1).name,'IEM'))
        mcolor = 'r';
        mrk = 'ro';
    elseif ~isempty(strfind(ff(i+1).name,'APV'))
        mcolor = 'g';
        mrk = 'go';
    elseif ~isempty(strfind(ff(i+1).name,'musc'))
        mcolor = 'm';
        mrk = 'mo';
    else
        mcolor = 'k';
        mrk = 'ko';
    end
    
    if ~isempty(strfind(ff(i+1).name,'sal'))
        startpt = '';
    else
        drugtime = iemapvlatency.(['tr_',ff(i+1).name]).treattime;
        startpt = (drugtime+0.5)*3600;
    end
    
    cmd4 = ['jc_plotboutpattern(bout_',ff(i).name,',bout_',ff(i+1).name,',mcolor,1,startpt,0,numsylls);'];
    eval(cmd4);
        
end
