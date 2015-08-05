function jc_repeatanalysis(fv_rep,fignums)
%use with jc_findrepeat, produces 7 figures

tb = jc_tb([fv_rep(:).datenm]','','');


%plot runlength over time
h = figure(fignums(1));
hold on;

subtightplot(7,1,1,[0.05 0.05]);
runlength = [tb [fv_rep(:).runlength]'];
i = jc_findoutliers(runlength,3.5);
runlength(i,:) = [];
plot(runlength(:,1),runlength(:,2),'k.');
title('runlength over time in seconds')

%plot pitch estimates over time for all syllables
hold on;
subtightplot(7,1,2,[0.05, 0.05]);
pitchest1 = [tb,arrayfun(@(x) x.pitchest(1),fv_rep)'];
i = jc_findoutliers(pitchest1,3.5);
pitchest1(i,:) = [];
plot(pitchest1(:,1),pitchest1(:,2),'k.');
title('pitch of first repeat syllable over time in seconds')

%plot volume for all syllables over time, 
hold on;
subtightplot(7,1,3,[0.05 0.05]);
vol = [tb,arrayfun(@(x) x.amp(1),fv_rep)'];
i = jc_findoutliers(vol,3.5);
vol(i,:) = [];
plot(vol(:,1),vol(:,2),'k.');
title('volume of first repeat syllable over time in seconds')

%plot all syllable durations and all syllable gaps over time
hold on;
subtightplot(7,1,4,[0.05, 0.05]);
sylldurations1 = [tb,arrayfun(@(x) x.sylldurations(1),fv_rep)'];
i = jc_findoutliers(sylldurations1,3.5);
sylldurations1(i,:) = [];
plot(sylldurations1(:,1),sylldurations1(:,2),'k.');
title('duration of first repeat syllable over time in seconds')

    %compute tb for syllgaps separately because some repeat runs have only
    %one syllable, no gap
    syllgaps1 = [];
    for i = 1:length(fv_rep)
        if isempty(fv_rep(i).syllgaps)
            continue
        else 
            syllgaps1 = cat(1,syllgaps1,[fv_rep(i).datenm, fv_rep(i).syllgaps(1)]);
        end
    end
    syllgaps1(:,1) = arrayfun(@(x) jc_tb(x,'',''),syllgaps1(:,1));
    i = jc_findoutliers(syllgaps1,3.5);
    syllgaps1(i,:) = [];
    
hold on;   
subtightplot(7,1,5,[0.05, 0.05]);
plot(syllgaps1(:,1),syllgaps1(:,2),'k.');
title('duration of first gap in repeat run over time in seconds')

%plot entropy for all syllables over time, plot running average
%separately for all syllable numbers in repeat
hold on;
subtightplot(7,1,6,[0.05, 0.05]);
ent = [tb,arrayfun(@(x) x.ent(1),fv_rep)'];
i = jc_findoutliers(ent,3.5);
ent(i,:) = [];
plot(ent(:,1),ent(:,2),'k.')
title('entropy of first syllable in repeat run over time in seconds')    
    
%plot xcorr values for each repeat run over time, plot running average of those
%values

xcorrvals = [];
for i = 1:length(fv_rep)
    if isempty(fv_rep(i).syllgaps)
        continue
    else
        [c lags] = xcorr(fv_rep(i).sm,'coeff');
        c = c(ceil(length(c)/2):end);
        [pks locs] = findpeaks(c,'MINPEAKDISTANCE',960,'MINPEAKHEIGHT',0.1);%peaks need to be at least 30 ms apart
        xcorrvals = cat(1,xcorrvals,[fv_rep(i).datenm,mean(diff([1;locs]))/32000]);
    end
end
xcorrvals = xcorrvals(~isnan(xcorrvals(:,2)),:);
xcorrvals(:,1) = arrayfun(@(x) jc_tb(x,'',''),xcorrvals(:,1));
i = jc_findoutliers(xcorrvals,3.5);
xcorrvals(i,:) = [];
hold on;
subtightplot(7,1,7,[0.05,0.05]);
plot(xcorrvals(:,1),xcorrvals(:,2),'k.');
title('duration between adjacent syllables in repeat from xcorr over time in seconds')
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%plot running median of runlength over time
figure(fignums(2));
hold on;

subtightplot(2,1,1,[0.05,0.05]);
plot(runlength(:,1),jc_RunningMed(runlength(:,2),100),'k');
title('running median of repeat length over time in seconds');

%plot running average of xcorr duration over time
subtightplot(2,1,2,[0.05,0.05]);
plot(xcorrvals(:,1),mRunningAvg(xcorrvals(:,2),100),'k');
title('running average of xcorr duration over time in seconds')
hold off;

%plot cross correlation of xcorr duration with runlength


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot running average of pitch estimates separately for first 7 syllables
%in repeat
figure(fignums(3));hold on;

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

hold on; h = subtightplot(3,1,1,[0.05,0.05]);legend('-DynamicLegend');
fldnames = fieldnames(pitchest);
cmap = hsv(maxlength);
hithresh = mean(pitchest1(:,2)) + 3.5*std(pitchest1(:,2));
lothresh = mean(pitchest1(:,2)) - 3.5*std(pitchest1(:,2));
for i = 1:length(fldnames)
    outliers = find(pitchest.([fldnames{i}])(:,2) > hithresh | ...
        pitchest.([fldnames{i}])(:,2) < lothresh);
    pitchestcurrentsyll = pitchest.([fldnames{i}]);
    pitchestcurrentsyll(outliers,:) = [];
    tbase = jc_tb(pitchestcurrentsyll(:,1),'','');
    if length(pitchestcurrentsyll) >= 50
        plot(h,tbase,mRunningAvg(...
            pitchestcurrentsyll(:,2),50),'color',cmap(i,:),'DisplayName',...
            fldnames{i});
        hold on;
    elseif length(pitchestcurrentsyll) < 50 & length(pitchestcurrentsyll) >=20
        plot(h,tbase,mRunningAvg(pitchestcurrentsyll(:,2),20),'color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    else
        plot(h,tbase,pitchestcurrentsyll(:,2),'color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    end
end
legend(gca,'show')
title('running average of pitch for each syllable in repeat over time in seconds');

%plot running average of volume separately for all syllable numbers in repeat
volest = struct();
for i = 1:maxlength
    volest.(['syll',num2str(i)]) = arrayfun(@(x) volext(x,i),fv_rep,...
        'UniformOutput',false);
    volest.(['syll',num2str(i)]) =  [cellfun(@(x) x(:,1),volest.(['syll',num2str(i)]))',...
        cellfun(@(x) x(:,2),volest.(['syll',num2str(i)]))'];
    ii = find(isnan(volest.(['syll',num2str(i)])(:,1)));
    volest.(['syll',num2str(i)])(ii,:) = [];
end


hold on; h = subtightplot(3,1,2,[0.05,0.05]);
hithresh = mean(vol(:,2)) + 3.5*std(vol(:,2));
lothresh = mean(vol(:,2)) - 3.5*std(vol(:,2));
for i = 1:length(fldnames)
    outliers = find(volest.([fldnames{i}])(:,2) > hithresh | ...
        volest.([fldnames{i}])(:,2) < lothresh);
    volcurrentsyll = volest.([fldnames{i}]);
    volcurrentsyll(outliers,:) = [];
    tbase = jc_tb(volcurrentsyll(:,1),'','');
    if length(volcurrentsyll) >= 50
        plot(h,tbase,mRunningAvg(...
            volcurrentsyll(:,2),50),'color',cmap(i,:));
        hold on;
    elseif length(volcurrentsyll) < 50 & length(volcurrentsyll) >=20
        plot(h,tbase,mRunningAvg(volcurrentsyll(:,2),20),'color',cmap(i,:));
        hold on;
    else
        plot(h,tbase,volcurrentsyll(:,2),'color',cmap(i,:));
        hold on;
    end
end
title('running average of volume for each syllable in repeat over time in seconds')

%plot running average of entropy separately for all syllable numbers in
%repeat
entest = struct();
for i = 1:maxlength
    entest.(['syll',num2str(i)]) = arrayfun(@(x) entext(x,i),fv_rep,...
        'UniformOutput',false);
    entest.(['syll',num2str(i)]) =  [cellfun(@(x) x(:,1),entest.(['syll',num2str(i)]))',...
        cellfun(@(x) x(:,2),entest.(['syll',num2str(i)]))'];
    ii = find(isnan(entest.(['syll',num2str(i)])(:,1)));
    entest.(['syll',num2str(i)])(ii,:) = [];
end


hold on; h = subtightplot(3,1,3,[0.05,0.05]);
for i = 1:length(fldnames)
    entcurrentsyll = entest.([fldnames{i}]);
    tbase = jc_tb(entcurrentsyll(:,1),'','');
    if length(entcurrentsyll) >= 50
        plot(h,tbase,mRunningAvg(...
            entcurrentsyll(:,2),50),'color',cmap(i,:));
        hold on;
    elseif length(entcurrentsyll) < 50 & length(entcurrentsyll) >=20
        plot(h,tbase,mRunningAvg(entcurrentsyll(:,2),20),'color',cmap(i,:));
        hold on;
    else
        plot(h,tbase,entcurrentsyll(:,2),'color',cmap(i,:));
        hold on;
    end
end
title('running average of wiener entropy for each syllable in repeat over time in seconds');

uistack(legend,'up')
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot running average of syllable durations and gaps separately 
figure(fignums(4));hold on;

sylldurs = struct();
for i = 1:maxlength
    sylldurs.(['syll',num2str(i)]) = arrayfun(@(x) sylldurext(x,i),fv_rep,...
        'UniformOutput',false);
    sylldurs.(['syll',num2str(i)]) =  [cellfun(@(x) x(:,1),sylldurs.(['syll',num2str(i)]))',...
        cellfun(@(x) x(:,2),sylldurs.(['syll',num2str(i)]))'];
    ii = find(isnan(sylldurs.(['syll',num2str(i)])(:,1)));
    sylldurs.(['syll',num2str(i)])(ii,:) = [];
end

h = subtightplot(2,1,1,[0.05, 0.05]);legend('-DynamicLegend');
hithresh = mean(sylldurations1(:,2)) + 3.5*std(sylldurations1(:,2));
lothresh = mean(sylldurations1(:,2)) - 3.5*std(sylldurations1(:,2));
for i = 1:length(fldnames)
    outliers = find(sylldurs.([fldnames{i}])(:,2) > hithresh | ...
        sylldurs.([fldnames{i}])(:,2) < lothresh);
    durcurrentsyll = sylldurs.([fldnames{i}]);
    durcurrentsyll(outliers,:) = [];
    if isempty(durcurrentsyll)
        continue
    end
    tbase = jc_tb(durcurrentsyll(:,1),'','');
    if length(durcurrentsyll) >= 50
        plot(h,tbase,mRunningAvg(...
            durcurrentsyll(:,2),50),'color',cmap(i,:),'DisplayName',...
            fldnames{i});
        hold on;
    elseif length(durcurrentsyll) < 50 & length(durcurrentsyll) >=20
        plot(h,tbase,mRunningAvg(durcurrentsyll(:,2),20),'color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    else
        plot(h,tbase,durcurrentsyll(:,2),'color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    end
end
legend(gca,'show');
title('running average of durations for each syllable in repeat over time in seconds')

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

h2 = subtightplot(2,1,2,[0.05, 0.05]);legend('-DynamicLegend');
gapfldnames = fieldnames(syllgaps);
hithresh = mean(syllgaps1(:,2)) + 3.5*std(syllgaps1(:,2));
lothresh = mean(syllgaps1(:,2)) - 3.5*std(syllgaps1(:,2));
for i = 1:length(gapfldnames)
    outliers = find(syllgaps.([gapfldnames{i}])(:,2) > hithresh | ...
        syllgaps.([gapfldnames{i}])(:,2) < lothresh);
    durcurrentsyll = syllgaps.([gapfldnames{i}]);
    durcurrentsyll(outliers,:) = [];
    tbase = jc_tb(durcurrentsyll(:,1),'','');
    if length(durcurrentsyll) >= 50
        plot(h2,tbase,mRunningAvg(...
            durcurrentsyll(:,2),50),'color',cmap(i,:),'DisplayName',...
            gapfldnames{i});
        hold on;
    elseif length(durcurrentsyll) < 50 & length(durcurrentsyll) >=20
        plot(h2,tbase,mRunningAvg(durcurrentsyll(:,2),20),'color',cmap(i,:),...
            'DisplayName',gapfldnames{i});
        hold on;
    else
        plot(h2,tbase,durcurrentsyll(:,2),'color',cmap(i,:),...
            'DisplayName',gapfldnames{i});
        hold on;
    end
end
legend(gca,'show');
title('running average of duration for each gap in repeat over time in seconds')
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%plot running CV of pitch, volume and entropy 
figure(fignums(5));hold on;

h = subtightplot(3,1,1,[0.05,0.05]);legend('-DynamicLegend');
hithresh = mean(pitchest1(:,2)) + 3.5*std(pitchest1(:,2));
lothresh = mean(pitchest1(:,2)) - 3.5*std(pitchest1(:,2));
for i = 1:length(fldnames)
    outliers = find(pitchest.([fldnames{i}])(:,2) > hithresh | ...
        pitchest.([fldnames{i}])(:,2) < lothresh);
    pitchestcurrentsyll = pitchest.([fldnames{i}]);
    pitchestcurrentsyll(outliers,:) = [];
    tbase = jc_tb(pitchestcurrentsyll(:,1),'','');
    if length(pitchestcurrentsyll) >= 50
        plot(h,tbase,mRunningCV(...
            pitchestcurrentsyll(:,2),50),'color',cmap(i,:),'DisplayName',...
            fldnames{i});
        hold on;
    elseif length(pitchestcurrentsyll) < 50 & length(pitchestcurrentsyll) >=20
        plot(h,tbase,mRunningCV(pitchestcurrentsyll(:,2),20),'color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    else
        continue
    end
end
legend(gca,'show')
title('running CV of pitch for syllables in repeat over time in seconds')

hold on; h = subtightplot(3,1,2,[0.05,0.05]);
for i = 1:length(fldnames)
    volcurrentsyll = volest.([fldnames{i}]);
    tbase = jc_tb(volcurrentsyll(:,1),'','');
    if length(volcurrentsyll) >= 50
        plot(h,tbase,mRunningCV(...
            volcurrentsyll(:,2),50),'color',cmap(i,:),'DisplayName',...
            fldnames{i});
        hold on;
    elseif length(volcurrentsyll) < 50 & length(volcurrentsyll) >=20
        plot(h,tbase,mRunningCV(volcurrentsyll(:,2),20),'color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    else
       continue
    end
end
title('running CV of volume for syllables in repeat over time in seconds')

hold on; h = subtightplot(3,1,3,[0.05,0.05]);
for i = 1:length(fldnames)
    entcurrentsyll = entest.([fldnames{i}]);
    tbase = jc_tb(entcurrentsyll(:,1),'','');
    if length(entcurrentsyll) >= 50
        plot(h,tbase,mRunningCV(...
            entcurrentsyll(:,2),50),'color',cmap(i,:),'DisplayName',...
            fldnames{i});
        hold on;
    elseif length(entcurrentsyll) < 50 & length(entcurrentsyll) >=20
        plot(h,tbase,mRunningCV(entcurrentsyll(:,2),20),'color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    else
        continue
    end
end
title('running CV of wiener entropy for syllables in repeat over time in seconds')

uistack(legend,'up')
hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%plot running CV or duration/gaps, xcorr
figure(fignums(6));hold on;

subtightplot(3,1,1,[0.05,0.05]);
plot(xcorrvals(:,1),mRunningCV(xcorrvals(:,2),100),'k');
title('running CV of xcorr duration over time in seconds')

hold on; h = subtightplot(3,1,2,[0.05,0.05]);legend('-DynamicLegend');
for i = 1:length(fldnames)
    durcurrentsyll = sylldurs.([fldnames{i}]);
    tbase = jc_tb(durcurrentsyll(:,1),'','');
    if length(durcurrentsyll) >= 50
        plot(h,tbase,mRunningCV(...
            durcurrentsyll(:,2),50),'color',cmap(i,:),'DisplayName',...
            fldnames{i});
        hold on;
    elseif length(durcurrentsyll) < 50 & length(durcurrentsyll) >=20
        plot(h,tbase,mRunningCV(durcurrentsyll(:,2),20),'color',cmap(i,:),...
            'DisplayName',fldnames{i});
        hold on;
    else
        continue
    end
end
legend(gca,'show');
title('running CV of durations for each syllable in repeat over time in seconds')

h2 = subtightplot(3,1,3,[0.05, 0.05]);legend('-DynamicLegend');
gapfldnames = fieldnames(syllgaps);
for i = 1:length(gapfldnames)
    durcurrentsyll = syllgaps.([gapfldnames{i}]);
    tbase = jc_tb(durcurrentsyll(:,1),'','');
    if length(durcurrentsyll) >= 50
        plot(h2,tbase,mRunningCV(...
            durcurrentsyll(:,2),50),'color',cmap(i,:),'DisplayName',...
            gapfldnames{i});
        hold on;
    elseif length(durcurrentsyll) < 50 & length(durcurrentsyll) >=20
        plot(h2,tbase,mRunningCV(durcurrentsyll(:,2),20),'color',cmap(i,:),...
            'DisplayName',gapfldnames{i});
        hold on;
    else
        continue
    end
end
legend(gca,'show');
title('running CV of duration for each gap in repeat over time in seconds')
hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot relative volumes, pitches,and entropy, durations, gaps for each repeat run
figure(fignums(7));hold on;

relativepitch = {};
hithresh = mean(pitchest1(:,2)) + 3.5*std(pitchest1(:,2));
lothresh = mean(pitchest1(:,2)) - 3.5*std(pitchest1(:,2));
for i = 1:length(fv_rep)
    if fv_rep(i).pitchest(1) == 0
        continue
    else
        outliers = find(fv_rep(i).pitchest > hithresh | fv_rep(i).pitchest < lothresh);
        relativepitch{i} = fv_rep(i).pitchest;
        relativepitch{i}(outliers) = NaN;
        if isnan(relativepitch{i}(1))
            continue
        else
            relativepitch{i} = relativepitch{i}./relativepitch{i}(1);%normalized to first syllable in repeat
        end
    end
end

relativepitch = cell2mat(cellfun(@(x) [x; NaN(maxlength-length(x),1)],...
    relativepitch,'UniformOutput',false));
x = 1:maxlength;
y1 = nanmean(relativepitch,2)+nanstderr(relativepitch,2);
y2 = nanmean(relativepitch,2)-nanstderr(relativepitch,2);
cmap = colormap(summer(3));
plot(x,y1,'Color',cmap(1,:));hold on;
plot(x,y2,'Color',cmap(1,:));
h1 = fill([x fliplr(x)],[y1' fliplr(y2')],cmap(1,:),'EdgeColor','none');
set(h1,'FaceAlpha',0.5)


relativevol = {};
for i = 1:length(fv_rep)
    if fv_rep(i).amp(1) == 0
        continue
    else
        relativevol{i} = fv_rep(i).amp/fv_rep(i).amp(1);%normalized to first syllable in repeat
    end
end

relativevol = cell2mat(cellfun(@(x) [x; NaN(maxlength-length(x),1)],...
    relativevol,'UniformOutput',false));
hold all;
y1 = nanmean(relativevol,2)+nanstderr(relativevol,2);
y2 = nanmean(relativevol,2) - nanstderr(relativevol,2);
plot(x,y1,'Color',cmap(1,:));hold on;
plot(x,y2,'Color',cmap(1,:));
h2 = fill([x fliplr(x)],[y1' fliplr(y2')],cmap(2,:),'EdgeColor','none');
set(h2,'FaceAlpha',0.5);


relativeent = {};
for i = 1:length(fv_rep)
    relativeent{i} = fv_rep(i).ent-fv_rep(i).ent(1);%normalized by subtraction of first syllable
end

relativeent = cell2mat(cellfun(@(x) [x; NaN(maxlength-length(x),1)],...
    relativeent,'UniformOutput',false));
hold all;
y1 = nanmean(relativeent,2)+nanstderr(relativeent,2);
y2 = nanmean(relativeent,2) - nanstderr(relativeent,2);
plot(x,y1,'Color',cmap(3,:));hold on;
plot(x,y2,'Color',cmap(3,:));
h3 = fill([x fliplr(x)],[y1' fliplr(y2')],cmap(3,:),'EdgeColor','none');
set(h2,'FaceAlpha',0.5);
legend([h1,h2,h3],'pitch','volume','entropy');
legend('boxoff');
title('pitch, volume, and entropy relative to syllable position in repeat')
xlabel('syllable number in repeat')

hold off;

%plot runlength, pitch estimate, syllable duration/gaps, xcorr, volume,
%entropy with bout assignments













peaksforcluster = [];
for i = 1:length(sp)
    [pks locs] = findpeaks(abs(sp(1:96,i)),'SortStr','descend');%below 6 kHz
    peaksforcluster = cat(1,peaksforcluster,f(locs(1:2)));
end

[idx cen] = kmeans(peaksforcluster,2); %2 peaks
dev = [3*std(peaksforcluster(idx == 1)),3*std(peaksforcluster(idx==2))];


fv = [];
npnts = 3;
for i = 1:length(sp)
    fdat = abs(sp(:,i));
    c = xcorr(fdat,'coeff');
    c = c(ceil(length(c)/2):end);
    [pks locs] = findpeaks(c);
    a = [];
    for ii = 1:length(cen)
        ind = find(f(locs) >= cen(ii)-dev(ii) & f(locs) <= cen(ii)+dev(ii));
        [mx id] = max(pks(ind));
        a = cat(1,a,locs(ind(id)));
    end
    a = [a(1) + [-npnts:npnts];a(2) + [-npnts:npnts]];
    fv = cat(2,fv,sort([dot(f(a(1,:)),fdat(a(1,:)))/sum(fdat(a(1,:)));...
        dot(f(a(2,:)),fdat(a(2,:)))/sum(fdat(a(2,:)))]));
end



















