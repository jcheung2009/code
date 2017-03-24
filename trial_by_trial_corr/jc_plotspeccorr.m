function [fv_vol fv_ent vol_ent fv_vol_sal fv_ent_sal vol_ent_sal] = ...
    jc_plotspeccorr(fv_sal,fv_cond,excludewashin,startpt,matchtm)
%plots pairwise trial by trial correlation of spectral features 

pitch = [fv_sal(:).mxvals];
vol = log([fv_sal(:).maxvol]);
ent = [fv_sal(:).spent];
tb_sal = jc_tb([fv_sal(:).datenm]',7,0);
tb_cond = jc_tb([fv_cond(:).datenm]',7,0);

if excludewashin == 1 & ~isempty(startpt)
    ind = find(tb_cond < startpt);
    tb_cond(ind) = [];
elseif excludewashin == 1
    ind = find(tb_cond<tb_sal(end)+1800); %exclude first half hour of wash in 
    tb_cond(ind) = [];
end

if matchtm == 1
    indsal = find(tb_sal>=tb_cond(1) & tb_sal <= tb_cond(end)); 
    tb_sal = tb_sal(indsal);
    pitch = pitch(indsal);
    vol = vol(indsal);
    ent = ent(indsal);
end 

pitch2 = [fv_cond(:).mxvals];
vol2 = log([fv_cond(:).maxvol]);
ent2 = [fv_cond(:).spent];
if excludewashin == 1
    pitch2(ind) = [];
    vol2(ind) = [];
    ent2(ind) = [];
end

%absolute scores

fv_vol.abs = [pitch2' vol2'];
fv_ent.abs = [pitch2' ent2'];
vol_ent.abs = [vol2' ent2'];
fv_vol_sal.abs = [pitch' vol'];
fv_ent_sal.abs = [pitch' ent'];
vol_ent_sal.abs = [vol' ent'];

fv_vol.abs = fv_vol.abs(~any(isnan(fv_vol.abs),2),:);
fv_ent.abs = fv_ent.abs(~any(isnan(fv_ent.abs),2),:);
vol_ent.abs = vol_ent.abs(~any(isnan(vol_ent.abs),2),:);
fv_vol_sal.abs = fv_vol_sal.abs(~any(isnan(fv_vol_sal.abs),2),:);
fv_ent_sal.abs = fv_ent_sal.abs(~any(isnan(fv_ent_sal.abs),2),:);
vol_ent_sal.abs = vol_ent_sal.abs(~any(isnan(vol_ent_sal.abs),2),:);
%zscores scores

pitch2 = (pitch2-nanmean(pitch))./std(pitch);
pitch = (pitch-nanmean(pitch))./std(pitch);
vol2 = (vol2-nanmean(vol))./std(vol);
vol = (vol-nanmean(vol))./std(vol);
ent2 = (ent2-nanmean(ent))./std(ent);
ent = (ent-nanmean(ent))./std(ent);


fv_vol.zsc = [pitch2' vol2'];
fv_ent.zsc = [pitch2' ent2'];
vol_ent.zsc = [vol2' ent2'];
fv_vol_sal.zsc = [pitch' vol'];
fv_ent_sal.zsc = [pitch' ent'];
vol_ent_sal.zsc = [vol' ent'];

fv_vol.zsc = fv_vol.zsc(~any(isnan(fv_vol.zsc),2),:);
fv_ent.zsc = fv_ent.zsc(~any(isnan(fv_ent.zsc),2),:);
vol_ent.zsc = vol_ent.zsc(~any(isnan(vol_ent.zsc),2),:);
fv_vol_sal.zsc = fv_vol_sal.zsc(~any(isnan(fv_vol_sal.zsc),2),:);
fv_ent_sal.zsc = fv_ent_sal.zsc(~any(isnan(fv_ent_sal.zsc),2),:);
vol_ent_sal.zsc = vol_ent_sal.zsc(~any(isnan(vol_ent_sal.zsc),2),:);


