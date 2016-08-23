ff = load_batchf('batch');
for i = 64:65%1:length(ff)
    if isempty(ff(i).name)
        continue
    end
    cd(ff(i).name);
    eval(['seq_ab_or_gb_',ff(i).name,'=struct(''trans_per_song'',[],''time_per_song'',[],''conv_or_div'',[]);']);
    
    eval(['[trans,tm,conordiv]=db_transition_probability_for_sequence(''batch.keep'',{''ab'',''gb''},''n'');']);
    eval(['seq_ab_or_gb_',ff(i).name,'.trans_per_song=trans;']);
    eval(['seq_ab_or_gb_',ff(i).name,'.time_per_song=tm;']);
    eval(['seq_ab_or_gb_',ff(i).name,'.conv_or_div=conordiv;']);
    cd ../analysis/data_structures
    varname = ['''seq_ab_or_gb_',ff(i).name,''''];
    eval(['save(',varname,',',varname,',','''-v7.3'')']);
    
    clearvars -except ff
    cd ../../
end

    