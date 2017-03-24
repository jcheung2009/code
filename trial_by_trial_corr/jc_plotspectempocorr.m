function [fvacorr_sal fvdur_sal fvgap_sal volacorr_sal voldur_sal volgap_sal varargout] = ...
    jc_plotspectempocorr(excludewashin,startpt,matchtm,syllables,varargin)
%plots pairwise trial by trial correlation of spectral and temporal features 


if length(varargin) == 2
    motif_sal = varargin{1};
    motif_cond = varargin{2};
    
    tb_sal = jc_tb([motif_sal(:).datenm]',7,0);
    tb_cond = jc_tb([motif_cond(:).datenm]',7,0);

    if excludewashin == 1 & ~isempty(startpt)
        ind = find(tb_cond < startpt);
        motif_cond(ind) = [];
    elseif excludewashin == 1
        ind = find(tb_cond<tb_sal(end)+1800); %exclude first half hour of wash in 
        motif_cond(ind) = [];
    end

    if matchtm==1
        indsal = find(tb_sal>=tb_cond(1) & tb_sal <= tb_cond(end)); 
        motif_sal = motif_sal(indsal);
    end 

    tb_sal = jc_tb([motif_sal(:).datenm]',7,0);
    tb_cond = jc_tb([motif_cond(:).datenm]',7,0);
    
    pitch2 = cell2mat(arrayfun(@(x) x.syllpitch,motif_cond,'unif',0)');
    vol2 = cell2mat(arrayfun(@(x) log10(x.syllvol),motif_cond,'unif',0)');
    ent2 = cell2mat(arrayfun(@(x) x.syllent,motif_cond,'unif',0)');
    acorr2 = cell2mat(arrayfun(@(x) x.firstpeakdistance,motif_cond,'unif',0)');
    sylldur2 = cell2mat(arrayfun(@(x) x.durations,motif_cond,'unif',0))';
    syllgap2 = cell2mat(arrayfun(@(x) x.gaps,motif_cond,'unif',0))';
    
else
    motif_sal = varargin{1};
end

pitch = cell2mat(arrayfun(@(x) x.syllpitch,motif_sal,'unif',0)');
vol = cell2mat(arrayfun(@(x) log10(x.syllvol),motif_sal,'unif',0)');
ent = cell2mat(arrayfun(@(x) x.syllent,motif_sal,'unif',0)');
acorr = cell2mat(arrayfun(@(x) x.firstpeakdistance,motif_sal,'unif',0)');
sylldur = cell2mat(arrayfun(@(x) x.durations,motif_sal,'unif',0))';
syllgap = cell2mat(arrayfun(@(x) x.gaps,motif_sal,'unif',0))';
    
%absolute scores
if length(varargin) == 2
    for i = 1:length(syllables)
        fvacorr_cond.(['syll',syllables{i}]).abs = [pitch2(:,i) acorr2];
        fvdur_cond.(['syll',syllables{i}]).abs = [pitch2(:,i) sylldur2];
        fvgap_cond.(['syll',syllables{i}]).abs = [pitch2(:,i) syllgap2];
        volacorr_cond.(['syll',syllables{i}]).abs = [vol2(:,i) acorr2];
        voldur_cond.(['syll',syllables{i}]).abs = [vol2(:,i) sylldur2];
        volgap_cond.(['syll',syllables{i}]).abs = [vol2(:,i) syllgap2];
    end
end
for i = 1:length(syllables)
    fvacorr_sal.(['syll',syllables{i}]).abs = [pitch(:,i) acorr];
    fvdur_sal.(['syll',syllables{i}]).abs = [pitch(:,i) sylldur];
    fvgap_sal.(['syll',syllables{i}]).abs = [pitch(:,i) syllgap];
    volacorr_sal.(['syll',syllables{i}]).abs = [vol(:,i) acorr];
    voldur_sal.(['syll',syllables{i}]).abs = [vol(:,i) sylldur];
    volgap_sal.(['syll',syllables{i}]).abs = [vol(:,i) syllgap];
end


%z-scores
if length(varargin) == 2
    pitch2 = bsxfun(@minus,pitch2,nanmean(pitch));
    pitch2 = bsxfun(@rdivide,pitch2,nanstd(pitch));
    vol2 = bsxfun(@minus,vol2,nanmean(vol));
    vol2 = bsxfun(@rdivide,vol2,nanstd(vol));
    acorr2 = bsxfun(@minus,acorr2,nanmean(acorr));
    acorr2 = bsxfun(@rdivide,acorr2,nanstd(acorr));
    sylldur2 = bsxfun(@minus,sylldur2,nanmean(sylldur));
    sylldur2 = bsxfun(@rdivide,sylldur2,nanstd(sylldur));
    syllgap2 = bsxfun(@minus,syllgap2,nanmean(syllgap));
    syllgap2 = bsxfun(@rdivide,syllgap2,nanstd(syllgap));
end
pitch = bsxfun(@rdivide,bsxfun(@minus,pitch,nanmean(pitch)),nanstd(pitch));
vol = bsxfun(@rdivide,bsxfun(@minus,vol,nanmean(vol)),nanstd(vol));
acorr = bsxfun(@rdivide,bsxfun(@minus,acorr,nanmean(acorr)),nanstd(acorr));
sylldur = bsxfun(@rdivide,bsxfun(@minus,sylldur,nanmean(sylldur)),nanstd(sylldur));
syllgap = bsxfun(@rdivide,bsxfun(@minus,syllgap,nanmean(syllgap)),nanstd(syllgap));


if length(varargin) == 2
    for i = 1:length(syllables)
        fvacorr_cond.(['syll',syllables{i}]).zsc = [pitch2(:,i) acorr2];
        fvdur_cond.(['syll',syllables{i}]).zsc = [pitch2(:,i) sylldur2];
        fvgap_cond.(['syll',syllables{i}]).zsc = [pitch2(:,i) syllgap2];
        volacorr_cond.(['syll',syllables{i}]).zsc = [vol2(:,i) acorr2];
        voldur_cond.(['syll',syllables{i}]).zsc = [vol2(:,i) sylldur2];
        volgap_cond.(['syll',syllables{i}]).zsc = [vol2(:,i) syllgap2];
    end
end

for i = 1:length(syllables)
    fvacorr_sal.(['syll',syllables{i}]).zsc = [pitch(:,i) acorr];
    fvdur_sal.(['syll',syllables{i}]).zsc = [pitch(:,i) sylldur];
    fvgap_sal.(['syll',syllables{i}]).zsc = [pitch(:,i) syllgap];
    volacorr_sal.(['syll',syllables{i}]).zsc = [vol(:,i) acorr];
    voldur_sal.(['syll',syllables{i}]).zsc = [vol(:,i) sylldur];
    volgap_sal.(['syll',syllables{i}]).zsc = [vol(:,i) syllgap];
end

if length(varargin) == 2
    varargout{1} = fvacorr_cond;
    varargout{2} = fvdur_cond;
    varargout{3} = fvgap_cond;
    varargout{4} = volacorr_cond;
    varargout{5} = voldur_cond;
    varargout{6} = volgap_cond;
end



