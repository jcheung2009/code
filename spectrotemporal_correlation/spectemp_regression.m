motifdur = arrayfun(@(x) x.motifdur,motif)';
syll = arrayfun(@(x) mean(x.durations),motif)';
gap = arrayfun(@(x) mean(x.gaps),motif)';
vol = arrayfun(@(x) mean(x.syllvol),motif)';



tbl = table(motifdur,syll,gap,vol,'VariableNames',{'motifdur','syll','gap','vol'});
lm = fitlm(tbl,'motifdur~syll+gap+vol')


pitch = arrayfun(@(x) x.syllpitch(2),motif)';
vol = arrayfun(@(x) x.syllvol(2),motif)';
vol_pre = arrayfun(@(x) x.syllvol(1),motif)';
vol_post = arrayfun(@(x) x.syllvol(3),motif)';
gap_pre = arrayfun(@(x) x.gaps(1),motif)';
gap_post = arrayfun(@(x) x.gaps(2),motif)';
syll = arrayfun(@(x) x.durations(2),motif)';
syll_pre = arrayfun(@(x) x.durations(1),motif)';
syll_post = arrayfun(@(x) x.durations(3),motif)';
tbl = table(pitch,gap_pre,gap_post,syll,syll_pre,syll_post,vol,vol_pre,vol_post,'VariableNames',...
    {'pitch','gap_pre','gap_post','syll','syll_pre','syll_post','vol','vol_pre','vol_post'});
lm = fitlm(tbl,'pitch~gap_pre+gap_post+syll+syll_pre+syll_post+vol+vol_pre+vol_post');
