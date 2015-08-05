function labels = mCorrLabel(templates,templatelabels,songfile,ampthresh)
%
%
% mCorrLabel(templates,templatelabels,songfile,ampthresh)
%
% labels syllables in songfile based on strength of spectral correlations
% between segmented vocalizations and spectral templates in templates
%
% templatelabels is a vector of syllable labels corresponding to spectrograms in
% templates
%
% templates is a cell array of spectrograms, i.e. syllable avg spectrograms
%
% elements of templates should all be the same duration.
%
% ampthresh is amplitude threshold for segmentation 
%

[pth,nm,ext]=fileparts(songfile);
if (strcmp(ext,'.ebin'))
    [dat,fs]=readevtaf(songfile,'0r');
elseif(strcmp(ext,'.cbin'))
    [dat,fs]=ReadCbinFile(songfile);
elseif(strcmp(ext,'.wav'))
    [dat,fs]=wavread(songfile);
end

pad = 0.05*fs; 
sm = mquicksmooth(dat,fs);
[ons offs] = msegment(sm,fs,15,20,ampthresh);
labels=char(ones([1,length(ons)])*45);

bestmatch = 0;
for i=1:1:length(ons) % each segmented vocalization
   bestmatch = 0;
   theseg = dat((ons(i)*fs)-pad:(offs(i)*fs));
   [segsm segspec segt segf] = evsmooth(theseg,fs,2,512,0.85,2.5);
   for j=1:1:length(templates) % check each template against vocalization
       corrmtx = mSpecCorrMtx_fast(abs(segspec),templates{j});
       thecorr = diag(corrmtx);
       if(mean(thecorr) > bestmatch);
           bestmatch = mean(diag(corrmtx));
           labels(i) = templatelabels(j);
       end       
   end   
end

% these are necessary to write the not.mat file -
threshold = ampthresh;
sm_win = 2;
onsets = ons*1e3;
offsets = offs*1e3;
min_int = 5;
min_dur = 20;
Fs = fs;
fname=songfile;
cmd = ['save ',songfile,'.not.mat fname Fs labels min_dur min_int ',...
	                      'offsets onsets sm_win threshold'];
eval(cmd);