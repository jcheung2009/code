ff = load_batchf('batchsal');
boutsal = struct();
load('analysis/data_structures/naspmlatency.mat');
trialcnt = 0;
for i = 1:2:length(ff)
    trialcnt = trialcnt+1;
    load(['analysis/data_structures/bout_',ff(i).name]);
    load(['analysis/data_structures/bout_',ff(i+1).name]);
    motif1 = ['bout_',ff(i).name];
    motif2 = ['bout_',ff(i+1).name];
    if ~isempty(strfind(ff(i+1).name,'naspm'))
            mcolor = 'r';
            mrk = 'ro';
    else
            mcolor = 'k';
            mrk = 'ko';
    end
        
     if ~isempty(strfind(ff(i+1).name,'sal'))
        startpt = '';
    else
        drugtime = iemapvlatency.(['tr_',ff(i+1).name]).treattime;
        startpt = (drugtime+0.6)*3600;
     end
    
    boutsal(trialcnt).singrate = jc_plotboutsummary(eval(motif1),eval(motif2),mrk,mcolor,0.5,0,startpt,0,16);

end
