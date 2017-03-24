ff = load_batchf('batchsal');
fvsal = struct();
load('analysis/data_structures/iemapvlatency');
syllables = {'A','C','R','W1','W2'};
trialcnt = 0;
for i = 1:2:length(ff)
    trialcnt = trialcnt+1;
    for ii = 1:length(syllables)
        
        load(['analysis/data_structures/fv_syll',syllables{ii},'_',ff(i).name]);
        load(['analysis/data_structures/fv_syll',syllables{ii},'_',ff(i+1).name]);
        fv1 = ['fv_syll',syllables{ii},'_',ff(i).name];
        fv2 = ['fv_syll',syllables{ii},'_',ff(i+1).name];
        if ~isempty(strfind(ff(i+1).name,'naspm'))
            mcolor = 'r';
            mrk = 'ro';
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
        
        if ~isempty(strfind(ff(i+1).name,'sal'))
            startpt = '';
        else
            drugtime = iemapvlatency.(['tr_',ff(i+1).name]).treattime;
            startpt = (drugtime+0.6)*3600;%change latency time
        end
        
        %% for saline morn vs drug afternoon design 
        [fvsal(trialcnt).(['syll',syllables{ii}]).fv fvsal(trialcnt).(['syll',syllables{ii}]).vol ...
            fvsal(trialcnt).(['syll',syllables{ii}]).ent ...
            fvsal(trialcnt).(['syll',syllables{ii}]).pcv] = ...
            jc_plotfvsummary(eval(fv1),eval(fv2),mrk,mcolor,0.5,0,startpt,0,'y','n',20);
        
        %% for blocked experiment design, drug day vs saline pre day
%         [fvsal(trialcnt).fv fvsal(trialcnt).vol fvsal(trialcnt).ent ...
%             fvsal(trialcnt).pcv] = jc_plotfvsummary2(eval(fv1),eval(fv2),mrk,mcolor,0.5);
        clearvars -except ff fvsal syllables trialcnt iemapvlatency i 
    end
end

