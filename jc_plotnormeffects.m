function jc_plotnormeffects(fv_sal, fv_cond,marker,linecolor)
%lab meeting 7-16-2015
%fv_sal = {fv structures for saline condition}
%fv_cond = {fv structures for drug condition}


pitchest_sal_n = [];
entest_sal_n = [];
volest_sal_n = [];
for i = 1:length(fv_sal)
    pitchest_sal_n = [pitchest_sal_n; [fv_sal{i}(:).mxvals]'./mean([fv_sal{i}(:).mxvals])];
    entest_sal_n = [entest_sal_n; [fv_sal{i}(:).we]'./mean([fv_sal{i}(:).we])];
    volest_sal_n = [volest_sal_n; [fv_sal{i}(:).maxvol]'./mean([fv_sal{i}(:).maxvol])];
end

pitchest_cond_n = [];
entest_cond_n = [];
volest_cond_n = [];
for i = 1:length(fv_cond)
    pitchest_cond_n = [pitchest_cond_n; [fv_cond{i}(:).mxvals]'./mean([fv_sal{i}(:).mxvals])];
    entest_cond_n = [entest_cond_n; [fv_cond{i}(:).we]'./mean([fv_sal{i}(:).we])];
    volest_cond_n = [volest_cond_n; [fv_cond{i}(:).maxvol]'./mean([fv_sal{i}(:).maxvol])];
end

fignum = input('figure for plotting normalized effects:');
figure(fignum);hold on;
subtightplot(1,3,1,0.05);hold on;
plot(1,mean(pitchest_sal_n),marker,[1 1],[mean(pitchest_sal_n)+stderr(pitchest_sal_n),...
    mean(pitchest_sal_n)-stderr(pitchest_sal_n)],linecolor);hold on;
plot(2,mean(pitchest_cond_n),marker,[2 2],[mean(pitchest_cond_n)+stderr(pitchest_cond_n),...
    mean(pitchest_cond_n)-stderr(pitchest_cond_n)],linecolor);hold on;
plot([1 2],[mean(pitchest_sal_n) mean(pitchest_cond_n)],linecolor);hold on;
title('Pitch');
xlim([0.5 2.5]);
ylabel('normalized change');

subtightplot(1,3,2,0.05);hold on;
plot(1,mean(volest_sal_n),marker,[1 1],[mean(volest_sal_n)+stderr(volest_sal_n),...
    mean(volest_sal_n)-stderr(volest_sal_n)],linecolor);hold on;
plot(2,mean(volest_cond_n),marker,[2 2],[mean(volest_cond_n)+stderr(volest_cond_n),...
    mean(volest_cond_n)-stderr(volest_cond_n)],linecolor);hold on;
plot([1 2],[mean(volest_sal_n) mean(volest_cond_n)],linecolor);hold on;
title('Volume');
xlim([0.5 2.5]);
ylabel('normalized change');

subtightplot(1,3,3,0.05);hold on;
plot(1,mean(entest_sal_n),marker,[1 1],[mean(entest_sal_n)+stderr(entest_sal_n),...
    mean(entest_sal_n)-stderr(entest_sal_n)],linecolor);hold on;
plot(2,mean(entest_cond_n),marker,[2 2],[mean(entest_cond_n)+stderr(entest_cond_n),...
    mean(entest_cond_n)-stderr(entest_cond_n)],linecolor);hold on;
plot([1 2],[mean(entest_sal_n) mean(entest_cond_n)],linecolor);hold on;
title('Entropy');
xlim([0.5 2.5]);
ylabel('normalized change');

