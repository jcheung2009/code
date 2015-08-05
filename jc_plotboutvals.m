function jc_plotboutvals(boutinfo,marker,linecolor)
%boutinfo from jc_findbout
%remember to change numsylls
numsylls = 1; %number of syllables measured for spectral features

%% plot number of motifs in bout over time
tb_nummotif = jc_tb([boutinfo(:).datenm]',7,0);
nummotifs = [boutinfo(:).nummotifs]';
fignum = input('figure for number of intro notes, motifs, singing rate in bout:');
figure(fignum);hold on;
subtightplot(3,1,1,0.07);hold on;
plot(tb_nummotif,nummotifs,marker);
runningaverage = jc_RunningAverage(nummotifs,10);
fill([tb_nummotif' fliplr(tb_nummotif')],[runningaverage(:,1)'-runningaverage(:,2)',...
    fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,'EdgeColor','none','FaceAlpha',0.5);
ylabel('Number of motifs in bout');
xlabel('Time (seconds since lights on)');
title('Number of motifs in bout with running average and SEM');

%% plot number of intronotes in bout over time
tb_numintro = jc_tb([boutinfo(:).datenm]',7,0);
numintro = [boutinfo(:).numintro]';
subtightplot(3,1,2,0.07);hold on;
plot(tb_numintro,numintro,marker);
runningaverage = jc_RunningAverage(numintro,10);
fill([tb_numintro' fliplr(tb_numintro')],[runningaverage(:,1)'-runningaverage(:,2)',...
    fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,'EdgeColor','none','FaceAlpha',0.5);
ylabel('Number of intro notes in bout');
xlabel('Time (seconds since lights on)');
title('Number of intro notes in bout with running average and SEM');

%% plot singing rate
tb_singingrate = jc_tb([boutinfo(:).datenm]',7,0);
numseconds = tb_singingrate(end)-tb_singingrate(1);
timewindow = 3600; %1 hr in seconds
jogsize = 1800;%half an hour in seconds
numtimewindows = 2*floor(numseconds/timewindow)-1;
timept1 = tb_singingrate(1);
numsongs = [];
for i = 1:numtimewindows
    timept2 = timept1+timewindow;
    numsongs(i,:) = [timept1+jogsize length(find(tb_singingrate>= timept1 & tb_singingrate < timept2))];
    timept1 = timept1+jogsize;
end
subtightplot(3,1,3,0.07);hold on;
bar(numsongs(:,1),numsongs(:,2),1,'edgecolor','none','facecolor',linecolor);
h=findobj(gca,'Type','patch');set(h,'facealpha',0.5);
xlabel('Time (seconds since lights on)');
ylabel('Number of songs per hour');
title('Singing Rate')

%% plot within bout pitch,volume,entropy, and tempo patterns
fignum = input('figure for spectral and tempo patterns within bouts:');
figure(fignum);hold on;
maxnummotifs = max(arrayfun(@(x) x.nummotifs,boutinfo));
pitchpattern = cell(numsylls,1);
for i = 1:length(boutinfo)
    for ii = 1:numsylls
        pitchpattern{ii} = [pitchpattern{ii} [boutinfo(i).boutpitch(:,ii)/boutinfo(i).boutpitch(1,ii);...
            NaN(maxnummotifs-boutinfo(i).nummotifs,1)]];%normalize by syllable in first motif
    end
end
subtightplot(4,1,1,0.07);hold on;
for i = 1:length(pitchpattern)
    fill([1:maxnummotifs fliplr(1:maxnummotifs)],[nanmean(pitchpattern{i},2)'-nanstderr(pitchpattern{i},2)',...
        fliplr(nanmean(pitchpattern{i},2)'+nanstderr(pitchpattern{i},2)')],linecolor,'edgecolor','none',...
        'FaceAlpha',0.5);
end
xlabel('Motif position of target syllable within bout');
ylabel('Frequency (normalized to first syllable)');
title('Pitch changes within bout (running average with SEM)');

volumepattern = cell(numsylls,1);
for i = 1:length(boutinfo)
    for ii = 1:numsylls
        volumepattern{ii} = [volumepattern{ii} [log(boutinfo(i).boutvolume(:,ii))/log(boutinfo(i).boutvolume(1,ii));...
            NaN(maxnummotifs-boutinfo(i).nummotifs,1)]];%normalize by syllable in first motif
    end
end
subtightplot(4,1,2,0.07);hold on;
for i = 1:length(volumepattern)
    fill([1:maxnummotifs fliplr(1:maxnummotifs)],[nanmean(volumepattern{i},2)'-nanstderr(volumepattern{i},2)',...
        fliplr(nanmean(volumepattern{i},2)'+nanstderr(volumepattern{i},2)')],linecolor,'edgecolor','none',...
        'FaceAlpha',0.5);
end
xlabel('Motif position of target syllable within bout');
ylabel('Volume (normalized to first syllable)');
title('Volume changes within bout (running average with SEM)');
        
entropypattern = cell(numsylls,1);
for i = 1:length(boutinfo)
    for ii = 1:numsylls
        entropypattern{ii} = [entropypattern{ii} [boutinfo(i).boutentropy(:,ii)/boutinfo(i).boutentropy(1,ii);...
            NaN(maxnummotifs-boutinfo(i).nummotifs,1)]];%normalize by syllable in first motif
    end
end
subtightplot(4,1,3,0.07);hold on;
for i = 1:length(entropypattern)
    fill([1:maxnummotifs fliplr(1:maxnummotifs)],[nanmean(entropypattern{i},2)'-nanstderr(entropypattern{i},2)',...
        fliplr(nanmean(entropypattern{i},2)'+nanstderr(entropypattern{i},2)')],linecolor,'edgecolor','none',...
        'FaceAlpha',0.5);
end
xlabel('Motif position of target syllable within bout');
ylabel('Entropy (normalized to first syllable)');
title('Entropy changes within bout (running average with SEM)');
    
tempopattern = [];
for i = 1:length(boutinfo)
    tempopattern = [tempopattern [boutinfo(i).bouttempo/boutinfo(i).bouttempo(1);NaN(maxnummotifs-boutinfo(i).nummotifs,1)]];
end
subtightplot(4,1,4,0.07);hold on;
fill([1:maxnummotifs fliplr(1:maxnummotifs)],[nanmean(tempopattern,2)'-nanstderr(tempopattern,2)',...
    fliplr(nanmean(tempopattern,2)'+nanstderr(tempopattern,2)')],linecolor,'edgecolor','none',...
    'facealpha',0.5);
xlabel('Motif position of target syllable within bout');
ylabel('Motif duration (normalized to first motif)');
title('Tempo changes within bout (running average with SEM)');
    
    
    
    