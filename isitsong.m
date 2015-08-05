function [param]=isitsong(song,fs);
% function [param]=isitsong(song,fs);
%
%  Characterizes a "song" file (as returned by soundin) (fs
%  argument optional -- assumes 32000 if left out) by one number as
%  "param" -- usually <=1.0 if the file is just noise, and >1.0
%     At present, this looks at the song between 1000 Hz and 5000
%     Hz, and then counts notes, defined to be regions in which the
%     amplitude in that frequency range is more than 4 times the
%     mean value.
%

m=0;

%old (commented out version);
%  Characterizes a "song" file (as returned by soundin) (fs
%  argument optional -- assumes 32000 if left out) by one number as
%  "param" -- usually ==1.0 if the file is just noise, and >1.0
%  if it has any song-like qualities -- essentially any higher
%  frequency peaks in the spectral distribution of the entire
%  file.  Just noise would be expected to have a 1/f distribution,
%  and broad-band noise (i.e. wing-flaps, seed-crunches, etc.)
%  should ha

if nargin==1
  fs=32000;
end

fone=ceil(length(song)*1000/(fs/2)); % fone=1000 Hz.
ftwo=ceil(length(song)*5000/(fs/2)); % ftwo=5000 Hz.
fend=length(song);

flit=[zeros(fone,1);ones(ftwo-fone,1);zeros(fend-ftwo,1)];
preout=abs(ifft(flit.*fft(song)));
pout=mean(reshape(preout(1:1000*floor(fend/1000)),1000,[]));
m=4*mean(pout);
mout=(pout>m);
dout=diff(mout);
notes=sum(dout>0);
param=notes/10;


%z=ceil(3*fs/1000); % 3 ms smoothing window
%asong=abs(song);
%asong=2*(asong/sum(asong)-0.5);
%smoothed=mean(reshape(asong(1:z*floor(length(asong)/z)),z,[]));
%preout=abs(fft(smoothed));
%out=mean(reshape(preout(1:250*floor(length(preout)/250)),[],250));
%out=out(2:floor(end/2));

%using this definition for lowpeak, findsongs returns about half of
%B23B28's songs in run 6, with very little non-song junk...
%%%lowpeak=max(out)/max(out(1:5));
%using this definition for lowpeak, findsongs returns nearly all of
%the actual songs in B23B28_6, but cuts out only about 25% of the
%junk.  This one is probably less useful
%%%%lowpeak=5*mean(out(6:end))/mean(out(1:5));

