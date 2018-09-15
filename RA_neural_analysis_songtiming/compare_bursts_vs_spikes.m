%% results for analyzing gap and syllable premotor activity with gap and syll
%duration comparing with using bursts vs spikes in fixed window

load gap_multicorrelation_analysis_fr.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('gap bursts')


load gap_multicorrelation_analysis_fr_spks.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('gap spikes')

load dur_multicorrelation_analysis_fr.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('syll bursts')


load dur_multicorrelation_analysis_fr_spks.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('syll spikes')