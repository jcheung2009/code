%summary plot of changes in sequence entropy and transition probability for
%dominant transition across all drug conditions 
%stores bootstrapped CI for entropy and ts prob as well pval of the
%difference between baseline and treatment in structure 

config;
h = figure;
seq = struct();
for i = 1:length(params.trial)
    if isfield(params,'findseq')
        for n = 1:length(params.findseq)
            transitions = params.findseq(n).transitions;
            fldnames = cellfun(@(x) x(isletter(x)),transitions,'un',0);
            load(['analysis/data_structures/',params.findseq(n).seqstruct,params.trial(i).name]);
            load(['analysis/data_structures/',params.findseq(n).seqstruct,params.trial(i).baseline]);
            seq_cond = eval([params.findseq(n).seqstruct,params.trial(i).name]);
            seq_base = eval([params.findseq(n).seqstruct,params.trial(i).baseline]);
            seq(i).([strjoin(fldnames,'_')]) = jc_plotseqsummary(seq_base,...
                seq_cond,transitions,params,params.trial(i),h);
        end
    end
end
            