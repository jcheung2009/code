function jc_repeatanalysis2(fv_rep,marker,linecolor)
%use with jc_findrepeat2, produces 5 figures
fs = 32000;
tb = jc_tb([fv_rep(:).datenm]',7,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 1: tempo and spectral raw data for first syllable
%plot runlength over time
fignum = input('figure for tempo and spectral measurements over time:');
figure(fignum);hold on;
runlength = [tb [fv_rep(:).runlength]'];
subtightplot(4,2,1,0.07);
plot(runlength(:,1),runlength(:,2),marker);hold on;
title('Average repeat length with SEM')
xlabel('Time (seconds since lights on)');
ylabel('Number of syllables in repeat');
runningaverage = jc_RunningAverage(runlength(:,2),50);
fill([tb' fliplr(tb')],[runningaverage(:,1)'-runningaverage(:,2)',...
    fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,...
    'EdgeColor','none','FaceAlpha',0.5);

%plot xcorr values for each repeat run over time
xcorrvals = [];
for i = 1:length(fv_rep)
    if length(fv_rep(i).syllgaps)<3%at least 4 syllables
        continue
    else
        [c lags] = xcorr(fv_rep(i).sm,'coeff');
        c = c(ceil(length(c)/2):end);
        lags = lags(ceil(length(lags)/2):end);
        [pks locs] = findpeaks(c);%peaks need to be at least 30 ms apart
        xcorrvals = cat(1,xcorrvals,[fv_rep(i).datenm,locs(1)/fs]);
    end
end
xcorrvals(:,1) = jc_tb(xcorrvals(:,1),7,0);

subtightplot(4,2,3,0.07);hold on;
h = plot(xcorrvals(:,1),xcorrvals(:,2),marker);
removeoutliers=input('remove outliers? (y/n):','s');
while removeoutliers=='y'
    delete(h);
    nstd = input('number of standard devs to detect outliers:');
    ind = jc_findoutliers(xcorrvals(:,2),nstd);
    xcorrvals(ind,:) = [];
    h = plot(xcorrvals(:,1),xcorrvals(:,2),marker);
    removeoutliers=input('remove outliers? (y/n):','s');
end
title('Average tempo estimate over time with SEM');
xlabel('Time (seconds since lights on)');
ylabel('Duration between adjacent syllables (seconds)');
runningaverage = jc_RunningAverage(xcorrvals(:,2),50);
fill([xcorrvals(:,1)' fliplr(xcorrvals(:,1)')],[runningaverage(:,1)'-runningaverage(:,2)',...
    fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,'EdgeColor','none',...
    'FaceAlpha',0.5);

%plot average syllable duration and gaps over time
meansylldurations = [tb,arrayfun(@(x) mean(x.sylldurations),fv_rep)'];
meansyllgaps = [];
for i = 1:length(fv_rep)
    if isempty(fv_rep(i).syllgaps)
        continue
    else 
        meansyllgaps = cat(1,meansyllgaps,[fv_rep(i).datenm, mean(fv_rep(i).syllgaps)]);
    end
end
meansyllgaps(:,1) = jc_tb(meansyllgaps,7,0);
    
subtightplot(4,2,5,0.07);hold on;
h = plot(meansylldurations(:,1),meansylldurations(:,2),marker);hold on;
removeoutliers=input('remove outliers? (y/n):','s');
while removeoutliers=='y'
    delete(h);
    ind = jc_findoutliers(meansylldurations(:,2),3.5);
    meansylldurations(ind,:) = [];
    h = plot(meansylldurations(:,1),meansylldurations(:,2),marker);
    removeoutliers=input('remove outliers? (y/n):','s');
end
title('Average syllable duration over time with SEM');
xlabel('Time (seconds since lights on)');
ylabel('Syllable duration (seconds)');
runningaverage = jc_RunningAverage(meansylldurations(:,2),50);
fill([meansylldurations(:,1)' fliplr(meansylldurations(:,1)')],[runningaverage(:,1)'-runningaverage(:,2)',...
    fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,'EdgeColor','none',...
    'FaceAlpha',0.5);

subtightplot(4,2,7,0.07);hold on;
h = plot(meansyllgaps(:,1),meansyllgaps(:,2),marker);
removeoutliers=input('remove outliers? (y/n):','s');
while removeoutliers=='y'
    delete(h);
    ind = jc_findoutliers(meansyllgaps(:,2),3.5);
    meansyllgaps(ind,:) = [];
    h = plot(meansyllgaps(:,1),meansyllgaps(:,2),marker);
    removeoutliers=input('remove outliers? (y/n):','s');
end
title('Average gap duration over time with SEM');
xlabel('Time (seconds since lights on)');
ylabel('Gap duration (seconds)');
runningaverage = jc_RunningAverage(meansyllgaps(:,2),50);
fill([meansyllgaps(:,1)' fliplr(meansyllgaps(:,1)')],[runningaverage(:,1)'-runningaverage(:,2)',...
    fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,'EdgeColor','none',...
    'FaceAlpha',0.5);

%plot pitch estimate of first syllable over time for all syllables
pitchest1 = [tb,arrayfun(@(x) x.pitchest(1),fv_rep)'];
subtightplot(4,2,2,0.07);hold on;
h =plot(pitchest1(:,1),pitchest1(:,2),marker);
removeoutliers=input('remove outliers? (y/n):','s');
while removeoutliers=='y'
    nstd = input('number of standard devs to detect outliers:');
    delete(h);
    ind = jc_findoutliers(pitchest1(:,2),nstd);
    pitchest1(ind,:) = [];
    h = plot(pitchest1(:,1),pitchest1(:,2),marker);
    removeoutliers=input('remove outliers? (y/n):','s');
end
title('Average pitch of first syllable with SEM');
xlabel('Time (seconds since lights on)');
ylabel('Frequency (Hz)');
runningaverage = jc_RunningAverage(pitchest1(:,2),50);
fill([pitchest1(:,1)' fliplr(pitchest1(:,1)')],[runningaverage(:,1)'-runningaverage(:,2)',...
    fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,'EdgeColor','none',...
    'FaceAlpha',0.5);

%plot volume for first syllable over time
vol1 = [tb,arrayfun(@(x) log(x.amp(1)),fv_rep)'];
subtightplot(4,2,4,0.07);hold on;
h=plot(vol1(:,1),vol1(:,2),marker);
removeoutliers=input('remove outliers? (y/n):','s');
while removeoutliers=='y'
    delete(h);
    ind = jc_findoutliers(vol1(:,2),3.5);
    vol1(ind,:) = [];
    h = plot(vol1(:,1),vol1(:,2),marker);
    removeoutliers=input('remove outliers? (y/n):','s');
end
title('Average amplitude of first syllable with SEM');
xlabel('Time (seconds since lights on)');
ylabel('Amplitude (log)');
runningaverage = jc_RunningAverage(vol1(:,2),50);
fill([vol1(:,1)' fliplr(vol1(:,1)')],[runningaverage(:,1)'-runningaverage(:,2)',...
    fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,'EdgeColor','none',...
    'FaceAlpha',0.5);

%plot entropy for all syllables over time
ent1 = [tb,arrayfun(@(x) x.ent(1),fv_rep)'];
subtightplot(4,2,6,0.07);hold on;
h=plot(ent1(:,1),ent1(:,2),marker);hold on;
removeoutliers=input('remove outliers? (y/n):','s');
while removeoutliers=='y'
    delete(h);
    ind = jc_findoutliers(ent1(:,2),3.5);
    ent1(ind,:) = [];
    h = plot(ent1(:,1),ent1(:,2),marker);
    removeoutliers=input('remove outliers? (y/n):','s');
end
title('Average entropy of first syllable with SEM');
xlabel('Time (seconds since lights on)');
ylabel('Wiener Entropy');
runningaverage = jc_RunningAverage(ent1(:,2),50);
fill([ent1(:,1)' fliplr(ent1(:,1)')],[runningaverage(:,1)'-runningaverage(:,2)',...
    fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,'EdgeColor','none',...
    'FaceAlpha',0.5);

% pitch contour for first syllable
N = 512;
overlap = N-2;
pitchcontour1 = {};
for i = 1:length(fv_rep)
    pitchcontour1{i} = fv_rep(i).pc(2,:);
end
maxpclength = max(cellfun(@length,pitchcontour1));
pitchcontour1 = cell2mat(cellfun(@(x) [x, NaN(1,maxpclength-length(x))]',pitchcontour1,'UniformOutput',false));
tb_pc = N/2/fs+([0:maxpclength-1]*(N-overlap)/fs);
subtightplot(4,2,8,0.07);hold on;
plot(tb_pc,nanmean(pitchcontour1,2)+nanstderr(pitchcontour1,2),linecolor,'linewidth',2);hold on;
plot(tb_pc,nanmean(pitchcontour1,2)-nanstderr(pitchcontour1,2),linecolor,'linewidth',2);hold on;
title('Average pitch contour of first syllabe with SEM')
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 2: syllable duration, gaps, and tempo by repeat length
fignum = input('figure for tempo measurements by repeat position:');
figure(fignum);
maxlength = max(arrayfun(@(x) x.runlength,fv_rep));
%syllable duration
sylldurs = struct();
for i = 1:maxlength
    sylldurs.(['syll',num2str(i)]) = arrayfun(@(x) sylldurext(x,i),fv_rep,...
        'UniformOutput',false);
    sylldurs.(['syll',num2str(i)]) =  [cellfun(@(x) x(:,1),sylldurs.(['syll',num2str(i)]))',...
        cellfun(@(x) x(:,2),sylldurs.(['syll',num2str(i)]))'];
    ii = find(isnan(sylldurs.(['syll',num2str(i)])(:,1)));
    sylldurs.(['syll',num2str(i)])(ii,:) = [];
end
fldnames = fieldnames(sylldurs);

subtightplot(3,1,1,[0.07 0.07],[0.05 0.05],[0.05 0.09]);hold on;legend('-Dynamiclegend');
hithresh = nanmean(meansylldurations(:,2)) + 3.5*nanstd(meansylldurations(:,2));
lothresh = nanmean(meansylldurations(:,2)) - 3.5*nanstd(meansylldurations(:,2));
cmap = hsv(length(fldnames));
for i = 1:length(fldnames)
    outliers = find(sylldurs.([fldnames{i}])(:,2) > hithresh | ...
        sylldurs.([fldnames{i}])(:,2) < lothresh);
    durcurrentsyll = sylldurs.([fldnames{i}]);
    durcurrentsyll(outliers,:) = [];
    if isempty(durcurrentsyll)
        continue
    end
    tbase = jc_tb(durcurrentsyll(:,1),7,0);
    if length(durcurrentsyll) >= 50
%         plot(tbase,mRunningAvg(...
%             durcurrentsyll(:,2),50),'color',cmap(i,:),'linewidth',2,'DisplayName',...
%             fldnames{i});
        plot(tbase, durcurrentsyll(:,2),'.','color',cmap(i,:),'DisplayName',...
            fldnames{i});
        hold on;
    elseif length(durcurrentsyll) < 50 & length(durcurrentsyll) >=20
%         plot(tbase,mRunningAvg(durcurrentsyll(:,2),20),'color',cmap(i,:),...
%             'linewidth',2,'DisplayName',fldnames{i});
            plot(tbase,durcurrentsyll(:,2),'.','color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    else
%         plot(tbase,durcurrentsyll(:,2),'color',cmap(i,:),...
%             'linewidth',2,'DisplayName',fldnames{i});
        plot(tbase,durcurrentsyll(:,2),'.','color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    end
end
legend(gca,'show');
title('Running average of syllable duration by repeat position over time')
xlabel('Time (seconds since lights on');
ylabel('Duration (seconds)');

%gap duration
maxlengthgaps = max(arrayfun(@(x) numel(x.syllgaps),fv_rep));
syllgaps = struct();
for i = 1:maxlengthgaps
    syllgaps.(['gap',num2str(i)]) = arrayfun(@(x) syllgapext(x,i),fv_rep,...
        'UniformOutput',false);
    syllgaps.(['gap',num2str(i)]) =  [cellfun(@(x) x(:,1),syllgaps.(['gap',num2str(i)]))',...
        cellfun(@(x) x(:,2),syllgaps.(['gap',num2str(i)]))'];
    ii = find(isnan(syllgaps.(['gap',num2str(i)])(:,1)));
    syllgaps.(['gap',num2str(i)])(ii,:) = [];
end

subtightplot(3,1,2,[0.07 0.07],[0.05 0.05],[0.05 0.09]);hold on;legend('-DynamicLegend');
gapfldnames = fieldnames(syllgaps);
hithresh = nanmean(meansyllgaps(:,2)) + 3.5*nanstd(meansyllgaps(:,2));
lothresh = nanmean(meansyllgaps(:,2)) - 3.5*nanstd(meansyllgaps(:,2));
for i = 1:length(gapfldnames)
    outliers = find(syllgaps.([gapfldnames{i}])(:,2) > hithresh | ...
        syllgaps.([gapfldnames{i}])(:,2) < lothresh);
    durcurrentsyll = syllgaps.([gapfldnames{i}]);
    durcurrentsyll(outliers,:) = [];
    tbase = jc_tb(durcurrentsyll(:,1),7,0);
    if length(durcurrentsyll) >= 50
%         plot(tbase,mRunningAvg(...
%             durcurrentsyll(:,2),50),'color',cmap(i,:),'linewidth',2,'DisplayName',...
%             gapfldnames{i});
        plot(tbase,durcurrentsyll(:,2),'.','color',cmap(i,:),'DisplayName',...
            gapfldnames{i});
        hold on;
    elseif length(durcurrentsyll) < 50 & length(durcurrentsyll) >=20
%         plot(tbase,mRunningAvg(durcurrentsyll(:,2),20),'color',cmap(i,:),...
%             'linewidth',2,'DisplayName',gapfldnames{i});
        plot(tbase,durcurrentsyll(:,2),'.','color',cmap(i,:),...
            'DisplayName',gapfldnames{i});
        hold on;
    else
%         plot(tbase,durcurrentsyll(:,2),'color',cmap(i,:),...
%             'linewidth',2,'DisplayName',gapfldnames{i});
        plot(tbase,durcurrentsyll(:,2),'.','color',cmap(i,:),...
            'DisplayName',gapfldnames{i});
        hold on;
    end
end
legend(gca,'show');
title('Running average of gap duration by repeat position over time')
xlabel('Time (seconds since lights on)');
ylabel('Duration (seconds)');

%tempo
maxlength = max(arrayfun(@(x) x.runlength,fv_rep));
xcorrvals_syll = struct();
for i = 4:maxlength
    xcorrvals_syll.(['length',num2str(i)]) = [];
    for ii = 1:length(fv_rep)
        if length(fv_rep(ii).ons) >= i
            [c lags] = xcorr(fv_rep(ii).sm(1:ceil(fv_rep(ii).off(i)*fs)),'coeff');
            c = c(ceil(length(c)/2):end);
            [pks locs] = findpeaks(c,'MINPEAKDISTANCE',960,'MINPEAKHEIGHT',0.1);%peaks min 30 ms apart
            xcorrvals_syll.(['length',num2str(i)]) = cat(1,xcorrvals_syll.(['length',num2str(i)]),...
                [fv_rep(ii).datenm,mean(diff([1;locs]))/32000]);
        else
            continue
        end
    end
end

fn = fieldnames(xcorrvals_syll);
cmap = hsv(length(fn));
subtightplot(3,1,3,[0.07 0.07],[0.05 0.05],[0.05 0.09]);hold on;legend('-DynamicLegend');
for i = 1:length(fn)
    tbase = jc_tb(xcorrvals_syll.(fn{i})(:,1),7,0);
    if length(xcorrvals_syll.(fn{i})) > 100
%         plot(tbase,mRunningAvg(xcorrvals_syll.(fn{i})(:,2),50),'color',...
%             cmap(i,:),'linewidth',2,'DisplayName',fn{i});
          plot(tbase,xcorrvals_syll.(fn{i})(:,2),'.','color',...
            cmap(i,:),'DisplayName',fn{i});
        hold on;
    else
%         plot(tbase,xcorrvals_syll.(fn{i})(:,2),'color',cmap(i,:),'linewidth',2,...
%             'DisplayName',fn{i});
        plot(tbase,xcorrvals_syll.(fn{i})(:,2),'.','color',cmap(i,:),...
            'DisplayName',fn{i});
        hold on
    end
end
legend(gca,'show');
title('Running average of tempo by repeat length over time')
xlabel('Time (seconds since lights on)');
ylabel('Duration between adjacent syllables (seconds)');
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 3: plot pitch, volume, entropy, frequency modulation by repeat position
fignum = input('figure for spectral features by repeat position:');
figure(fignum);hold on;

%pitch 
maxlength = max(arrayfun(@(x) numel(x.pitchest),fv_rep));
pitchest = struct();
for i = 1:maxlength
    pitchest.(['syll',num2str(i)]) = arrayfun(@(x) pitchext(x,i),fv_rep,...
        'UniformOutput',false);
    pitchest.(['syll',num2str(i)]) =  [cellfun(@(x) x(:,1),pitchest.(['syll',num2str(i)]))',...
        cellfun(@(x) x(:,2),pitchest.(['syll',num2str(i)]))'];
    ii = find(isnan(pitchest.(['syll',num2str(i)])(:,1)));
    pitchest.(['syll',num2str(i)])(ii,:) = [];
end
fldnames = fieldnames(pitchest);

subtightplot(3,1,1,[0.07 0.07],[0.05 0.05],[0.05 0.09]);hold on;
fldnames = fieldnames(pitchest);
cmap = hsv(maxlength);
hithresh = nanmean(pitchest1(:,2)) + 3.5*nanstd(pitchest1(:,2));
lothresh = nanmean(pitchest1(:,2)) - 3.5*nanstd(pitchest1(:,2));
for i = 1:length(fldnames)
    outliers = find(pitchest.([fldnames{i}])(:,2) > hithresh | ...
        pitchest.([fldnames{i}])(:,2) < lothresh);
    pitchestcurrentsyll = pitchest.([fldnames{i}]);
    pitchestcurrentsyll(outliers,:) = [];
    if isempty(pitchestcurrentsyll)
        continue
    end
    tbase = jc_tb(pitchestcurrentsyll(:,1),7,0);
    if length(pitchestcurrentsyll) >= 50
%         plot(tbase,mRunningAvg(pitchestcurrentsyll(:,2),50),...
%             'color',cmap(i,:),'linewidth',1,'DisplayName',...
%             fldnames{i});hold on;
        plot(tbase,pitchestcurrentsyll(:,2),'.','color',cmap(i,:),'DisplayName',fldnames{i});
        hold on;
    elseif length(pitchestcurrentsyll) < 50 & length(pitchestcurrentsyll) >=20
%        plot(tbase,mRunningAvg(pitchestcurrentsyll(:,2),20),'color',cmap(i,:),...
%             'linewidth',1,'DisplayName',fldnames{i});hold on;
         plot(tbase,pitchestcurrentsyll(:,2),'.','color',cmap(i,:),'DisplayName',fldnames{i});
        hold on;
    else
%         plot(tbase,pitchestcurrentsyll(:,2),'color',cmap(i,:),...
%             'linewidth',1,'DisplayName',fldnames{i});
        plot(tbase,pitchestcurrentsyll(:,2),'.','color',cmap(i,:),'DisplayName',fldnames{i});
        hold on;
    end
end
legend(gca,'show')
title('Pitch by repeat position over time');
xlabel('Time (seconds since lights on)');
ylabel('Frequency (Hz)');

%volume
volest = struct();
for i = 1:maxlength
    volest.(['syll',num2str(i)]) = arrayfun(@(x) volext(x,i),fv_rep,...
        'UniformOutput',false);
    volest.(['syll',num2str(i)]) =  [cellfun(@(x) x(:,1),volest.(['syll',num2str(i)]))',...
        cellfun(@(x) x(:,2),volest.(['syll',num2str(i)]))'];
    ii = find(isnan(volest.(['syll',num2str(i)])(:,1)));
    volest.(['syll',num2str(i)])(ii,:) = [];
end
fldnames = fieldnames(volest);

subtightplot(3,1,2,[0.07 0.07],[0.05 0.05],[0.05 0.09]);hold on;legend('-DynamicLegend');
hithresh = nanmean(vol1(:,2)) + 3.5*nanstd(vol1(:,2));
lothresh = nanmean(vol1(:,2)) - 3.5*nanstd(vol1(:,2));
for i = 1:length(fldnames)
    outliers = find(volest.([fldnames{i}])(:,2) > hithresh | ...
        volest.([fldnames{i}])(:,2) < lothresh);
    volcurrentsyll = volest.([fldnames{i}]);
    volcurrentsyll(outliers,:) = [];
    if isempty(volcurrentsyll)
        continue
    end
    tbase = jc_tb(volcurrentsyll(:,1),7,0);
    if length(volcurrentsyll) >= 50
%         plot(tbase,mRunningAvg(...
%             volcurrentsyll(:,2),50),'color',cmap(i,:),'linewidth',2,...
%             'DisplayName',fldnames{i});
          plot(tbase,volcurrentsyll(:,2),'.','color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    elseif length(volcurrentsyll) < 50 & length(volcurrentsyll) >=20
%         plot(tbase,mRunningAvg(volcurrentsyll(:,2),20),'color',cmap(i,:),'linewidth',2,...
%             'DisplayName',fldnames{i});
        plot(tbase,volcurrentsyll(:,2),'.','color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    else
%         plot(tbase,volcurrentsyll(:,2),'color',cmap(i,:),'linewidth',2,...
%             'DisplayName',fldnames{i});
        plot(tbase,volcurrentsyll(:,2),'.','color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    end
end
legend(gca,'show');
title('Volume by repeat position over time')
xlabel('Time (seconds since lights on)');
ylabel('Amplitude');

%weiner entropy
entest = struct();
for i = 1:maxlength
    entest.(['syll',num2str(i)]) = arrayfun(@(x) entext(x,i),fv_rep,...
        'UniformOutput',false);
    entest.(['syll',num2str(i)]) =  [cellfun(@(x) x(:,1),entest.(['syll',num2str(i)]))',...
        cellfun(@(x) x(:,2),entest.(['syll',num2str(i)]))'];
    ii = find(isnan(entest.(['syll',num2str(i)])(:,1)));
    entest.(['syll',num2str(i)])(ii,:) = [];
end
fldnames = fieldnames(entest);

subtightplot(3,1,3,[0.07 0.07],[0.05 0.05],[0.05 0.09]);hold on;legend('-DynamicLegend');
for i = 1:length(fldnames)
    entcurrentsyll = entest.([fldnames{i}]);
    tbase = jc_tb(entcurrentsyll(:,1),7,0);
    if length(entcurrentsyll) >= 50
%         plot(tbase,mRunningAvg(...
%             entcurrentsyll(:,2),50),'color',cmap(i,:),'linewidth',2,...
%             'DisplayName',fldnames{i});
        plot(tbase,entcurrentsyll(:,2),'.','color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    elseif length(entcurrentsyll) < 50 & length(entcurrentsyll) >=20
%         plot(tbase,mRunningAvg(entcurrentsyll(:,2),20),'color',cmap(i,:),'linewidth',2,...
%             'DisplayName',fldnames{i});
        plot(tbase,entcurrentsyll(:,2),'.','color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    else
%         plot(tbase,entcurrentsyll(:,2),'color',cmap(i,:),'linewidth',2,...
%             'DisplayName',fldnames{i});
        plot(tbase,entcurrentsyll(:,2),'.','color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    end
end
legend(gca,'show');
title('Wiener entropy by repeat position over time');
xlabel('Time (seconds since lights on)');
ylabel('Entropy');
hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 4: patterns within repeats
fignum = input('figure for within repeat patterns:');
figure(fignum);hold on;

pitchpattern_by_length = struct();
volpattern_by_length= struct();
entpattern_by_length =struct();
durpattern_by_length=struct();
gappattern_by_length= struct();
for ii = 1:maxlength
    ind = find(arrayfun(@(x) length(x.pitchest),fv_rep)==ii);
    if isempty(ind)
        continue
    end
    pitchvector = [];ampvector=[];entvector = [];durvector = [];gapvector = [];
    for k = 1:length(ind)
        pitchvector = [pitchvector fv_rep(ind(k)).pitchest];
        ampvector = [ampvector log(fv_rep(ind(k)).amp)];
        entvector =[entvector fv_rep(ind(k)).ent];
        durvector = [durvector fv_rep(ind(k)).sylldurations];
        gapvector = [gapvector fv_rep(ind(k)).syllgaps];
    end
    pitchpattern_by_length.(['length',num2str(ii)]) = pitchvector;
    volpattern_by_length.(['length',num2str(ii)]) = ampvector;
    entpattern_by_length.(['length',num2str(ii)]) = entvector;
    durpattern_by_length.(['length',num2str(ii)]) = durvector;
    gappattern_by_length.(['length',num2str(ii)]) = gapvector;
end

fldnames = fieldnames(pitchpattern_by_length);
cmap = hsv(length(fldnames));
subtightplot(1,5,1,[0.03 0.03],[0.1 0.05],[0.03 0.03]);hold on;
for i = 1:length(fldnames)
    pitchpattern = pitchpattern_by_length.([fldnames{i}])./...
        repmat(pitchpattern_by_length.([fldnames{i}])(1,:),[size(pitchpattern_by_length.([fldnames{i}]),1),1]);
    plot(nanmean(pitchpattern,2),'color',cmap(i,:),...
        'linewidth',2,'DisplayName',fldnames{i});hold on;
end
legend(gca,'show')
xlabel('Syllable position in repeat');
ylabel('Relative pitch');
title('Pitch relative to repeat position');

subtightplot(1,5,2,[0.03 0.03],[0.1 0.05],[0.03 0.03]);hold on;
for i = 1:length(fldnames)
    volpattern = volpattern_by_length.([fldnames{i}])./...
        repmat(volpattern_by_length.([fldnames{i}])(1,:),[size(volpattern_by_length.([fldnames{i}]),1),1]);
    plot(nanmean(volpattern,2),'color',cmap(i,:),...
        'linewidth',2,'DisplayName',fldnames{i});hold on;
end
legend(gca,'show')
xlabel('Syllable position in repeat');
ylabel('Relative amplitude');
title('Amplitude relative to repeat position');

subtightplot(1,5,3,[0.03 0.03],[0.1 0.05],[0.03 0.03]);hold on;
for i = 1:length(fldnames)
    entpattern = entpattern_by_length.([fldnames{i}])./...
        repmat(entpattern_by_length.([fldnames{i}])(1,:),[size(entpattern_by_length.([fldnames{i}]),1),1]);
    plot(nanmean(entpattern,2),'color',cmap(i,:),...
        'linewidth',2,'DisplayName',fldnames{i});hold on;
end
legend(gca,'show')
xlabel('Syllable position in repeat');
ylabel('Relative entropy');
title('Entropy relative to repeat position');

subtightplot(1,5,4,[0.03 0.03],[0.1 0.05],[0.03 0.03]);hold on;
for i = 1:length(fldnames)
    durpattern = durpattern_by_length.([fldnames{i}])./...
        repmat(durpattern_by_length.([fldnames{i}])(1,:),[size(durpattern_by_length.([fldnames{i}]),1),1]);
    plot(nanmean(durpattern,2),'color',cmap(i,:),...
        'linewidth',2,'DisplayName',fldnames{i});hold on;
end
legend(gca,'show')
xlabel('Syllable position in repeat');
ylabel('Relative duration');
title('Syllable duration relative to repeat position');

fldnames = fieldnames(gappattern_by_length);
subtightplot(1,5,5,[0.03 0.03],[0.1 0.05],[0.03 0.03]);hold on;
for i = 1:length(fldnames)
    gappattern = gappattern_by_length.([fldnames{i}])./...
        repmat(gappattern_by_length.([fldnames{i}])(1,:),[size(gappattern_by_length.([fldnames{i}]),1),1]);
    plot(nanmean(gappattern,2),'color',cmap(i,:),...
        'linewidth',2,'DisplayName',fldnames{i});hold on;
end
legend(gca,'show')
xlabel('Gap position in repeat');
ylabel('Relative duration');
title('Gap duration relative to repeat position');


%This computes average with SEM of relative pitch pattern over all repeat
%lengths
% relativepitch = {};
% hithresh = mean(pitchest1(:,2)) + 3.5*std(pitchest1(:,2));
% lothresh = mean(pitchest1(:,2)) - 3.5*std(pitchest1(:,2));
% for i = 1:length(fv_rep)
%     if fv_rep(i).pitchest(1) == 0
%         continue
%     else
%         outliers = find(fv_rep(i).pitchest > hithresh | fv_rep(i).pitchest < lothresh);
%         relativepitch{i} = fv_rep(i).pitchest;
%         relativepitch{i}(outliers) = NaN;
%         if isnan(relativepitch{i}(1))
%             relativepitch{i} = NaN(length(relativepitch{i}),1);
%         else
%             relativepitch{i} = relativepitch{i}./relativepitch{i}(1);%normalized to first syllable in repeat
%         end
%     end
% end
% relativepitch = cell2mat(cellfun(@(x) [x; NaN(maxlength-length(x),1)],...
%     relativepitch,'UniformOutput',false));
% x = 1:maxlength;
% y1 = nanmean(relativepitch,2)+nanstderr(relativepitch,2);
% y2 = nanmean(relativepitch,2)-nanstderr(relativepitch,2);
% cmap = colormap(hsv(3));
% subtightplot(1,3,1,[0.03 0.03],[0.1 0.05],[0.03 0.03]);hold on
% % plot(x,y1,'Color',cmap(1,:));hold on;
% % plot(x,y2,'Color',cmap(1,:));
% fill([x fliplr(x)],[y1' fliplr(y2')],cmap(1,:),'EdgeColor','none','FaceAlpha',0.5);
% xlabel('Syllable position in the repeat');
% ylabel('Relative pitch');
% title('Pitch relative to repeat position');

%This computes average pitch pattern by repeat length 


%This computes average volume pattern with SEM over all repeat lengths
% relativevol = {};
% for i = 1:length(fv_rep)
%     if fv_rep(i).amp(1) == 0
%         continue
%     else
%         relativevol{i} = fv_rep(i).amp/fv_rep(i).amp(1);%normalized to first syllable in repeat
%     end
% end
% 
% relativevol = cell2mat(cellfun(@(x) [x; NaN(maxlength-length(x),1)],...
%     relativevol,'UniformOutput',false));
% hold all;
% y1 = nanmean(relativevol,2)+nanstderr(relativevol,2);
% y2 = nanmean(relativevol,2) - nanstderr(relativevol,2);
% % plot(x,y1,'Color',cmap(1,:));hold on;
% % plot(x,y2,'Color',cmap(1,:));
% subtightplot(1,3,2,[0.07 0.07],[0.1 0.05],[0.03 0.03]);hold on;
% fill([x fliplr(x)],[y1' fliplr(y2')],cmap(2,:),'EdgeColor','none','FaceAlpha',0.5);
% xlabel('Syllable position in repeat');
% ylabel('Relative Amplitude');
% title('Amplitude relative to repeat position');



%This computes average entropy pattern with SEM within repeat by repeat length
% relativeent = {};
% for i = 1:length(fv_rep)
%     if isnan(fv_rep(i).ent(1))
%         continue
%     else
%         relativeent{i} = fv_rep(i).ent-fv_rep(i).ent(1);%normalized by subtraction of first syllable
%     end
% end
% 
% relativeent = cell2mat(cellfun(@(x) [x; NaN(maxlength-length(x),1)],...
%     relativeent,'UniformOutput',false));
% i = find(isinf(relativeent));
% relativeent(i) = NaN;
% 
% y1 = nanmean(relativeent,2)+nanstderr(relativeent,2);
% y2 = nanmean(relativeent,2) - nanstderr(relativeent,2);
% % plot(x,y1,'Color',cmap(3,:));hold on;
% % plot(x,y2,'Color',cmap(3,:));
% subtightplot(1,3,3,[0.03 0.03],[0.1 0.05],[0.03 0.03]);hold on;
% fill([x fliplr(x)],[y1' fliplr(y2')],cmap(3,:),'EdgeColor','none','FaceAlpha',0.5);
% xlabel('Syllable position in repeat');
% ylabel('Relative Entropy');
% title('Entropy relative to repeat position');
hold off;
%% Figure 5: plot correlation between tempo vs spectral features

fignum = input('figure for correlating tempo and spectral features:');
figure(fignum);hold on;
pitch1_vs_replength = [];
pitchend_vs_replength = [];
fldnames = fieldnames(pitchpattern_by_length);
for i = 1:length(fldnames)
    replength = size(pitchpattern_by_length.([fldnames{i}]),1);
    numtimes = size(pitchpattern_by_length.([fldnames{i}]),2);
    pitch1 = pitchpattern_by_length.([fldnames{i}])(1,:);
    pitchend = pitchpattern_by_length.([fldnames{i}])(end,:);
    pitch1_vs_replength = [pitch1_vs_replength; [repmat(replength,[numtimes,1]) pitch1']];
    pitchend_vs_replength = [pitchend_vs_replength; [repmat(replength,[numtimes,1]) pitchend']];
end
subtightplot(1,4,1,[0.03 0.03],[0.1 0.05],[0.03 0.03]);hold on;
plot(pitch1_vs_replength(:,1),pitch1_vs_replength(:,2),'k.','DisplayName','first syllable');hold on;
plot(pitchend_vs_replength(:,1),pitchend_vs_replength(:,2),'r.','DisplayName','last syllable');hold on;
p = polyfit(pitch1_vs_replength(:,1),pitch1_vs_replength(:,2),1);
[c1 pval] = corrcoef(pitch1_vs_replength(:,1),pitch1_vs_replength(:,2));
plot([1:maxlength],polyval(p,[1:maxlength]),'k','DisplayName',...
    sprintf(['R=',num2str(c1(2)),'\np=',num2str(pval(2))]));hold on;
p = polyfit(pitchend_vs_replength(:,1),pitchend_vs_replength(:,2),1);
[c1 pval] = corrcoef(pitchend_vs_replength(:,1),pitchend_vs_replength(:,2));
plot([1:maxlength],polyval(p,[1:maxlength]),'r','DisplayName',...
    sprintf(['R=',num2str(c1(2)),'\np=',num2str(pval(2))]));hold on;
legend(gca,'show');
title('Pitch of the first or last syllable vs repeat length');
xlabel('Repeat length (number of syllables)')
ylabel('Frequency (Hz)');

vol1_vs_replength = [];
volend_vs_replength = [];
fldnames = fieldnames(volpattern_by_length);
for i = 1:length(fldnames)
    replength = size(volpattern_by_length.([fldnames{i}]),1);
    numtimes = size(volpattern_by_length.([fldnames{i}]),2);
    amp1 = volpattern_by_length.([fldnames{i}])(1,:);
    ampend = volpattern_by_length.([fldnames{i}])(end,:);
    vol1_vs_replength = [vol1_vs_replength; [repmat(replength,[numtimes,1]) amp1']];
    volend_vs_replength = [volend_vs_replength; [repmat(replength,[numtimes,1]) ampend']];
end
subtightplot(1,4,2,[0.03 0.03],[0.1 0.05],[0.03 0.03]);hold on;
plot(vol1_vs_replength(:,1),log(vol1_vs_replength(:,2)),'k.','DisplayName','first syllable');hold on;
plot(volend_vs_replength(:,1),log(volend_vs_replength(:,2)),'r.','DisplayName','last syllable');hold on;
p = polyfit(vol1_vs_replength(:,1),log(vol1_vs_replength(:,2)),1);
[c1 pval] = corrcoef(vol1_vs_replength(:,1),log(vol1_vs_replength(:,2)));
plot([1:maxlength],polyval(p,[1:maxlength]),'k','DisplayName',...
    sprintf(['R=',num2str(c1(2)),'\np=',num2str(pval(2))]));hold on;
p = polyfit(volend_vs_replength(:,1),log(volend_vs_replength(:,2)),1);
[c1 pval] = corrcoef(volend_vs_replength(:,1),log(volend_vs_replength(:,2)));
plot([1:maxlength],polyval(p,[1:maxlength]),'r','DisplayName',...
    sprintf(['R=',num2str(c1(2)),'\np=',num2str(pval(2))]));hold on;
legend(gca,'show')
title('Volume of the first or last syllable vs repeat length');
xlabel('Repeat length (number of syllables)');
ylabel('Amplitude (log)');

ent1_vs_replength = [];
entend_vs_replength = [];
fldnames = fieldnames(entpattern_by_length);
for i = 1:length(fldnames)
    replength = size(entpattern_by_length.([fldnames{i}]),1);
    numtimes = size(entpattern_by_length.([fldnames{i}]),2);
    ent1 = entpattern_by_length.([fldnames{i}])(1,:);
    entend = entpattern_by_length.([fldnames{i}])(end,:);
    ent1_vs_replength = [ent1_vs_replength; [repmat(replength,[numtimes,1]) ent1']];
    entend_vs_replength = [entend_vs_replength; [repmat(replength,[numtimes,1]) entend']];
end
subtightplot(1,4,3,[0.03 0.03],[0.1 0.05],[0.03 0.03]);hold on;
plot(ent1_vs_replength(:,1),ent1_vs_replength(:,2),'k.','DisplayName','first syllable');hold on;
plot(entend_vs_replength(:,1),entend_vs_replength(:,2),'r.','DisplayName','last syllable');hold on;
p = polyfit(ent1_vs_replength(:,1),ent1_vs_replength(:,2),1);
[c1 pval] = corrcoef(ent1_vs_replength(:,1),ent1_vs_replength(:,2));
plot([1:maxlength],polyval(p,[1:maxlength]),'k','DisplayName',...
    sprintf(['R=',num2str(c1(2)),'\np=',num2str(pval(2))]));hold on;
p = polyfit(entend_vs_replength(:,1),entend_vs_replength(:,2),1);
[c1 pval] = corrcoef(entend_vs_replength(:,1),entend_vs_replength(:,2));
plot([1:maxlength],polyval(p,[1:maxlength]),'r','DisplayName',...
    sprintf(['R=',num2str(c1(2)),'\np=',num2str(pval(2))]));hold on;
legend(gca,'show')
title('Entropy of the first or last syllable vs repeat length');
xlabel('Repeat length (number of syllables)');
ylabel('Entropy');

dur1_vs_replength = [];
durend_vs_replength = [];
fldnames = fieldnames(durpattern_by_length);
for i = 1:length(fldnames)
    replength = size(durpattern_by_length.([fldnames{i}]),1);
    numtimes = size(durpattern_by_length.([fldnames{i}]),2);
    dur1 = durpattern_by_length.([fldnames{i}])(1,:);
    durend = durpattern_by_length.([fldnames{i}])(end,:);
    dur1_vs_replength = [dur1_vs_replength; [repmat(replength,[numtimes,1]) dur1']];
    durend_vs_replength = [durend_vs_replength; [repmat(replength,[numtimes,1]) durend']];
end
subtightplot(1,4,4,[0.03 0.03],[0.1 0.05],[0.03 0.03]);hold on;
plot(dur1_vs_replength(:,1),dur1_vs_replength(:,2),'k.','DisplayName','first syllable');hold on;
plot(durend_vs_replength(:,1),durend_vs_replength(:,2),'r.','DisplayName','last syllable');hold on;
p = polyfit(dur1_vs_replength(:,1),dur1_vs_replength(:,2),1);
[c1 pval] = corrcoef(dur1_vs_replength(:,1),dur1_vs_replength(:,2));
plot([1:maxlength],polyval(p,[1:maxlength]),'k','DisplayName',...
    sprintf(['R=',num2str(c1(2)),'\np=',num2str(pval(2))]));hold on;
p = polyfit(durend_vs_replength(:,1),durend_vs_replength(:,2),1);
[c1 pval] = corrcoef(durend_vs_replength(:,1),durend_vs_replength(:,2));
plot([1:maxlength],polyval(p,[1:maxlength]),'r','DisplayName',...
    sprintf(['R=',num2str(c1(2)),'\np=',num2str(pval(2))]));hold on;
legend(gca,'show')
title('Duration of the first or last syllable vs repeat length');
xlabel('Repeat length (number of syllables)');
ylabel('Duration (seconds)');

    


        
         