function script_findseqtrans(batch,ind)
%script to make seq structs
%for identified branch points

config;
pathname = fileparts([pwd,'/analysis/data_structures/']);
ff = load_batchf(batch);
if isempty(ind)
    ind = [1 length(ff)];
end

for n = 1:length(params.findseq)
    for i = ind(1):ind(2)
        if isempty(ff(i).name)
            continue
        end
        cd(ff(i).name);
        eval([params.findseq(n).seqstruct,ff(i).name,'=struct(''trans_per_song'',[],''time_per_song'',[],''conv_or_div'',[]);']);
        eval(['[trans,tm,conordiv]=db_transition_probability_for_sequence(params.batchfile,params.findseq(n).transitions,''n'');']);
        eval([params.findseq(n).seqstruct,ff(i).name,'.trans_per_song=trans;']);
        eval([params.findseq(n).seqstruct,ff(i).name,'.time_per_song=tm;']);
        eval([params.findseq(n).seqstruct,ff(i).name,'.conv_or_div=conordiv;']);
        varname = [params.findseq(n).seqstruct,ff(i).name];
        matfile = fullfile(pathname,varname);
        savecmd = ['save(matfile,varname,''-v7.3'')'];
        eval(savecmd);
        cd ..
    end
end

