function pitch2 = jc_detrendpitch(pitch1,tb);
%detrend pitch for accurate pitch cv measurements

numseconds = tb(end)-tb(1);
timewindow = 3600; % hr in seconds
numtimewindows = ceil(numseconds/timewindow);
if numtimewindows <= 0
    numtimewindows = 1;
end
timept1 = tb(1);
pitch2 = [];
for p = 1:numtimewindows
    timept2 = timept1+timewindow;
    indcv = find(tb >= timept1 & tb < timept2);
    diff = nanmean(pitch1(indcv))-nanmean(pitch1);
    pitch2 = [pitch2 pitch1(indcv)-diff];
    timept1 = timept2;
end

if length(pitch2)~=length(pitch1)
    error('detrend');
end