function [sm_ons sm_offs] = syl_ampsegment(smtemp,fs);
%uses amplitude segmentation of smoothed amp env for ons and offs of
%syllable (seconds into smtemp)

threshold = 0.3;%threhsold used on normalized amp 

sm = evsmooth(smtemp,fs,'','','',5);
sm=log(sm);sm=sm-min(sm);sm=sm./max(sm);
abovethresh = find(sm>=threshold);
sm_ons = abovethresh(1)/fs;
sm_offs = abovethresh(end)/fs;
