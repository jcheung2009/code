function jc_plotboutvals(boutinfo,marker,linecolor,tbshift)
%boutinfo from jc_findbout
%remember to change numsylls
numsylls = 1; %number of syllables measured for spectral features
plotintronotes = input('plot intro notes measurements:','s');
  xticklabel = [0:2:16];
    xtick = xticklabel*3600;
    xticklabel = arrayfun(@(x) num2str(x),xticklabel,'unif',0);
%% plot number of motifs in bout over time
% tb_nummotif = jc_tb([boutinfo(:).datenm]',7,0);
% nummotifs = [boutinfo(:).nummotifs]';
% fignum = input('figure for bout measurements:');
% figure(fignum);hold on;
% if plotintronotes == 'y'
%     subtightplot(3,1,1,0.07,0.05,0.08);hold on;
% else
%     subtightplot(2,1,1,0.07,0.05,0.08);hold on;
% end
% plot(tb_nummotif,nummotifs,marker);
% % runningaverage = jc_RunningAverage(nummotifs,10);
% % fill([tb_nummotif' fliplr(tb_nummotif')],[runningaverage(:,1)'-runningaverage(:,2)',...
% %     fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,'EdgeColor','none','FaceAlpha',0.5);
% ylabel('Number of motifs in bout');
% title('Number of motifs in bout');
% set(gca,'xtick',xtick,'xticklabel',xticklabel);
%     xlabel('');

%% plot number of intronotes in bout over time

% if plotintronotes == 'y'
%     tb_numintro = jc_tb([boutinfo(:).datenm]',7,0);
%     numintro = [boutinfo(:).numintro]';
%     subtightplot(3,1,2,0.07,0.05,0.08);hold on;
%     plot(tb_numintro,numintro,marker);
% %     runningaverage = jc_RunningAverage(numintro,10);
% %     fill([tb_numintro' fliplr(tb_numintro')],[runningaverage(:,1)'-runningaverage(:,2)',...
% %         fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,'EdgeColor','none','FaceAlpha',0.5);
%     ylabel('Number of intro notes in bout');
%     set(gca,'xtick',xtick,'xticklabel',xticklabel);
%     xlabel('');
%     title('Number of intro notes in bout');
% end


%% plot singing rate
tb_singingrate = jc_tb([boutinfo(:).datenm]',7,0);

 if tbshift == -1
        tb_singingrate = tb_singingrate - (24*3600);
        xticklabel = [-24:2:38];
 elseif tbshift == 1
     tb_singingrate = tb_singingrate + (24*3600);
      xticklabel = [-24:2:38];
 elseif tbshift == 0
     xticklabel = [-24:2:38];
 end
 xtick = xticklabel*3600;
 xticklabel = arrayfun(@(x) num2str(x),xticklabel,'unif',0);

numseconds = tb_singingrate(end)-tb_singingrate(1);
timewindow = 1800; %half hr in seconds
jogsize = 900;%15 minutes
numtimewindows = 2*floor(numseconds/timewindow)-1;
if numtimewindows < 0
    numtimewindows = 1;
end

timept1 = tb_singingrate(1);
numsongs = [];
for i = 1:numtimewindows
    timept2 = timept1+timewindow;
    numsongs(i,:) = [timept1+jogsize length(find(tb_singingrate>= timept1 & tb_singingrate < timept2))];
    timept1 = timept1+jogsize;
end
if numtimewindows == 1
    numsongs = [numsongs; timept1+jogsize 0];
end

% if plotintronotes == 'y'
%     subtightplot(3,1,3,0.07,0.05,0.08);hold on;
% else
%     subtightplot(2,1,2,0.07,0.05,0.08);hold on;
% end
fignum = input('fig number for singing rate:');
figure(fignum);hold on;
bar(numsongs(:,1),numsongs(:,2),1,'edgecolor','none','facecolor',linecolor);
h=findobj(gca,'Type','patch');set(h,'facealpha',0.5);
set(gca,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
    xlabel('Time in hours since 7 AM');
ylabel('Number of songs per hour');
title('Singing Rate')

%% plot within bout pitch,volume,entropy, and tempo patterns
tempopattern = input('plot bout pattern?:','s');
if tempopattern == 'y'
    fignum = input('figure for spectral and tempo patterns within bouts:');
    figure(fignum);hold on;
    maxnummotifs = max(arrayfun(@(x) x.nummotifs,boutinfo));
    pitchpattern = [];
    for i = 1:length(boutinfo)
        for ii = 1:numsylls
            pitchpattern = [pitchpattern [boutinfo(i).boutpitch(:,ii)/boutinfo(i).boutpitch(1,ii);...
                NaN(maxnummotifs-boutinfo(i).nummotifs,1)]];%normalize by syllable in first motif, concatenates data for all syllables into one set
        end
    end

    subtightplot(4,1,1,0.07,0.05,0.1);hold on;
    fill([1:maxnummotifs fliplr(1:maxnummotifs)],[nanmean(pitchpattern,2)'-nanstderr(pitchpattern,2)',...
    fliplr(nanmean(pitchpattern,2)'+nanstderr(pitchpattern,2)')],linecolor,'edgecolor','none',...
    'FaceAlpha',0.5);

    xlabel('Motif position of target syllable within bout');
    ylabel({'Normalized Frequency'});
    title('Pitch changes within bout (running average with SEM)');

    volumepattern = [];
    for i = 1:length(boutinfo)
        for ii = 1:numsylls
            volumepattern = [volumepattern [log(boutinfo(i).boutvolume(:,ii))/log(boutinfo(i).boutvolume(1,ii));...
                NaN(maxnummotifs-boutinfo(i).nummotifs,1)]];%normalize by syllable in first motif
        end
    end

    subtightplot(4,1,2,0.07,0.05,0.1);hold on;
    fill([1:maxnummotifs fliplr(1:maxnummotifs)],[nanmean(volumepattern,2)'-nanstderr(volumepattern,2)',...
    fliplr(nanmean(volumepattern,2)'+nanstderr(volumepattern,2)')],linecolor,'edgecolor','none',...
    'FaceAlpha',0.5);

    xlabel('Motif position of target syllable within bout');
    ylabel({'Normalized Volume'});
    title('Volume changes within bout (running average with SEM)');

    entropypattern = [];
    for i = 1:length(boutinfo)
        for ii = 1:numsylls
            entropypattern = [entropypattern [boutinfo(i).boutentropy(:,ii)/boutinfo(i).boutentropy(1,ii);...
                NaN(maxnummotifs-boutinfo(i).nummotifs,1)]];%normalize by syllable in first motif
        end
    end

    subtightplot(4,1,3,0.07,0.05,0.1);hold on;
    fill([1:maxnummotifs fliplr(1:maxnummotifs)],[nanmean(entropypattern,2)'-nanstderr(entropypattern,2)',...
    fliplr(nanmean(entropypattern,2)'+nanstderr(entropypattern,2)')],linecolor,'edgecolor','none',...
    'FaceAlpha',0.5);

    xlabel('Motif position of target syllable within bout');
    ylabel({'Normalized Entropy'});
    title('Entropy changes within bout (running average with SEM)');

    tempopattern = [];
    for i = 1:length(boutinfo)
        tempopattern = [tempopattern [boutinfo(i).bouttempo/boutinfo(i).bouttempo(1);NaN(maxnummotifs-boutinfo(i).nummotifs,1)]];
    end
    subtightplot(4,1,4,0.07,0.05,0.1);hold on;
    fill([1:maxnummotifs fliplr(1:maxnummotifs)],[nanmean(tempopattern,2)'-nanstderr(tempopattern,2)',...
        fliplr(nanmean(tempopattern,2)'+nanstderr(tempopattern,2)')],linecolor,'edgecolor','none',...
        'facealpha',0.5);
    xlabel('Motif position of target syllable within bout');
    ylabel({'Normalized motif duration'});
    title('Tempo changes within bout (running average with SEM)');
    end
end
    
    
    