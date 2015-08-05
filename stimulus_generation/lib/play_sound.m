function play_sound(wf,fs,dB)

lref = 100;
pref = 1/ 10^(lref/20);  % refrence for 120dB
boc_factor = pref * 10^(dB/20);
wf = boc_factor*wf;


ap = audioplayer(wf(:),fs);
ap.play();
pause(length(wf)/fs);
