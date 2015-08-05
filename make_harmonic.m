function h=make_harmonic(ff)

%make a harmonic stim with equal amplitude components; ff=ff
% over range 0 to 8kHz
% roughly 1 second in duration
%sample rate =20k

max_freq=8000;
Fs=20000;
h=zeros(1,Fs);
nh=round(max_freq/ff);

for i=1:nh

ch=sin(2*pi*[1:i*ff/Fs:2*Fs]);
h=h+ch(1:Fs);

end


