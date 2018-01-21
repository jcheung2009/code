ff = load_batchf('batch');
%spectrogram params
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

for i = 1:length(ff)
    if ~isempty(strfind(ff(i).name,'saline'))
        cd ff(i).name
        songfiles = load_batchf('batch.keep');
        for m = 1:length(songfiles)
            load([songfiles(m).name,'.not.mat']);
            [dat fs] = evsoundin('',songfiles(m).name,'obs0');
            dat = bandpass(dat,fs,300,10000,'hanningffir');
            labels = labels(isletter(labels));
            sylldat = arrayfun(@(y,z) dat(floor((y-16)*1e-3*fs):...
                ceil((z+16)*1e-3*fs)),onsets,offsets,'un',0);
            [sp f] = cellfun(@spectrogram,sylldat,'un',0);
            sp = cellfun(@(x) imresize(log(abs(x)),[227 227]),sp,'un',0);
            sp = cat(4,sp{:});