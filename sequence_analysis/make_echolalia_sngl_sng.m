function [] = make_echolalia_sngl_sng(sngfile,ftype,notmatfile);

load(char(notmatfile));
mtrx = [onsets offsets];
save sngl_sng.txt mtrx -ASCII -TABS
save sng_syls.txt labels -ASCII -TABS

[x,fs] = soundin('',sngfile,char(ftype));
f_sng=bandpass(x,fs,300,10000,'hanningfir');
wavwrite(.99*(f_sng./max(abs(f_sng))),32e3,16,'sng.wav');