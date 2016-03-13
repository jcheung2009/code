%plot latency correlations

ff = load_batchf('naspm_birds');
fv_motif = [];
vol_motif = [];
fv_singingrate = [];
vol_singingrate = [];
for i = 1:length(ff)
    load([ff(i).name,'/analysis/data_structures/summary']);
    crosscorr = eval(['crosscorrlatency_',ff(i).name]);
    fv_motif = [fv_motif; structfun(@(x) x.fv_motif,crosscorr)];
    vol_motif = [vol_motif; structfun(@(x) x.vol_motif,crosscorr)];
    fv_singingrate = [fv_singingrate; structfun(@(x) x.fv_singingrate,crosscorr)];
    vol_singingrate = [vol_singingrate; structfun(@(x) x.vol_singingrate,crosscorr)];
end

figure;hold on;
subtightplot(1,2,1,0.08,0.1,0.1);hold on;
plot(fv_motif,vol_motif,'ok','markersize',8);hold on;
refline(1,0);
xlabel('frequency vs tempo correlation');
ylabel('volume vs tempo correlation');

subtightplot(1,2,2,0.08,0.1,0.1);hold on;
plot(fv_singingrate,vol_singingrate,'ok','markersize',8);hold on;
refline(1,0);
xlabel('frequency vs singing rate correlation');
ylabel('volume vs singing rate correlation');