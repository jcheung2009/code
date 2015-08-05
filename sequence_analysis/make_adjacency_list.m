function [] = make_adjacency_list(batch,rmv_intro,do_color)

fidb = fopen(batch);
while 1
    crntfile = fscanf(fidb,'%s',1);
    if isempty(crntfile), break; end
    load(char(crntfile))
    breks= strfind(crntfile,'.');
    if ~rmv_intro && ~do_color
        name = [crntfile(1:breks(1)-1) '.all.motifs'];
    elseif rmv_intro && ~do_color
        name = [crntfile(1:breks(1)-1) '.syls.motifs'];
    elseif rmv_intro && do_color
        name = [crntfile(1:breks(1)-1) '.clred.all.motifs'];
    elseif ~rmv_intro && do_color
        name = [crntfile(1:breks(1)-1) '.clred.syls.motifs'];
    end

    if rmv_intro
        intros = 'ijkx';
        k=0;
        for i =1:4
            id = strfind(trns_strct.lbls,intros(i));
            if ~isempty(id)
                k = k+1;
                ids(k) = id;
            end
        end
    else ids =[];
    end

    mtrx = trns_strct.mtrx(setdiff([1:length(trns_strct.mtrx)],ids),setdiff([1:length(trns_strct.mtrx)],ids));
    cnt = 0;
    
    for i=1:length(mtrx)
        for ii = 1:length(mtrx)
            if mtrx(i,ii) >0
                cnt = cnt+1;
                if do_color
                    edge(cnt,:) = [i ii i ii];
                else
                    edge(cnt,:) = [i ii];
                end
            end
        end
    end
    fid = fopen(char(name),'wt');
    fprintf(fid,'%0.0f %1.0f\n',edge);
    fclose(fid);
end