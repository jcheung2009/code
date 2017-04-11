%tonality
        startind = 1;
        tonality = []; startind = 1;
        NFFT=512;
        t=-NFFT/2+1:NFFT/2;
        sigma=(1/1000)*fs;
        w=exp(-(t/sigma).^2);
        entropy = [];
       
        while length(filtsong)-startind>=512
            endind=startind+512-1;
            win = filtsong(startind:endind);
            [pxx f]=periodogram(win,w,NFFT,fs);
            indf=find(f>=1000&f<=10000);
            pxx=pxx(indf);
            entropy=[entropy;-sum(pxx.*log2(pxx))/log2(length(pxx))];
            startind=startind+1;
        end
                
        while length(filtsong)-startind>=512
            endind = startind+512-1;
            win = filtsong(startind:endind);
            win = [win;zeros(512,1)];
            [c lag] = xcorr(win,'coeff');
            len=5;
            h   = ones(1,len)/len;
            smooth = conv(h, c);
            offset = round((length(smooth)-length(c))/2);
            smooth=smooth(1+offset:length(c)+offset);
            smooth=smooth(ceil(length(smooth)/2):end);
            [pks locs] = findpeaks(smooth);
            if ~isempty(pks)
                tonality=[tonality;max(pks)];
            else
                tonality=[tonality;NaN];
            end
            startind=startind+1;
        end