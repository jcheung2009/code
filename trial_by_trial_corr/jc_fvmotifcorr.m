function [fv_syll fv_gap0 fv_gap1 vol_syll vol_gap0 vol_gap1] = ...
    jc_fvmotifcorr(motif_sal, motif_cond,excludewashin,startpt,matchtm,motif,syllables)
%for experiment design saline morning vs drug afternoon
%stores changes in spectral features of syllables with corresponding
%syllable duration/gaps

tb_sal = jc_tb([motif_sal(:).datenm]',7,0);
tb_cond = jc_tb([motif_cond(:).datenm]',7,0);

if excludewashin == 1 & ~isempty(startpt)
    ind = find(tb_cond < startpt);
    motif_cond(ind) = [];
elseif excludewashin == 1
    ind = find(tb_cond<tb_sal(end)+1800); %exclude first half hour of wash in 
    motif_cond(ind) = [];
end

if ~isempty(matchtm)
    indsal = find(tb_sal>=tb_cond(1) & tb_sal <= tb_cond(end)); 
    motif_sal = motif_sal(indsal);
end 

fv_syll = struct();
fv_gap0 = struct();
fv_gap1 = struct();
vol_syll = struct();
vol_gap0 = struct();    
    
    
vol_gap1 = struct();
for i = 1:length(syllables)
    syllind = strfind(motif,syllables{i});
    syllind = syllind(1);
    fv = arrayfun(@(x) x.syllpitch(i),motif_cond,'unif',1)';
    fv_sal = arrayfun(@(x) x.syllpitch(i),motif_sal,'unif',1)';
    vol = arrayfun(@(x) x.syllvol(i),motif_cond,'unif',1)';
    vol_sal = arrayfun(@(x) x.syllvol(i),motif_sal,'unif',1)';
    
    sylldur = arrayfun(@(x) x.durations(syllind),motif_cond,'unif',1)';
    sylldur_sal = arrayfun(@(x) x.durations(syllind),motif_sal,'unif',1)';
    if syllind ~= length(motif)
        gap1 = arrayfun(@(x) x.gaps(syllind),motif_cond,'unif',1)';
        gap1_sal = arrayfun(@(x) x.gaps(syllind),motif_sal,'unif',1)';
    end
    if syllind ~= 1
        gap0 = arrayfun(@(x) x.gaps(syllind-1),motif_cond,'unif',1)';
        gap0_sal = arrayfun(@(x) x.gaps(syllind-1),motif_sal,'unif',1)';
    end
        
    fv = nanmean((fv-nanmean(fv_sal))./nanstd(fv_sal));
    vol = nanmean((vol-nanmean(vol_sal))./nanstd(vol_sal));
    sylldur = nanmean((sylldur-nanmean(sylldur_sal))./nanstd(sylldur_sal));
    if syllind ~= length(motif)
        gap1 = nanmean((gap1-nanmean(gap1_sal))./nanstd(gap1_sal));
    end
    if syllind ~= 1
        gap0 = nanmean((gap0-nanmean(gap0_sal))./nanstd(gap0_sal));
    end
    
    fv_syll.(['syll',syllables{i}]) = [(fv) sylldur];
    vol_syll.(['syll',syllables{i}]) = [vol sylldur];
    
    
    if syllind ~= 1
        fv_gap0.(['syll',syllables{i}]) = [fv gap0];
        vol_gap0.(['syll',syllables{i}]) = [vol gap0];
    end
    
    if syllind ~= length(motif)
        fv_gap1.(['syll',syllables{i}]) = [fv gap1];
        vol_gap1.(['syll',syllables{i}]) = [vol gap1];
    end
end
    
