ff = load_batchf('batchnaspm');
boutnaspm = struct();
load('analysis/data_structures/naspmpitchlatency.mat');
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
        elseif ~isempty(strfind(ff(i+1).name,'iem'))
            mcolor = 'm';
            mrk = 'mo';
        elseif ~isempty(strfind(ff(i+1).name,'apv'))
            mcolor = 'b';
            mrk = 'bo';
        else
            mcolor = 'k';
            mrk = 'ko';
    end
        
     if ~isempty(strfind(ff(i+1).name,'sal'))
        startpt = '';
    else
        drugtime = naspmpitchlatency.(['tr_',ff(i+1).name]).treattime;
        startpt = (drugtime+1.5)*3600;
     end
    
    boutnaspm(trialcnt).singrate = jc_plotboutsummary(eval(motif1),eval(motif2),mrk,mcolor,0.5,0,startpt,'',16);
    %boutnaspm(trialcnt).singrate = jc_plotboutsummary2(eval(motif1),eval(motif2),'ko','k',5.5);
end
