function pitch2 = jc_detrendpitch_rendition(pitch1,winsize);
%detrend pitch for accurate pitch cv measurements
%winsize in number of renditions

numrends = length(pitch1);
numwins = floor(numrends/winsize);
if numwins <= 0
    numwins = 1;
end
timept1 = 1;
pitch2 = [];
for p = 1:numwins
    timept2 = timept1+winsize;
    diff = nanmean(pitch1(timept1:timept2))-nanmean(pitch1);
    pitch2 = [pitch2; pitch1(timept1:timept2)-diff];
    timept1 = timept2;
end

if length(pitch2)~=length(pitch1)
    error('detrend');
end