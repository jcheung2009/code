function vols = jc_getvols(fv)
% use with jc_getvals2

vols = [];
for i = 1:length(fv)
    vols = [vols; fv(i).datenm fv(i).maxvol fv(i).ind];
end
