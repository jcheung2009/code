% Stim generation for krank for Helen

% /net/penguin/gkim/code/stimgen

gk_song_edit
gk_song_edit_tmp

gk_songfiltnorm
%--> Have a batch file with *.raw filename from above
% --> ignore "save?" question at the end.

gk_songensemblestats
%--> Have a batch file with *.raw filename from above
%--> songstd_glob (rms for the stim segment)
% 20*log10(rms) + 25.2 - 85 = xx dB : attenuation factor


gk_set_gain
gk_set_gain_each
% provide atteunation factor
% new raw file with new gain

gk_add_ramp_silence

