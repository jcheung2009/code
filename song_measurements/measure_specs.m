function [pitch pitchcontour spectempent entvar varargout] = measure_specs(filtsong,fvalbnd,timeshift,fs);
%measure pitch at target timepoint in syllable measure pitch contour and
%spectrotemporal entropy

%spectrogram params
NFFT = 512;
overlap = NFFT-10;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

pitch = [];pitchcontour=[];spectempent=[];
if length(w) > length(filtsong)
    pitch = NaN;
    pitchcontour = NaN;
    spectempent = NaN;
    entvar = NaN;
else
    [sp f tm pxx] = spectrogram(filtsong,w,overlap,NFFT,fs);
    pitchcontour = [];
    for m = 1:size(sp,2)
        fdat = abs(sp(:,m));
        mxtmpvec = zeros([1,size(fvalbnd,1)]);
        for kk = 1:size(fvalbnd,1)
            tmpinds = find((f>=fvalbnd(kk,1))&(f<=fvalbnd(kk,2)));
            NPNTS = 10;
            [tmp pf] = max(fdat(tmpinds));
            pf = pf+tmpinds(1)-1;
            tmpxv=pf + [-NPNTS:NPNTS];
            tmpxv=tmpxv(find((tmpxv>0)&(tmpxv<=length(f))));
            mxtmpvec(kk)=f(tmpxv)'*fdat(tmpxv);
            mxtmpvec(kk)=mxtmpvec(kk)./sum(fdat(tmpxv));
        end
        pitchcontour = cat(1,pitchcontour,mean(diff([0,mxtmpvec])));
    end
    tm=tm-0.016;%to account for buffer time added to filtsong)
    
    %estimate pitch at target time
    if length(timeshift) == 1
        ti1 = find(tm<=timeshift);
        ti1 = ti1(end);
        pitch = pitchcontour(ti1);%pitch estimate at timeshift 
    elseif length(timeshift) == 2
        ti1 = find(tm>=timeshift(1) & tm<= timeshift(2));
        pitch = mean(pitchcontour(ti1));
    end

    %Spectral temporal entropy
    indf = find(f>=500 & f <= 10000);
    pxx = pxx(indf,:);
    entvar = var(log(geomean(pxx)./mean(pxx)));
    pxx = bsxfun(@rdivide,pxx,sum(sum(pxx)));
    spectempent = -sum(sum(pxx.*log2(pxx)))/log2(length(pxx(:)));
    
    varargout{1} = abs(sp(indf,:));
    varargout{2} = f(indf);
    varargout{3} = tm;
end