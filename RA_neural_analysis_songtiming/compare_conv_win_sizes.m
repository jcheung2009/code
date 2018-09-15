%% results for analyzing gap and syllable premotor activity with gap and syll
%duration comparing with different size convolution windows 

load gap_multicorrelation_analysis_fr.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable5.unitid))];
end
corrtable = corrtable5(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('5 ms conv window')


id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('10 ms conv window')


id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable20.unitid))];
end
corrtable = corrtable20(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('20 ms conv window')



load dur_multicorrelation_analysis_fr.mat
activitythresh = 50;
ff = load_batchf('singleunits_leq_1pctISI_2pcterr');
id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable5.unitid))];
end
corrtable = corrtable5(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('5 ms conv window')

id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable10.unitid))];
end
corrtable = corrtable10(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('10 ms conv window')

id = [];
for i = 1:length(ff)
    id = [id;find(cellfun(@(x) contains(ff(i).name,x),corrtable20.unitid))];
end
corrtable = corrtable20(id,:);
plot_distr_corrs(corrtable,50,1000,0.01);
title('20 ms conv window')