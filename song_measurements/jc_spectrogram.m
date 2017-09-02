function jc_spectrogram(filtsong,fs,varargin);
if ~isempty(varargin)
    ax = varargin{1};
else
    ax = '';
end

%spectrogram params
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

[sp f tm pxx] = spectrogram(filtsong,w,overlap,NFFT,fs);
indf = find(f>=500 & f<=10000);
%tm=tm-0.016;
if ~isempty(ax)
    axes(ax);hold on;imagesc(tm,f(indf),log(abs(sp(indf,:))));axis('xy');hold on;
    xlim([tm(1) tm(end)]);ylim([f(1) f(end)]);
else
    figure;imagesc(tm,f(indf),log(abs(sp(indf,:))));axis('xy');hold on;
    xlim([tm(1) tm(end)]);ylim([f(1) f(end)]);
end
xlabel('Time (seconds)');ylabel('Frequency (Hz)');
set(gca,'fontweight','bold');