function jc_testcript(fv_rep)
fs = 32000;
maxlength = max(arrayfun(@(x) x.runlength,fv_rep));
xcorrvals_syll = struct();
for i = 2:maxlength
    for ii = 1:length(fv_rep)
        if fv_rep(ii).runlength >= i
            
            [c lags] = xcorr(fv_rep(ii).sm(1:ceil(fv_rep(ii).off(i)*fs)),'coeff');
            c = c(ceil(length(c)/2):end);
            [pks locs] = findpeaks(c,'MINPEAKDISTANCE',960,'MINPEAKHEIGHT',0.1);%peaks min 30 ms apart
            xcorrvals_syll.(['syll',num2str(i)]) = [fv_rep(ii).datenm,mean(diff([1;locs]))/32000];
        else
            continue
        end
    end
end