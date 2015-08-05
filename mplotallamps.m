function [meanAmp] = mplotallamps(fv,fs)
%
% [meanAmp] = mplotallamps(fv)
%
% plots all smoothed amplitude contours in fv
%


dt = 1/fs;
figure(4);hold on;
for i=1:length(fv)
    timebase = [dt:dt:dt*length(fv(i).sm)];
    plot(timebase,fv(i).sm,'r');
    if(i==1)
        meanAmp = fv(i).sm;        
    else
        meanAmp = meanAmp + fv(i).sm;
    end
end
meanAmp = meanAmp ./ i;

