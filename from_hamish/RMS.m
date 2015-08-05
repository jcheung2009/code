function [RMS] = RMS(signal)

    signal=signal-mean(signal);
    signal=signal.^2;
    n=length(signal);
    RMS=sqrt((sum(signal)/n));

end

