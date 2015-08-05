function [vol_and_ent] = plotsafsim(cbin,sim_in,counters)
%
% cbin is song file, sim_in is struct with msaf_sim() parameters, counters
% is struct with temporal criteria
%
[voltrigs enttrigs rattrigs] = msaf_sim(cbin,sim_in);

%temporal filtering with counters:
voltrigs_filt = counterfilt(voltrigs,counters.volmin);


[enttrigs_filt entmin] = counterfilt(enttrigs,counters.entmin);
rattrigs_filt = counterfilt(rattrigs,counters.ratmin);

%note hardcodes:
fs = 32000;
nfft = 256;

timebase = maketimebase(length(voltrigs),fs/nfft);

% there's probably a better way to do this: 
vol_and_ent = voltrigs_filt & enttrigs_filt;
vol_or_ent = voltrigs_filt | enttrigs_filt;
vol_and_rat = voltrigs_filt & rattrigs_filt;
vol_or_rat = voltrigs_filt | rattrigs_filt;
ent_and_rat = enttrigs_filt & rattrigs_filt;
ent_or_rat = enttrigs_filt | rattrigs_filt;
vol_and_ent_or_rat = vol_and_ent | rattrigs_filt;
vol_or_ent_and_rat = vol_or_ent & rattrigs_filt;


alltrigs = vol_and_rat & enttrigs_filt;
anytrigs = voltrigs_filt | enttrigs_filt | rattrigs_filt;
  
% 
% plots volume, filtered volume, & the running min/max counters for volume:
% figure();temp_ax(6) = subplot(5,1,1);mplotcbin(cbin,[]);
% 
% temp_ax(7)=subplot(5,1,2);bar(timebase,voltrigs,'b');
% title('volume');
% ylim([-0.25 1.25]);
% temp_ax(8)=subplot(5,1,3);bar(timebase,voltrigs_filt,'r');
% ylim([-0.25 1.25]);
% 
% temp_ax(9)=subplot(5,1,4);bar(timebase,entmin);
% title('volume counters min & max');
% 
% 
% ylim([-0.25 1.25]);
% temp_ax(10)=subplot(5,1,5);bar(timebase,entmax);


% linkaxes(temp_ax,'x');

% modify to allow flexible plotting of logical possibilities 
figure();
simax(6)=subplot(7,1,1);mplotcbin(cbin,[]);

simax(7)=subplot(7,1,2);bar(timebase,voltrigs,'b');
title('volume');
ylim([-0.25 1.25]);
simax(8)=subplot(7,1,3);bar(timebase,voltrigs_filt,'r');
ylim([-0.25 1.25]);

simax(9)=subplot(7,1,4);bar(timebase,enttrigs,'b');
title('entropy');
ylim([-0.25 1.25]);
simax(10)=subplot(7,1,5);bar(timebase,enttrigs_filt,'r');
ylim([-0.25 1.25]);

simax(11)=subplot(7,1,6);bar(timebase,rattrigs,'b');
title('high/low freq ratio');
ylim([-0.25 1.25]);
simax(12)=subplot(7,1,7);bar(timebase,rattrigs_filt,'r');
ylim([-0.25 1.25]);

%linkaxes(temp_ax,'x');
% 
figure();
simax(4) = subplot(6,1,1:2);mplotcbin(cbin,[]);

simax(1) = subplot(6,1,3);bar(timebase,vol_and_ent,'r');
title('volume & entropy');
ylim([-0.25 1.25]);

simax(2)=subplot(6,1,4);bar(timebase,voltrigs_filt,'b');
title('volume');
ylim([-0.25 1.25]);

simax(3)=subplot(6,1,5);bar(timebase,enttrigs_filt,'b');
title('entropy');
ylim([-0.25 1.25]);

simax(5)=subplot(6,1,6);bar(timebase,rattrigs_filt,'b');
title('high/low ratio');
ylim([-0.25 1.25]);

linkaxes(simax,'x');
