function wf = add_noise(wf,snr)

wf = wf(:); 
rms0 = rms(wf);
wf = wf/rms0;
noise = randn(size(wf))/db2mag(snr);
noise = cut_segment(noise,20e3,0,length(wf)/20e3); 
wf = wf + noise; 
wf = wf./rms(wf);
wf = wf*rms0; 

