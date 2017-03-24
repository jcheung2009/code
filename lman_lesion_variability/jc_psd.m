function [ px f ] = jc_psd(fvals, window,noverlap,nfft,fs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


% welch's psd 

px = NaN(size(fvals,1),size([0:1/nfft:1/2],2));
for i = 1:size(fvals,1)
    [pxx f] = pwelch(fvals(i,:),window,noverlap,nfft,fs,'onesided');
    px(i,:) = 10*log10(pxx);
end



    
    
   

end

