function varargout = spectrogram(x,varargin)
%
% cribbed from spectrogra - doesnt plot
%
%SPECTROGRAM Spectrogram using a Short-Time Fourier Transform (STFT).
%   S = SPECTROGRAM(X) returns the spectrogram of the signal specified by
%   vector X in the matrix S. By default, X is divided into eight segments
%   with 50% overlap, each segment is windowed with a Hamming window. The
%   number of frequency points used to calculate the discrete Fourier
%   transforms is equal to the maximum of 256 or the next power of two
%   greater than the length of each segment of X.
%
%   If X cannot be divided exactly into eight segments, X will be truncated
%   accordingly.
%
%   S = SPECTROGRAM(X,WINDOW) when WINDOW is a vector, divides X into
%   segments of length equal to the length of WINDOW, and then windows each
%   segment with the vector specified in WINDOW.  If WINDOW is an integer,
%   X is divided into segments of length equal to that integer value, and a
%   Hamming window of equal length is used.  If WINDOW is not specified, the
%   default is used.
%
%   S = SPECTROGRAM(X,WINDOW,NOVERLAP) NOVERLAP is the number of samples
%   each segment of X overlaps. NOVERLAP must be an integer smaller than
%   WINDOW if WINDOW is an integer.  NOVERLAP must be an integer smaller
%   than the length of WINDOW if WINDOW is a vector.  If NOVERLAP is not
%   specified, the default value is used to obtain a 50% overlap.
%
%   S = SPECTROGRAM(X,WINDOW,NOVERLAP,NFFT) specifies the number of
%   frequency points used to calculate the discrete Fourier transforms.
%   If NFFT is not specified, the default NFFT is used. 
%
%   S = SPECTROGRAM(X,WINDOW,NOVERLAP,NFFT,Fs) Fs is the sampling frequency
%   specified in Hz. If Fs is specified as empty, it defaults to 1 Hz. If 
%   it is not specified, normalized frequency is used.
%
%   Each column of S contains an estimate of the short-term, time-localized
%   frequency content of the signal X.  Time increases across the columns
%   of S, from left to right.  Frequency increases down the rows, starting
%   at 0.  If X is a length NX complex signal, S is a complex matrix with
%   NFFT rows and k = fix((NX-NOVERLAP)/(length(WINDOW)-NOVERLAP)) columns.
%   For real X, S has (NFFT/2+1) rows if NFFT is even, and (NFFT+1)/2 rows
%   if NFFT is odd.  
%
%   [S,F,T] = SPECTROGRAM(...) returns a vector of frequencies F and a
%   vector of times T at which the spectrogram is computed. F has length
%   equal to the number of rows of S. T has length k (defined above) and
%   its value corresponds to the center of each segment.
%
%   [S,F,T,P] = SPECTROGRAM(...) P is a matrix representing the Power
%   Spectral Density (PSD) of each segment. For real signals, SPECTROGRAM
%   returns the one-sided modified periodogram estimate of the PSD of each
%   segment; for complex signals, it returns the two-sided PSD.  
%
%   SPECTROGRAM(X,WINDOW,NOVERLAP,F,Fs) where F is a vector of frequencies
%   in Hz (with 2 or more elements) computes the spectrogram at those
%   frequencies using the Goertzel algorithm. 
%
%   SPECTROGRAM(...) with no output arguments plots the PSD estimate for
%   each segment on a surface. A trailing input string, FREQLOCATION,
%   controls where MATLAB displays the frequency axis. This string can be
%   either 'xaxis' or 'yaxis'.  Setting this FREQLOCATION to 'yaxis'
%   displays frequency on the y-axis and time on the x-axis.  The default
%   is 'xaxis' which displays the frequency on the x-axis.
%
%   EXAMPLE 1: Compute the spectrogram of a quadratic chirp.
%     t=0:0.001:2;                    % 2 secs @ 1kHz sample rate
%     y=chirp(t,100,1,200,'q');       % Start @ 100Hz, cross 200Hz at t=1sec 
%     spectrogram(y,128,120,128,1E3); % Display the spectrogram
%     title('Quadratic Chirp: start at 100Hz and cross 200Hz at t=1sec');
%
%   EXAMPLE 2: Compute the spectrogram of a linear chirp.
%     t=0:0.001:2;                    % 2 secs @ 1kHz sample rate
%     y=chirp(t,0,1,150);             % Start @ DC, cross 150Hz at t=1sec 
%     % Display the frequency on the y-axis
%     spectrogram(y,256,250,256,1E3,'yaxis'); 
%     title('Linear Chirp: start at 100Hz and cross 200Hz at t=1sec');
%
%   See also PERIODOGRAM, SPECTRUM/PERIODOGRAM, PWELCH, SPECTRUM/WELCH, GOERTZEL.

% [1] Oppenheim, A.V., and R.W. Schafer, Discrete-Time Signal Processing,
% Prentice-Hall, Englewood Cliffs, NJ, 1989, pp. 713-718.
% [2] Mitra, S. K., Digital Signal Processing. A Computer-Based Approach.
% 2nd Ed. McGraw-Hill, N.Y., 2001.

%   Author(s): L. Shure, T. Krauss, P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/11/01 19:29:56 $

error(nargchk(1,6,nargin));
error(nargoutchk(0,4,nargout));

% Frequency axis location for case when no output is requested.
faxisloc = 'xaxis';
if nargout == 0 && nargin > 1 && ischar(varargin{end}),
    if strcmpi(varargin{end},'yaxis'),
        faxisloc = 'yaxis';
    end
    varargin(end)=[];
end

% Check for valid input signal
msg = chkinput(x);
error(msg)

% Parse input arguments (using the PWELCH parser since we share the same API).
% The following outputs are NOT used: y, Ly, winName,winParam, k, and L. 
esttype = 'psd';
[x,nx,xisreal,y,Ly,win,winName,winParam,noverlap,k,L,options,msg] = ...
    welchparse(x,esttype,varargin{:});  %#ok
error(msg)

% Determine whether an empty was specified for Fs (i.e., Fs=1Hz) or
% returned by welchparse which means normalized Fs is used.
Fs = options.Fs; isFsnormalized = false;
if isempty(Fs)
    lv = length(varargin);
    if lv == 5,
        isFsnormalized = false; % Fs = 1Hz.
        Fs = 1;
    elseif lv < 5
        isFsnormalized = true;  % Fs is normalized
        Fs = 2*pi;
    end
end

% Window length
nwind = length(win);

% Make x and win into columns
x = x(:); 
win = win(:); 

% Determine the number of columns of the STFT output (i.e., the S output)
ncol = fix((nx-noverlap)/(nwind-noverlap));

%
% Pre-process X
%
colindex = 1 + (0:(ncol-1))*(nwind-noverlap);
rowindex = (1:nwind)';
xin = zeros(nwind,ncol);

% Put x into columns of xin with the proper offset
xin(:) = x(rowindex(:,ones(1,ncol))+colindex(ones(nwind,1),:)-1);

% Apply the window to the array of offset signal segments.
xin = win(:,ones(1,ncol)).*xin;

%
% Compute the raw STFT with the appropriate algorithm
%
nfft = options.nfft;
if (length(nfft)==1),
    % Use FFT
    [y,f] = STFTviaFFT(xin,nx,xisreal,nfft,Fs,win,ncol);
else
    % Use Goertzel
    [y,f] = STFTviaGoertzel(xin,nfft,Fs,win,ncol);
end

% colindex already takes into account the noverlap factor; Return a T
% vector whose elements are centered in the segment.
t = ((colindex-1)+((nwind)/2)')/Fs; 

% Outputs
switch nargout,
    case 0,
        % Use surface to display spectrogram
        Pxx = compute_PSD(win,y,nfft,f,options,Fs,esttype);
        % here is hack
        displayspectrogram(t,f,Pxx,isFsnormalized,faxisloc);
    case 1,
        varargout = {y};
    case 2,
        varargout = {y,f};
    case 3,
        varargout = {y,f,t};
    case 4,
        Pxx = compute_PSD(win,y,nfft,f,options,Fs,esttype);
        varargout = {y,f,t,Pxx};
end


%--------------------------------------------------------------------------
function msg = chkinput(x)
% Check for valid input signal

msg = '';

if isempty(x) || issparse(x) || ~isa(x,'double'),
    msg.identifier = generatemsgid('invalidInput');
    msg.message = 'The input signal X must be a double-precision vector.';
    return;
end

if min(size(x))~=1,
    msg.identifier = generatemsgid('invalidInput');
    msg.message = 'X must be a vector (either row or column).';
    return;
end


%--------------------------------------------------------------------------
function [y,f] = STFTviaFFT(xin,nx,xisreal,nfft,Fs,win,ncol)
% Use FFT to compute raw STFT and return the F vector.

% Handle the case where NFFT is less than the segment length, i.e., "wrap"
% the data as appropriate.
if nx > nfft,
    xin = datawrap(xin,nfft);
end

y = fft(xin,nfft);

if xisreal,
    f = psdfreqvec(nfft, Fs,'half');
    y = y(1:length(f),:);
else
    f = psdfreqvec(nfft, Fs);
end


%--------------------------------------------------------------------------
function [y,f] = STFTviaGoertzel(xin,freqvec,Fs,win,ncol)
% Use Goertzel to compute raw STFT and return the F vector.

f = freqvec(:);
f = mod(f,Fs); % 0 <= f < = Fs
xm = size(xin,1); % NFFT

% Indices used by the Goertzel function (see equation 11.1 pg. 755 of [2])
k = round(f/Fs*xm)+1; % +1 of zero-based indexing

y = goertzel(xin,k);


%--------------------------------------------------------------------------
function displayspectrogram(t,f,Pxx,isFsnormalized,faxisloc)

% Cell array of the standard frequency units strings
frequnitstrs = getfrequnitstrs;
if isFsnormalized, 
    idx = 1;
else
    idx = 2;
end

newplot;
if strcmpi(faxisloc,'yaxis'),
    if length(t)==1
        % surf requires a matrix for the third input.
        args = {[0 t],f,10*log10(abs([Pxx Pxx])+eps)};
    else
        args = {t,f,10*log10(abs(Pxx)+eps)};
    end

    % Axis labels
    xlbl = 'Time';
    ylbl = frequnitstrs{idx};
else
    if length(t)==1
        args = {f,[0 t],10*log10(abs([Pxx' Pxx'])+eps)};
    else
        args = {f,t,10*log10(abs(Pxx')+eps)};
    end
    xlbl = frequnitstrs{idx};
    ylbl = 'Time';
end
hndl = surf(args{:},'EdgeColor','none');

axis xy; axis tight;
colormap(jet);

% AZ = 0, EL = 90 is directly overhead and the default 2-D view.
view(0,90);

ylabel(ylbl);
xlabel(xlbl);

% -------------------------------------------------------------------------
function Pxx = compute_PSD(win,y,nfft,f,options,Fs,esttype)
% Evaluate the window normalization constant.  A 1/N factor has been
% omitted since it will cancel below.
U = win'*win;     % Compensates for the power of the window.
Sxx = y.*conj(y)/U; % Auto spectrum.

% The computepsd function expects NFFT to be a scalar
if length(nfft) > 1, nfft = length(nfft); end

% Compute the one-sided or two-sided PSD [Power/freq]. Also compute
% the corresponding half or whole power spectrum [Power].
Pxx = computepsd(Sxx,f,options.range,nfft,Fs,esttype);


% [EOF]
