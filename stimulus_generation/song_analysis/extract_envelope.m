function envelope = extract_envelope(wf,fs,windowsize)
if nargin<3
    windowsize = .05;
end

% extract and filter envelope
envelope = abs(hilbert(wf));
envelope = filtfilt(ones(1,round(windowsize*fs)), 1, envelope);
envelope = envelope / max(envelope);
