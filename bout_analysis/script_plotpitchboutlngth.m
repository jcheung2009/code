%correlates pitch at the beginning/end of bout and bout length
config 

ff = load_batchf('batch');
for ii = 1:length(params.boutstructs)
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
    jc_pitch_vs_boutlength(eval([params.boutstructs{i},'pre']),'ok',params.boutmotifs{i});
    jc_pitch_vs_boutlength(eval([params.boutstructs{i},'post']),'or',params.boutmotifs{i});
end

