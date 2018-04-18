function [sp f tm pxx] = jc_spectrogram(filtsong,fs,plt,varargin);
if nargin > 3
    ax = varargin{1};
end

%spectrogram params
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

[sp f tm pxx] = spectrogram(filtsong,w,overlap,NFFT,fs);
indf = find(f>=500 & f<=10000);
f=f(indf);sp=sp(indf,:);

ind = find(abs(sp)<=mean(mean(abs(sp))));
sp(ind)=mean(mean(abs(sp)))/2;

if plt==1
    if nargin > 3
        axes(ax);hold on;imagesc(tm,f,log(abs(sp)));axis('xy');hold on;
        xlim([tm(1) tm(end)]);ylim([f(1) f(end)]);
    else
        figure;imagesc(tm,f,log(abs(sp)));axis('xy');hold on;
        xlim([tm(1) tm(end)]);ylim([f(1) f(end)]);
    end
    xlabel('seconds');ylabel('Hz');
end
