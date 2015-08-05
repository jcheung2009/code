function gk_gen_silence

% Generates silent stim file (ie just zeros) for recording spontaneous
% activity

Fs = 40000
stimlen_sec = input('Enter the length of silence (in sec) :   ')

stimlen = stimlen_sec*Fs
stim = zeros(stimlen,1);

figure
plot((0:stimlen-1)/Fs, stim)
% pause

fid = fopen(['/net/penguin1/gkim/stim/ripple_gk/silence_30sec.raw'],'wb','b');
fwrite(fid, stim,'int16');
fclose(fid);