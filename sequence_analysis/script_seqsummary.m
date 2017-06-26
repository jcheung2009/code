
%extracts change in transition entropy and probability

config;

seq = struct();
for i = 1:length(params.trial)
    if isfield(params,'findseq')
        for n = 1:length(params.findseq)
            transitions = params.findseq(n).transitions;
            load(['analysis/data_structures/',params.findseq(n).seqstruct,params.trial(i).name]);
            load(['analysis/data_structures/',params.findseq(n).seqstruct,params.trial(i).baseline]);
            seq_cond = eval([params.findseq(n).seqstruct,params.trial(i).name]);
            seq_base = eval([params.findseq(n).seqstruct,params.trial(i).baseline]);
            seq(i).([strjoin(transitions,'_')]) = jc_plotseqsummary(seq_base,seq_cond,transitions,params,params.trial(i));
        end
    end
end
            