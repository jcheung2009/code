%align smoothed amplitude waveform by syllable in motif 
fs = 32000;
ind = 1;
m1 = motif_abc_saline_4_15_2018;
m2 = motif_abc_naspm_4_16_2018;
maxbefore2 = max(arrayfun(@(x) floor(x.syllons(ind)*fs),m1));
maxafter2 = max(arrayfun(@(x) length(x.smtmp)-floor(x.syllons(ind)*fs),m1));
maxbefore1 = max(arrayfun(@(x) floor(x.syllons(ind)*fs),m2));
maxafter1 = max(arrayfun(@(x) length(x.smtmp)-floor(x.syllons(ind)*fs),m2));
maxbefore = max([maxbefore1 maxbefore2]);
maxafter = max([maxafter1 maxafter2]);

sm = arrayfun(@(x) [NaN(maxbefore-floor(x.syllons(ind)*fs),1);log10(evsmooth(x.smtmp,fs,'','','',5));NaN(maxafter-(length(x.smtmp)-floor(x.syllons(ind)*fs)),1)],m2,'unif',0);
sm = cellfun(@(x) x-min(x),sm,'unif',0);
sm = cellfun(@(x) x/max(x),sm,'unif',0);
sm = cell2mat(sm);


figure;hold on;
subtightplot(3,1,3,0.07,0.08,0.15);hold on;
plot([0:size(sm,1)-1]/fs,nanmean(sm,2),'r','linewidth',2);hold on;
plot([0:size(sm,1)-1]/fs,nanmean(sm,2)+nanstderr(sm,2),'r','linewidth',2);hold on;
plot([0:size(sm,1)-1]/fs,nanmean(sm,2)-nanstderr(sm,2),'r','linewidth',2);hold on;

sm = arrayfun(@(x) [NaN(maxbefore-floor(x.syllons(ind)*fs),1);log10(evsmooth(x.smtmp,fs,'','','',5));NaN(maxafter-(length(x.smtmp)-floor(x.syllons(ind)*fs)),1)],m1,'unif',0);
sm = cellfun(@(x) x-min(x),sm,'unif',0);
sm = cellfun(@(x) x/max(x),sm,'unif',0);
sm = cell2mat(sm);

plot([0:size(sm,1)-1]/fs,nanmean(sm,2),'k','linewidth',2);hold on;
plot([0:size(sm,1)-1]/fs,nanmean(sm,2)+nanstderr(sm,2),'k','linewidth',2);hold on;
plot([0:size(sm,1)-1]/fs,nanmean(sm,2)-nanstderr(sm,2),'k','linewidth',2);hold on;

xlabel('seconds');
ylabel('normalized amplitude');
set(gca,'fontweight','bold');

ylim([0 1]);

[~,ind1] = min([m1(:).motifdur]-mean([m1(:).motifdur]));
[~,ind2] = min([m2(:).motifdur]-mean([m2(:).motifdur]));

smtmp1 = m1(ind1).smtmp;
smtmp2 = m2(ind2).smtmp;
syllons1 = m1(ind1).syllons;
sylloffs1 = m1(ind1).sylloffs;
syllons2 = m2(ind2).syllons;
sylloffs2 = m2(ind2).sylloffs;
filtsong1 = bandpass(smtmp1,fs,500,10000,'hanningffir');
filtsong2 = bandpass(smtmp2,fs,500,10000,'hanningffir');
subtightplot(3,1,1,0.07,0.08,0.15);hold on;ax1 = gca;
jc_spectrogram(filtsong1,fs,1,ax1);hold on;ylim([500 10000]);
plot([syllons1 syllons1],[500 10000],'g',[sylloffs1 sylloffs1],[500 10000],'g','linewidth',4);hold on;

subtightplot(3,1,2,0.07,0.08,0.15);hold on;ax2=gca;
jc_spectrogram(filtsong2,fs,1,ax2);ylim([500 10000]);
plot([syllons2 syllons2],[500 10000],'g',[sylloffs2 sylloffs2],[500 10000],'g','linewidth',4);hold on;
x = get(ax1,'xlim');
set(ax2,'xlim',x);