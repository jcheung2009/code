function jc_plotfig(fv_syll,marker,linecolor)
%invect is structure from jc_getfvals2 generated from jc_findwnote5
%plots raw points, running average, running CV with SEM
%clr = 'k', color for points and lines

% tbinvect = jc_tb(invect,7,0);
% fignum = input('figure number:');
% subplotnum = input('subplot number for raw points:');
% 
% figure(fignum);
% subtightplot(numplots,3,subplotnum,0.05);hold on;
% plot(tbinvect,invect(:,2),'.','color',clr);3_13_2012_iem1
% ylabel('Frequency (Hz)');xlabel('Time (seconds since lights on)');
% 
% runBS = jc_RunningBootstrap_mean(invect(:,2),50);
% subtightplot(numplots,3,subplotnum+1,0.05);hold on;
% fill([tbinvect',fliplr(tbinvect')],[runBS(:,2)',fliplr(runBS(:,3)')],clr,...
%     'EdgeColor','none','FaceAlpha',0.5);
% title('Running Average with 95% CI');
% ylabel('Frequency (Hz)');xlabel('Time (seconds since lights on)');
% 
% runcvbs = jc_RunningBootstrap_cv(invect(:,2),50);
% subtightplot(numplots,3,subplotnum+2,0.05);hold on;
% fill([tbinvect',fliplr(tbinvect')],[runcvbs(:,2)',fliplr(runcvbs(:,3)')],clr,...
%     'EdgeColor','none','FaceAlpha',0.5);
% title('Running CV with 95% CI');
% ylabel('CV');xlabel('Time (seconds since lights on)');



%% plot pitch, volume, entropy time course with running average and SEM for every syllable 
%% includes CV of each feature and pitch contour
fignum = input('figure for spectral measurements:');
figure(fignum);hold on;

pitchestimates =  cell2mat(arrayfun(@(x) [x.datenm x.mxvals]',fv_syll,'UniformOutput',false))';
volestimates = cell2mat(arrayfun(@(x) [x.datenm log(x.maxvol)]',fv_syll,'UniformOutput',false))';
entestimates = cell2mat(arrayfun(@(x) [x.datenm x.spent]',fv_syll,'UniformOutput',false))';

tb_pitch = jc_tb(pitchestimates(:,1),7,0);
subtightplot(4,1,1,0.07,0.04,0.15);hold on;
h = plot(tb_pitch,pitchestimates(:,2),marker);
removeoutliers = input('remove outliers? (y/n):','s');
while removeoutliers == 'y'
    nstd = input('use this nstd threshold:');
    delete(h);
    ind = jc_findoutliers(pitchestimates(:,2),nstd);
    pitchestimates(ind,:) = [];
    tb_pitch(ind) = [];
    h = plot(tb_pitch,pitchestimates(:,2),marker);
    removeoutliers = input('remove outliers? (y/n):','s');
end
if length(pitchestimates) >= 50
    runningaverage = jc_RunningAverage(pitchestimates(:,2),50);
    fill([tb_pitch' fliplr(tb_pitch')],[runningaverage(:,1)'-runningaverage(:,2)',...
        fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,'EdgeColor','none',...
        'FaceAlpha',0.5);
end
xlabel('Time (seconds since lights on)');
ylabel('Frequency (Hz)');
title('Pitch running average with SEM');


tb_amp = jc_tb(volestimates(:,1),7,0);
subtightplot(4,1,2,0.07,0.04,0.15);hold on;
h = plot(tb_amp,volestimates(:,2),marker);
removeoutliers = input('remove outliers? (y/n):','s');
while removeoutliers == 'y'
    nstd = input('use this nstd threshold:');
    delete(h);
    ind = jc_findoutliers(volestimates(:,2),nstd);
    volestimates(ind,:) = [];
    tb_amp(ind) = [];
    h = plot(tb_amp,volestimates(:,2),marker);
    removeoutliers = input('remove outliers? (y/n):','s');
end
if length(volestimates)>= 50
    runningaverage = jc_RunningAverage(volestimates(:,2),50);
    fill([tb_amp' fliplr(tb_amp')],[runningaverage(:,1)'-runningaverage(:,2)',...
        fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,'EdgeColor','none',...
        'FaceAlpha',0.5);
end
xlabel('Time (seconds since lights on)');
ylabel('Amplitude (log)');
title('Amplitude running average with SEM');

tb_ent = jc_tb(entestimates(:,1),7,0);
subtightplot(4,1,3,0.07,0.04,0.15);hold on;
h = plot(tb_ent,entestimates(:,2),marker);
removeoutliers = input('remove outliers? (y/n):','s');
while removeoutliers == 'y'
    nstd = input('use this nstd threshold:');
    delete(h);
    ind = jc_findoutliers(entestimates(:,2),nstd);
    entestimates(ind,:) = [];
    tb_ent(ind) = [];
    h = plot(tb_ent,entestimates(:,2),marker);
    removeoutliers = input('remove outliers? (y/n):','s');
end
if length(entestimates)>=50
    runningaverage = jc_RunningAverage(entestimates(:,2),50);
    fill([tb_ent' fliplr(tb_ent')],[runningaverage(:,1)'-runningaverage(:,2)',...
        fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,'EdgeColor','none',...
        'FaceAlpha',0.5);
end
xlabel('Time (seconds since lights on)');
ylabel('Entropy (Hz)');
title('Entropy running average with SEM');

% runningcv = jc_RunningCV(pitchestimates(:,2),50);
% subtightplot(4,2,2,0.07);hold on;
% plot(tb_pitch,runningcv,linecolor,'linewidth',2);
% xlabel('Time (seconds since lights on');
% ylabel('CV');
% title('Pitch running CV');
% 
% runningcv = jc_RunningCV(volestimates(:,2),50);
% subtightplot(4,2,4,0.07);hold on;
% plot(tb_amp,runningcv,linecolor,'linewidth',2);
% xlabel('Time (seconds since lights on');
% ylabel('CV');
% title('Amplitude running CV');
% 
% runningcv = jc_RunningCV(entestimates(:,2),50);
% subtightplot(4,2,6,0.07);hold on;
% plot(tb_ent,runningcv,linecolor,'linewidth',2);
% xlabel('Time (seconds since lights on');
% ylabel('CV');
% title('Entropy running CV');


N = 512;
overlap = N-2;
fs= 32000;
pitchcontour = {};
for i = 1:length(fv_syll)
    pitchcontour{i} = fv_syll(i).pitchcontour(:,2);
end
maxpclength = max(cellfun(@length,pitchcontour));
pitchcontour = cell2mat(cellfun(@(x) [x; NaN(maxpclength-length(x),1)],pitchcontour,'UniformOutput',false));
tb_pc = N/2/fs+([0:maxpclength-1]*(N-overlap)/fs);
subtightplot(4,1,4,0.07,0.04,0.15);hold on;
plot(tb_pc,nanmean(pitchcontour,2)+nanstderr(pitchcontour,2),linecolor);hold on;
plot(tb_pc,nanmean(pitchcontour,2)-nanstderr(pitchcontour,2),linecolor);
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
title('Average pitch contour with SEM');


