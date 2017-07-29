%spectral correlation with gap duration analysis from all birds in
%directory 

%% extract infromation from each bird's gapdata 
config;
batch = uigetfile;
ff = load_batchf(batch);

gapdata = [];
for i = 1:length(ff)
    if ~exist(ff(i).name)
        if exist([params.subfolders{1},'/',ff(i).name,'/analysis/data_structures/gapdata_',ff(i).name,'.mat'])
            load([params.subfolders{1},'/',ff(i).name,'/analysis/data_structures/gapdata_',ff(i).name,'.mat']);
            gapdata = [gapdata;eval(['gapdata_',ff(i).name])];
        end
    else
        if exist([ff(i).name,'/analysis/data_structures/gapdata_',ff(i).name,'.mat'])
            load([ff(i).name,'/analysis/data_structures/gapdata_',ff(i).name,'.mat']);
            gapdata = [gapdata;eval(['gapdata_',ff(i).name])];
        end
    end
end

%center and transform each predictor 
birdnm = unique(gapdata.BirdID);
gapidx = 0;
for i = 1:length(birdnm)
    ind = strcmp(gapdata.BirdID,birdnm{i});
    gapid = unique(gapdata.GapID(ind));
    newgapid = gapid+gapidx;
    for n = 1:length(gapid)
        id = strcmp(gapdata.BirdID,birdnm{i}) & gapdata.GapID==gapid(n);
        gapdata.GapID(id) = newgapid(n);%rename each gap uniquely across birds
        id = strcmp(gapdata.BirdID,birdnm{i}) & gapdata.GapID==newgapid(n) & gapdata.Treatment==0;
        id2 = strcmp(gapdata.BirdID,birdnm{i}) & gapdata.GapID==newgapid(n) & gapdata.Treatment==1;
        
        %z-score from baseline vals 
        gapdur = gapdata.GapDur(id);
        gapdurt = gapdata.GapDur(id2);
        gapdurt = (gapdurt-nanmean(gapdur))./nanstd(gapdur);
        gapdur = (gapdur-nanmean(gapdur))./nanstd(gapdur);
        
        pitchN1 = gapdata.PitchN1(id);
        pitchN1t = gapdata.PitchN1(id2);
        volN1 = gapdata.VolN1(id);
        volN1t = gapdata.VolN1(id2);
        durN1 = gapdata.DurN1(id);
        durN1t = gapdata.DurN1(id2);
        
        pitchN2 = gapdata.PitchN2(id);
        pitchN2t = gapdata.PitchN2(id2);
        volN2 = gapdata.VolN2(id);
        volN2t = gapdata.VolN2(id2);
        durN2 = gapdata.DurN2(id);
        durN2t = gapdata.DurN2(id2);
        
        pitchN1t = (pitchN1t-nanmean(pitchN1))./nanstd(pitchN1);
        volN1t = (volN1t-nanmean(volN1))./nanstd(volN1);
        durN1t = (durN1t-nanmean(durN1))./nanstd(durN1);
        pitchN2t = (pitchN2t-nanmean(pitchN2))./nanstd(pitchN2);
        volN2t = (volN2t-nanmean(volN2))./nanstd(volN2);
        durN2t = (durN2t-nanmean(durN2))./nanstd(durN2);
        
        pitchN1 = (pitchN1-nanmean(pitchN1))./nanstd(pitchN1);
        volN1 = (volN1-nanmean(volN1))./nanstd(volN1);
        durN1 = (durN1-nanmean(durN1))./nanstd(durN1);
        pitchN2 = (pitchN2-nanmean(pitchN2))./nanstd(pitchN2);
        volN2 = (volN2-nanmean(volN2))./nanstd(volN2);
        durN2 = (durN2-nanmean(durN2))./nanstd(durN2);
        
        gapdata.GapDur(id) = gapdur;
        gapdata.GapDur(id2) = gapdurt;
        
        gapdata.PitchN1(id) = pitchN1;
        gapdata.PitchN1(id2) = pitchN1t;
        gapdata.VolN1(id) = volN1;
        gapdata.VolN1(id2) = volN1t;
        gapdata.DurN1(id) = durN1;
        gapdata.DurN1(id2) = durN1t;
        
        gapdata.PitchN2(id) = pitchN2;
        gapdata.PitchN2(id2) = pitchN2t;
        gapdata.VolN2(id) = volN2;
        gapdata.VolN2(id2) = volN2t;
        gapdata.DurN2(id) = durN2;
        gapdata.DurN2(id2) = durN2t;
    end
    gapidx = gapidx+length(gapid);
end
        
%% plot scatterplots for each response vs predictor for each gap and regression for each bivariate pair
birdnm = unique(gapdata.BirdID);
pitchN1corrs = [];pitchN2corrs = [];
volN1corrs = [];volN2corrs = [];
durN1corrs = [];durN2corrs = [];
for i = 1:length(birdnm)
    ind = strcmp(gapdata.BirdID,birdnm{i});
    gapid = unique(gapdata.GapID(ind));
    figure;hold on;
    for n = 1:length(gapid)
        id = strcmp(gapdata.BirdID,birdnm{i}) & gapdata.GapID==gapid(n) & gapdata.Treatment==0;
        id2 = strcmp(gapdata.BirdID,birdnm{i}) & gapdata.GapID==gapid(n) & gapdata.Treatment==1;
                
        subtightplot(length(gapid),6,1+6*(n-1),[0.07 0.04],0.05,0.05);hold on;
        plot(gapdata.PitchN1(id),gapdata.GapDur(id),'k.');hold on;
        plot(gapdata.PitchN1(id2),gapdata.GapDur(id2),'r.');hold on;
        xlabel('Pitch N1');ylabel('Gap Dur');title([birdnm{i},' gap ',num2str(gapid(n))]);
        [r1 p1] = corrcoef(gapdata.PitchN1(id),gapdata.GapDur(id),'rows','complete');p = pval(p1(2));
        text(0,1,{['r=',num2str(r1(2))];['p',p]},'units','normalized','verticalalignment','top');
        [r2 p2] = corrcoef(gapdata.PitchN1(id2),gapdata.GapDur(id2),'rows','complete');p = pval(p2(2));
        text(1,1,{['\color{red}r=',num2str(r2(2))];['\color{red}p',p]},'units','normalized',...
            'horizontalalignment','right','verticalalignment','top');
        pitchN1corrs = [pitchN1corrs; [r1(2) p1(2) r2(2) p2(2)]];
        
        subtightplot(length(gapid),6,2+6*(n-1),[0.07 0.04],0.05,0.05);hold on;
        plot(gapdata.PitchN2(id),gapdata.GapDur(id),'k.');hold on;
        plot(gapdata.PitchN2(id2),gapdata.GapDur(id2),'r.');hold on;
        xlabel('Pitch N2');ylabel('Gap Dur');title([birdnm{i},' gap ',num2str(gapid(n))]);
        [r1 p1] = corrcoef(gapdata.PitchN2(id),gapdata.GapDur(id),'rows','complete');p = pval(p1(2));
        text(0,1,{['r=',num2str(r1(2))];['p',p]},'units','normalized','verticalalignment','top');
        [r2 p2] = corrcoef(gapdata.PitchN2(id2),gapdata.GapDur(id2),'rows','complete');p = pval(p2(2));
        text(1,1,{['\color{red}r=',num2str(r2(2))];['\color{red}p',p]},'units','normalized',...
            'horizontalalignment','right','verticalalignment','top');
        pitchN2corrs = [pitchN2corrs; [r1(2) p1(2) r2(2) p2(2)]];
        
        subtightplot(length(gapid),6,3+6*(n-1),[0.07 0.04],0.05,0.05);hold on;
        plot(gapdata.VolN1(id),gapdata.GapDur(id),'k.');hold on;
        plot(gapdata.VolN1(id2),gapdata.GapDur(id2),'r.');hold on;
        xlabel('Vol N1');ylabel('Gap Dur');title([birdnm{i},' gap ',num2str(gapid(n))]);
        [r1 p1] = corrcoef(gapdata.VolN1(id),gapdata.GapDur(id),'rows','complete');p = pval(p1(2));
        text(0,1,{['r=',num2str(r1(2))];['p',p]},'units','normalized','verticalalignment','top');
        [r2 p2] = corrcoef(gapdata.VolN1(id2),gapdata.GapDur(id2),'rows','complete');p = pval(p2(2));
        text(1,1,{['\color{red}r=',num2str(r2(2))];['\color{red}p',p]},'units','normalized',...
            'horizontalalignment','right','verticalalignment','top');
        volN1corrs = [volN1corrs; [r1(2) p1(2) r2(2) p2(2)]];
        
        subtightplot(length(gapid),6,4+6*(n-1),[0.07 0.04],0.05,0.05);hold on;
        plot(gapdata.VolN2(id),gapdata.GapDur(id),'k.');hold on;
        plot(gapdata.VolN2(id2),gapdata.GapDur(id2),'r.');hold on;
        xlabel('Vol N2');ylabel('Gap Dur');title([birdnm{i},' gap ',num2str(gapid(n))]);
        [r1 p1] = corrcoef(gapdata.VolN2(id),gapdata.GapDur(id),'rows','complete');p = pval(p1(2));
        text(0,1,{['r=',num2str(r1(2))];['p',p]},'units','normalized','verticalalignment','top');
        [r2 p2] = corrcoef(gapdata.VolN2(id2),gapdata.GapDur(id2),'rows','complete');p = pval(p2(2));
        text(1,1,{['\color{red}r=',num2str(r2(2))];['\color{red}p',p]},'units','normalized',...
            'horizontalalignment','right','verticalalignment','top');
        volN2corrs = [volN2corrs; [r1(2) p1(2) r2(2) p2(2)]];
        
        subtightplot(length(gapid),6,5+6*(n-1),[0.07 0.04],0.05,0.05);hold on;
        plot(gapdata.DurN1(id),gapdata.GapDur(id),'k.');hold on;
        plot(gapdata.DurN1(id2),gapdata.GapDur(id2),'r.');hold on;
        xlabel('Dur N1');ylabel('Gap Dur');title([birdnm{i},' gap ',num2str(gapid(n))]);
        [r1 p1] = corrcoef(gapdata.DurN1(id),gapdata.GapDur(id),'rows','complete');p = pval(p1(2));
        text(0,1,{['r=',num2str(r1(2))];['p',p]},'units','normalized','verticalalignment','top');
        [r2 p2] = corrcoef(gapdata.DurN1(id2),gapdata.GapDur(id2),'rows','complete');p = pval(p2(2));
        text(1,1,{['\color{red}r=',num2str(r2(2))];['\color{red}p',p]},'units','normalized',...
            'horizontalalignment','right','verticalalignment','top');
        durN1corrs = [durN1corrs; [r1(2) p1(2) r2(2) p2(2)]];
        
        subtightplot(length(gapid),6,6+6*(n-1),[0.07 0.04],0.05,0.05);hold on;
        plot(gapdata.DurN2(id),gapdata.GapDur(id),'k.');hold on;
        plot(gapdata.DurN2(id2),gapdata.GapDur(id2),'r.');hold on;
        xlabel('Dur N2');ylabel('Gap Dur');title([birdnm{i},' gap ',num2str(gapid(n))]);
        [r1 p1] = corrcoef(gapdata.DurN2(id),gapdata.GapDur(id),'rows','complete');p = pval(p1(2));
        text(0,1,{['r=',num2str(r1(2))];['p',p]},'units','normalized','verticalalignment','top');
        [r2 p2] = corrcoef(gapdata.DurN2(id2),gapdata.GapDur(id2),'rows','complete');p = pval(p2(2));
        text(1,1,{['\color{red}r=',num2str(r2(2))];['\color{red}p',p]},'units','normalized',...
            'horizontalalignment','right','verticalalignment','top');
        durN2corrs = [durN2corrs; [r1(2) p1(2) r2(2) p2(2)]];
    end
end

%compare distribution of corr values
varnames = {'PitchN1','PitchN2','VolN1','VolN2','DurN1','DurN2'};
coeffs = table(pitchN1corrs(:,1),pitchN2corrs(:,1),volN1corrs(:,1),volN2corrs(:,1),...
    durN1corrs(:,1),durN2corrs(:,1),'VariableNames',varnames);
pvals = table(pitchN1corrs(:,2),pitchN2corrs(:,2),volN1corrs(:,2),volN2corrs(:,2),...
    durN1corrs(:,2),durN2corrs(:,2),'VariableNames',varnames);
coeffs_treat = table(pitchN1corrs(:,3),pitchN2corrs(:,3),volN1corrs(:,3),volN2corrs(:,3),...
    durN1corrs(:,3),durN2corrs(:,3),'VariableNames',varnames);
pvals_treat = table(pitchN1corrs(:,4),pitchN2corrs(:,4),volN1corrs(:,4),volN2corrs(:,4),...
    durN1corrs(:,4),durN2corrs(:,4),'VariableNames',varnames);

figure;hold on;signranktest = NaN(length(varnames)*2,1);
for i = 1:length(varnames)
    ind1 = pvals{:,varnames{i}}<=0.05;
    ind2 = pvals_treat{:,varnames{i}}<=0.05;
    barh(i*2,mean(coeffs{ind1,varnames{i}}),'facecolor',[0.5 0.5 0.5],'EdgeColor','none');
    barh(i*2-1,mean(coeffs_treat{ind2,varnames{i}}),'facecolor',[0.7 0.3 0.3],'EdgeColor','none');
    plot(coeffs{ind1,varnames{i}},i*2,'ok','markersize',8);hold on;
    plot(coeffs{~ind1,varnames{i}},i*2,'k.','markersize',8);hold on;
    plot(coeffs{ind1,varnames{i}},i*2-1,'or','markersize',8);hold on;
    plot(coeffs{~ind1,varnames{i}},i*2-1,'r.','markersize',8);hold on;
    signranktest(i*2) = signrank(coeffs{ind1,varnames{i}});
    signranktest(i*2-1) = signrank(coeffs_treat{ind2,varnames{i}});
end
x = get(gca,'xlim');
for i = 1:length(signranktest)
    if signranktest(i) <=0.05
        text(x(2),i,['p<=0.05']);
    end
end
set(gca,'ytick',[2:2:2*length(varnames)],'yticklabel',varnames,'fontweight','bold');
xlabel('correlation');

%% separate multiple regression for each gap ID
gapid = unique(gapdata.GapID);
coefs = [];
coefs_pvals = [];
rsq = [];
for i = 1:length(gapid)
    id = gapdata.GapID==gapid(i);
    dat = gapdata(id,:);
    formula = 'GapDur ~ Treatment*(PitchN1+PitchN2+VolN1+VolN2+DurN1+DurN2)';
    formula_pitchN1 = 'GapDur ~ Treatment*(PitchN2+VolN1+VolN2+DurN1+DurN2)';
    formula_pitchN2 = 'GapDur ~ Treatment*(PitchN1+VolN1+VolN2+DurN1+DurN2)';
    formula_volN1 = 'GapDur ~ Treatment*(PitchN1+PitchN2+VolN2+DurN1+DurN2)';
    formula_volN2 = 'GapDur ~ Treatment*(PitchN1+PitchN2+VolN1+DurN1+DurN2)';
    formula_durN1 = 'GapDur ~ Treatment*(PitchN1+PitchN2+VolN1+VolN2+DurN2)';
    formula_durN2 = 'GapDur ~ Treatment*(PitchN1+PitchN2+VolN1+VolN2+DurN1)';
    formula_pitch = 'GapDur ~ Treatment*(VolN1+VolN2+DurN1+DurN2)';
    formula_vol = 'GapDur ~ Treatment*(PitchN1+PitchN2+DurN1+DurN2)';
    formula_dur = 'GapDur ~ Treatment*(PitchN1+PitchN2+VolN1+VolN2)';

    mdl = fitlme(dat,formula);
    mdl_pitchN1 = fitlme(dat,formula_pitchN1);
    mdl_pitchN2 = fitlme(dat,formula_pitchN2);
    mdl_volN1 = fitlme(dat,formula_volN1);
    mdl_volN2 = fitlme(dat,formula_volN2);
    mdl_durN1 = fitlme(dat,formula_durN1);
    mdl_durN2 = fitlme(dat,formula_durN2);
    mdl_pitch = fitlme(dat,formula_pitch);
    mdl_vol = fitlme(dat,formula_vol);
    mdl_dur = fitlme(dat,formula_dur);
    
    [beta,betanames,stats] = mdl.fixedEffects;
    coefs = [coefs; beta'];
    coefs_pvals = [coefs_pvals; stats.pValue'];
    
    fullmdl = mdl.Rsquared.Adjusted;
    rsq = [rsq; fullmdl-mdl_pitchN1.Rsquared.Adjusted fullmdl-mdl_pitchN2.Rsquared.Adjusted ...
        fullmdl-mdl_volN1.Rsquared.Adjusted fullmdl-mdl_volN2.Rsquared.Adjusted ...
        fullmdl-mdl_durN1.Rsquared.Adjusted fullmdl-mdl_durN2.Rsquared.Adjusted ...
        fullmdl-mdl_pitch.Rsquared.Adjusted fullmdl-mdl_vol.Rsquared.Adjusted ...
        fullmdl-mdl_dur.Rsquared.Adjusted];
end
betanames = betanames.Name;
betanames = cellfun(@(x) strrep(x,':',''),betanames,'unif',0);
betanames = cellfun(@(x) strrep(x,'(',''),betanames,'unif',0);
betanames = cellfun(@(x) strrep(x,')',''),betanames,'unif',0);
coeff = array2table(coefs,'VariableNames',betanames);
coeffpvals = array2table(coefs_pvals,'VariableNames',betanames);
rsq = array2table(rsq,'VariableNames',{'PitchN1','PitchN2','VolN1','VolN2','DurN1','DurN2',...
    'Pitch','Vol','Dur'});
    
figure;hold on;signranktest = NaN(13,1);
for i = 1:length(betanames)-1
    ind = coeffpvals{:,betanames{i+1}}<=0.05;
    barh(i,mean(coeff{ind,betanames{i+1}}),'facecolor',[0.5 0.5 0.5],'EdgeColor','none');
    plot(coeff{ind,betanames{i+1}},i,'ok','markersize',8);hold on;
    plot(coeff{~ind,betanames{i+1}},i,'k.','markersize',8);hold on;
    signranktest(i) = signrank(coeff{ind,betanames{i+1}});
end
x = get(gca,'xlim');
for i = 1:length(signranktest)
    if signranktest(i) <=0.05
        text(x(2),i,['p<=0.05']);
    end
end
xlabel('beta');
set(gca,'ytick',[1:13],'yticklabel',betanames(2:end),'fontweight','bold');


varnames = rsq.Properties.VariableNames;
figure;hold on;
for i = 1:length(varnames)
    barh(i,mean(rsq.([varnames{i}])),'facecolor',[0.5 0.5 0.5],'edgecolor','none');
    plot(rsq.([varnames{i}]),i,'ok','markersize',8);
end
xlabel('r squared');
set(gca,'ytick',[1:length(varnames)],'yticklabel',varnames,'fontweight','bold');

%% no pooling multiple regression with group indicators for gap ID
