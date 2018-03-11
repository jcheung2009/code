function script_findseqtrans2(batch,ind)
%script to make seq structs
%for counting full and shortened motifs
%runs jc_motif_probability_calc on all files in batch

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
        eval([params.findseq(n).seqstruct,ff(i).name,'=struct(''trans_per_song'',[],''time_per_song'',[]);']);
        eval(['[trans,tm]=jc_cnt_truncated_motifs(params.batchfile,params.findseq(n).transitions{1});']);
        eval([params.findseq(n).seqstruct,ff(i).name,'.trans_per_song=trans;']);
        eval([params.findseq(n).seqstruct,ff(i).name,'.time_per_song=tm;']);
        varname = [params.findseq(n).seqstruct,ff(i).name];
        matfile = fullfile(pathname,varname);
        savecmd = ['save(matfile,varname,''-v7.3'')'];
        eval(savecmd);
        cd ..
    end
end

