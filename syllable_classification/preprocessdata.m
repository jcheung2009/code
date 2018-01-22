
%% extract spectrograms and save as jpgs 
ff = load_batchf('batch');
buffer = 16;

%spectrogram params
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

for i = 1:length(ff)
    if ~isempty(strfind(ff(i).name,'sal'))
        cd(ff(i).name)
        if ~exist('specdata')
            mkdir('specdata');
        end
        songfiles = load_batchf('batch.keep.rand');
        for m = 1:length(songfiles)
            load([songfiles(m).name,'.not.mat']);
            [dat fs] = evsoundin('',songfiles(m).name,'obs0');
            dat = bandpass(dat,fs,300,10000,'hanningffir');
            ind = find(isletter(labels));
            labels = labels(ind);onsets=onsets(ind);offsets=offsets(ind);
            sylldat = arrayfun(@(y,z) dat(floor((y-buffer)*1e-3*fs):...
                ceil((z+buffer)*1e-3*fs)),onsets,offsets,'un',0);
            [sp f] = cellfun(@(x) spectrogram(x,w,overlap,NFFT,fs),sylldat,'un',0);
            indf = cellfun(@(x) find(x>=300 & x<=10000),f,'un',0);
            sp = cellfun(@(x,y) mat2gray(imresize(log(abs(x(y,:))),[227 227])),sp,indf,'un',0);
            labels = mat2cell(labels,1,repmat(1,1,length(labels)));
            indices = mat2cell(1:length(labels),1,repmat(1,1,length(labels)));
            cd specdata
            cellfun(@(x,y,z) imwrite(x,[songfiles(m).name,num2str(z),y,'.jpg']),...
                sp,labels',indices');  
            cd ../
        end
        ds = imageDatastore(
        cd ../
    end
end

