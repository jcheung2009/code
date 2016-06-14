ff = load_batchf('batchmusc');
skewmusc = struct();
load('analysis/data_structures/musclatency');
syllables = {'A1','A2','B1','B2'};
trialcnt = 0;
pitch1 = [];
pitch2 = [];
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
        elseif ~isempty(strfind(ff(i+1).name,'musc'))
            mcolor = 'm';
            mrk = 'mo';
        else
            mcolor = 'k';
            mrk = 'ko';
        end
        
        if ~isempty(strfind(ff(i+1).name,'sal'))
            startpt = '';
        else
            drugtime = musclatency.(['tr_',ff(i+1).name]).treattime;
            startpt = (drugtime+0.4)*3600;%change latency time
        end
        
        %% for saline morn vs drug afternoon design 
        [skewmusc(trialcnt).(['syll',syllables{ii}]) pitch1n pitch2n] = ...
            jc_plotskewsummary(eval(fv1),eval(fv2),mrk,mcolor,3.5,1,startpt,'y','n',21);
        pitch1 = [pitch1; pitch1n];
        pitch2 = [pitch2; pitch2n];
        %% for blocked experiment design, drug day vs saline pre day
%         [fvnaspm(trialcnt).fv fvnaspm(trialcnt).vol fvnaspm(trialcnt).ent ...
%             fvnaspm(trialcnt).pcv] = jc_plotfvsummary2(eval(fv1),eval(fv2),mrk,mcolor,0.5);
        clearvars -except ff skewmusc syllables trialcnt musclatency i pitch1 pitch2 mcolor
    end
end
% 
% figure;hold on;
% mn = floor(min([pitch1;pitch2]));
% mx = ceil(max([pitch1;pitch2]));
% [n b] = hist(pitch1,[mn:0.01:mx]);
% stairs(b,n/sum(n),'k','linewidth',2);
% [n b] = hist(pitch2,[mn:0.01:mx]);
% stairs(b,n/sum(n),mcolor,'linewidth',2);
% legend('saline','naspm');
% xlabel('z-score (relative to saline)');
% ylabel('probability');
% title('pitch distribution');
% set(gca,'fontweight','bold');