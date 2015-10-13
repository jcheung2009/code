function jc_fndlbl(vlsorind, vlsorfn, ind, newsyll)
%use with jc_vlsorfn and jc_chcklbl to replace syllable labels

displayfn = input(['display filename instead of change syllable to ',newsyll,'?:'],'s');

for i = 1:length(ind)
    if ~exist([vlsorfn{ind(i)},'.not.mat'])
        disp(vlsorfn{ind(i)})
    else 
        if displayfn == 'y'
            disp(['check ',vlsorfn{ind(i)}]);
        else
            load([vlsorfn{ind(i)},'.not.mat']);
            labels(vlsorind(ind(i))) = newsyll;
            save([vlsorfn{ind(i)},'.not.mat'],'labels','-append');
        end
    end
end

