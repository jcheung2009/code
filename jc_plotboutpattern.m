function jc_plotboutpattern(boutinfo_sal,boutinfo_cond,linecolor,excludewashin,startpt,matchtm,motif)

tb_sal = jc_tb([boutinfo_sal(:).datenm]',7,0);
tb_cond = jc_tb([boutinfo_cond(:).datenm]',7,0);

if excludewashin == 1 & ~isempty(startpt)
    ind = find(tb_cond < startpt);
    boutinfo_cond(ind) = [];
    tb_cond(ind) = [];
elseif excludewashin == 1
    ind = find(tb_cond<tb_sal(end)+1800); %exclude first half hour of wash in 
    boutinfo_cond(ind) = [];
    tb_cond(ind) = [];
end

if ~isempty(matchtm)
    indsal = find(tb_sal>=tb_cond(1) & tb_sal <= tb_cond(end)); 
    tb_sal = tb_sal(indsal);
    boutinfo_sal = boutinfo_sal(indsal);
end 


%% plot within bout pitch,volume,entropy, and tempo patterns
numsylls = length(motif);
maxnummotifs1 = max(arrayfun(@(x) x.nummotifs,boutinfo_sal));
pitchpattern1 = [];
for i = 1:length(boutinfo_sal)
    for ii = 1:numsylls
        pitchpattern1 = [pitchpattern1 [boutinfo_sal(i).boutpitch(:,ii)/boutinfo_sal(i).boutpitch(1,ii);...
            NaN(maxnummotifs1-boutinfo_sal(i).nummotifs,1)]];%normalize by syllable in first motif, concatenates data for all syllables into one set
    end
end
maxnummotifs2 = max(arrayfun(@(x) x.nummotifs,boutinfo_cond));
pitchpattern2 = [];
for i = 1:length(boutinfo_cond)
    for ii = 1:numsylls
        pitchpattern2 = [pitchpattern2 [boutinfo_cond(i).boutpitch(:,ii)/boutinfo_cond(i).boutpitch(1,ii);...
            NaN(maxnummotifs2-boutinfo_cond(i).nummotifs,1)]];%normalize by syllable in first motif, concatenates data for all syllables into one set
    end
end

figure;hold on;
subtightplot(4,1,1,0.07,0.05,0.1);hold on;
fill([1:maxnummotifs1 fliplr(1:maxnummotifs1)],[nanmean(pitchpattern1,2)'-nanstderr(pitchpattern1,2)',...
fliplr(nanmean(pitchpattern1,2)'+nanstderr(pitchpattern1,2)')],'k','edgecolor','none',...
'FaceAlpha',0.5);
fill([1:maxnummotifs2 fliplr(1:maxnummotifs2)],[nanmean(pitchpattern2,2)'-nanstderr(pitchpattern2,2)',...
fliplr(nanmean(pitchpattern2,2)'+nanstderr(pitchpattern2,2)')],linecolor,'edgecolor','none',...
'FaceAlpha',0.5);
ylabel({'Normalized Frequency'});
set(gca,'fontweight','bold');
title('Pitch changes within bout (running average with SEM)');

volumepattern1 = [];
for i = 1:length(boutinfo_sal)
    for ii = 1:numsylls
        volumepattern1 = [volumepattern1 [log(boutinfo_sal(i).boutvolume(:,ii))/log(boutinfo_sal(i).boutvolume(1,ii));...
            NaN(maxnummotifs1-boutinfo_sal(i).nummotifs,1)]];%normalize by syllable in first motif
    end
end
volumepattern2 = [];
for i = 1:length(boutinfo_cond)
    for ii = 1:numsylls
        volumepattern2 = [volumepattern2 [log(boutinfo_cond(i).boutvolume(:,ii))/log(boutinfo_cond(i).boutvolume(1,ii));...
            NaN(maxnummotifs2-boutinfo_cond(i).nummotifs,1)]];%normalize by syllable in first motif
    end
end

subtightplot(4,1,2,0.07,0.05,0.1);hold on;
fill([1:maxnummotifs1 fliplr(1:maxnummotifs1)],[nanmean(volumepattern1,2)'-nanstderr(volumepattern1,2)',...
fliplr(nanmean(volumepattern1,2)'+nanstderr(volumepattern1,2)')],'k','edgecolor','none',...
'FaceAlpha',0.5);
fill([1:maxnummotifs2 fliplr(1:maxnummotifs2)],[nanmean(volumepattern2,2)'-nanstderr(volumepattern2,2)',...
fliplr(nanmean(volumepattern2,2)'+nanstderr(volumepattern2,2)')],linecolor,'edgecolor','none',...
'FaceAlpha',0.5);
ylabel({'Normalized Volume'});
set(gca,'fontweight','bold');
title('Volume changes within bout (running average with SEM)');

entropypattern1 = [];
for i = 1:length(boutinfo_sal)
    for ii = 1:numsylls
        entropypattern1 = [entropypattern1 [boutinfo_sal(i).boutentropy(:,ii)/boutinfo_sal(i).boutentropy(1,ii);...
            NaN(maxnummotifs1-boutinfo_sal(i).nummotifs,1)]];%normalize by syllable in first motif
    end
end
entropypattern2 = [];
for i = 1:length(boutinfo_cond)
    for ii = 1:numsylls
        entropypattern2 = [entropypattern2 [boutinfo_cond(i).boutentropy(:,ii)/boutinfo_cond(i).boutentropy(1,ii);...
            NaN(maxnummotifs2-boutinfo_cond(i).nummotifs,1)]];%normalize by syllable in first motif
    end
end

subtightplot(4,1,3,0.07,0.05,0.1);hold on;
fill([1:maxnummotifs1 fliplr(1:maxnummotifs1)],[nanmean(entropypattern1,2)'-nanstderr(entropypattern1,2)',...
fliplr(nanmean(entropypattern1,2)'+nanstderr(entropypattern1,2)')],'k','edgecolor','none',...
'FaceAlpha',0.5);
fill([1:maxnummotifs2 fliplr(1:maxnummotifs2)],[nanmean(entropypattern2,2)'-nanstderr(entropypattern2,2)',...
fliplr(nanmean(entropypattern2,2)'+nanstderr(entropypattern2,2)')],linecolor,'edgecolor','none',...
'FaceAlpha',0.5);
ylabel({'Normalized Entropy'});
set(gca,'fontweight','bold');
title('Entropy changes within bout (running average with SEM)');

tempopattern1 = [];
for i = 1:length(boutinfo_sal)
    tempopattern1 = [tempopattern1 [boutinfo_sal(i).bouttempo/boutinfo_sal(i).bouttempo(1);NaN(maxnummotifs1-boutinfo_sal(i).nummotifs,1)]];
end
tempopattern2 = [];
for i = 1:length(boutinfo_cond)
    tempopattern2 = [tempopattern2 [boutinfo_cond(i).bouttempo/boutinfo_cond(i).bouttempo(1);NaN(maxnummotifs2-boutinfo_cond(i).nummotifs,1)]];
end
subtightplot(4,1,4,0.07,0.05,0.1);hold on;
fill([1:maxnummotifs1 fliplr(1:maxnummotifs1)],[nanmean(tempopattern1,2)'-nanstderr(tempopattern1,2)',...
    fliplr(nanmean(tempopattern1,2)'+nanstderr(tempopattern1,2)')],'k','edgecolor','none',...
    'facealpha',0.5);
fill([1:maxnummotifs2 fliplr(1:maxnummotifs2)],[nanmean(tempopattern2,2)'-nanstderr(tempopattern2,2)',...
    fliplr(nanmean(tempopattern2,2)'+nanstderr(tempopattern2,2)')],linecolor,'edgecolor','none',...
    'facealpha',0.5);
xlabel('Motif position of target syllable within bout');
ylabel({'Normalized motif duration'});
set(gca,'fontweight','bold');
title('Tempo changes within bout (running average with SEM)');

%     fignum = input('figure for plotting pitch by bout:');
%     figure(fignum);hold on;
%     cmap = hsv(length(boutinfo_sal));
%     for ii = 1:numsylls
%         ind = 0;
%         h = subtightplot(numsylls,1,ii,0.07,0.05,0.1);hold on;
%         for i = 1:length(boutinfo_sal)
%             indn = ind+length(boutinfo_sal(i).boutpitch(:,ii));
%             plot(h,[ind+1:indn],boutinfo_sal(i).boutpitch(:,ii),'.-','markersize',8,'color',cmap(i,:));
%             ind = indn;
%         end
%     end


allpitch1 = [];
firstpitch1 = [];
lastpitch1 = [];
allpitch2 = [];
firstpitch2 = [];
lastpitch2 = [];
for i = 1:numsylls
    allpitch = arrayfun(@(x) x.boutpitch(:,i),boutinfo_sal,'unif',0)';
    allpitch = cell2mat(allpitch);
    firstpitch = arrayfun(@(x) x.boutpitch(1,i),boutinfo_sal,'unif',0)';
    firstpitch = cell2mat(firstpitch);
    firstpitch1 = [firstpitch1; (firstpitch-mean(allpitch))/std(allpitch)];
    lastpitch = arrayfun(@(x) x.boutpitch(end,i),boutinfo_sal,'unif',0)';
    lastpitch = cell2mat(lastpitch);
    lastpitch1 = [lastpitch1; (lastpitch-mean(allpitch))/std(allpitch)];
    allpitch1 = [allpitch1; (allpitch-mean(allpitch))/std(allpitch)];
    
    allpitch = arrayfun(@(x) x.boutpitch(:,i),boutinfo_cond,'unif',0)';
    allpitch = cell2mat(allpitch);
    firstpitch = arrayfun(@(x) x.boutpitch(1,i),boutinfo_cond,'unif',0)';
    firstpitch = cell2mat(firstpitch);
    firstpitch2 = [firstpitch2; (firstpitch-mean(allpitch))/std(allpitch)];
    lastpitch = arrayfun(@(x) x.boutpitch(end,i),boutinfo_cond,'unif',0)';
    lastpitch = cell2mat(lastpitch);
    lastpitch2 = [lastpitch2; (lastpitch-mean(allpitch))/std(allpitch)];
    allpitch2 = [allpitch2; (allpitch-mean(allpitch))/std(allpitch)];
end

figure;hold on;
h = subtightplot(2,1,1,0.15,0.07,0.1);hold on;
[n b] = hist(allpitch1,[floor(min(allpitch1)):0.1:ceil(max(allpitch1))]);
stairs(b,n/sum(n),'k','linewidth',2);
[n b] = hist(firstpitch1,[floor(min(firstpitch1)):0.1:ceil(max(firstpitch1))]);
stairs(b,n/sum(n),'r','linewidth',2);
[n b] = hist(lastpitch1,[floor(min(lastpitch1)):0.1:ceil(max(lastpitch1))]);
stairs(b,n/sum(n),'b','linewidth',2);
[h1 p] = ttest2(allpitch1,firstpitch1);
legend('all','first','last');
xlabel('pitch (z-score)');
ylabel('probability');
set(h,'fontweight','bold');

if p <= 0.05
    str = ['{\color{red}p=',num2str(p),'}'];
else
    str = ['{\color{black}p=',num2str(p),'}'];
end
xmin = get(h,'xlim');
ymax = get(h,'ylim');
set(h,'xlim',xmin,'ylim',ymax);
text(xmin(1),ymax(2),str);
title(h,'saline');

h2 = subtightplot(2,1,2,0.15,0.07,0.1);hold on;
[n b] = hist(allpitch2,[floor(min(allpitch2)):0.1:ceil(max(allpitch2))]);
stairs(b,n/sum(n),'k','linewidth',2);
[n b] = hist(firstpitch2,[floor(min(firstpitch2)):0.1:ceil(max(firstpitch2))]);
stairs(b,n/sum(n),'r','linewidth',2);
[n b] = hist(lastpitch2,[floor(min(lastpitch2)):0.1:ceil(max(lastpitch2))]);
stairs(b,n/sum(n),'b','linewidth',2);
[h1 p] = ttest2(allpitch2,firstpitch2);

xlabel('pitch (z-score)');
ylabel('probability');
set(h2,'fontweight','bold');

if p <= 0.05
    str = ['{\color{red}p=',num2str(p),'}'];
else
    str = ['{\color{black}p=',num2str(p),'}'];
end
xmin = get(h2,'xlim');
ymax = get(h2,'ylim');
set(h2,'xlim',xmin,'ylim',ymax);
text(xmin(1),ymax(2),str);
title(h2,'drug');
