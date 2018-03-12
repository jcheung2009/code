%summary plot of changes in sequence entropy and transition probability for
%dominant transition across all drug conditions 
%stores bootstrapped CI for entropy and ts prob as well pval of the
%difference between baseline and treatment in structure 

config;

seq = struct();
if isfield(params,'findseq')
    for n = 1:length(params.findseq)
        h = figure;
        transitions = params.findseq(n).transitions;
        fldnames = cellfun(@(x) x(isletter(x)),transitions,'un',0);
        for i = 1:length(params.trial)
            if exist(['analysis/data_structures/',params.findseq(n).seqstruct,params.trial(i).name,'.mat'])
                load(['analysis/data_structures/',params.findseq(n).seqstruct,params.trial(i).name]);
            else
                continue
            end
            if exist(['analysis/data_structures/',params.findseq(n).seqstruct,params.trial(i).baseline,'.mat'])
                load(['analysis/data_structures/',params.findseq(n).seqstruct,params.trial(i).baseline]);
            else
                continue
            end
            seq_cond = eval([params.findseq(n).seqstruct,params.trial(i).name]);
            seq_base = eval([params.findseq(n).seqstruct,params.trial(i).baseline]);
            seq(i).([strjoin(fldnames,'_')]) = jc_plotseqsummary(seq_base,...
                seq_cond,transitions,params,params.trial(i),h);
        end
    end
end
            