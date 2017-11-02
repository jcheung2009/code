function jc_plotsyllspec(fv,fs,varargin);
%plot spectrogram and pitch contour from syllable exemplar in fv struct

%spectrogram params
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

smtmp = fv.smtmp;
filtsong = bandpass(smtmp,fs,300,10000,'hanningffir');
[sp f tm pxx] = spectrogram(filtsong,w,overlap,NFFT,fs);
tm = tm-0.016;
indf = find(f>=300 & f<=10000);
id = find(abs(sp)<=mean(mean(abs(sp))));
sp(id)=mean(mean(abs(sp)))/2;
axes(varargin{1});imagesc(tm,f(indf),log(abs(sp(indf,:))));axis('xy');colormap hot;hold on;
ylim([300 10000]);xlim([tm(1) tm(end)]);

t = fv.pitchcontour(:,1);pc = fv.pitchcontour(:,2);
plot(t,pc,'g','linewidth',2);