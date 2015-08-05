function [] = mautosegment_batch2(optional_batch,syll_label,CSPEC,threshold)
%
% autosegments vocalizations more than SDthresh louder than noise and
% labele them with syll_label.
%
% syll_label='a' by default
%
% CSPEC = 'Obs0' or 'w'
%
% ~mnm 1.20.2012
%


if nargin > 0
    path='';
    batch=optional_batch;
else
    [batch,path] = uigetfile('*','Select Batch file');
    pause(.1);
end

if(~exist('SDthresh'))
    SDthresh = 3;
end

if(~exist('syll_label'))
    syll_label = 'a';
end


if(~exist('threshold'))
    [batchbins batchhist] = mbatchampdist(batch);
    [pks,pksloc] = findpeaks(batchhist,'SORTSTR','descend');
    threshold = 10^(batchbins(pksloc(1))+(batchbins(pksloc(2))-batchbins(pksloc(1))));
end

    
min_int=5;
min_dur=30;
sm_win=2;

mlabel_segs(batch,syll_label,CSPEC,threshold,1,min_int,min_dur,sm_win);