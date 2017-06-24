%align smoothed amplitude waveform by syllable in motif 
fs = 32000;
ind = 3;
maxbefore2 = max(arrayfun(@(x) floor(x.syllons(ind)*fs),motif_abcdeeerww_8_16_2011_IEM));
maxafter2 = max(arrayfun(@(x) length(x.smtmp)-floor(x.syllons(ind)*fs),motif_abcdeeerww_8_16_2011_IEM));
maxbefore1 = max(arrayfun(@(x) floor(x.syllons(ind)*fs),motif_abcdeeerww_8_16_2011_saline));
maxafter1 = max(arrayfun(@(x) length(x.smtmp)-floor(x.syllons(ind)*fs),motif_abcdeeerww_8_16_2011_saline));
maxbefore = max([maxbefore1 maxbefore2]);
maxafter = max([maxafter1 maxafter2]);

sm = arrayfun(@(x) [NaN(maxbefore-floor(x.syllons(ind)*fs),1);log10(evsmooth(x.smtmp,fs,'','','',5));NaN(maxafter-(length(x.smtmp)-floor(x.syllons(ind)*fs)),1)],motif_abcdeeerww_8_16_2011_IEM,'unif',0);
sm = cellfun(@(x) x-min(x),sm,'unif',0);
sm = cellfun(@(x) x/max(x),sm,'unif',0);
sm = cell2mat(sm);


figure;hold on;
plot([0:size(sm,1)-1]/fs,nanmean(sm,2),'r','linewidth',2);hold on;
plot([0:size(sm,1)-1]/fs,nanmean(sm,2)+nanstderr(sm,2),'r','linewidth',2);hold on;
plot([0:size(sm,1)-1]/fs,nanmean(sm,2)-nanstderr(sm,2),'r','linewidth',2);hold on;

sm = arrayfun(@(x) [NaN(maxbefore-floor(x.syllons(ind)*fs),1);log10(evsmooth(x.smtmp,fs,'','','',5));NaN(maxafter-(length(x.smtmp)-floor(x.syllons(ind)*fs)),1)],motif_abcdeeerww_8_16_2011_saline,'unif',0);
sm = cellfun(@(x) x-min(x),sm,'unif',0);
sm = cellfun(@(x) x/max(x),sm,'unif',0);
sm = cell2mat(sm);

plot([0:size(sm,1)-1]/fs,nanmean(sm,2),'k','linewidth',2);hold on;
plot([0:size(sm,1)-1]/fs,nanmean(sm,2)+nanstderr(sm,2),'k','linewidth',2);hold on;
plot([0:size(sm,1)-1]/fs,nanmean(sm,2)-nanstderr(sm,2),'k','linewidth',2);hold on;

xlabel('seconds');
ylabel('normalized amplitude');
set(gca,'fontweight','bold');
xlim([0.1 0.4])
