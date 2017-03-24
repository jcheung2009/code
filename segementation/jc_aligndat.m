function [dat_total avsm avsp t f] = jc_aligndat(datref, dat,PRETIME)
%provide rawsong template to align rawsongs in dat



dat_corr = [];
dat_total = [];
shft_total = [];
for i = 1:size(dat,2)
    
        [corr lag] = xcorr(abs(datref),abs(dat(:,i)));
        dat_corr = [dat_corr corr];
end

    %shift each rawsong by lag in cross correlation
    for i = 1:size(dat_corr,2)
        [c ii] = max(dat_corr(:,i));
        shft = lag(ii);
        %shft_total = [shft_total; shft];
        if shft > 0 %shift second signal right
            dat_total(:,i) = [zeros(shft,1);dat(1:end-shft,i)];
        elseif shft < 0 %shift second signal left
            dat_total(:,i) = [dat(abs(shft)+1:end,i);zeros(abs(shft),1)];
        elseif shft == 0
            dat_total(:,i) = dat(:,i);
        end
    end
    
    
    %smooth and compute spec

spcnt = 0;
sm_total = [];
N = 512;
t = -N/2+1:N/2;
fs = 32000;
sigma = (1/1000)*fs;
w = exp(-(t/sigma).^2);


for i = 1:size(dat_total,2)

    %[sm,sp,t,f]=evsmooth(dat_total(:,i),fs,0.0001,512,0.8,2,100);


    [sp f t] = spectrogram(dat_total(:,i),w,N-2,N,fs);%matches with pitch contour code
    sm = mquicksmooth(dat_total(:,i),fs,1,2,100,'');

    sm_total = [sm_total sm];
    if (spcnt == 0)
        avsm = sm;
        avsp = abs(sp);
        spcnt = spcnt +1;
    else
        avsp = avsp + abs(sp);
        avsm = avsm + sm;
        spcnt = spcnt +1;
    end
end

avsp = avsp./spcnt;
avsm = avsm./spcnt;
 t = t-PRETIME;  