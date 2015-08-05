function [vol_list,entlist,ratlist] = msaf_params(cbin,critstruct)
%
% EvSAF2 simulation for determining appropriate trigger criteria.
% returns filtered volume, entropy, and ratio vectors from the cbin's spect
% partner. Use msaf_sim() with the same arguments to get the same data but
% filtered through the triggering function.
% mnm, 28 april 2009
%
[rawsong fs] = ReadCbinFile(cbin);
rawsong = rawsong(:,1);

%Frequency bins
% F_low  = critstruct.highpass;
% F_high = critstruct.lowpass;

%FFT params
nfft=256;
olap = 0.8;

%Volume params:
vol_lowpass = critstruct.vol_lowpass;
vol_highpass = critstruct.vol_highpass;
minvol= critstruct.vol_min;
maxvol= critstruct.vol_max;

%entropy params:
ent_lowpass = critstruct.ent_lowpass;
ent_highpass = critstruct.ent_highpass;
maxent= critstruct.ent_max;
minent= critstruct.ent_min;

%ratio params:
ratsplit= critstruct.rat_split;
%ratthresh= critstruct.rat_thresh;
rat_max = critstruct.rat_max;
rat_min = critstruct.rat_min;


indlst = (1:nfft:length(rawsong)-nfft);

ratlist=(1:nfft:length(indlst));
entlist=(1:nfft:length(indlst));
vol_list=(1:nfft:length(indlst));

%trigger vectors for each volume/entropy/ratio:
voltrigs=(1:nfft:length(indlst));
enttrigs=(1:nfft:length(indlst));
rattrigs=(1:nfft:length(indlst));

voltrigs=nan;enttrigs=nan;rattrigs=nan;


startind=1;
for jj=1:length(indlst)
    datvals=rawsong(indlst(jj):indlst(jj)+nfft-1);
    startind=startind+nfft;
    %filtsong=bandpass(datvals,Fs,F_low,F_high,filter_type);
    spect_win = nfft;
    noverlap = floor(olap*nfft);
    %[spec,f,t,p] = spectrogram(datvals,spect_win,noverlap,nfft,Fs);
    
    %FFT:
    fdat=(abs(fft(hamming(nfft).*datvals))./nfft);
    ffv=get_fft_freqs(nfft,fs);
    ffv=ffv(1:end/2);
    frqind=find((ffv>=vol_highpass)&(ffv<=vol_lowpass));

    %volume calculation:
    volcalc=sum(fdat(frqind));
    vol_list(jj) = volcalc;
    if((volcalc > minvol) && (volcalc < maxvol))
        voltrigs(jj)=1;
    else
        voltrigs(jj)=0;
    end
    
    %entropy calculation:
    frqind = find((ffv>=ent_highpass)&(ffv<=ent_lowpass));
    pnorm=(fdat(frqind))/sum(fdat(frqind));
    entcalc=-(pnorm'*log2(pnorm));
    entlist(jj) = entcalc;
    if((entcalc > minent) && (entcalc < maxent))
        enttrigs(jj)=1;
    else
        enttrigs(jj)=0;
    end

    %ratio calculation:
    hi_F_id=find(ffv>ratsplit);
    lo_F_id=find(ffv<=ratsplit);
    mean_p_hi=mean(mean(fdat(hi_F_id,:)));
    mean_p_lo=mean(mean(fdat(lo_F_id,:)));
    ratio=mean_p_hi/mean_p_lo;
    ratlist(jj) = ratio;
    if(ratio < rat_max && ratio > rat_min )
        rattrigs(jj)=1;
    else
        rattrigs(jj)=0;
    end
    
end

%plotting:
% songaxis = maketimebase(length(rawsong),fs);
% stataxis = (nfft/fs:nfft/fs:length(rawsong)/fs);
% 
% figure();
% safax(5)=subplot(7,1,1:2);mplotcbin(cbin,[]);
% safax(4)=subplot(7,1,3:4);plot(songaxis,abs(rawsong));
% 
% safax(1)=subplot(7,1,5);plot(stataxis,vol_list,'.');
% title('volume');
% axis_max = max(vol_list);
% ylim([-50,axis_max*1.5]);
% 
% safax(2)=subplot(7,1,6);plot(stataxis,entlist,'.');
% title('entropy');
% ylim([2,max(entlist)*1.25]);
% 
% safax(3)=subplot(7,1,7);plot(stataxis,ratlist,'.');
% title('high/low ratio');
% ylim([-0.25,1]);
% 
% linkaxes(safax,'x');




