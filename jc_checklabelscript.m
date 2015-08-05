

ans = input('check label?:','s')

while strcmp(ans,'y')
    var = input('syllable string (nt, prent, postnt):')
    jc_chcklbl('batch',var{1},0.01,0.01,var{2},var{3},'obs0');
    delete('syll*.not.mat');
    !ls *.wav > wav
    evsonganaly
    load('syllwv1.wav.not.mat');labels1 = labels;
    load('syllwv2.wav.not.mat');labels2 = labels;
    labels = [labels1 labels2];
    [vlsorfn vlsorind] = jc_vlsorfn('batch',var{1},var{2},var{3});
    if size(vlsorfn) == size(labels)
        sylmark = input('marking syllable in chcklbl for change:','s')
        newsyl = input('new syllable:','s')
        ind = strfind(labels,sylmark);
        jc_fndlbl(vlsorind,vlsorfn,ind,newsyl);
    else
        disp('size vlsorfn ~= size labels')
    end
    ans = input('check label?:','s')
end

listofsylls = input('list of syllables to change to repeat syl:')
repeatsyll = input('repeat syllable:','s')
for i = 1:length(listofsylls)
    changelabel('batch',listofsylls{i},'','',repeatsyll,'');
end
