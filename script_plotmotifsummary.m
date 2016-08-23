ff = load_batchf('batchsal');

load('analysis/data_structures/iemapvlatency');

motifsal = struct();

trialcnt = 0;
for i = 1:2:length(ff)
    trialcnt = trialcnt+1;
    load(['analysis/data_structures/motif_abcdeeerww_',ff(i).name]);
    load(['analysis/data_structures/motif_abcdeeerww_',ff(i+1).name]);
    
     if ~isempty(strfind(ff(i+1).name,'iem')) & ~isempty(strfind(ff(i+1).name,'apv'))
            mcolor = 'g';
            mrk = 'go';
    elseif ~isempty(strfind(ff(i+1).name,'IEM'))
        mcolor = 'r';
        mrk = 'ro';
    elseif ~isempty(strfind(ff(i+1).name,'APV'))
         mcolor = 'g';
         mrk = 'go';
    else
        mcolor = 'k';
        mrk = 'ko';
     end
        
    motif1 = ['motif_abcdeeerww_',ff(i).name];
    motif2 = ['motif_abcdeeerww_',ff(i+1).name];
    
    
    if ~isempty(strfind(ff(i+1).name,'sal'))
            startpt = '';
    else
        drugtime = iemapvlatency.(['tr_',ff(i+1).name]).treattime;
        startpt = (drugtime+0.5)*3600;%change latency time
    end

    [motifsal(trialcnt).mdur motifsal(trialcnt).sdur ...
    motifsal(trialcnt).gdur motifsal(trialcnt).macorr] = jc_plotmotifsummary(...
    eval(motif1),eval(motif2),mrk,mcolor,0.5,0,startpt,0,'y','n',17);
%     [motifsal(trialcnt).mdur motifsal(trialcnt).sdur ...
%         motifsal(trialcnt).gdur motifsal(trialcnt).mcv] = jc_plotmotifsummary3b(...
%         eval(motif1),eval(motif2),'ro','r',3.5);
end
