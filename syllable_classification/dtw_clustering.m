ff = load_batchf('batch.keep');

ons = []; offs = []; lbls = []; filtsong = [];
tm = 0; 
for i = 1:10%1:length(ff)
    load([ff(i).name,'.not.mat']);
    ons = [ons;onsets+tm];
    offs = [offs;offsets+tm];
    lbls = [lbls labels];
    [dat fs] = evsoundin('',ff(i).name,'obs0');
    filtsong = [filtsong; bandpass(dat,fs,300,10000,'hanningffir')];
    tm = tm+(length(dat)*1000)/fs;
end

buff = 0.016*fs;
NFFT = 512;
overlap = NFFT-32;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

sylls = unique(lbls);
sylls = sylls(isletter(sylls));

templates = cell(length(sylls),1);
for i = 1:length(sylls)
    ind = strfind(lbls,sylls(i));
    ix = ind(randsample(length(ind),1));
    dat = filtsong(floor(ons(ix)*fs/1000)-buff:ceil(offs(ix)*fs/1000)+buff);
    sp = spectrogram(dat,w,overlap,NFFT,fs);
    templates{i} = abs(sp);
end

dist = NaN(length(lbls),length(sylls));
for i = 1:length(sylls)
    for ii = 1:length(lbls)
        dat = filtsong(floor(ons(ii)*fs/1000)-buff:ceil(offs(ii)*fs/1000)+buff);
        sp = spectrogram(dat,w,overlap,NFFT,fs);
        dist(ii,i) = dtw(templates{i},abs(sp));
    end
end
