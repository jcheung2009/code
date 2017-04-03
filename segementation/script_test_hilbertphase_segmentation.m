



motif_sal = motif_bcd_11_11_2015_saline;
motif_naspm = motif_bcd_11_12_2015_naspm;
sm_sal = arrayfun(@(x) (x.logsm-mean(x.logsm))/std(x.logsm),motif_sal,'unif',0);
sm_naspm = arrayfun(@(x) (x.logsm-mean(x.logsm))/std(x.logsm),motif_naspm,'unif',0);
ph_sal = cellfun(@(x) angle(hilbert(x)),sm_sal,'unif',0);
ph_naspm = cellfun(@(x) angle(hilbert(x)),sm_naspm,'unif',0);
ind_sal = cellfun(@(x) (x>=-0.5*pi & x<0.5*pi),ph_sal,'unif',0);
ind_naspm = cellfun(@(x) (x>=-0.5*pi & x<0.5*pi),ph_naspm,'unif',0);
[onsets_sal offsets_sal] = cellfun(@(x) SegmentNotes(x,fs,5,20,0.5),ind_sal,'unif',0);
[onsets_n offsets_n] = cellfun(@(x) SegmentNotes(x,fs,5,20,0.5),ind_naspm,'unif',0);
onsets_sal = cell2mat(onsets_sal);
offsets_sal = cell2mat(offsets_sal);
durs_sal = offsets_sal-onsets_sal;
gaps_sal = onsets_sal(2:end,:)-offsets_sal(1:end-1,:);

onsets_n = cell2mat(onsets_n);
offsets_n = cell2mat(offsets_n);
durs_n = offsets_n-onsets_n;
gaps_n = onsets_n(2:end,:)-offsets_n(1:end-1,:);