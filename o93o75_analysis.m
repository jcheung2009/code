%o93o75 analysis
%clustering a's 

volentpitch = [];
cmap = hsv(3);
C = [];
for i = 1:length(fv_rep)
    volentpitch = [volentpitch; [log(fv_rep(i).amp), fv_rep(i).pitchest, fv_rep(i).ent]];
    numlength = length(fv_rep(i).pitchest);
    if numlength >= 3
        C = [C; cmap(1,:); cmap(2,:); repmat(cmap(3,:),length(fv_rep(i).pitchest)-2,1)];
    elseif numlength == 2 
        C = [C; cmap(1,:); cmap(2,:)];
    elseif numlength == 1
        C = [C; cmap(1,:)];
    end
end

syll1 = arrayfun(@(x) x.sylldurations(1),fv_rep)';
syll2 = [];
syl3 = [];
for i = 1:length(fv_rep)
    if numel(fv_rep(i).sylldurations) > 1
        syll2 = [syll2; fv_rep(i).sylldurations(2)];
    end
    if numel(fv_rep(i).sylldurations) > 2
        syll3 = [syll3; fv_rep(i).sylldurations(3:end)];
    end
end
figure;hold on;
[n b] = hist(syll1,[0.025:0.005:0.155]);
stairs(b,n/sum(n),'r','Linewidth',2);
%h = findobj(gca,'Type','patch');set(h,'FaceAlpha',0.5);
hold on;
[n b] = hist(syll2,[0.025:0.005:0.155]);
stairs(b,n/sum(n),'g','linewidth',2);
%h = findobj(gca,'Type','patch');set(h,'FaceAlpha',0.5);
hold on;
[n b] = hist(syll3,[0.025:0.005:0.155]);
stairs(b,n/sum(n),'b','linewidth',2);
%h = findobj(gca,'Type','patch');set(h,'FaceAlpha',0.5);


gap1 = [];
gap2 = [];
gap3 = [];
for i = 1:length(fv_rep)
    if numel(fv_rep(i).syllgaps) > 0
        gap1 = [gap2;fv_rep(i).syllgaps(1)];
    end
    if numel(fv_rep(i).syllgaps) > 1
        gap2 = [gap2; fv_rep(i).syllgaps(2)];
    end
    if numel(fv_rep(i).syllgaps) > 2
        gap3 = [gap3; fv_rep(i).syllgaps(3:end)];
    end
end
figure;hold on;
[n b] = hist(gap1,[0.01:0.005:0.06]);
bar(b,n/sum(n),1,'r','edgecolor','none');
h = findobj(gca,'Type','patch');set(h,'FaceAlpha',0.5);
hold on;
[n b] = hist(gap2,[0.01:0.005:0.06]);
bar(b,n/sum(n),1,'g','edgecolor','none');
h = findobj(gca,'Type','patch');set(h,'FaceAlpha',0.5);
hold on;
[n b] = hist(gap3,[0.01:0.005:0.06]);
bar(b,n/sum(n),1,'b','edgecolor','none');
h = findobj(gca,'Type','patch');set(h,'FaceAlpha',0.5);

countAb = 0;
countAA = 0;
countAstop = 0;
fv_repAb = fv_repAb_3_24_sal;
fv_repAstop = fv_repAstop_3_24_sal;
for i = 1:length(fv_repAb)
    countAb = countAb+1;
    countAA = countAA + fv_repAb(i).runlength-3;
end
for i = 1:length(fv_repAstop)
    countAstop = countAstop+1;
    countAA = countAA + fv_repAstop(i).runlength-3;
end

%bootstrap probability statistics
ff = load_batchf('batch.keep');
alllabels = {};
for i = 1:length(ff)
    fn = ff(i).name;
    load([fn,'.not.mat']);
    alllabels{i} = labels;
end

numreps = 10000;
shuffvectAb = zeros(1,numreps);
shuffvectAA = zeros(1,numreps);
shuffvectAstop = zeros(1,numreps);
for i = 1:numreps
    fileind = randi(length(alllabels),1,length(alllabels));
    countAb = 0;
    countAA = 0;
    countAstop = 0;
    for n = 1:length(fileind)
        labels = alllabels{fileind(n)};
        Ab = '[a]+b';
        Astop = '[a]+i';
        [p pend] = regexp(labels,Ab);
        runlengthAb = pend-p;
        if ~isempty(runlengthAb)
            countAb = countAb+1;
            countAA = countAA+sum(runlengthAb-3);
        end
        [k kend] = regexp(labels,Astop);
        runlengthAstop = kend-k;
        if ~isempty(runlengthAstop)
            countAstop=countAstop+1;
            countAA=countAA+sum(runlengthAstop-3);
        end
    end
    probAb = countAb/(countAb+countAA+countAstop);
    probAA = countAA/(countAb+countAA+countAstop);
    probAstop = countAstop/(countAb+countAA+countAstop);
    shuffvectAb(i) = probAb;
    shuffvectAA(i) = probAA;
    shuffvectAstop(i) = probAstop;
end
shuffvectAb = sort(shuffvectAb);
shuffvectAA = sort(shuffvectAA);
shuffvectAstop = sort(shuffvectAstop);

hiconfAA = shuffvectAA(fix(length(shuffvectAA)*0.95));
loconfAA = shuffvectAA(fix(length(shuffvectAA)*0.05));

hiconfAb = shuffvectAb(fix(length(shuffvectAb)*0.95));
loconfAb = shuffvectAb(fix(length(shuffvectAb)*0.05));
    
hiconfAstop = shuffvectAstop(fix(length(shuffvectAstop)*0.95));
loconfAstop = shuffvectAstop(fix(length(shuffvectAstop)*0.05));

plot(1,mean(shuffvectAb),'r.',[1 1],[loconfAb hiconfAb],'r');hold on;
plot(2,mean(shuffvectAA),'r.',[2 2],[loconfAA hiconfAA],'r');hold on;
plot(3,mean(shuffvectAstop),'r.',[3 3],[loconfAstop hiconfAstop],'r');hold on;

%permutation test
ff_sal = load_batchf('batch.keep');
nsal = length(ff_sal);
all_labels = {};
for i = 1:nsal
    fn = ff_sal(i).name;
    load([fn,'.not.mat']);
    all_labels{i} = labels;
end
ff_naspm = load_batchf('batch.keep');
nnaspm = length(ff_naspm);
for i = 1:nnaspm
    fn = ff_naspm(i).name;
    load([fn,'.not.mat']);
    all_labels{i+nsal} = labels;
end

numreps = 1000;
diffAb = zeros(1,numreps);
diffAA = zeros(1,numreps);
diffAstop = zeros(1,numreps);
for i = 1:numreps
    %saline sample
    samp_sal = randi(length(all_labels),1,nsal);
    countAb = 0;
    countAA = 0;
    countAstop = 0;
    for n = 1:length(samp_sal)
        labels = all_labels{samp_sal(n)};
        Ab = '[a]+b';
        Astop = '[a]+i';
        [p pend] = regexp(labels,Ab);
        runlengthAb = pend-p;
        if ~isempty(runlengthAb)
            countAb = countAb+1;
            countAA = countAA+sum(runlengthAb-3);
        end
        [k kend] = regexp(labels,Astop);
        runlengthAstop = kend-k;
        if ~isempty(runlengthAstop)
            countAstop=countAstop+1;
            countAA=countAA+sum(runlengthAstop-3);
        end
    end
    probAb = countAb/(countAb+countAA+countAstop);
    probAA = countAA/(countAb+countAA+countAstop);
    probAstop = countAstop/(countAb+countAA+countAstop);
    %naspm sample
    samp_naspm = randi(length(all_labels),1,nnaspm);
    countAb_naspm = 0;
    countAA_naspm = 0;
    countAstop_naspm = 0;
    for n = 1:length(samp_naspm)
        labels = all_labels{samp_naspm(n)};
        Ab = '[a]+b';
        Astop = '[a]+i';
        [p pend] = regexp(labels,Ab);
        runlengthAb = pend-p;
        if ~isempty(runlengthAb)
            countAb_naspm = countAb_naspm+1;
            countAA_naspm = countAA_naspm+sum(runlengthAb-3);
        end
        [k kend] = regexp(labels,Astop);
        runlengthAstop = kend-k;
        if ~isempty(runlengthAstop)
            countAstop_naspm=countAstop_naspm+1;
            countAA_naspm=countAA_naspm+sum(runlengthAstop-3);
        end
    end
    probAb_naspm = countAb_naspm/(countAb_naspm+countAA_naspm+countAstop_naspm);
    probAA_naspm = countAA_naspm/(countAb_naspm+countAA_naspm+countAstop_naspm);
    probAstop_naspm = countAstop_naspm/(countAb_naspm+countAA_naspm+countAstop_naspm);
    
    diffAb(i) = probAb_naspm-probAb;
    diffAA(i) = probAA_naspm-probAA;
    diffAstop(i) = probAstop_naspm-probAstop;
end
diffAb = sort(diffAb);
diffAA = sort(diffAA);
diffAstop = sort(diffAstop);

hiconfdiffAb = diffAb(fix(length(diffAb)*0.95));
loconfdiffAb = diffAb(fix(length(diffAb)*0.05));

hiconfdiffAA = diffAA(fix(length(diffAA)*0.95));
loconfdiffAA = diffAA(fix(length(diffAA)*0.05));

hiconfdiffAstop = diffAb(fix(length(diffAstop)*0.95));
loconfdiffAstop = diffAb(fix(length(diffAstop)*0.05));


figure;hold on;
plot([1 1],[hiconfdiffAb loconfdiffAb],'k');hold on;
plot(1,Ab_naspm-Ab_sal,'r.','markersize',20);
plot([2 2],[hiconfdiffAA loconfdiffAA],'k');hold on;
plot(2,AA_naspm-AA_sal,'r.','markersize',20);
plot([3 3],[hiconfdiffAstop loconfdiffAstop],'k');hold on;
plot(3,Astop_naspm-Astop_sal,'r.','markersize',20);

% plot specific gaps and durations

firstpeakdistance = [];sylldurations = [];gaps = [];
    for i = 1:length(motifinfo)
        if ~isempty(motifinfo(i).firstpeakdistance)
            firstpeakdistance = [firstpeakdistance; [motifinfo(i).datenm motifinfo(i).firstpeakdistance]];
        end
        sylldurations = [sylldurations; [motifinfo(i).datenm motifinfo(i).durations(1)]];
        gaps = [gaps;[motifinfo(i).datenm mean(motifinfo(i).gaps)]];
    end
    
     tb_syllduration = jc_tb(sylldurations(:,1),7,0);
    h = plot(tb_syllduration,sylldurations(:,2),marker);
    removeoutliers = input('remove outliers? (y/n):','s');
    while removeoutliers == 'y'
        delete(h)
        ind = jc_findoutliers(sylldurations(:,2),3.5);
        sylldurations(ind,:) = [];
        tb_syllduration(ind) = [];
        h = plot(tb_syllduration,sylldurations(:,2),marker);
        removeoutliers = input('remove outliers? (y/n):','s');
    end
    hold on;
    runningaverage = jc_RunningAverage(sylldurations(:,2),50);
    fill([tb_syllduration' fliplr(tb_syllduration')],[runningaverage(:,1)'-runningaverage(:,2)',...
    fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,...
    'EdgeColor','none','FaceAlpha',0.5);
    
%%% spectral patterhs in repeat 

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
for i = 1:length(fldnames)
    plot(i,mean(pitchest.([fldnames{i}])(:,2)),marker,[i i],[mean(pitchest.([fldnames{i}])(:,2))+stderr(pitchest.([fldnames{i}])(:,2)),...
        mean(pitchest.([fldnames{i}])(:,2))-stderr(pitchest.([fldnames{i}])(:,2))],linecolor);hold on;
end

meanpitchest = [];
for i = 1:length(fldnames)
    meanpitchest = [meanpitchest;mean(pitchest.([fldnames{i}])(:,2))];
end
hold on;
plot(meanpitchest,linecolor);hold on;

volest = struct();
for i = 1:maxlength
    volest.(['syll',num2str(i)]) = arrayfun(@(x) volext(x,i),fv_rep,...
        'UniformOutput',false);
    volest.(['syll',num2str(i)]) =  [cellfun(@(x) x(:,1),volest.(['syll',num2str(i)]))',...
        cellfun(@(x) log(x(:,2)),volest.(['syll',num2str(i)]))'];
    ii = find(isnan(volest.(['syll',num2str(i)])(:,1)));
    volest.(['syll',num2str(i)])(ii,:) = [];
end
fldnames = fieldnames(volest);
for i = 1:length(fldnames)
    plot(i,mean(volest.([fldnames{i}])(:,2)),marker,[i i],[mean(volest.([fldnames{i}])(:,2))+stderr(volest.([fldnames{i}])(:,2)),...
        mean(volest.([fldnames{i}])(:,2))-stderr(volest.([fldnames{i}])(:,2))],linecolor);hold on;
end

meanvolest = [];
for i = 1:length(fldnames)
    meanvolest = [meanvolest;mean(volest.([fldnames{i}])(:,2))];
end
hold on;
plot(meanvolest,linecolor);hold on;

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
for i = 1:length(fldnames)
    ind = find(abs(entest.([fldnames{i}])(:,2)) == Inf);
    entest.([fldnames{i}])(ind,:) = [];
    plot(i,mean(entest.([fldnames{i}])(:,2)),marker,[i i],[mean(entest.([fldnames{i}])(:,2))+stderr(entest.([fldnames{i}])(:,2)),...
        mean(entest.([fldnames{i}])(:,2))-stderr(entest.([fldnames{i}])(:,2))],linecolor);hold on;
end


meanentest = [];
for i = 1:length(fldnames)
    meanentest = [meanentest;mean(entest.([fldnames{i}])(:,2))];
end
hold on;
plot(meanentest,linecolor);hold on;

%% spec and repeat length correlation
pitchpattern_by_length = struct();
volpattern_by_length= struct();
entpattern_by_length =struct();
durpattern_by_length=struct();
gappattern_by_length= struct();
maxlength = max(arrayfun(@(x) numel(x.pitchest),fv_rep));
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

%%
fv_naspm = {fv_syllA_11_19_naspm fv_syllA_11_20_naspm}; 
fv_sal = {fv_syllA_11_19_sal; fv_syllA_11_20_sal};

pitchest_sal_n = [[fv_sal{1}(:).mxvals]./mean([fv_sal{1}(:).mxvals]) [fv_sal{2}(:).mxvals]./mean([fv_sal{2}(:).mxvals])];
pitchest_naspm_n = [[fv_naspm{1}(:).mxvals]./mean([fv_sal{1}(:).mxvals]) [fv_naspm{2}(:).mxvals]./mean([fv_sal{2}(:).mxvals])];
entest_sal_n = [[fv_sal{1}(:).we]./mean([fv_sal{1}(:).we]) [fv_sal{2}(:).we]./mean([fv_sal{2}(:).we])];
entest_naspm_n = [[fv_naspm{1}(:).we]./mean([fv_sal{1}(:).we]) [fv_naspm{2}(:).we]./mean([fv_sal{2}(:).we])];
volest_sal_n = 

%% checking labels to see that they match onsets after using changelabel
ff = load_batchf('batch.keep')
for i = 1:length(ff)
    load([ff(i).name,'.not.mat']);
    if length(labels)~=length(onsets)
        disp(ff(i).name);
    end
end



