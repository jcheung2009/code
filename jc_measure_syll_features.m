function [feature_vecs,varargout] = jc_measure_syll_features(batch,classes,featuretype)

ff = load_batchf(batch);
feature_vecs = {};


for i = 1:length(classes)
    feature_vecs.(classes(i))= [];
    for ii = 1:length(ff)
        [dat fs] = evsoundin('',ff(ii).name,'obs0');
        load([ff(ii).name,'.not.mat']);
        p = strfind(labels, classes(i));
        for ind = 1:length(p)
            onsamp = floor(onsets(p(ind))*1e-3*fs)-256;
            offsamp = ceil(offsets(p(ind))*1e-3*fs)+256;
            sylldat = dat(onsamp:offsamp);
            sylldat = bandpass(sylldat,fs,300,10000,'hanningffir');
            len = round(fs*5/1000);
            h = ones(1,len)/len;
            sm = conv(h,sylldat.^2);
            offset = round((length(sm)-length(sylldat))/2);
            sm=sm(1+offset:length(sylldat)+offset);
            logsm = log(sm);
            logsm = logsm-min(logsm);
            logsm = logsm./max(logsm);
            abovethresh = find(logsm>=0.3);
            sm_ons = abovethresh(1);
            sm_offs = abovethresh(end);
            onsamp = onsamp+sm_ons;
            offsamp = onsamp+sm_offs;
            ton = (onsamp/fs)*1e3;
            toff = (offsamp/fs)*1e3;
            sylldat = dat(onsamp:offsamp);
            sylldat = bandpass(sylldat,fs,300,10000,'hanningffir');

            nfft = 2^14;
            [pxx f] = pwelch(sylldat,'','',nfft,fs);

            if strcmp(featuretype,'psd')
                feature_vecs.(classes(i)) = [feature_vecs.(classes(i)); pxx'];
            else
                amp = mean(sylldat.^2);%mean volume
                dur = toff-ton;%syllable duration
                pxx = pxx/sum(pxx);
                spec_ent = -sum(pxx.*log2(pxx))/log2(length(pxx));%spectral entropy
                freq1 = mean(pxx(f<1000));%power in different frequency ranges
                freq2 = mean(pxx(f>=1000 & f<2000));
                freq3 = mean(pxx(f>=2000 & f<3000));
                freq4 = mean(pxx(f>=4000 & f<5000));

                spNFFT = 512;
                overlap = spNFFT-2;
                t=-spNFFT/2+1:spNFFT/2;
                sigma=(1/1000)*fs;
                w=exp(-(t/sigma).^2);
                [sp f tm pxx] = spectrogram(sylldat,w,overlap,spNFFT,fs);
                indf = find(f>=300 & f <= 10000);
                pxx = pxx(indf,:);
                pxx = bsxfun(@rdivide,pxx,sum(sum(pxx)));%spectrotemporal entropy
                spec_tempo_ent = -sum(sum(pxx.*log2(pxx)))/log2(length(pxx(:)));

                sm = sm/sum(sm);
                tempo_ent = -sum(sm.*log2(sm))/log2(length(sm));%temporal entropy

                feature_vecs.(classes(i)) = [feature_vecs.(classes(i)); [freq1,freq2,freq3,freq4,amp,dur,spec_ent,spec_tempo_ent,tempo_ent]];
            end

        end
        disp(ff(ii).name);
    end
end

    

    
            
            
            
            
        