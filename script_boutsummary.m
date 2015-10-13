ff = load_batchf('batchconsecutive');

salbout = struct();
trialcnt = 0;

for i = 1:2:length(ff)
    trialcnt = trialcnt +1;
    load(['analysis/data_structures/bout_',ff(i).name]);
    load(['analysis/data_structures/bout_',ff(i+1).name]);
    cmd = ['bout_',ff(i).name];
    cmd2 = ['bout_',ff(i+1).name];
    salbout(trialcnt).rate = jc_plotboutsummary2(eval(cmd),eval(cmd2),...
        'r.','r');
end
    