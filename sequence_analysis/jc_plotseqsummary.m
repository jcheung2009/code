function seq = jc_plotseqsummary(seq_sal,seq_cond,transition,params,trialparams);
%summary plot of sequence changes

conditions=params.conditions;
base = params.baseepoch;
removeoutliers=params.removeoutliers;
trialname=trialparams.name;
treattime=trialparams.treattime;
linecolor = trialparams.linecolor;
marker=trialparams.marker;
xpt = find(strcmp(conditions,trialparams.condition));

%exclude wash-in and match time of day
tb_sal = seq_sal.time_per_song;
tb_cond = seq_cond.time_per_song;
tb_sal = jc_tb(cell2mat(tb_sal)',7,0);
tb_cond = jc_tb(cell2mat(tb_cond)',7,0);
if isempty(treattime)
    start_time = tb_cond(1)+3600;
else
    start_time = time2datenum(treattime) + 3600;%1 hr buffer
end

if ~strcmp(base,'morn') & ~strcmp(trialparams.condition,'saline')
    ind2 = find(tb_cond > start_time);
    tb_cond = tb_cond(ind2);
    ind1 = find(tb_sal >= tb_cond(1));
    tb_sal = tb_sal(ind1);
elseif ~strcmp(base,'morn') & strcmp(trialparams.condition,'saline')
    ind2 = find(tb_cond > start_time);
    tb_cond = tb_cond(ind2);
    ind1 = find(tb_sal >= tb_cond(1));
    tb_sal = tb_sal(ind1);
elseif strcmp(base,'morn') & ~strcmp(trialparams.condition,'saline')
    ind2 = find(tb_cond > start_time);
    tb_cond = tb_cond(ind2);
    ind1 = 1:length(tb_sal);
    tb_sal = tb_sal(ind1);
elseif strcmp(base,'morn') & strcmp(trialparams.condition,'saline')
    ind2 = find(tb_cond >= 5*3600);
    tb_cond = tb_cond(ind2);
    ind1 = find(tb_sal < 5*3600) ;
    tb_sal = tb_sal(ind1);
end

trans_sal = cell2mat(seq_sal.trans_per_song);
trans_cond = cell2mat(seq_cond.trans_per_song);
trans_sal = trans_sal(ind1);
trans_cond = trans_cond(ind2);

[boot_results1 entropy_results1] = db_transition_probability_calculation2(trans_sal,transition);
[boot_results2 entropy_results2] = db_transition_probability_calculation2(trans_cond,transition);

if mean(entropy_results1) == 0
    trans_sal = cell2mat(seq_sal.trans_per_song);
    [boot_results1 entropy_results1] = db_transition_probability_calculation2(trans_sal,transition);
end

hi1 = prctile(entropy_results1,95);
lo1 = prctile(entropy_results1,5);
mn1 = mean(entropy_results1);
hi2 = prctile(entropy_results2,95);
lo2 = prctile(entropy_results2,5);
mn2 = mean(entropy_results2);

seq.trialname = trialname;
seq.condition = trialparams.condition;
seq.seq_entropy_base = [mn1 hi1 lo1];
seq.seq_entropy_cond = [mn2 hi2 lo2];
for n = 1:length(transition)
    hi1 = prctile(boot_results1.([transition{n}]),95);
    lo1 = prctile(boot_results1.([transition{n}]),5);
    mn1 = median(boot_results1.([transition{n}]));
    hi2 = prctile(boot_results2.([transition{n}]),95);
    lo2 = prctile(boot_results2.([transition{n}]),5);
    mn2 = median(boot_results2.([transition{n}]));
    seq.([transition{n}]).boot_base = [mn1 hi1 lo1];
    seq.([transition{n}]).boot_cond = [mn2 hi2 lo2];
end
