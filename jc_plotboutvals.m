function jc_plotboutvals(boutinfo,marker,linecolor,tbshift,fignum)
%boutinfo from jc_findbout
%remember to change numsylls
%numsylls = number of syllables measured for spectral features

% plotintronotes = input('plot intro notes measurements:','s');
% xticklabel = [0:2:16];
% xtick = xticklabel*3600;
% xticklabel = arrayfun(@(x) num2str(x),xticklabel,'unif',0);
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
nummotifs = [boutinfo(:).nummotifs]';

 if ~isempty(tbshift)
        tb_singingrate = tb_singingrate+(tbshift*24*3600);
 end

numseconds = tb_singingrate(end)-tb_singingrate(1);
timewindow = 3600; %half hr in seconds
jogsize = 900;%15 minutes
numtimewindows = 2*floor(numseconds/timewindow)-1;
if numtimewindows < 0
    numtimewindows = 1;
end

timept1 = tb_singingrate(1);
numsongs = [];
nummotifs_per_window = [];
for i = 1:numtimewindows
    timept2 = timept1+timewindow;
    ind = find(tb_singingrate >= timept1 & tb_singingrate < timept2);
    numsongs(i,:) = [timept1+jogsize length(ind)];
    nummotifs_per_window(i,:) = [timept1+jogsize  sum(nummotifs(ind))];
    timept1 = timept1+jogsize;
end
if numtimewindows == 1
    numsongs = [numsongs; timept1+jogsize 0];
    nummotifs_per_window = [nummotifs_per_window; timept1+jogsize 0];
end

if isempty(fignum)
    fignum = input('fig number for singing rate:');
end
figure(fignum);hold on;
h1 = subtightplot(2,1,1,[0.08 0.08],0.08,0.1);hold on;
plot(numsongs(:,1),numsongs(:,2),linecolor);
dataob = get(h1,'children');
xd = get(dataob,'xdata');
if iscell(xd)
    xd = cell2mat(xd');
end
xlim = [min(xd) max(xd)];
xtick = [xlim(1):24*3600:xlim(2)];
xticklabel = round(xtick/3600);
set(h1,'xlim',xlim,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
xlabel(h1,'Time in hours since 7 AM');
ylabel(h1,'Number of songs per hour');
title(h1,'Singing Rate')
h2 = subtightplot(2,1,2,[0.08 0.08],0.08,0.1);hold on;
plot(nummotifs_per_window(:,1),nummotifs_per_window(:,2),linecolor);
set(h2,'xlim',xlim,'xtick',xtick,'xticklabel',xticklabel,'fontweight','bold');
xlabel(h2,'Time in hours since 7 AM');
ylabel(h2,'Number of motifs per hour');






    

    
    
    