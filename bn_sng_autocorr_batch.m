function [mucormtrx,mumxlcvct] = bn_sng_autocorr_batch(batchbrds)

fidb = fopen(batchbrds,'r'); cnt = 0;
while 1
    crntbrd = fscanf(fidb,'%s',1); if isempty(crntbrd), break; end
    cnt = cnt+1;
    cd(crntbrd)
    [mucorvct,mumxlc] = bn_sng_autocorr_tm('batchnotmat');
    mucormtrx(cnt,:) = mucorvct;mumxlcvct(cnt) = mumxlc;
    cd ../
end
figure; 
plotmstd(mean(mucormtrx(:,21:50)),std(mucormtrx(:,21:50))./sqrt(cnt),linspace(0,300,30),'b','b')
