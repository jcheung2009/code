function [boutlengths,bouttimes] = mBoutLengthVsTime(batch)
%
%
% plots file length vs time recorded for all files in batch
%
%

boutlengths = mGetBoutLengths(batch);
bouttimes = mGetSongTimes(batch);

figure();subplot(2,1,1);plot(bouttimes,boutlengths,'r.');subplot(2,1,2);hist(boutlengths,50);