%preference for single units to fire relative to target gap or syll onset

[PSTHs, spiketrains, PSTHs_rand, spiketrains_rand] = firing_phase(...
    'singleunits_leq_1pctISI_2pcterr',6,25,0,10,'gap');

[hi lo] = mBootstrapCI2(PSTHs);
figure;hold on;
patch([-100:100,fliplr(-100:100)],[hi fliplr(lo)],'r','edgecolor','none','facealpha',0.5);hold on;

[hi lo] = mBootstrapCI2(PSTHs_rand);
patch([-100:100,fliplr(-100:100)],[hi fliplr(lo)],'k','edgecolor','none','facealpha',0.5);hold on;

ylabel('firing rate (hz)');xlabel('time relative to gap onset (ms)');

[PSTHs, spiketrains, PSTHs_rand, spiketrains_rand] = firing_phase(...
    'singleunits_leq_1pctISI_2pcterr',5,25,0,10,'sylls');

[hi lo] = mBootstrapCI2(PSTHs);
figure;hold on;
patch([-100:100,fliplr(-100:100)],[hi fliplr(lo)],'r','edgecolor','none','facealpha',0.5);hold on;

[hi lo] = mBootstrapCI2(PSTHs_rand);
patch([-100:100,fliplr(-100:100)],[hi fliplr(lo)],'k','edgecolor','none','facealpha',0.5);hold on;
ylabel('firing rate (hz)');xlabel('time relative to syll onset (ms)');