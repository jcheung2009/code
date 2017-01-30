function jc_findtransprob(batch)
%takes batch and config file in bird's directory and goes through each folder listed in batch to
%extract variable transitions for each bout, timestamps, conv/div type and
%saves to data structures folder

config;


ff = load_batchf(batch);
for i = 1:length(ff)
    if isempty(ff(i).name)
        continue
    end
    cd(ff(i).name);
    numtransitiontypes = length(params.sequences);
    for k = 1:numtransitiontypes
        varname = ['seq_',strjoin(params.sequences{k},'_'),'_',ff(i).name];
        eval([varname,'= struct(''trans_per_song'',[],''time_per_song'',[],''conv_or_div'',[]);']);
        [trans,tm,conordiv] = db_transition_probability_for_sequence(params.batchname,params.sequences{k},'n');
        eval([varname,'.trans_per_song=trans;']);
        eval([varname,'.time_per_song=tm;']);
        eval([varname,'.conv_or_div=conordiv;']);
        eval([varname,'.transitions=params.sequences{',num2str(k),'};']);
        eval(['save(''../analysis/data_structures/',varname,''',''',varname,''',','''-v7.3'')']);
        disp(['saving ',ff(i).name,'...']);
    end
    cd ../
end

    