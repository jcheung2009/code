function lklhdstrct = get_lklhdstrct(batchptnstrcts,labels,name)

%%
%%
%%

fidb = fopen(char(batchptnstrcts),'r');
cntlng = 1;

while 1
    crntfile = fscanf(fidb,'%s',1);
    if isempty(crntfile)
        break
    end

    load(crntfile)
    cntlng = cntlng+1;
    for l = 1:length(labels)
        lklhdstrct(l).lng(cntlng).totlkl =[];
        lklhdstrct(l).lng(cntlng).patterns =[];
        lklhdstrct(l).lng(cntlng).lklhd =0;
    end

    [ptnprobstrct,uniqueptnsvect] = prob_of_patterns(patternstruct);

    for i = 1:length(ptnprobstrct)-1
        crntptn = ptnprobstrct(i).ptn;
        idx = strfind(labels,crntptn(end));
        if ~isempty(strfind(labels,crntptn(end)))
            lklhdstrct(idx).lng(cntlng).patterns = [lklhdstrct(idx).lng(cntlng).patterns '$' char(crntptn)];
            lklhdstrct(idx).lng(cntlng).lklhd = [lklhdstrct(idx).lng(cntlng).lklhd ptnprobstrct(i).prob];
            lklhdstrct(idx).lng(cntlng).totlkl = lklhdstrct(idx).lng(cntlng).totlkl+ptnprobstrct(i).prob;
        end
    end
end

name = [name 'lklhdstrct.mat'];
save(name,'lklhdstrct')