function [spectempocorr] = jc_plotspectempocorr(...
   motif_sal,motif_cond,syllind,durind,gap0ind,gap1ind,excludewashin,startpt,matchtm)
%plots pairwise trial by trial correlation of spectral and temporal features 
%[fv_acorr fv_sdur fv_g0dur fv_g1dur vol_acorr vol_sdur vol_g0dur ...
%    vol_g1dur ent_acorr ent_sdur ent_g0dur ent_g1dur fv_acorr_sal fv_sdur_sal ...
%    fv_g0dur_sal fv_g1dur_sal vol_acorr_sal vol_sdur_sal vol_g0dur_sal vol_g1dur_sal ...
%    ent_acorr_sal ent_sdur_sal ent_g0dur_sal ent_g1dur_sal]
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

tb_sal = jc_tb([motif_sal(:).datenm]',7,0);
tb_cond = jc_tb([motif_cond(:).datenm]',7,0);

pitch = arrayfun(@(x) x.syllpitch(syllind),motif_sal,'unif',1)';
vol = arrayfun(@(x) log10(x.syllvol(syllind)),motif_sal,'unif',1)';
ent = arrayfun(@(x) x.syllent(syllind),motif_sal,'unif',1)';
acorr = arrayfun(@(x) x.firstpeakdistance,motif_sal,'unif',1)';
sylldur = arrayfun(@(x) x.durations(durind),motif_sal,'unif',1)';
if ~isempty(gap0ind) 
    gap0 = arrayfun(@(x) x.gaps(gap0ind),motif_sal,'unif',1)';
else
    gap0 = NaN(length(pitch),1);
end

if ~isempty(gap1ind)
    gap1 = arrayfun(@(x) x.gaps(gap1ind),motif_sal,'unif',1)';
else
    gap1 = NaN(length(pitch),1);
end


pitch2 = arrayfun(@(x) x.syllpitch(syllind),motif_cond,'unif',1)';
vol2 = arrayfun(@(x) log10(x.syllvol(syllind)),motif_cond,'unif',1)';
ent2 = arrayfun(@(x) x.syllent(syllind),motif_cond,'unif',1)';
acorr2 = arrayfun(@(x) x.firstpeakdistance,motif_cond,'unif',1)';
sylldur2 = arrayfun(@(x) x.durations(durind),motif_cond,'unif',1)';
if ~isempty(gap0ind)
    gap02 = arrayfun(@(x) x.gaps(gap0ind),motif_cond,'unif',1)';
else
    gap02 = NaN(length(pitch2),1);
end

if ~isempty(gap1ind)
    gap12 = arrayfun(@(x) x.gaps(gap1ind),motif_cond,'unif',1)';
else
    gap12 = NaN(length(pitch2),1);
end

%absolute scores
spectempocorr.cond.abs = [pitch2 vol2 ent2 acorr2 sylldur2 gap02 gap12];
spectempocorr.sal.abs = [pitch vol ent acorr sylldur gap0 gap1];


%relative scores
pitch2n = (pitch2-nanmean(pitch))./nanmean(pitch);
pitchn = (pitch-nanmean(pitch))./nanmean(pitch);
vol2n = (vol2-nanmean(vol))./abs(nanmean(vol));
voln = (vol-nanmean(vol))./abs(nanmean(vol));
ent2n = (ent2-nanmean(ent))./nanmean(ent);
entn = (ent-nanmean(ent))./nanmean(ent);
acorr2n = (acorr2-nanmean(acorr))./nanmean(acorr);
acorrn = (acorr-nanmean(acorr))./nanmean(acorr);
sylldur2n = (sylldur2-nanmean(sylldur))./nanmean(sylldur);
sylldurn = (sylldur-nanmean(sylldur))./nanmean(sylldur);
if ~isempty(gap0ind)
    gap02n = (gap02-nanmean(gap0))./nanmean(gap0);
    gap0n = (gap0-nanmean(gap0))./nanmean(gap0);
else
    gap02n = NaN(length(pitch2),1);
    gap0n = NaN(length(pitch),1);
end

if ~isempty(gap1ind)
    gap12n = (gap12-nanmean(gap1))./nanmean(gap1);
    gap1n = (gap1-nanmean(gap1))./nanmean(gap1);
else
    gap12n = NaN(length(pitch2),1);
    gap1n = NaN(length(pitch),1);
end

spectempocorr.cond.rel = [pitch2n vol2n ent2n acorr2n sylldur2n gap02n gap12n];
spectempocorr.sal.rel = [pitchn voln entn acorrn sylldurn gap0n gap1n];


%z-scores
pitch2 = (pitch2-nanmean(pitch))./nanstd(pitch);
pitch = (pitch-nanmean(pitch))./nanstd(pitch);
vol2 = (vol2-nanmean(vol))./nanstd(vol);
vol = (vol-nanmean(vol))./nanstd(vol);
ent2 = (ent2-nanmean(ent))./nanstd(ent);
ent = (ent-nanmean(ent))./nanstd(ent);
acorr2 = (acorr2-nanmean(acorr))./nanstd(acorr);
acorr = (acorr-nanmean(acorr))./nanstd(acorr);
sylldur2 = (sylldur2-nanmean(sylldur))./nanstd(sylldur);
sylldur = (sylldur-nanmean(sylldur))./nanstd(sylldur);
if ~isempty(gap0ind)
    gap02 = (gap02-nanmean(gap0))./nanstd(gap0);
    gap0 = (gap0-nanmean(gap0))./nanstd(gap0);
else
    gap02 = NaN(length(pitch2),1);
    gap0 = NaN(length(pitch),1);
end

if ~isempty(gap1ind)
    gap12 = (gap12-nanmean(gap1))./nanstd(gap1);
    gap1 = (gap1-nanmean(gap1))./nanstd(gap1);
else
    gap12 = NaN(length(pitch2),1);
    gap1 = NaN(length(pitch),1);
end

spectempocorr.cond.zsc = [pitch2 vol2 ent2 acorr2 sylldur2 gap02 gap12];
spectempocorr.sal.zsc = [pitch vol ent acorr sylldur gap0 gap1];

% fv_acorr.abs = [pitch2 acorr2];
% fv_sdur.abs = [pitch2 sylldur2];
% vol_acorr.abs = [vol2 acorr2];
% vol_sdur.abs = [vol2 sylldur2];
% ent_acorr.abs = [ent2 acorr2];
% ent_sdur.abs = [ent2 sylldur2];
% 
% if ~isempty(gap0ind)
%     fv_g0dur.abs = [pitch2 gap02];
%     vol_g0dur.abs = [vol2 gap02];
%     ent_g0dur.abs = [ent2 gap02];
% else
%     fv_g0dur.abs = [];
%     vol_g0dur.abs = [];
%     ent_g0dur.abs = [];
% end
% 
% if ~isempty(gap1ind)
%     fv_g1dur.abs = [pitch2 gap12];
%     vol_g1dur.abs = [vol2 gap12];
%     ent_g1dur.abs = [ent2 gap12];
% else
%     fv_g1dur.abs = [];
%     vol_g1dur.abs = [];
%     ent_g1dur.abs = [];
% end
% 
% fv_acorr.abs = fv_acorr.abs(~any(isnan(fv_acorr.abs),2),:);
% fv_sdur.abs = fv_sdur.abs(~any(isnan(fv_sdur.abs),2),:);
% fv_g0dur.abs = fv_g0dur.abs(~any(isnan(fv_g0dur.abs),2),:);
% fv_g1dur.abs = fv_g1dur.abs(~any(isnan(fv_g1dur.abs),2),:);
% vol_acorr.abs = vol_acorr.abs(~any(isnan(vol_acorr.abs),2),:);
% vol_sdur.abs = vol_sdur.abs(~any(isnan(vol_sdur.abs),2),:);
% vol_g0dur.abs = vol_g0dur.abs(~any(isnan(vol_g0dur.abs),2),:);
% vol_g1dur.abs = vol_g1dur.abs(~any(isnan(vol_g1dur.abs),2),:);
% ent_acorr.abs = ent_acorr.abs(~any(isnan(ent_acorr.abs),2),:);
% ent_sdur.abs = ent_sdur.abs(~any(isnan(ent_sdur.abs),2),:);
% ent_g0dur.abs = ent_g0dur.abs(~any(isnan(ent_g0dur.abs),2),:);
% ent_g1dur.abs = ent_g1dur.abs(~any(isnan(ent_g1dur.abs),2),:);
% 
% fv_acorr_sal.abs = [pitch acorr];
% fv_sdur_sal.abs = [pitch sylldur];
% vol_acorr_sal.abs = [vol acorr];
% vol_sdur_sal.abs = [vol sylldur];
% ent_acorr_sal.abs = [ent acorr];
% ent_sdur_sal.abs = [ent sylldur];
% 
% if ~isempty(gap0ind)
%     fv_g0dur_sal.abs = [pitch gap0];
%     vol_g0dur_sal.abs = [vol gap0];
%     ent_g0dur_sal.abs = [ent gap0];
% else
%     fv_g0dur_sal.abs = [];
%     vol_g0dur_sal.abs = [];
%     ent_g0dur_sal.abs = [];
% end
% if ~isempty(gap1ind)
%     fv_g1dur_sal.abs = [pitch gap1];
%     vol_g1dur_sal.abs = [vol gap1];
%     ent_g1dur_sal.abs = [ent gap1];
% else
%     fv_g1dur_sal.abs = [];
%     vol_g1dur_sal.abs = [];
%     ent_g1dur_sal.abs = [];
% end
% 
% fv_acorr_sal.abs = fv_acorr_sal.abs(~any(isnan(fv_acorr_sal.abs),2),:);
% fv_sdur_sal.abs = fv_sdur_sal.abs(~any(isnan(fv_sdur_sal.abs),2),:);
% fv_g0dur_sal.abs = fv_g0dur_sal.abs(~any(isnan(fv_g0dur_sal.abs),2),:);
% fv_g1dur_sal.abs = fv_g1dur_sal.abs(~any(isnan(fv_g1dur_sal.abs),2),:);
% vol_acorr_sal.abs = vol_acorr_sal.abs(~any(isnan(vol_acorr_sal.abs),2),:);
% vol_sdur_sal.abs = vol_sdur_sal.abs(~any(isnan(vol_sdur_sal.abs),2),:);
% vol_g0dur_sal.abs = vol_g0dur_sal.abs(~any(isnan(vol_g0dur_sal.abs),2),:);
% vol_g1dur_sal.abs = vol_g1dur_sal.abs(~any(isnan(vol_g1dur_sal.abs),2),:);
% ent_acorr_sal.abs = ent_acorr_sal.abs(~any(isnan(ent_acorr_sal.abs),2),:);
% ent_sdur_sal.abs = ent_sdur_sal.abs(~any(isnan(ent_sdur_sal.abs),2),:);
% ent_g0dur_sal.abs = ent_g0dur_sal.abs(~any(isnan(ent_g0dur_sal.abs),2),:);
% ent_g1dur_sal.abs = ent_g1dur_sal.abs(~any(isnan(ent_g1dur_sal.abs),2),:);
% 
% %z-scores
% pitch2 = (pitch2-nanmean(pitch))./nanstd(pitch);
% pitch = (pitch-nanmean(pitch))./nanstd(pitch);
% vol2 = (vol2-nanmean(vol))./nanstd(vol);
% vol = (vol-nanmean(vol))./nanstd(vol);
% ent2 = (ent2-nanmean(ent))./nanstd(ent);
% ent = (ent-nanmean(ent))./nanstd(ent);
% acorr2 = (acorr2-nanmean(acorr))./nanstd(acorr);
% acorr = (acorr-nanmean(acorr))./nanstd(acorr);
% sylldur2 = (sylldur2-nanmean(sylldur2))./nanstd(sylldur2);
% sylldur = (sylldur-nanmean(sylldur))./nanstd(sylldur);
% if ~isempty(gap0ind)
%     gap02 = (gap02-nanmean(gap0))./nanstd(gap0);
%     gap0 = (gap0-nanmean(gap0))./nanstd(gap0);
% end
% if ~isempty(gap1ind)
%     gap12 = (gap12-nanmean(gap1))./nanstd(gap1);
%     gap1 = (gap1-nanmean(gap1))./nanstd(gap1);
% end
% 
% fv_acorr.zsc = [pitch2 acorr2];
% fv_sdur.zsc = [pitch2 sylldur2];
% vol_acorr.zsc = [vol2 acorr2];
% vol_sdur.zsc = [vol2 sylldur2];
% ent_acorr.zsc = [ent2 acorr2];
% ent_sdur.zsc = [ent2 sylldur2];
% 
% if ~isempty(gap0ind)
%     fv_g0dur.zsc = [pitch2 gap02];
%     vol_g0dur.zsc = [vol2 gap02];
%     ent_g0dur.zsc = [ent2 gap02];
% else
%     fv_g0dur.zsc = [];
%     vol_g0dur.zsc = [];
%     ent_g0dur.zsc = [];
% end
% if ~isempty(gap1ind)
%     fv_g1dur.zsc = [pitch2 gap12];
%     vol_g1dur.zsc = [vol2 gap12];
%     ent_g1dur.zsc = [ent2 gap12];
% else
%     fv_g1dur.zsc = [];
%     vol_g1dur.zsc = [];
%     ent_g1dur.zsc = [];
% end
% 
% fv_acorr.zsc = fv_acorr.zsc(~any(isnan(fv_acorr.zsc),2),:);
% fv_sdur.zsc = fv_sdur.zsc(~any(isnan(fv_sdur.zsc),2),:);
% fv_g0dur.zsc = fv_g0dur.zsc(~any(isnan(fv_g0dur.zsc),2),:);
% fv_g1dur.zsc = fv_g1dur.zsc(~any(isnan(fv_g1dur.zsc),2),:);    
% vol_acorr.zsc = vol_acorr.zsc(~any(isnan(vol_acorr.zsc),2),:);
% vol_sdur.zsc = vol_sdur.zsc(~any(isnan(vol_sdur.zsc),2),:);
% vol_g0dur.zsc = vol_g0dur.zsc(~any(isnan(vol_g0dur.zsc),2),:);
% vol_g1dur.zsc = vol_g1dur.zsc(~any(isnan(vol_g1dur.zsc),2),:);
% ent_acorr.zsc = ent_acorr.zsc(~any(isnan(ent_acorr.zsc),2),:);
% ent_sdur.zsc = ent_sdur.zsc(~any(isnan(ent_sdur.zsc),2),:);
% ent_g0dur.zsc = ent_g0dur.zsc(~any(isnan(ent_g0dur.zsc),2),:);
% ent_g1dur.zsc = ent_g1dur.zsc(~any(isnan(ent_g1dur.zsc),2),:);
% 
% fv_acorr_sal.zsc = [pitch acorr];
% fv_sdur_sal.zsc = [pitch sylldur];
% vol_acorr_sal.zsc = [vol acorr];
% vol_sdur_sal.zsc = [vol sylldur];
% ent_acorr_sal.zsc = [ent acorr];
% ent_sdur_sal.zsc = [ent sylldur];
% 
% if ~isempty(gap0ind)
%     fv_g0dur_sal.zsc = [pitch gap0];
%     vol_g0dur_sal.zsc = [vol gap0];
%     ent_g0dur_sal.zsc = [ent gap0];
% else
%     fv_g0dur_sal.zsc = [];
%     vol_g0dur_sal.zsc = [];
%     ent_g0dur_sal.zsc = [];
% end
% 
% if ~isempty(gap1ind)
%     fv_g1dur_sal.zsc = [pitch gap1];
%     vol_g1dur_sal.zsc = [vol gap1];
%     ent_g1dur_sal.zsc = [ent gap1];
% else
%     fv_g1dur_sal.zsc = [];
%     vol_g1dur_sal.zsc = [];
%     ent_g1dur_sal.zsc = [];
% end
% 
% fv_acorr_sal.zsc = fv_acorr_sal.zsc(~any(isnan(fv_acorr_sal.zsc),2),:);
% fv_sdur_sal.zsc = fv_sdur_sal.zsc(~any(isnan(fv_sdur_sal.zsc),2),:);
% fv_g0dur_sal.zsc = fv_g0dur_sal.zsc(~any(isnan(fv_g0dur_sal.zsc),2),:);
% fv_g1dur_sal.zsc = fv_g1dur_sal.zsc(~any(isnan(fv_g1dur_sal.zsc),2),:);
% vol_acorr_sal.zsc = vol_acorr_sal.zsc(~any(isnan(vol_acorr_sal.zsc),2),:);
% vol_sdur_sal.zsc = vol_sdur_sal.zsc(~any(isnan(vol_sdur_sal.zsc),2),:);
% vol_g0dur_sal.zsc = vol_g0dur_sal.zsc(~any(isnan(vol_g0dur_sal.zsc),2),:);
% vol_g1dur_sal.zsc = vol_g1dur_sal.zsc(~any(isnan(vol_g1dur_sal.zsc),2),:);
% ent_acorr_sal.zsc = ent_acorr_sal.zsc(~any(isnan(ent_acorr_sal.zsc),2),:);
% ent_sdur_sal.zsc = ent_sdur_sal.zsc(~any(isnan(ent_sdur_sal.zsc),2),:);
% ent_g0dur_sal.zsc = ent_g0dur_sal.zsc(~any(isnan(ent_g0dur_sal.zsc),2),:);
% ent_g1dur_sal.zsc = ent_g1dur_sal.zsc(~any(isnan(ent_g1dur_sal.zsc),2),:);
% 
