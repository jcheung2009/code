batchname = 'batchsal';
if ~isempty(strfind(batchname,'naspm')) & ~isempty(strfind(batchname,'musc'))
    mcolor = 'g';
elseif ~isempty(strfind(batchname,'naspm'))
    mcolor = 'r';
elseif ~isempty(strfind(batchname,'musc'))
    mcolor = 'm';
elseif ~isempty(strfind(batchname,'apv'))
    mcolor = 'b';
else
    mcolor = 'k';
end
ff = load_batchf(batchname);
speccorr = struct();
load('analysis/data_structures/naspmmusclatency');
syllables = {'A1','A2','B1','B2'};
trialcnt = 0;
for i = 1:2:length(ff)
    trialcnt = trialcnt+1;
    for ii = 1:length(syllables)
        
        load(['analysis/data_structures/fv_syll',syllables{ii},'_',ff(i).name]);
        load(['analysis/data_structures/fv_syll',syllables{ii},'_',ff(i+1).name]);
        fv1 = ['fv_syll',syllables{ii},'_',ff(i).name];
        fv2 = ['fv_syll',syllables{ii},'_',ff(i+1).name];
        
        if ~isempty(strfind(ff(i+1).name,'sal'))
            startpt = '';
        else
            drugtime = naspmmusclatency.(['tr_',ff(i+1).name]).treattime;
            startpt = (drugtime+1.5)*3600;%change latency time
        end
        
        [speccorr(trialcnt).(['syll',syllables{ii}]).fv_vol ...
            speccorr(trialcnt).(['syll',syllables{ii}]).fv_ent ...
            speccorr(trialcnt).(['syll',syllables{ii}]).vol_ent ...
            speccorr(trialcnt).(['syll',syllables{ii}]).fv_vol_sal ...
            speccorr(trialcnt).(['syll',syllables{ii}]).fv_ent_sal ...
            speccorr(trialcnt).(['syll',syllables{ii}]).vol_ent_sal] = ...
            jc_plotspeccorr(eval(fv1),eval(fv2),0,startpt,'',1);
    end
end

figure;hold on;
for i = 1:length(syllables)
    fv_vol = [];
    fv_vol_sal = [];
    for ii = 1:length(speccorr)
        fv_vol = [fv_vol; speccorr(ii).(['syll',syllables{i}]).fv_vol.abs];
        fv_vol_sal = [fv_vol_sal; speccorr(ii).(['syll',syllables{i}]).fv_vol_sal.abs];
    end
    
    h1 = subtightplot(2,length(syllables),i,[0.15 0.07],0.08, 0.08);
    scatter(h1,fv_vol(:,1),fv_vol(:,2),25,mcolor,'filled','MarkerFaceAlpha',0.3);
    [r p] = corrcoef(fv_vol(:,1),fv_vol(:,2));
    str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
    xlabel(h1,['pitch ',syllables{i}]);
    ylabel(h1,['volume ',syllables{i}]);
    set(h1,'fontweight','bold');
    title(h1,str);
    
    h2 = subtightplot(2,length(syllables),i+length(syllables),[0.15 0.07],0.08, 0.08);
    scatter(h2,fv_vol_sal(:,1),fv_vol_sal(:,2),25,'k','filled','MarkerFaceAlpha',0.3);
    [r p] = corrcoef(fv_vol_sal(:,1),fv_vol_sal(:,2));
    str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
    xlabel(h2,['pitch ',syllables{i}]);
    ylabel(h2,['volume ',syllables{i}]);
    set(h2,'fontweight','bold');
    title(h2,str);
end
    
% for i = 1:length(syllables)
%     fv_vol = [];
%     fv_ent = [];
%     vol_ent = [];
%     fv_vol_sal = [];
%     fv_ent_sal = [];
%     vol_ent_sal = [];
%     for ii = 1:length(speccorr)
%         fv_vol = [fv_vol; speccorr(ii).(['syll',syllables{i}]).fv_vol.abs];
%         fv_ent = [fv_ent; speccorr(ii).(['syll',syllables{i}]).fv_ent.abs];
%         vol_ent = [vol_ent; speccorr(ii).(['syll',syllables{i}]).vol_ent.abs];
%         fv_vol_sal = [fv_vol_sal; speccorr(ii).(['syll',syllables{i}]).fv_vol_sal.abs];
%         fv_ent_sal = [fv_ent_sal; speccorr(ii).(['syll',syllables{i}]).fv_ent_sal.abs];
%         vol_ent_sal = [vol_ent_sal; speccorr(ii).(['syll',syllables{i}]).vol_ent_sal.abs];
%     end
% 
%     figure;hold on;
%     h1 = subtightplot(2,3,1,[0.15 0.07],0.08, 0.08);
%     scatter(h1,fv_vol(:,1),fv_vol(:,2),25,'r','filled','MarkerFaceAlpha',0.3);
%     [r p] = corrcoef(fv_vol(:,1),fv_vol(:,2));
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h1,['pitch ',syllables{i}]);
%     ylabel(h1,['volume ',syllables{i}]);
%     set(h1,'fontweight','bold');
%     title(h1,str);
%     
%     h2 = subtightplot(2,3,2,[0.15 0.07],0.08, 0.08);
%     scatter(h2,fv_ent(:,1),fv_ent(:,2),25,'r','filled','MarkerFaceAlpha',0.3);
%     [r p] = corrcoef(fv_ent(:,1),fv_ent(:,2));
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h2,['pitch ',syllables{i}]);
%     ylabel(h2,['entropy ',syllables{i}]);
%     set(h2,'fontweight','bold');
%     title(h2,str);
%     
%     h3 = subtightplot(2,3,3,[0.15 0.07],0.08, 0.08);
%     scatter(h3,vol_ent(:,1),vol_ent(:,2),25,'r','filled','MarkerFaceAlpha',0.3);
%     [r p] = corrcoef(vol_ent(:,1),vol_ent(:,2));
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h3,['volume ',syllables{i}]);
%     ylabel(h3,['entropy ',syllables{i}]);
%     set(h3,'fontweight','bold');
%     title(h3,str);
%     
%     h4 = subtightplot(2,3,4,[0.15 0.07],0.08, 0.08);
%     scatter(h4,fv_vol_sal(:,1),fv_vol_sal(:,2),25,'k','filled','MarkerFaceAlpha',0.3);
%     [r p] = corrcoef(fv_vol_sal(:,1),fv_vol_sal(:,2));
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h4,['pitch ',syllables{i}]);
%     ylabel(h4,['volume ',syllables{i}]);
%     set(h4,'fontweight','bold');
%     title(h4,str);
%     
%     h5 = subtightplot(2,3,5,[0.15 0.07],0.08, 0.08);
%     scatter(h5,fv_ent_sal(:,1),fv_ent_sal(:,2),25,'k','filled','MarkerFaceAlpha',0.3);
%     [r p] = corrcoef(fv_ent_sal(:,1),fv_ent_sal(:,2));
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h5,['pitch ',syllables{i}]);
%     ylabel(h5,['entropy ',syllables{i}]);
%     set(h5,'fontweight','bold');
%     title(h5,str);
%     
%     h6 = subtightplot(2,3,6,[0.15 0.07],0.08, 0.08);
%     scatter(h6,vol_ent_sal(:,1),vol_ent_sal(:,2),25,'k','filled','MarkerFaceAlpha',0.3);
%     [r p] = corrcoef(vol_ent_sal(:,1),vol_ent_sal(:,2));
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h6,['volume ',syllables{i}]);
%     ylabel(h6,['entropy ',syllables{i}]);
%     set(h6,'fontweight','bold');
%     title(h6,str);
% end
% 
%    