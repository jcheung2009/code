%for individual birds, to make spectempocorr which contains trials for each
%syllable, pairwise correlation between spec and tempo from motifs 

ff = load_batchf('batchnaspm');
spectempocorr = struct();
load('analysis/data_structures/naspmvolumelatency');
syllables = {'A1','d'};
motif = 'aabb';
trialcnt = 0;
for i = 1:4:length(ff)
    trialcnt = trialcnt+1;
    for ii = 1:length(syllables)
        durind = strfind(motif,syllables{ii});
        durind = durind(1);
        if durind == length(motif);
            gap1ind = '';
            gap0ind = durind-1;
        elseif durind == 1;
            gap0ind = '';
            gap1ind = durind;
        else
            gap1ind = durind;
            gap0ind = durind-1;
        end

        load(['analysis/data_structures/motif_',motif,'_',ff(i).name]);
        load(['analysis/data_structures/motif_',motif,'_',ff(i+2).name]);
        fv1 = ['motif_',motif,'_',ff(i).name];
        fv2 = ['motif_',motif,'_',ff(i+2).name];
        
        if ~isempty(strfind(ff(i+2).name,'sal'))
            startpt = '';
        else
            drugtime = naspmvolumelatency.(['tr_',ff(i+2).name]).treattime;
            startpt = (drugtime+1.13)*3600;%change latency time
        end
        
%         [spectempocorr(trialcnt).(['syll',syllables{ii}]).fv_acorr ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).fv_sdur ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).fv_g0dur ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).fv_g1dur ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).vol_acorr ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).vol_sdur ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).vol_g0dur ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).vol_g1dur ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).ent_acorr ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).ent_sdur ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).ent_g0dur ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).ent_g1dur ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).fv_acorr_sal ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).fv_sdur_sal ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).fv_g0dur_sal ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).fv_g1dur_sal ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).vol_acorr_sal ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).vol_sdur_sal ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).vol_g0dur_sal ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).vol_g1dur_sal ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).ent_acorr_sal ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).ent_sdur_sal ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).ent_g0dur_sal ...
%             spectempocorr(trialcnt).(['syll',syllables{ii}]).ent_g1dur_sal] = ...
            spectempocorr(trialcnt).(['syll',syllables{ii}]) = jc_plotspectempocorr(eval(fv1),eval(fv2),ii,durind,gap0ind,gap1ind,0,startpt,'');
    end
end

% for i = 1:length(syllables)
%     x = [spectempocorr(:).(['syll',syllables{i}])];
%     xdata = [x(:).cond];
%     xdata = arrayfun(@(x) x.abs,xdata,'unif',0)';
%     xdata = cell2mat(xdata);
%     
%     figure;hold on;
%     h1 = subtightplot(3,4,1,[0.15 0.07],0.08, 0.08);
%     plot(h1,xdata(:,1),xdata(:,4),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,1),xdata(:,4),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h1,['pitch ',syllables{i}]);
%     ylabel(h1,'motif acorr');
%     set(h1,'fontweight','bold');
%     if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h1,str,'Color',c);
%     
%     h2 = subtightplot(3,4,2,[0.15 0.07],0.08, 0.08);
%     plot(h2,xdata(:,1),xdata(:,5),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,1),xdata(:,5),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h2,['pitch ',syllables{i}]);
%     ylabel(h2,['syll ',syllables{i},' dur']);
%     set(h2,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h2,str,'Color',c);
%     
%     h3 = subtightplot(3,4,3,[0.15 0.07],0.08, 0.08);
%     plot(h3,xdata(:,1),xdata(:,6),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,1),xdata(:,6),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h3,['pitch ',syllables{i}]);
%     ylabel(h3,'pre gap');
%     set(h3,'fontweight','bold');
%     if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h3,str,'Color',c);
%   
%     
%     h4 = subtightplot(3,4,4,[0.15 0.07],0.08, 0.08);
%     plot(h4,xdata(:,1),xdata(:,7),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,1),xdata(:,7),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h4,['pitch ',syllables{i}]);
%     ylabel(h4,'gap');
%     set(h4,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h4,str,'Color',c);
% 
%     h5 = subtightplot(3,4,5,[0.15 0.07],0.08, 0.08);
%     plot(h5,xdata(:,2),xdata(:,4),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,2),xdata(:,4),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h5,['volume ',syllables{i}]);
%     ylabel(h5,'motif acorr');
%     set(h5,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h5,str,'Color',c);
%     
%     h6 = subtightplot(3,4,6,[0.15 0.07],0.08, 0.08);
%     plot(h6,xdata(:,2),xdata(:,5),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,2),xdata(:,5),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h6,['volume ',syllables{i}]);
%     ylabel(h6,['syll ',syllables{i},' dur']);
%     set(h6,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h6,str,'Color',c);;
%     
%     h7 = subtightplot(3,4,7,[0.15 0.07],0.08, 0.08);
%     plot(h7,xdata(:,2),xdata(:,6),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,2),xdata(:,6),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h7,['volume ',syllables{i}]);
%     ylabel(h7,'pre gap');
%     set(h7,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h7,str,'Color',c);
%     
%     
%     h8 = subtightplot(3,4,8,[0.15 0.07],0.08, 0.08);
%     plot(h8,xdata(:,2),xdata(:,7),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,2),xdata(:,7),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h8,['volume ',syllables{i}]);
%     ylabel(h8,'gap');
%     set(h8,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h8,str,'Color',c);
% 
%     h9 = subtightplot(3,4,9,[0.15 0.07],0.08, 0.08);
%     plot(h9,xdata(:,3),xdata(:,4),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,3),xdata(:,4),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h9,['entropy ',syllables{i}]);
%     ylabel(h9,'motif acorr');
%     set(h9,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h9,str,'Color',c);
%     
%     h10 = subtightplot(3,4,10,[0.15 0.07],0.08, 0.08);
%     plot(h10,xdata(:,3),xdata(:,5),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,3),xdata(:,5),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h10,['entropy ',syllables{i}]);
%     ylabel(h10,['syll ',syllables{i},' dur']);
%     set(h10,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h10,str,'Color',c);
%     
%     h11 = subtightplot(3,4,11,[0.15 0.07],0.08, 0.08);
%     plot(h11,xdata(:,3),xdata(:,6),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,3),xdata(:,6),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h11,['entropy ',syllables{i}]);
%     ylabel(h11,'pre gap');
%     set(h11,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h11,str,'Color',c);
% 
%     
%     h12 = subtightplot(3,4,12,[0.15 0.07],0.08, 0.08);
%     plot(h12,xdata(:,3),xdata(:,7),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,3),xdata(:,7),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h12,['entropy ',syllables{i}]);
%     ylabel(h12,'gap');
%     set(h12,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h12,str,'Color',c);
% 
%     y = [spectempocorr(:).(['syll',syllables{i}])];
%     ydata = [y(:).sal];
%     ydata = arrayfun(@(x) x.abs,ydata,'unif',0)';
%     ydata = cell2mat(ydata);
%     
%     figure;hold on;
%     h1 = subtightplot(3,4,1,[0.15 0.07],0.08, 0.08);
%     plot(h1,ydata(:,1),ydata(:,4),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,1),ydata(:,4),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h1,['pitch ',syllables{i}]);
%     ylabel(h1,'motif acorr');
%     set(h1,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h1,str,'Color',c);
%     
%     h2 = subtightplot(3,4,2,[0.15 0.07],0.08, 0.08);
%     plot(h2,ydata(:,1),ydata(:,5),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,1),ydata(:,5),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h2,['pitch ',syllables{i}]);
%     ylabel(h2,['syll ',syllables{i},' dur']);
%     set(h2,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h2,str,'Color',c);
%     
%     h3 = subtightplot(3,4,3,[0.15 0.07],0.08, 0.08);
%     plot(h3,ydata(:,1),ydata(:,6),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,1),ydata(:,6),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h3,['pitch ',syllables{i}]);
%     ylabel(h3,'pre gap');
%     set(h3,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h3,str,'Color',c);
%   
%     
%     h4 = subtightplot(3,4,4,[0.15 0.07],0.08, 0.08);
%     plot(h4,ydata(:,1),ydata(:,7),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,1),ydata(:,7),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h4,['pitch ',syllables{i}]);
%     ylabel(h4,'gap');
%     set(h4,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h4,str,'Color',c);
% 
%     h5 = subtightplot(3,4,5,[0.15 0.07],0.08, 0.08);
%     plot(h5,ydata(:,2),ydata(:,4),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,2),ydata(:,4),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h5,['volume ',syllables{i}]);
%     ylabel(h5,'motif acorr');
%     set(h5,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h5,str,'Color',c);
%     
%     h6 = subtightplot(3,4,6,[0.15 0.07],0.08, 0.08);
%     plot(h6,ydata(:,2),ydata(:,5),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,2),ydata(:,5),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h6,['volume ',syllables{i}]);
%     ylabel(h6,['syll ',syllables{i},' dur']);
%     set(h6,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h6,str,'Color',c);
%     
%     h7 = subtightplot(3,4,7,[0.15 0.07],0.08, 0.08);
%     plot(h7,ydata(:,2),ydata(:,6),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,2),ydata(:,6),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h7,['volume ',syllables{i}]);
%     ylabel(h7,'pre gap');
%     set(h7,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h7,str,'Color',c);
%     
%     
%     h8 = subtightplot(3,4,8,[0.15 0.07],0.08, 0.08);
%     plot(h8,ydata(:,2),ydata(:,7),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,2),ydata(:,7),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h8,['volume ',syllables{i}]);
%     ylabel(h8,'gap');
%     set(h8,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h8,str,'Color',c);
% 
%     h9 = subtightplot(3,4,9,[0.15 0.07],0.08, 0.08);
%     plot(h9,ydata(:,3),ydata(:,4),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,3),ydata(:,4),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h9,['entropy ',syllables{i}]);
%     ylabel(h9,'motif acorr');
%     set(h9,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h9,str,'Color',c);
%     
%     h10 = subtightplot(3,4,10,[0.15 0.07],0.08, 0.08);
%     plot(h10,ydata(:,3),ydata(:,5),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,3),ydata(:,5),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h10,['entropy ',syllables{i}]);
%     ylabel(h10,['syll ',syllables{i},' dur']);
%     set(h10,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h10,str,'Color',c);
%     
%     h11 = subtightplot(3,4,11,[0.15 0.07],0.08, 0.08);
%     plot(h11,ydata(:,3),ydata(:,6),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,3),ydata(:,6),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h11,['entropy ',syllables{i}]);
%     ylabel(h11,'pre gap');
%     set(h11,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h11,str,'Color',c);
%     
%     h12 = subtightplot(3,4,12,[0.15 0.07],0.08, 0.08);
%     plot(h12,ydata(:,3),ydata(:,7),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,3),ydata(:,7),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h12,['entropy ',syllables{i}]);
%     ylabel(h12,'gap');
%     set(h12,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h12,str,'Color',c);
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     figure;hold on;
%     h1 = subtightplot(2,3,1,[0.15 0.07],0.08, 0.08);
%     plot(h1,xdata(:,1),xdata(:,2),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,1),xdata(:,2),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h1,['pitch ',syllables{i}]);
%     ylabel(h1,'volume');
%     set(h1,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h1,str,'Color',c);
%     
%     h2 = subtightplot(2,3,2,[0.15 0.07],0.08, 0.08);
%     plot(h2,xdata(:,1),xdata(:,3),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,1),xdata(:,3),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h2,['pitch ',syllables{i}]);
%     ylabel(h2,'entropy');
%     set(h2,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h2,str,'Color',c);
%     
%     h3 = subtightplot(2,3,3,[0.15 0.07],0.08, 0.08);
%     plot(h3,xdata(:,2),xdata(:,3),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,2),xdata(:,3),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h3,['volume ',syllables{i}]);
%     ylabel(h3,'entropy');
%     set(h3,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h3,str,'Color',c);
%     
%     h4 = subtightplot(2,3,4,[0.15 0.07],0.08, 0.08);
%     plot(h4,ydata(:,1),ydata(:,2),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,1),ydata(:,2),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h4,['pitch ',syllables{i}]);
%     ylabel(h4,'volume');
%     set(h4,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h4,str,'Color',c);
%     
%     h5 = subtightplot(2,3,5,[0.15 0.07],0.08, 0.08);
%     plot(h5,ydata(:,1),ydata(:,3),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,1),ydata(:,3),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h5,['pitch ',syllables{i}]);
%     ylabel(h5,'entropy');
%     set(h5,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h5,str,'Color',c);
%     
%     h6 = subtightplot(2,3,6,[0.15 0.07],0.08, 0.08);
%     plot(h6,ydata(:,2),ydata(:,3),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,2),ydata(:,3),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h6,['volume ',syllables{i}]);
%     ylabel(h6,'entropy');
%     set(h6,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h6,str,'Color',c);
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     figure;hold on;
%     h1 = subtightplot(2,5,1,[0.15 0.07],0.08, 0.08);
%     plot(h1,xdata(:,4),xdata(:,5),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,4),xdata(:,5),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h1,'motif acorr');
%     ylabel(h1,['syll ',syllables{i}, ' dur']);
%     set(h1,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h1,str,'Color',c);
%     
%     h2 = subtightplot(2,5,2,[0.15 0.07],0.08, 0.08);
%     plot(h2,xdata(:,4),xdata(:,6),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,4),xdata(:,6),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h2,'motif acorr');
%     ylabel(h2,'pre gap');
%     set(h2,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h2,str,'Color',c);
%     
%     h3 = subtightplot(2,5,3,[0.15 0.07],0.08, 0.08);
%     plot(h3,xdata(:,4),xdata(:,7),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,4),xdata(:,7),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h3,'motif acorr');
%     ylabel(h3,'gap');
%     set(h3,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h3,str,'Color',c);
%     
%      h4 = subtightplot(2,5,4,[0.15 0.07],0.08, 0.08);
%     plot(h4,xdata(:,5),xdata(:,6),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,5),xdata(:,6),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h4,['syll ',syllables{i},' dur']);
%     ylabel(h4,'pre gap');
%     set(h4,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h4,str,'Color',c);
%     
%     h5 = subtightplot(2,5,5,[0.15 0.07],0.08, 0.08);
%     plot(h5,xdata(:,5),xdata(:,7),'or','markersize',8);
%     [r p] = corrcoef(xdata(:,5), xdata(:,7),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h5,['syll ',syllables{i},' dur']);
%     ylabel(h5,'gap');
%     set(h5,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h5,str,'Color',c);
%     
%      h6 = subtightplot(2,5,6,[0.15 0.07],0.08, 0.08);
%     plot(h6,ydata(:,4),ydata(:,5),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,4),ydata(:,5),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h6,'motif acorr');
%     ylabel(h6,['syll ',syllables{i}, ' dur']);
%     set(h6,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h6,str,'Color',c);
%     
%     h7 = subtightplot(2,5,7,[0.15 0.07],0.08, 0.08);
%     plot(h7,ydata(:,4),ydata(:,6),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,4),ydata(:,6),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h7,'motif acorr');
%     ylabel(h7,'pre gap');
%     set(h7,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h7,str,'Color',c);
%     
%     h8 = subtightplot(2,5,8,[0.15 0.07],0.08, 0.08);
%     plot(h8,ydata(:,4),ydata(:,7),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,4),ydata(:,7),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h8,'motif acorr');
%     ylabel(h8,'gap');
%     set(h8,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h8,str,'Color',c);
%     
%      h9 = subtightplot(2,5,9,[0.15 0.07],0.08, 0.08);
%     plot(h9,ydata(:,5),ydata(:,6),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,5),ydata(:,6),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h9,['syll ',syllables{i},' dur']);
%     ylabel(h9,'pre gap');
%     set(h9,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h9,str,'Color',c);
%     
%     h10 = subtightplot(2,5,10,[0.15 0.07],0.08, 0.08);
%     plot(h10,ydata(:,5),ydata(:,7),'ok','markersize',8);
%     [r p] = corrcoef(ydata(:,5),ydata(:,7),'rows','complete');
%     str = {['r = ',num2str(r(2))],['p = ',num2str(p(2))]};
%     xlabel(h10,['syll ',syllables{i},' dur']);
%     ylabel(h10,'gap');
%     set(h10,'fontweight','bold');
%      if p(2)<= 0.05
%         c = 'r';
%     else
%         c = 'k';
%     end
%     title(h10,str,'Color',c);
%   
%     
% end
%     
