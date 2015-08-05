function [h] = quickspect(stimulus,samprate)
% h = quickspect(stimulus,samprate)
% Make a spectrogram of vector stimulus,
% frequencies from 500 to 8000Hz
% written by Kathy Nagel

% For zf. song:
fmin = 0.5;
fmax = 8;
nfft = 512;

% For speech:
% fmin = 0.05;
% fmax = 3.5;
% nfft = 1024;

% Pass a handle to figure back to function caller
% (in case she wants to further modify figure)
h = figure; 

% Get the spectrogram using matlab fn specgram:
[amp,freq,t_spec] = specgram(stimulus,nfft,samprate);

% Find the parts of the spectrogram within the specified frequency range:
ind = find(freq>fmin*1000&freq<fmax*1000);

% Change axis scale to ms and cut off at min and max freq:
axis([0 1000*length(stimulus)/samprate fmin fmax]);

% Plot the spectrogram using the matlab 2D plotting fn 'imagesc':
imagesc(t_spec*1000,freq(ind)/1000,20*log2(abs(amp(ind,:))));

% Use the colormap 'bone' -- can choose others -- see 'help colormap'
colormap('bone');

% Make sure Matlab axes are in default Cartesian mode:
axis xy;

% If this is uncommented, a legend will appear:
% colorbar;

% Make your axis values big enough to see on ppt:
set(gca,'FontSize',18);

% Always label your axes!
ylabel('Frequency (kHz)','FontSize',20);
xlabel('Time (msec)','Fontsize',20);