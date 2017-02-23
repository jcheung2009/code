function jc_pitch_vs_boutlength(boutinfo,marker,motif)
%this function plots the correlation between pitch of a target syllable
%sung at the beginning or end of bout with the bout length (number of times
%that syllable is sung in that bout, ~motif)

%% plot correlation between pitch of first syllable and bout length
pitch_vs_lngth = cell2mat(arrayfun(@(x) [x.nummotifs x.boutpitch(1,:)],boutinfo,'unif',0)');
removeind = jc_findoutliers(pitch_vs_lngth,3);
pitch_vs_lngth(removeind,:) = [];
removeind = find(isnan(pitch_vs_lngth(:,2)));
pitch_vs_lngth(removeind,:) = [];
numsylls = size(boutinfo(1).boutpitch,2);

figure;hold on;
for i = 1:numsylls
    subtightplot(numsylls,1,i,[0.08 0.08],[0.08 0.08],0.15);hold on;
    plot(pitch_vs_lngth(:,1),pitch_vs_lngth(:,i+1),marker);hold on;
    [r p] = corr(pitch_vs_lngth(:,1),pitch_vs_lngth(:,i+1));
    m = polyfit(pitch_vs_lngth(:,1),pitch_vs_lngth(:,i+1),1);
    refline(m(1),m(2));hold on;
    ylim = get(gca,'ylim');
    xlim = get(gca,'xlim');
    text(xlim(1),ylim(2),{['r=',num2str(r)];['p=',num2str(p)]});
    ylabel('pitch of first');
    xlabel('bout length');
    set(gca,'fontweight','bold');
    title(['bout ',motif]);
end

%% plot correlation between pitch of last syllable and bout length
pitch_vs_lngth = cell2mat(arrayfun(@(x) [x.nummotifs x.boutpitch(end,:)],boutinfo,'unif',0)');
%pitch_vs_lngth = cell2mat(arrayfun(@(x) [x.nummotifs x.boutpitch(end,:)./x.boutpitch(1,:)],boutinfo,'unif',0)');
removeind = jc_findoutliers(pitch_vs_lngth,3);
pitch_vs_lngth(removeind,:) = [];
removeind = find(isnan(pitch_vs_lngth(:,2)));
pitch_vs_lngth(removeind,:) = [];
numsylls = size(boutinfo(1).boutpitch,2);

figure;hold on;
for i = 1:numsylls
    subtightplot(numsylls,1,i,[0.08 0.08],[0.08 0.08],0.15);hold on;
    plot(pitch_vs_lngth(:,1),pitch_vs_lngth(:,i+1),marker);hold on;
    [r p] = corr(pitch_vs_lngth(:,1),pitch_vs_lngth(:,i+1));
    m = polyfit(pitch_vs_lngth(:,1),pitch_vs_lngth(:,i+1),1);
    refline(m(1),m(2));hold on;
    ylim = get(gca,'ylim');
    xlim = get(gca,'xlim');
    text(xlim(1),ylim(2),{['r=',num2str(r)];['p=',num2str(p)]});
    ylabel('pitch of last');
    xlabel('bout length');
    set(gca,'fontweight','bold');
    title(['bout ',motif]);
end