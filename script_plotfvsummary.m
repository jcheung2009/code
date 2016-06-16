ff = load_batchf('batchnaspm');
fvnaspm = struct();
load('analysis/data_structures/naspmpitchlatency');
syllables = {'A1','A2','B1','B2'};
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
            drugtime = apviempitchlatency.(['tr_',ff(i+1).name]).treattime;
            startpt = (drugtime+1.5)*3600;%change latency time
        end
        
        %% for saline morn vs drug afternoon design 
        [fvnaspm(trialcnt).(['syll',syllables{ii}]).fv fvnaspm(trialcnt).(['syll',syllables{ii}]).vol ...
            fvnaspm(trialcnt).(['syll',syllables{ii}]).ent ...
            fvnaspm(trialcnt).(['syll',syllables{ii}]).pcv] = ...
            jc_plotfvsummary(eval(fv1),eval(fv2),mrk,mcolor,0.5,1,startpt,'','n','n',20);
        
        %% for blocked experiment design, drug day vs saline pre day
%         [fvnaspm(trialcnt).fv fvnaspm(trialcnt).vol fvnaspm(trialcnt).ent ...
%             fvnaspm(trialcnt).pcv] = jc_plotfvsummary2(eval(fv1),eval(fv2),mrk,mcolor,0.5);
        clearvars -except ff fvnaspm syllables trialcnt naspmpitchlatency i 
    end
end

