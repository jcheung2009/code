function [interpPeakLoc peakval] = minterppeak(invect,fs)
%
%
% function interpPeak = minterppeak(invect)
%
% returns location of peak in inVect interpolated using 
% derivative's zero-crossing
% 
%


[peaks peaklocs]= findpeaks(invect);
if(length(peaks))
   diffvect = diff(invect);
   diffvect = [0 diffvect'];
   [maxpeak maxloc] = max(peaks);
   vectseg = invect(peaklocs(maxloc)-1:peaklocs(maxloc)+1);
   segaxis = [peaklocs(maxloc)-1:1:peaklocs(maxloc)+1];
   diffseg = diffvect(peaklocs(maxloc)-1:peaklocs(maxloc)+1);
   fitcoeffs = polyfit(segaxis,diffseg,1); % linear fit of 1st derivative
   interpPeakLoc = fitcoeffs(2) / -fitcoeffs(1);
   peakval = maxpeak;
else
    interpPeakLoc = 0;peakval=0;
end


return;