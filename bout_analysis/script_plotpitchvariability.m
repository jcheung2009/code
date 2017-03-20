%compare pitch variability for all renditions vs pitch variability after
%controlling for bout position 
%correlate pitch and bout position to get variability explained by bout
%position

config 
ff = load_batchf('batch');
for i = 1:length(params.boutstructs)
    eval([params.boutstructs{i},'pre = [];']);%combines several days of data into single pre condition
    eval([params.boutstructs{i},'post = [];']);
    for ii = 1:length(ff);
        cmd1 = ['load(''analysis/data_structures/',params.boutstructs{i},ff(ii).name,''')'];
        eval(cmd1);

        if ~isempty(strfind(ff(ii).name,'pre'))
            eval([params.boutstructs{i},'pre = [',params.boutstructs{i},'pre eval([params.boutstructs{i},ff(ii).name])];']);
        elseif ~isempty(strfind(ff(ii).name,'post'))
            eval([params.boutstructs{i},'post = [',params.boutstructs{i},'post eval([params.boutstructs{i},ff(ii).name])];']);
        end
    end
    
    fighandles = jc_pitchvariability(bout_syllA_pre,'ok','k',params.boutmotifs{i});
    jc_pitchvariability(bout_syllA_post,'or','r',params.boutmotifs{i},fighandles);
end
