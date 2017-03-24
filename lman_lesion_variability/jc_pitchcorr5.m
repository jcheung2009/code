function [ acorr ] = jc_pitchcorr5(fvals,maxlag  )
% 9_5_2014
%fvals = cell with pitch values for each day in condition
%or fvals = vector of pitch values for one day
% computes correlation coefficient of signal with itself 
%called by jc_pitchcorr6
 
if iscell(fvals)

    for i = 1:length(fvals)
        for ii = 1:maxlag+1
            var1 = var(fvals{i}(ii:end,2));
            var2 = var(fvals{i}(1:end-ii+1,2));
            x{i}(ii) = sqrt(var1*var2);
        end
    end

    acorr = NaN(maxlag+1,length(fvals));
    for i = 1:length(fvals)
        acov = xcov(fvals{i}(:,2),maxlag,'unbiased');
        acov = acov(ceil(length(acov)/2):end);
        acorr(:,i) = x{i}'.\acov;
      
    end

else
    
    x = NaN(1,maxlag+1);
    
    for ii = 1:maxlag+1
        x(ii) = sqrt(var(fvals(ii:end))*var(fvals(1:end-ii+1)));
    end
    
    
    acorr = xcov(fvals,maxlag,'unbiased');
    acorr = acorr(ceil(length(acorr)/2):end);
    acorr = x'.\acorr;
    
end
        



end

