function [mucorvct,mumxlc] = bn_sng_autocorr_tm(batch)

fidb = fopen(batch,'r')
cnt = 1;
while cnt <11
    crntfile = fscanf(fidb,'%s',1); if isempty(crntfile), break; end
    binarysong = binary_song(crntfile,100,0);
    v = xcorr(binarysong,50,'coeff');
    cormtrx(cnt,:) = v(31:100);
    df = diff(v(51:91)); zd = find(df ==0);
    if isempty(zd)  %find first max using derivative goes from + -> -
        pos= find(df>0);
        if isempty(pos)
            mxlc = nan;
        else
            id = find((sign(df(2:end)) == -1)+(sign(df(1:end-1)) ==1) ==2);
            mxlc(cnt) = 10*(id(1)+.5);
            cnt = cnt+1;
        end
    else
        mxlc(cnt) = 10*zd(1);
        cnt = cnt+1;
    end
end
cnt

%figure; plotmstd(mean(cormtrx),std(cormtrx)./sqrt(cnt),linspace(0,500,50),'k','k');
mucorvct = mean(cormtrx);
mumxlc = nanmean(mxlc);