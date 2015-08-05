function [fv_locs] = acorrpeak(acorr,pkct,lowlimit,uplimit)

fv_locs = [];
for i = 1:size(acorr,2)
    [n b] = hist(acorr(:,i));
    [c x] = max(n);
    [pks,locs] = findpeaks(acorr(:,i),'minpeakdistance',300,'minpeakheight',b(x));
    locs = locs*5/32000;
    if numel(locs) == 0;
        fv = NaN;
    else
        a = find(locs>lowlimit & locs < uplimit);
        if numel(a) == 0
            fv = NaN;
        else 
        [c y] = max(pks(a));
        fv = pkct/locs(a(y));
        end
    end
    fv_locs(i,1) = fv;
end



    
    
    
   