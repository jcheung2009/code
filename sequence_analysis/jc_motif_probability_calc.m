function [boot_results entropy_results] = jc_motif_probability_calc(cnts,motif,number_bootstraps)
%given a vector of 1's and 0's that cnt the occurence of the full or
%truncated motif, bootstraps their probabilities as well as entropy 

%set number of bootstrap reps
if nargin<3
    number_bootstraps = 10000;
end

%boostraping probability of full vs short motifs 
entropy_results = NaN(number_bootstraps,1);
for iii = 1:number_bootstraps
    %index for sample during this iteration
    sampling = randi(length(cnts),[1 length(cnts)]);
    
    %sample vector of 1's and 0's 
    boot_pool = cnts(sampling);
    
    boot_results.(motif)(iii) = sum(boot_pool)/length(boot_pool);
    boot_results.(motif(1))(iii) = sum(boot_pool==0)/length(boot_pool);
    entropy_full = boot_results.(motif)(iii).*log2(boot_results.(motif)(iii));
    entropy_short = boot_results.(motif(1))(iii).*log2(boot_results.(motif(1))(iii));
    entropy_results(iii) = -(entropy_full+entropy_short);
end

%replaces all NaN in entropy_results (when p = 0) to 0 (definition)
entropy_results(isnan(entropy_results)) = 0;

boot_results.(motif) = boot_results.(motif)';
boot_results.(motif(1)) =  boot_results.(motif(1))';