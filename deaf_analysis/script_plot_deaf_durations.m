%% plot distribution of gap and syll durations post deaf: saline vs treatment
ff = load_batchf('batchsal_postdf');
ff2 = load_batchf('batchnaspm_postdf');

salinegaps = [];
salinedurs = [];
for i = 1:length(ff)
    load(['analysis/data_structures/durations_',ff(i).name]);
    data = eval(['durations_',ff(i).name]);
    salinegaps = [salinegaps; cell2mat(arrayfun(@(x) x.gaps, data,'un',0)')];
    salinedurs = [salinegaps; cell2mat(arrayfun(@(x) x.durations, data,'un',0)')];
end

treatgaps = [];
treatdurs = [];
for i = 1:length(ff2)
    load(['analysis/data_structures/durations_',ff2(i).name]);
    data = eval(['durations_',ff2(i).name]);
    treatgaps = [treatgaps; cell2mat(arrayfun(@(x) x.gaps, data,'un',0)')];
    treatdurs = [treatgaps; cell2mat(arrayfun(@(x) x.durations, data,'un',0)')];
end

id = find(salinegaps > 1000);
salinegaps(id) = [];
id = find(salinedurs > 1000);
salinedurs(id) = [];
id = find(treatgaps > 1000);
treatgaps(id) = [];
id = find(treatdurs > 1000);
treatdurs(id) = [];

[n b] = hist(salinegaps,100);
figure;stairs(b,n/sum(n),'k','linewidth',2);hold on;
[n b] = hist(treatgaps,100);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
title('gaps post deaf');
legend({'saline','naspm'});

[n b] = hist(salinedurs,100);
figure;stairs(b,n/sum(n),'k','linewidth',2);hold on;
[n b] = hist(treatdurs,100);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
title('syll durs post deaf');
legend({'saline','naspm'});



