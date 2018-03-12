function seq = jc_plotseqsummary(seq_sal,seq_cond,transition,params,trialparams,fignum);
%extracts changes in transition probability and sequence entropy for all
%trials and stores in seq
%also plots summary

%parameters
conditions=params.conditions;
base = params.baseepoch;
trialname=trialparams.name;
treattime=trialparams.treattime;
linecolor = trialparams.linecolor;
marker=trialparams.marker;
xpt = find(strcmp(conditions,trialparams.condition));
shufftrials = 10000;

%exclude wash-in and match time of day
tb_sal = seq_sal.time_per_song;
tb_cond = seq_cond.time_per_song;
[ind1 ind2 tb_sal tb_cond] = restricttimewindow(tb_sal,tb_cond,treattime,base,trialparams.condition);

%transform into vector 
trans_sal = cell2mat(seq_sal.trans_per_song);
trans_cond = cell2mat(seq_cond.trans_per_song);
trans_sal = trans_sal(ind1);
trans_cond = trans_cond(ind2);

%bootstrap transition probs and entropy 
if length(transition)>1
    [boot_results1 entropy_results1] = db_transition_probability_calculation2(trans_sal,transition);
    [boot_results2 entropy_results2] = db_transition_probability_calculation2(trans_cond,transition);
else
    [boot_results1 entropy_results1] = jc_motif_probability_calc(trans_sal,transition{1});
    [boot_results2 entropy_results2] = jc_motif_probability_calc(trans_cond,transition{1});
end

%entropy 90% confidence intervals
hi1 = prctile(entropy_results1,95);
lo1 = prctile(entropy_results1,5);
mn1 = median(entropy_results1);
hi2 = prctile(entropy_results2,95);
lo2 = prctile(entropy_results2,5);
mn2 = median(entropy_results2);

seq.trialname = trialname;
seq.condition = trialparams.condition;
seq.seq_entropy_base = [mn1 hi1 lo1];
seq.seq_entropy_cond = [mn2 hi2 lo2];

%transition probs 90% confidence intervals
if length(transition)>1
    for n = 1:length(transition)
        hi1 = prctile(boot_results1.([transition{n}(isletter(transition{n}))]),95);
        lo1 = prctile(boot_results1.([transition{n}(isletter(transition{n}))]),5);
        mn1 = median(boot_results1.([transition{n}(isletter(transition{n}))]));
        hi2 = prctile(boot_results2.([transition{n}(isletter(transition{n}))]),95);
        lo2 = prctile(boot_results2.([transition{n}(isletter(transition{n}))]),5);
        mn2 = median(boot_results2.([transition{n}(isletter(transition{n}))]));
        seq.([transition{n}(isletter(transition{n}))]).boot_base = [mn1 hi1 lo1];
        seq.([transition{n}(isletter(transition{n}))]).boot_cond = [mn2 hi2 lo2];
    end
else
    hi1 = prctile(boot_results1.([transition{1}]),95);
    lo1 = prctile(boot_results1.([transition{1}]),5);
    mn1 = median(boot_results1.([transition{1}]));
    hi2 = prctile(boot_results2.([transition{1}]),95);
    lo2 = prctile(boot_results2.([transition{1}]),5);
    mn2 = median(boot_results2.([transition{1}]));
    seq.([transition{1}]).boot_base = [mn1 hi1 lo1];
    seq.([transition{1}]).boot_cond = [mn2 hi2 lo2];
    
    hi1 = prctile(boot_results1.([transition{1}(1)]),95);
    lo1 = prctile(boot_results1.([transition{1}(1)]),5);
    mn1 = median(boot_results1.([transition{1}(1)]));
    hi2 = prctile(boot_results2.([transition{1}(1)]),95);
    lo2 = prctile(boot_results2.([transition{1}(1)]),5);
    mn2 = median(boot_results2.([transition{1}(1)]));
    seq.([transition{1}(1)]).boot_base = [mn1 hi1 lo1];
    seq.([transition{1}(1)]).boot_cond = [mn2 hi2 lo2];
end

%pval for entropy difference and transition prob diff (perm test)

if length(transition)>1
    [seq.ts_pval seq.seq_entropy_pval] = permtest2(trans_sal,...
        trans_cond,transition,shufftrials);
else
    [seq.ts_pval seq.seq_entropy_pval] = permtest(trans_sal,...
        trans_cond,shufftrials);
end

%plot summary
figure(fignum);hold on;
h1 = subtightplot(1,2,1,[0.07 0.05],0.08,0.15);
jitter = 0.25+rand/5;
plot(h1,xpt-jitter,seq.seq_entropy_base(1),marker,'markersize',8);hold on;
plot(h1,[xpt xpt]-jitter,[seq.seq_entropy_base(2:3)],linecolor);hold on;
plot(h1,xpt+jitter,seq.seq_entropy_cond(1),marker,'markersize',8);hold on;
plot(h1,[xpt xpt]+jitter,[seq.seq_entropy_cond(2:3)]',linecolor);hold on;
plot(h1,[xpt-jitter xpt+jitter],[seq.seq_entropy_base(1) seq.seq_entropy_cond(1)]',linecolor);hold on;
ylabel('sequence entropy');
set(h1,'fontweight','bold','xlim',[0.5 length(conditions)+0.5],'xtick',1:length(conditions),...
    'xticklabel',conditions)
title(h1,transition);

h1 = subtightplot(1,2,2,[0.07 0.05],0.08,0.15);
jitter = 0.25+rand/5;
plot(h1,xpt-jitter,seq.(transition{1}).boot_base(1),marker,'markersize',8);hold on;
plot(h1,[xpt xpt]-jitter,[seq.(transition{1}).boot_base(2:3)],linecolor);hold on;
plot(h1,xpt+jitter,seq.(transition{1}).boot_cond(1),marker,'markersize',8);hold on;
plot(h1,[xpt xpt]+jitter,[seq.(transition{1}).boot_cond(2:3)]',linecolor);hold on;
plot(h1,[xpt-jitter xpt+jitter],[seq.(transition{1}).boot_base(1) ...
    seq.(transition{1}).boot_cond(1)]',linecolor);hold on;
ylabel('transition probability');
set(h1,'fontweight','bold','xlim',[0.5 length(conditions)+0.5],'xtick',1:length(conditions),...
    'xticklabel',conditions)
title(h1,transition);

function [ind1 ind2 tb_sal tb_cond] = restricttimewindow(tb_sal,tb_cond,...
    treattime,base,condition);
%restrict and match the time window of analysis between conditions
%outputs the indices for data and time vectors 
    %get time vector for data in seconds relative to 7 AM 
    tb_sal = jc_tb(cell2mat(tb_sal)',7,0);
    tb_cond = jc_tb(cell2mat(tb_cond)',7,0);
    if isempty(treattime)
        start_time = tb_cond(1)+3600;
    else
        start_time = time2datenum(treattime) + 3600;%1 hr buffer
    end

    if ~strcmp(base,'morn') & ~strcmp(condition,'saline')%comparing drug in afternoon to saline in afternoon 
        ind2 = find(tb_cond > start_time);
        ind1 = find(tb_sal >= tb_cond(1));
    elseif ~strcmp(base,'morn') & strcmp(condition,'saline')%comparing saline to saline between days 
        ind2 = find(tb_cond > start_time);
        ind1 = find(tb_sal >= tb_cond(1));
    elseif strcmp(base,'morn') & ~strcmp(condition,'saline')%comparing drug in afternoon to saline in morning
        ind2 = find(tb_cond > start_time);
        ind1 = 1:length(tb_sal);
    elseif strcmp(base,'morn') & strcmp(condition,'saline')%comparing saline in afternoon to saline in morning
        ind2 = find(tb_cond >= 5*3600);
        ind1 = find(tb_sal < 5*3600);
    end
    tb_sal = tb_sal(ind1);
    tb_cond = tb_cond(ind2);
    
function [tspval entpval] = permtest(trans_sal,trans_cond,shufftrials);
%permutation test for difference in trans prob for dominant transition and
%seq entropy when vect is 1's and 0's representing full and short motifs
    sylpool = [trans_sal trans_cond];
    tsdiff = NaN(shufftrials,1);
    ts1 = sum(trans_sal)/length(trans_sal);
    ts2 = sum(trans_cond)/length(trans_cond);
    ent1 = -((sum(trans_sal)/length(trans_sal))*log2(sum(trans_sal)/length(trans_sal)) + ...
            (sum(trans_sal==0)/length(trans_sal))*log2(sum(trans_sal==0)/length(trans_sal)));
    ent2 = -((sum(trans_cond)/length(trans_cond))*log2(sum(trans_cond)/length(trans_cond)) + ...
        (sum(trans_cond==0)/length(trans_cond))*log2(sum(trans_cond==0)/length(trans_cond)));
    for i = 1:shufftrials
        shuffpool = sylpool(randperm(length(sylpool)));
        samp1 = shuffpool(1:length(trans_sal));
        samp2 = shuffpool(length(trans_sal)+1:end);
        ts_samp1 = sum(samp1)/length(samp1);
        ts_samp2 = sum(samp2)/length(samp2);
        ent_samp1 = -((sum(samp1)/length(samp1))*log2(sum(samp1)/length(samp1)) + ...
            (sum(samp1==0)/length(samp1))*log2(sum(samp1==0)/length(samp1)));
        ent_samp2 = -((sum(samp2)/length(samp2))*log2(sum(samp2)/length(samp2)) + ...
            (sum(samp2==0)/length(samp2))*log2(sum(samp2==0)/length(samp2)));
        entdiff(i) = abs(ent_samp1-ent_samp2);
        tsdiff(i) = abs(ts_samp1-ts_samp2);
    end
    tspval = length(find(tsdiff>=abs(ts1-ts2)))/shufftrials;
    entpval = length(find(entdiff>=abs(ent1-ent2)))/shufftrials;
    
function [tspval entpval] = permtest2(trans_sal,trans_cond,transition,shufftrials)    
%permutation test for difference in seq entropy and transition prob of
%dominant ts
    [~,modified_motifs] = db_con_or_div(transition);
    
    %determine which ts is dominant
    ts_sal = [];ts_cond = [];
    for k = 1:length(transition)
        ts_sal = [ts_sal; length(strfind(trans_sal,modified_motifs(k)))./length(trans_sal)];
        ts_cond = [ts_cond; length(strfind(trans_cond,modified_motifs(k)))./length(trans_cond)];
    end
    [~,dominant_ts] = max(ts_sal);
    
    %empirical seq entropy 
    ent_sal = []; ent_cond = [];
    for k = 1:length(transition)
        ent_sal = [ent_sal ts_sal(k).*log2(ts_sal(k))/log2(length(transition))];
        ent_cond = [ent_cond ts_cond(k).*log2(ts_cond(k))/log2(length(transition))];
    end
    ent_sal = sum(ent_sal)*-1;
    ent_cond = sum(ent_cond)*-1;
    
    ts_sal = ts_sal(dominant_ts);
    ts_cond = ts_cond(dominant_ts);

    %iterate thru shuffle trials 
    sylpool = [trans_sal trans_cond];
    entdiff = NaN(shufftrials,1);
    tsdiff = NaN(shufftrials,1);
    for i = 1:shufftrials
        shuffpool = sylpool(randperm(length(sylpool)));
        samp1 = shuffpool(1:length(trans_sal));
        samp2 = shuffpool(length(trans_sal)+1:end);
        
        ts1 = [];ts2 = [];
        for k = 1:length(transition)
            ts1 = [ts1; length(strfind(samp1,modified_motifs(k)))./length(samp1)];
            ts2 = [ts2; length(strfind(samp2,modified_motifs(k)))./length(samp2)];
        end
        
        tsdiff(i) = abs(ts1(1)-ts2(1));
        
        ent1 = [];ent2 = [];
        for n = 1:length(transition)
            ent1 = [ent1 ts1(n).*log2(ts1(n))/log2(length(transition))];
            ent2 = [ent2 ts2(n).*log2(ts2(n))/log2(length(transition))];
        end
        ent1 = sum(ent1)*-1;
        ent2 = sum(ent2)*-1;
        
        entdiff(i) = abs(ent1-ent2);
    end
    tspval = length(find(tsdiff>=abs(ts_sal-ts_cond)))/shufftrials;
    entpval= length(find(entdiff>=abs(ent_sal-ent_cond)))/shufftrials;
