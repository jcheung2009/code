config;

for i = 1:length(params.trial)
    for n = 1:length(params.findmotif)
        motif = params.findmotif(n).motif;
        syllables = params.findmotif(n).syllables;
        syllind = cell2mat(cellfun(@(x) strfind(motif,x),syllables),'unif',0); 
        gapind = 1:length(motif)-1;
        gapind = gapind(arrayfun(@(x) length(intersect(syllind,[x x+1]))==2,gapind));
        load(['analysis/data_structures/',params.findmotif(n).motifstruct,params.trial(i).name]);
        load(['analysis/data_structures/',params.findmotif(n).motifstruct,params.trial(i).baseline]);
        motif_cond = eval([params.findmotif(n).motifstruct,params.trial(i).name]);
        motif_base = eval([params.findmotif(n).motifstruct,params.trial(i).baseline]);
        for m = 1:length(gapind)
            ind = [find(syllind == m) find(syllind == m+1)];
            gap_base = arrayfun(@(x) x.gaps(m),motif_base);
            pitch_base = cell2mat(arrayfun(@(x) x.syllpitch(ind)',motif_base,'unif',0)');
            vol_base = cell2mat(arrayfun(@(x) log10(x.syllvol(ind)'),motif_base,'unif',0)');
            dur_base = cell2mat(arrayfun(@(x) x.durations(ind)',motif_base,'unif',0)');
            
            gap_basen = (gap_base-mean(gap_base))./std(gap_base);
            pitch_basen = (pitch_base-mean(pitch_base))./std(pitch_base);
            vol_basen = (vol_base-mean(vol_base))./std(vol_base);
            dur_basen = (dur_base-mean(dur_base))./std(dur_base);
            
            gap_cond = arrayfun(@(x) x.gaps(m),motif_cond);
            pitch_cond = cell2mat(arrayfun(@(x) x.syllpitch(ind)',motif_cond,'unif',0)');
            vol_cond = cell2mat(arrayfun(@(x) log10(x.syllvol(ind)'),motif_cond,'unif',0)');
            dur_cond = cell2mat(arrayfun(@(x) x.durations(ind)',motif_cond,'unif',0)');

            gap = [gap_base'; gap_cond'];
            pitch = [pitch_base; pitch_cond];
            vol = [vol_base; vol_cond];
            dur = [dur_base; dur_cond];
            
            gapn = (gap-mean(gap))./std(gap);
            pitchn = (pitch-mean(pitch))./std(pitch);
            voln = (vol-mean(vol))./std(vol);
            durn = (dur-mean(dur))./std(dur);
        