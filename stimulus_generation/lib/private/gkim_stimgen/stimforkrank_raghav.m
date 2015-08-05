% List of functions for generating stimulus files for multikrank



% /net/penguin/gkim/code/stimgen

gk_song_edit_v2


gk_songfiltnorm
%--> Have a batch file with *.raw filename from above
% --> ignore "save?" question at the end.

song = gk_soundin('/home/raghav/AcuteHVCRecordings/b95w55','b95w55_101710191237_seg1_G65535.0-0.0i_Fs32.raw','b');


gk_songensemblestats
%--> Have a batch file with *.raw filename from above
%--> songstd_glob (rms for the stim segment)
% 20*log10(rms) + 25.2 - 85 = xx dB : attenuation factor


12.7083
gk_set_gain
gk_set_gain_each
% provide atteunation factor
% new raw file with new gain

gk_add_ramp_silence

song = gk_soundin('/home/raghav/AcuteHVCRecordings/b95w55','b95w55_101710191237_seg1_G1.9_Fs32_G0.23152_r50_bz2000_ez2000.raw','b');
song2 = flipud(song);
filename = 'b95w55_101710191237_seg1_G1.9_Fs32_G0.23152_r50_bz2000_ez2000_reversed.raw'
fid = fopen(filename,'wb','b');
fwrite(fid, song2, 'int16');
fclose(fid);


% to listen to the file using sox
play -x -r 32000 -s w -f s b95w55_101710191237_seg1_G1.9_Fs32_G0.23152_r50_bz2000_ez2000.raw
play -x -r 32000 -s w -f s b95w55_101710191237_seg1_G1.9_Fs32_G0.23152_r50_bz2000_ez2000_reversed.raw