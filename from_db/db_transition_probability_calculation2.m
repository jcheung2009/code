function [boot_results entropy_results] =...
    db_transition_probability_calculation2( syl_pool, motifs, number_bootstraps)
%MODIFIED: db_transition_probability_calculation Given a vector of syllables and a set 
%of motifs (needs to be a cell, ex: {'ab' 'ac'}), it will give the following:
% 3. if 'boot_yes_or_no is not specified or set to 'y', a bootstrap
% structure of each motif's transition probability. The number of
% iterations of the bootstrap can be set by number_bootstraps (default is
% 10,000). 
% 4. Transition entropy(-Sigma p log2 p)

[~, modified_motifs] = db_con_or_div(motifs);

%sets number_bootstraps if not specified 
if nargin < 3
number_bootstraps = 10000;
end

%bootstrap procedure for calculating transition probabilities
for iii = 1:number_bootstraps
    %creates a vector that indicates which syllables will be
    %sampled during this iteration
    sampling = randi(length(syl_pool),[1 length(syl_pool)]);

    %creates a list of syllables by sampling from syl_pool with
    %sampling variable above
    boot_pool = syl_pool(sampling);

    for jjj = 1:length(motifs)
        %goes through the different motifs and calculates how many
        %times it occured for this bootstrap iteration
        boot_results.(motifs{jjj}(isletter(motifs{jjj})))(iii) =...
            length(strfind(boot_pool,modified_motifs{jjj}))./length(boot_pool);
    end

    %calculates transition entropy for this bootstrap iteration
    %(entropy = Sigma -p * log2 p)
    entropy_iteration = [];
    for nnn = 1:length(motifs)
        entropy_iteration = [entropy_iteration boot_results.(motifs{nnn}...
            (isletter(motifs{nnn})))(iii).*log2(boot_results.(motifs{nnn}...
            (isletter(motifs{nnn})))(iii))/log2(length(motifs))];
    end

    entropy_results(iii) = sum(entropy_iteration)*-1;
    clear entropy_iteration

end

%replaces all NaN in entropy_results (when p = 0) to 0 (definition)
entropy_results(isnan(entropy_results)) = 0;

for mmm = 1:length(motifs)
    %transposes bootstrap results so it is easier to read
    boot_results.(motifs{mmm}(isletter(motifs{mmm}))) = ...
        boot_results.(motifs{mmm}(isletter(motifs{mmm})))';
end

entropy_results = entropy_results';

%now you have a structure of bootstrap results. the median is the
%transition probability for the day, and you can add 95% or 99% CI
    



        
    
    

end

