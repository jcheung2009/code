function filt_info = filter_setup(filt_info,Fs,varargin)

% This is for plotting only
nfft = 4096;
if nargin == 3
  do_plots = varargin{1};
else 
  do_plots = 0;
end

switch lower(filt_info.type)
  case 'butter'
    [filt_info.b,filt_info.a]=butter(8,[filt_info.F_low*2/Fs, filt_info.F_high*2/Fs]);
    filt_info.ndelay = 0;
  case 'kaiserfir'
    % FIR filter design with a Kaiser window
    % This one looks like a nice filter to use (don't erase!)
    Rp = 3.266;
    Rs = 30;
    %fbands = [500 600 8000 8800]
    fbands = [293 453.1 8223 8328];
    amps = [0 1 0];
    devs = [10^(-Rs/20) (10^(Rp/20)-1)/(10^(Rp/20)+1) 10^(-Rs/20)];
    [nfir,Wnfir,beta,ftype] = kaiserord(fbands,amps,devs,Fs);
    nfir = nfir + rem(nfir,2);
    filt_info.ndelay = fix(nfir/2);
    filt_info.b = fir1(nfir,Wnfir,ftype,kaiser(nfir+1,beta));
    filt_info.a = 1;
  case 'hanningfir'
    nfir = 512;
    filt_info.ndelay = fix(nfir/2);
    filt_info.b = fir1(nfir,[filt_info.F_low*2/Fs, filt_info.F_high*2/Fs]);
    filt_info.a = 1;
  case 'hipass'
    nfir = 512;
    filt_info.ndelay = fix(nfir/2);
    filt_info.b = fir1(nfir, filt_info.F_low*2/Fs, 'high');
    filt_info.a = 1;
  otherwise
    disp('No filter setup to be done.')
    return
end

if do_plots
  figure;
  freqz(filt_info.b,filt_info.a,nfft,Fs)
  figure;
  grpdelay(filt_info.b,filt_info.a,nfft,Fs)
end
