%plot spectral and temporal bout patterns

motif = 'aabb';

ff = load_batchf('batchnaspm');
load('analysis/data_structures/naspmpitchlatency');

for i = 1:2:length(ff);

    cmd1 = ['load(''analysis/data_structures/bout_',ff(i).name,''')'];
    cmd2 = ['load(''analysis/data_structures/bout_',ff(i+1).name,''')'];
    eval(cmd1);
    eval(cmd2);
    
    if ~isempty(strfind(ff(i+1).name,'naspm'))
        mcolor = 'r';
        mrk = 'ro';
    elseif ~isempty(strfind(ff(i+1).name,'iem'))
        mcolor = 'm';
        mrk = 'mo';
    elseif ~isempty(strfind(ff(i+1).name,'apv'))
        mcolor = 'b';
        mrk = 'bo';
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
        drugtime = naspmpitchlatency.(['tr_',ff(i+1).name]).treattime;
        startpt = (drugtime+1.5)*3600;
    end
    
    cmd4 = ['jc_plotboutpattern(bout_',ff(i).name,',bout_',ff(i+1).name,',mcolor,1,startpt,''y'',''aabb'');'];
    eval(cmd4);
        
end
