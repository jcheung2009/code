function jc_plotrepeatvals(fv_rep,marker,linecolor)
%fv_rep from jc_findrepeat2 or jc_findrepeat3
%does not plot spectral values in repeat
%use jc_repeatanalysis2 for spectral measurements
fs = 32000;

%plot repeat length
fignum = input('figure for repeat measurements:');
figure(fignum);hold on;
replength = [jc_tb([fv_rep(:).datenm]',7,0) [fv_rep(:).runlength]'];
subtightplot(3,1,1,0.07,0.05,0.08);hold on;
plot(replength(:,1),replength(:,2),marker);
ylabel('Repeat length (number of syllables)');
xlabel('Time (seconds since lights on)');
title('Number of syllables in repeat');

%plot average syllable and gap duration
sylldur = [];
gapdur = [];
tb_sylldur = jc_tb([fv_rep(:).datenm]',7,0);
tb_gapdur = jc_tb([fv_rep(:).datenm]',7,0);
for i = 1:length(fv_rep)
    sylldur = [sylldur; nanmean(fv_rep(i).sylldurations)];
    gapdur = [gapdur; nanmean(fv_rep(i).syllgaps)];
end

subtightplot(3,1,2,0.07,0.05,0.08);hold on;
h = plot(tb_sylldur,sylldur,marker);hold on;
removeoutliers = input('remove outliers?:','s');
while removeoutliers == 'y'
    nstd = input('use nstd:');
    delete(h);
    ind = jc_findoutliers(sylldur,nstd);
    tb_sylldur(ind) = [];
    sylldur(ind) = [];
    h = plot(tb_sylldur, sylldur,marker);
    removeoutliers = input('remove outliers?:','s');
end
ylabel('Average syllable duration (s)');
xlabel('Time (seconds since lights on)');
title('Average syllable duration in repeat');

subtightplot(3,1,3,0.07,0.05,0.08);hold on;
h = plot(tb_gapdur,gapdur,marker);hold on;
removeoutliers = input('remove outliers?:','s');
while removeoutliers == 'y'
    nstd = input('use nstd:');
    delete(h);
    ind = jc_findoutliers(gapdur,nstd);
    tb_gapdur(ind) = [];
    gapdur(ind) = [];
    h = plot(tb_gapdur, gapdur,marker);
    removeoutliers = input('remove outliers?:','s');
end
ylabel('Average gap duration (s)');
xlabel('Time (seconds since lights on)');
title('Average gap duration in repeat');
