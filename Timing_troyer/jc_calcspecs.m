function jc_calcspecs(batch,note,prenote,postnote,CHANSPEC)
%computes the spectrograms of all target syllables and saves it in separate
%folder in the directory, also saves mat file containing parameters used to
%compute spectrograms
%mat file contains structure notespecs with following fields
%   filename
%   clip (of the rawsong)
%   amp (amplitude envelop from ftr_amp which sums the power in the
%   spectrogram) 
%   specedges: onsets/offsets indices of spectrogram based on threshold crossing of
%   the amp envelop
%   cliponset/clipoffset: in seconds of the clip taken from the original
%   song
%   ntonset/ntoffset: in seconds of the syllable from the original song
%   based on segmentnotes
%   noteindex: index of the label in the song file where note was found
%   

datadir = ['specs_for_note_',note];
if ~exist(datadir)
    mkdir(datadir);
end
specparams = jc_defaultspecparams;
freqrange = [0 16];
ampthresh = .1;
save(fullfile([cd filesep datadir],'specparams.mat'),'specparams','ampthresh','freqrange');

%extract raw amplitude waveforms for syllables into structure
ff = load_batchf(batch);
h = waitbar(0,'computing spectrograms');
for i = 1:length(ff)
    fn = ff(i).name;
    fnn=[fn,'.not.mat'];
    if (~exist(fnn,'file'))
        continue;
    end
    load(fnn);
    labels = lower(labels);
    labels(findstr(labels,'0'))='-';
 
    srchstr = [prenote,note,postnote];
    p = strfind(labels,srchstr);
    if isempty(p)
        continue
    else
         [pthstr,tnm,ext] = fileparts(fn);
        if (strcmp(CHANSPEC,'w'))
                [dat,fs] = wavread(fn);
        elseif (strcmp(ext,'.ebin'))
            [dat,fs]=readevtaf(fn,CHANSPEC);
        else
            [dat,fs]=evsoundin('',fn,CHANSPEC);
        end
        if (isempty(dat))
            disp(['hey no data!']);
            continue;
        end
    end
    
    notespecs = struct();
    for ii = 1:length(p)
        onsamp = floor(onsets(p(ii))*1e-3*fs) - 128;
        offsamp = ceil(offsets(p(ii))*1e-3*fs) + 128;
        rawsong = dat(onsamp:offsamp);
        [spec f t] = jc_ftr_specgram(rawsong,specparams);
        amp = ftr_amp(spec,specparams.f,'freqrange',freqrange);
        amp = amp./max(amp); 
        abovethreshinds = find(amp > ampthresh);
        edges = [min(abovethreshinds) max(abovethreshinds)];
        notespecs(ii).spec = log(abs(spec));
        if specparams.tds == 1
            spec = conv2(log(abs(spec)),specparams.gaussfilter,'same');
            spec = diff(spec,1,2); 
            t = t(1:end-1);
            notespecs(ii).spectds = spec;
            notespecs(ii).tm = t;
        else
            notespecs(ii).tm = t;
        end
        
        notespecs(ii).filename = fn;
        notespecs(ii).clip = rawsong;
        notespecs(ii).amp = amp;%amplitude envelop from spectrogram power 
        notespecs(ii).specedges = edges;
        notespecs(ii).cliponset = onsamp/fs;
        notespecs(ii).clipoffset = offsamp/fs;
        notespecs(ii).ntonset = onsets(p(ii))*1e-3;%determined from segmentnotes 
        notespecs(ii).ntoffset = offsets(p(ii))*1e-3;
        notespecs(ii).noteindex = p(ii);
    end
    save(fullfile([cd filesep datadir],[fn,'_spec.mat']),'notespecs')
    waitbar(i/length(ff));
end
close(h)
