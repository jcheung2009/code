function [] = mautosegment_batch(optional_batch,syll_label,threshold)
%
% autosegments vocalizations more than SDthresh louder than noise and
% labele them with syll_label.
%
% syll_label='a' by default
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

    



fin=fopen([path,batch]); % batch file ID
file = fscanf(fin,'%s',1);
disp('working...');
while ~isempty(file); % each file in batch
    thecell = 1;
  
    fullfile=file;
    if ~(file(1)=='/')
        fullfile=[path,file];
    end
    
    if (fullfile(end-7:end)=='.not.mat')
        fullfile=fullfile(1:end-8);
    end
    
    if (fullfile(end-4:end)=='.cbin')
        titlestr = '';
        type='obs0r';
    else
        type='w';
    end
    
    mautosegments(file,threshold,syll_label);
    
    thecell = thecell +1;
    file = fscanf(fin,'%s',1); % advances to the next line in batch    
end
fclose(fin);
disp('done.');


