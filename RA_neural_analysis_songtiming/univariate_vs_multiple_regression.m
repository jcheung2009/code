%% results for analyzing gap and syllable premotor activity with gap and syll
%duration (simple regression)

load gap_correlation_analysis.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);

load dur_correlation_analysis.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);

%% results for analyzing gap and syllable premotor activity with gap and syll
%duration while controlling for duration of neighboring syllables

load gap_correlation_analysis_control_dur.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);

load dur_correlation_analysis_control_dur.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);

%% results for analyzing gap and syllable premotor activity with gap and syll
%duration while controlling for duration AND volume of neighboring syllables

load gap_correlation_analysis_control_dur_vol.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);

load dur_correlation_analysis_control_dur_vol.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
