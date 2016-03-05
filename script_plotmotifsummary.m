ff = load_batchf('batchapv');

load('analysis/data_structures/apvlatency');

motifsal = struct();

trialcnt = 0;
for i = 1:2:length(ff)
    trialcnt = trialcnt+1;
    load(['analysis/data_structures/motif_aabb_',ff(i).name]);
    load(['analysis/data_structures/motif_aabb_',ff(i+1).name]);
    
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
        
    motif1 = ['motif_aabb_',ff(i).name];
    motif2 = ['motif_aabb_',ff(i+1).name];
    
    
    if ~isempty(strfind(ff(i+1).name,'sal'))
            startpt = '';
    else
        drugtime = apvlatency.(['tr_',ff(i+1).name]).treattime;
        startpt = (drugtime+1.88)*3600;%change latency time
    end

    [motifsal(trialcnt).mdur motifsal(trialcnt).sdur ...
    motifsal(trialcnt).gdur motifsal(trialcnt).mcv motifsal(trialcnt).macorr] = jc_plotmotifsummary(...
    eval(motif1),eval(motif2),mrk,mcolor,0.5,1,startpt,1,'n','n',17);
%     [motifsal(trialcnt).mdur motifsal(trialcnt).sdur ...
%         motifsal(trialcnt).gdur motifsal(trialcnt).mcv] = jc_plotmotifsummary3b(...
%         eval(motif1),eval(motif2),'ro','r',3.5);
end
