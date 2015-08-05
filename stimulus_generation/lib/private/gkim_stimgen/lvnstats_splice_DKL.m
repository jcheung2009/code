savefile1 = '/pipit/bdwright/sangsong/lvnstats_susasongs_T0.1to3.0ms.mat'
savefile2 = '/pipit/bdwright/sangsong/lvnstats_susasongs_T3.2to20.0ms.mat'

results1 = load(savefile1,'smwin_dur','DKL_gausslvn2','DKL_lvngauss2');
results2 = load(savefile2,'smwin_dur','DKL_gausslvn2','DKL_lvngauss2');

smwin_dur = [results1.smwin_dur results2.smwin_dur]
DKL_gausslvn2 = [results1.DKL_gausslvn2 results2.DKL_gausslvn2]
DKL_lvngauss2 = [results1.DKL_lvngauss2 results2.DKL_lvngauss2]

figure
plot(smwin_dur,DKL_gausslvn2)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(N||P) (bits)')
title('D_{KL} using better Gaussian estimate')

figure
plot(smwin_dur,DKL_lvngauss2)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(P||N) (bits)')
title('D_{KL} using better Gaussian estimate')

figure
semilogy(smwin_dur,DKL_gausslvn2)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(N||P) (bits)')
title('D_{KL} using better Gaussian estimate')

figure
semilogy(smwin_dur,DKL_lvngauss2)
xlabel('LV window duration (msec)')
ylabel('D_{KL}(P||N) (bits)')
title('D_{KL} using better Gaussian estimate')


[DKL_min, iw_min] = min(DKL_lvngauss2)
lvwin_min = smwin_dur(iw_min)

[DKL2_min, iw2_min] = min(DKL_gausslvn2)
lvwin2_min = smwin_dur(iw2_min)

