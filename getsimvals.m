function [vol ent rat meanStatAxis]=getsimvals(cbin,syll,plotit)
%
% mnm, 28 april 2009. in progress.
%

% note hardcodes:
fs = 32000;
nfft = 256;

if(isempty(syll))
    syll = '';
end

% get the .not.mat file from the cbin argument:
notMatFN = cbin(1,1:length(cbin));
notMatFN = [notMatFN '.not.mat'];
notMat = load(notMatFN);

%get the corresponding spect values:
%[raw_vol raw_ent raw_rat] = msaf_params(cbin,safstruct);
[raw_vol raw_ent raw_rat stataxis] = plotspect(cbin,[],0);
%stataxis = (fs/nfft:fs/nfft:length(raw_vol)*(fs/nfft));

% and syllable information: 
labels = notMat.labels;
onsets = notMat.onsets; % in ms
offsets = notMat.offsets; % also in ms

if(~isempty(syll)) % need to fill this in
    
end

%initialize vectors for syllable-wise volume, entropy, & ratio:
vol = zeros(1,length(labels));
vol = nan;
ent = vol;
rat = vol;
meanStatAxis = onsets/1e3; % convert to seconds 
offsets_sec = offsets/1e3;
outaxis = meanStatAxis * fs;

for index=1:length(labels);
    thesyll = labels(index);  
    onset = meanStatAxis(index)*fs; % project these on same timebase as interpolated spect values 
    offset = offsets_sec(index)*fs;
    if(~isempty(syll))
        if(strcmp(syll,thesyll))
            vol(index) = mean(raw_vol(onset:offset));
            ent(index) = mean(raw_ent(onset:offset));
            rat(index) = mean(raw_rat(onset:offset));
        end
    else
        vol(index) = mean(raw_vol(onset:offset));
        ent(index) = mean(raw_ent(onset:offset));
        rat(index) = mean(raw_rat(onset:offset));
    end
end


%plotting:
if(plotit)
    figure();
    ax(1) = subplot(5,1,1);mplotcbin(cbin,[]);
    ax(2) = subplot(5,1,2);plot(stataxis,raw_vol);
    ax(3) = subplot(5,1,3);plot(meanStatAxis,vol);
    ax(4) = subplot(5,1,4);plot(meanStatAxis,ent);
    ax(5) = subplot(5,1,5);plot(meanStatAxis,rat);

    linkaxes(ax,'x');
end