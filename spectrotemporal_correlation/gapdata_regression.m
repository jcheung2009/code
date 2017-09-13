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

%% center and transform each predictor 
birdnm = unique(gapdata.BirdID);
newgapid = NaN(size(gapdata,1),1);
newrendid = NaN(size(gapdata,1),1);
gapcnt = 0;rendcnt = 0;
for i = 1:length(birdnm)
    ind = strcmp(gapdata.BirdID,birdnm{i});
    gapid = unique(gapdata.GapID(ind));
    for n = 1:length(gapid)
        id = strcmp(gapdata.BirdID,birdnm{i}) & gapdata.GapID==gapid(n) & gapdata.Treatment==0;
        id2 = strcmp(gapdata.BirdID,birdnm{i}) & gapdata.GapID==gapid(n) & gapdata.Treatment==1;
        
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
        
        id = strcmp(gapdata.BirdID,birdnm{i}) & gapdata.GapID==gapid(n);
        gapcnt = gapcnt + 1;
        newgapid(id) = gapcnt;%rename each gap uniquely across birds
        
        rendid = unique(gapdata.RenditionID(id));
        for r = 1:length(rendid)
            idx = strcmp(gapdata.BirdID,birdnm{i}) & gapdata.GapID==gapid(n) & gapdata.RenditionID == rendid(r);
            rendcnt = rendcnt + 1;
            newrendid(idx) = rendcnt;
        end
    end
end
gapdata.GapID = newgapid; 
% gapdata.RenditionID = newrendid;

boutid = NaN(size(gapdata,1),1);
gapid = unique(gapdata.GapID);
for i = 1:length(gapid)
    ind = gapdata.GapID == gapid(i);
    [~,~,ic] = unique(gapdata.BoutID(ind));
    boutid(ind) = ic;
end
gapdata.BoutID = boutid;



%% check normality and correlation of predictors

%plot qqplot for each predictor for each gapID/treatment: 
%all predictors in all gapIDs in treatment group are not normal by kstest (washin period, no plateau in drug effect)
%have tried different transformations for pitch/vol/dur before
%centering/z-score transformation but only marginally improves normality
%normality in predictors and response variables is not a criterion for
%regression 

birdnm = unique(gapdata.BirdID);
varnames = gapdata.Properties.VariableNames;
varnames = varnames(2:7);
kstestresults = [];
for i = 1:length(birdnm)
    ind = strcmp(gapdata.BirdID,birdnm{i});
    gapid = unique(gapdata.GapID(ind));
    figure;hold on;
    test2 = [];
    for m = 1:length(varnames)
        test = [];
        for n = 1:length(gapid);
            id = strcmp(gapdata.BirdID,birdnm{i}) & gapdata.GapID==gapid(n) & gapdata.Treatment==0;
            id2 = strcmp(gapdata.BirdID,birdnm{i}) & gapdata.GapID==gapid(n) & gapdata.Treatment==1;

            ax = subtightplot(length(gapid),6,m+6*(n-1),[0.07 0.04],0.05,0.05);hold on;
            h = qqplot(gapdata.([varnames{m}])(id));hold on;
            h(1).LineStyle = '-';h(1).Marker = 'none';h(1).Color = 'k';
            h = qqplot(gapdata.([varnames{m}])(id2));hold on;
            h(1).LineStyle = '-';h(1).Marker = 'none';h(1).Color = 'r';
            ax.Title.String = varnames{m};
            test = [test; kstest(gapdata.([varnames{m}])(id)) kstest(gapdata.([varnames{m}])(id2))];
        end
        test2 = [test2 test];
    end
    kstestresults = [kstestresults; test2];
end
sum(kstestresults) %number of gaps with not-normal predictor distributions (PitchN1base PitchN1treat,PitchN2base,..., VolN1base,...,VolN2base,...,DurN1base, ...)
    
% qqplot for response variable gapdur
gapid = unique(gapdata.GapID);
figure;hold on;kstestresults = [];
for i = 1:length(gapid)
    ax = subtightplot(4,7,i,[0.07 0.04],0.05,0.05);hold on;
    ind = gapdata.GapID == gapid(i) & gapdata.Treatment == 0;
    ind2 = gapdata.GapID == gapid(i) & gapdata.Treatment == 1;
    h = qqplot(gapdata.GapDur(ind));hold on;
    h(1).LineStyle = '-';h(1).Marker = 'none';h(1).Color = 'k';
    h = qqplot(gapdata.GapDur(ind2));hold on;
    h(1).LineStyle = '-';h(1).Marker = 'none';h(1).Color = 'r';
    ax.Title.String = 'Gap Dur';
    kstestresults = [kstestresults; kstest(gapdata.GapDur(ind)) kstest(gapdata.GapDur(ind2))];
end
sum(kstestresults) % number of gaps with not-normal response distribution (gapdurbase, gapdurtreat) 

%plot correlation between predictors separately for baseline and treatment
%(pooled across all gaps)
%pitchN1 vs pitchN2 = 0.24 and 0.41
%volN1 vs volN2 = 0.5 and 0.5
varnames = gapdata.Properties.VariableNames;
varnames = varnames(2:7);
cbs = nchoosek(varnames,2);
figure;hold on;
for i = 1:length(cbs)
    ind = gapdata.Treatment == 0;
    ind2 = gapdata.Treatment==1;
    subtightplot(3,5,i,[0.07 0.04],0.05,0.05);hold on;
    plot(gapdata.([cbs{i,1}])(ind),gapdata.([cbs{i,2}])(ind),'k.');hold on;  
    plot(gapdata.([cbs{i,1}])(ind2),gapdata.([cbs{i,2}])(ind2),'r.');hold on;  
    [r1 p1] = corrcoef(gapdata.([cbs{i,1}])(ind),gapdata.([cbs{i,2}])(ind),'rows','complete');p = pval(p1(2));
    text(0,1,{['r=',num2str(r1(2))];['p',p]},'units','normalized','verticalalignment','top');
    [r2 p2] = corrcoef(gapdata.([cbs{i,1}])(ind2),gapdata.([cbs{i,2}])(ind2),'rows','complete');p = pval(p2(2));
    text(1,1,{['\color{red}r=',num2str(r2(2))];['\color{red}p',p]},'units','normalized',...
            'horizontalalignment','right','verticalalignment','top');
    ylabel(cbs{i,2});xlabel(cbs{i,1});
end

%plot correlation between predictors separately for baseline and treatment
%for each gapID: 
%average correlation pitchN1 vs pitchN2: r = 0.3 and 0.4 
%average correlation pitchN1 vs DurN2: r = -0.066 and -0.0826 
%average correlation pitchN2 vs volN1: r = 0.0812 and 0.1531 
%average correlation pitchN2 and DurN1: r = -0.05 and -0.058 
%average correlation volN1 vs volN2: r = 0.4 and 0.4
%average correlation durN1 vs durN2: r = 0.2 and 0.2 
%note that some pitch vs vol and pitch vs pitch regressions do not look
%linear and a few where the slope/intercept changes in treatment
%in general, treatment relationships seem to be linear extension of
%baseline relationship
gapid = unique(gapdata.GapID);
corrvals = [];
for n = 1:length(gapid)
    figure;hold on;
    for i = 1:length(cbs)
        ind = gapdata.GapID == gapid(n) & gapdata.Treatment == 0;
        ind2 = gapdata.GapID == gapid(n) & gapdata.Treatment==1;
        subtightplot(3,5,i,[0.07 0.04],0.05,0.05);hold on;
        plot(gapdata.([cbs{i,1}])(ind),gapdata.([cbs{i,2}])(ind),'k.');hold on;  
        plot(gapdata.([cbs{i,1}])(ind2),gapdata.([cbs{i,2}])(ind2),'r.');hold on;  
        [r1 p1] = corrcoef(gapdata.([cbs{i,1}])(ind),gapdata.([cbs{i,2}])(ind),'rows','complete');p = pval(p1(2));
        text(0,1,{['r=',num2str(r1(2))];['p',p]},'units','normalized','verticalalignment','top');
        [r2 p2] = corrcoef(gapdata.([cbs{i,1}])(ind2),gapdata.([cbs{i,2}])(ind2),'rows','complete');p = pval(p2(2));
        text(1,1,{['\color{red}r=',num2str(r2(2))];['\color{red}p',p]},'units','normalized',...
                'horizontalalignment','right','verticalalignment','top');
        ylabel(cbs{i,2});xlabel(cbs{i,1});
        corrvals = [corrvals; r1(2) p1(2) r2(2) p2(2)];
    end
end

figure;hold on;
yticklbls = {};signranktest = NaN(length(cbs)*2,1);
for i = 1:length(cbs)
    cbscorrs = corrvals(i:15:end,:);
    ind1 = cbscorrs(:,2)<=0.05;
    ind2 = cbscorrs(:,4)<=0.05;
    barh(i*2,mean(cbscorrs(:,1)),'facecolor',[0.5 0.5 0.5],'EdgeColor','none');
    barh(i*2-1,mean(cbscorrs(:,3)),'facecolor',[0.7 0.3 0.3],'EdgeColor','none');
    try
        plot(cbscorrs(ind1,1),i*2,'ok','markersize',8);hold on;
        plot(cbscorrs(~ind1,1),i*2,'k.','markersize',8);hold on;
        plot(cbscorrs(ind2,1),i*2-1,'or','markersize',8);hold on;
        plot(cbscorrs(~ind2,1),i*2-1,'r.','markersize',8);hold on;
    end
    yticklbls{i} = [cbs{i,1},'vs',cbs{i,2}];
    signranktest(i*2) = signrank(cbscorrs(:,1));
    signranktest(i*2-1) = signrank(cbscorrs(:,1));
end
set(gca,'ytick',[2:2:2*length(cbs)],'yticklabel',yticklbls,'fontweight','bold');
xlabel('correlation');
title('correlation between predictors');
x = get(gca,'xlim');
for i = 1:length(signranktest)
    if signranktest(i) <=0.05
        text(x(2),i,['p<=0.05']);
    end
end

%predictors are not highly correlated. But may want to look at excluding
%VolN1 or VolN2, PitchN1 or PitchN2, DurN1 or DurN2
    
%% plot scatterplots for each response vs predictor for each gap and regression for each bivariate pair
%significant average correlations (sign rank across all gaps): PitchN1(treatment), PitchN2 (baseline/treatment), DurN1 (baseline/treatment), DurN2 (baseline)
%average correlation with PitchN1 and PitchN2 (across all gaps): r = -0.056 and r = -0.0702 (baseline) and r = -0.0992 and r = -0.0985 (treatment) 
%number of significant correlations out of 28 gaps for PitchN1 and PitchN2: 21 and 22 (baseline) and 21 and 21 (treatment)
%greatest average correlation is with DurN1: r ~ -0.4 (baseline/treatment) 

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
    barh(i*2,mean(coeffs{:,varnames{i}}),'facecolor',[0.5 0.5 0.5],'EdgeColor','none');
    barh(i*2-1,mean(coeffs_treat{:,varnames{i}}),'facecolor',[0.7 0.3 0.3],'EdgeColor','none');
    plot(coeffs{ind1,varnames{i}},i*2,'ok','markersize',8);hold on;
    plot(coeffs{~ind1,varnames{i}},i*2,'k.','markersize',8);hold on;
    plot(coeffs{ind2,varnames{i}},i*2-1,'or','markersize',8);hold on;
    plot(coeffs{~ind2,varnames{i}},i*2-1,'r.','markersize',8);hold on;
    signranktest(i*2) = signrank(coeffs{:,varnames{i}});
    signranktest(i*2-1) = signrank(coeffs_treat{:,varnames{i}});
end
x = get(gca,'xlim');
for i = 1:length(signranktest)
    if signranktest(i) <=0.05
        text(x(2),i,['p<=0.05']);
    end
end
set(gca,'ytick',[2:2:2*length(varnames)],'yticklabel',varnames,'fontweight','bold');
xlabel('correlation');
title('separate bivariate correlation');

disp(['average r for PitchN1 (baseline): ',num2str(mean(coeffs.PitchN1))]);%-0.056
disp(['average r for PitchN2 (baseline): ',num2str(mean(coeffs.PitchN2))]);%-0.0702
disp(['average r for PitchN1 (treatment): ',num2str(mean(coeffs_treat.PitchN1))]);%-0.0992
disp(['average r for PitchN2 (treatment): ',num2str(mean(coeffs_treat.PitchN2))]);%-0.0985
disp(['average Rsq for PitchN1 (baseline): ',num2str(mean(coeffs.PitchN1)^2)]);%0.0031
disp(['average Rsq for PitchN2 (baseline): ',num2str(mean(coeffs.PitchN2)^2)]);%0.005

%% separate multiple regression for each gap ID
gapid = unique(gapdata.GapID);
coefs = [];
coefs_pvals = [];
rsq = [];res = {};
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
    res = [res; {residuals(mdl)}];
    
    fullmdl = mdl.Rsquared.Adjusted;
    rsq = [rsq; fullmdl fullmdl-mdl_pitchN1.Rsquared.Adjusted fullmdl-mdl_pitchN2.Rsquared.Adjusted ...
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
rsq = array2table(rsq,'VariableNames',{'Full','PitchN1','PitchN2','VolN1','VolN2','DurN1','DurN2',...
    'Pitch','Vol','Dur'});

%plot histogram of residuals (not normal by ks test but look ~normal, std = 0.80
figure;subplot(1,2,1);hold on;
qqplot(res);subplot(1,2,2);hold on;histfit(res);xlabel('residuals');ylabel('counts');

%plot beta for each variable and each gapID   
figure;hold on;
for i = 1:length(betanames)
    ind = coeffpvals{:,betanames{i}}<=0.05;
    try
        p = signrank(coeff{:,betanames{i}});
    catch 
        p = 1;
    end
    if p<=0.05
        color = [0.8 0.3 0.3];
    else
        color = [0.5 0.5 0.5];
    end
    barh(i,mean(coeff{:,betanames{i}}),'facecolor',color,'EdgeColor','none');
    try
        plot(coeff{ind,betanames{i}},i,'ok','markersize',8);hold on;
    end
    plot(coeff{~ind,betanames{i}},i,'k.','markersize',8);hold on;
end
xlabel('beta');
set(gca,'ytick',[1:length(betanames)],'yticklabel',betanames,'fontweight','bold');
title('separate regression for each GapID');

varnames = rsq.Properties.VariableNames;
figure;hold on;
for i = 1:length(varnames)
    barh(i,mean(rsq.([varnames{i}])),'facecolor',[0.5 0.5 0.5],'edgecolor','none');
    plot(rsq.([varnames{i}]),i,'ok','markersize',8);
end
xlabel('r squared');
set(gca,'ytick',[1:length(varnames)],'yticklabel',varnames,'fontweight','bold');
title('separate regression for each GapID');

disp(['average beta for PitchN1 (baseline): ',num2str(mean(coeff.PitchN1))]);%-0.057908
disp(['average beta for PitchN2 (baseline): ',num2str(mean(coeff.PitchN2))]);%-0.072899

disp(['average proportion of variance explained: ',num2str(mean(rsq.Full))]);%0.3563
disp(['average proportion of variance explained by pitchN1: ',num2str(mean(rsq.PitchN1))]);%0.010338
disp(['average proportion of variance explained by pitchN2: ',num2str(mean(rsq.PitchN2))]);%0.0117
disp(['average proportion of variance explained pitch: ',num2str(mean(rsq.Pitch))]);%0.0273
%% no pooling multiple regression with group indicators for gap ID
formula = 'GapDur ~ GapID*Treatment*(PitchN1+PitchN2+VolN1+VolN2+DurN1+DurN2)-1';
mdl_nopooling = fitlme(gapdata,formula);

disp(['proportion of variation explained by no pooling model: ',num2str(mdl_nopooling.Rsquared.Adjusted)]);%=0.22357
%% multilevel regression with no group predictors 
formula = 'GapDur ~ Treatment*(PitchN1+PitchN2+VolN1+VolN2+DurN1+DurN2)+(Treatment*(PitchN1+PitchN2+VolN1+VolN2+DurN1+DurN2)|GapID)';
mdl_1 = fitlme(gapdata,formula);

%plot betas for each level 
[~,betanames,fixedstats] = fixedEffects(mdl_1);
[~,~,randomstats] = randomEffects(mdl_1);
betanames = betanames.Name;
figure;hold on;
for i = 1:length(betanames)
    id = strcmp(randomstats.Name,betanames{i});
    randomeff = randomstats.Estimate(id);
    id = strcmp(fixedstats.Name,betanames{i});
    beta = randomeff + fixedstats.Estimate(id);
    if fixedstats.pValue(id) <= 0.05
        color = [0.8 0.3 0.3];
    else
        color = [0.5 0.5 0.5];
    end
    barh(i,fixedstats.Estimate(id),'facecolor',color,'EdgeColor','none');
    plot(beta,i,'ok','markersize',8);hold on;
end
set(gca,'ytick',[1:length(betanames)],'yticklabel',betanames,'fontweight','bold');
title('multilevel regression with no group predictors');
xlabel('beta');

figure;hold on;subplot(2,1,1);hold on;
plotResiduals(mdl_1);
subplot(2,1,2);hold on;
plotResiduals(mdl_1,'fitted');

disp(['proportion of variation explained by multilevel model with no group predictors: ',num2str(mdl_1.Rsquared.Adjusted)]);%=0.3939
[~,~,fixedstats] = fixedEffects(mdl_1)

% formula = ['GapDur ~ Treatment*(PitchN1+PitchN2+VolN1+VolN2+DurN1+DurN2)+',...
%     '(Treatment*(PitchN1+PitchN2)-Treatment-1|GapID)+(Treatment*(VolN1+VolN2)-',...
%     'Treatment-1|GapID)+(Treatment*(DurN1+DurN2)-Treatment-1|GapID)+(1|GapID)+(Treatment|GapID)'];
% mdl_1a = fitlme(gapdata,formula);

ind = gapdata.Treatment==0;
gapdata_baseline = gapdata(ind,:);
formula = 'GapDur ~ PitchN1+PitchN2+VolN1+VolN2+DurN1+DurN2+(PitchN1+PitchN2+VolN1+VolN2+DurN1+DurN2|GapID)';
mdl_1a = fitlme(gapdata_baseline,formula);

%% multilevel regression with group predictors 

%center and transform group predictor for mean gap (baseline)
avgmeangap = mean(unique(gapdata.MeanGap));
stdmeangap = std(unique(gapdata.MeanGap));
gapid = unique(gapdata.GapID);
for i = 1:length(gapid)
    id = gapdata.GapID == gapid(i);
    meangap = unique(gapdata.MeanGap(id));
    meangap = (meangap-avgmeangap)/stdmeangap;
    gapdata.MeanGap(id) = meangap;
end

%group predictor for mean gap (baseline)
formula = 'GapDur ~ MeanGap*Treatment*(PitchN1+PitchN2+VolN1+VolN2+DurN1+DurN2)+(Treatment*(PitchN1+PitchN2+VolN1+VolN2+DurN1+DurN2)|GapID)';
mdl_2 = fitlme(gapdata,formula);

%center and transform group predictor for gap cv (baseline)
avggapcv = mean(unique(gapdata.GapCV));
stdgapcv = std(unique(gapdata.GapCV));
gapid = unique(gapdata.GapID);
for i = 1:length(gapid)
    id = gapdata.GapID == gapid(i);
    gapcv = unique(gapdata.GapCV(id));
    gapcv = (gapcv-avggapcv)/stdgapcv;
    gapdata.GapCV(id) = gapcv;
end

%group predictor for gap cv (baseline)
formula = 'GapDur ~ GapCV*Treatment*(PitchN1+PitchN2+VolN1+VolN2+DurN1+DurN2)+(Treatment*(PitchN1+PitchN2+VolN1+VolN2+DurN1+DurN2)|GapID)';
mdl_3 = fitlme(gapdata,formula);

disp(['proportion of variation explained by multilevel model with meangap group predictor: ',num2str(mdl_2.Rsquared.Adjusted)]);%=0.3939, not different from mdl_1
disp(['proportion of variation explained by multilevel model with gapcv group predictor: ',num2str(mdl_3.Rsquared.Adjusted)]);%=0.3939, not different from mdl_1

compare(mdl_1,mdl_2)%including meangap improves fit?
compare(mdl_1,mdl_3)%including gapcv improves fit? 

[~,~,fixedstats] = fixedEffects(mdl_2)%no significant coeff for meangap or any of its interactions except for DurN2:Treatment:MeanGap 
[~,~,fixedstats] = fixedEffects(mdl_3)%no significant coeff for gapcv or any of its interactions

%Group Predictor only on pitch predictor 
formula = 'GapDur ~ MeanGap*Treatment*(PitchN1+PitchN2)+Treatment*(VolN1+VolN2+DurN1+DurN2)+(Treatment*(PitchN1+PitchN2+VolN1+VolN2+DurN1+DurN2)|GapID)';
mdl_2a = fitlme(gapdata,formula);%rsq not different from mdl_1, but significant coeff for PitchN1:MeanGap 

formula = 'GapDur ~ GapCV*Treatment*(PitchN1+PitchN2)+Treatment*(VolN1+VolN2+DurN1+DurN2)+(Treatment*(PitchN1+PitchN2+VolN1+VolN2+DurN1+DurN2)|GapID)';
mdl_3a = fitlme(gapdata,formula);%rsq not different from mdl_1

[~,~,fixedstats] = fixedEffects(mdl_2a)%significant negative coeff for meangap:pitchN1 and treatment:meangap 
[~,~,fixedstats] = fixedEffects(mdl_3a)%significant positive coeff for gapcv:pitchN1

%plot meangap vs coeffs for pitch
[~,betanames,fixedstats] = fixedEffects(mdl_2a);
[~,~,randomstats] = randomEffects(mdl_2a);
meangap = [];
for i = 1:length(gapid)
    id = find(gapdata.GapID==gapid(i));
    meangap = [meangap;gapdata.MeanGap(id(1))];
end
id1 = strcmp(fixedstats.Name,'PitchN1');
id2 = find(strcmp(fixedstats.Name,'PitchN1:MeanGap'));
fixedeff = fixedstats.Estimate(id1)+fixedstats.Estimate(id2)*meangap;
id = strcmp(randomstats.Name,'PitchN1');
randomeff = randomstats.Estimate(id);
beta = randomeff + fixedeff;
figure;hold on;
subplot(2,1,1);hold on;plot(meangap,beta,'ok');
xlabel('Mean Gap Duration');ylabel('PitchN1 Beta');
[r p] = corrcoef(meangap,beta);
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

id1 = strcmp(fixedstats.Name,'PitchN2');
id2 = find(strcmp(fixedstats.Name,'PitchN2:MeanGap'));
fixedeff = fixedstats.Estimate(id1)+fixedstats.Estimate(id2)*meangap;
id = strcmp(randomstats.Name,'PitchN2');
randomeff = randomstats.Estimate(id);
beta = randomeff + fixedeff;
subplot(2,1,2);hold on;plot(meangap,beta,'ok');
xlabel('Mean Gap Duration');ylabel('PitchN2 Beta');
[r p] = corrcoef(meangap,beta);
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

%plot gapcv vs coeffs for pitch
[~,betanames,fixedstats] = fixedEffects(mdl_3a);
[~,~,randomstats] = randomEffects(mdl_3a);
gapcv = [];
for i = 1:length(gapid)
    id = find(gapdata.GapID==gapid(i));
    gapcv = [gapcv;gapdata.GapCV(id(1))];
end
id1 = strcmp(fixedstats.Name,'PitchN1');
id2 = find(strcmp(fixedstats.Name,'PitchN1:GapCV'));
fixedeff = fixedstats.Estimate(id1)+fixedstats.Estimate(id2)*gapcv;
id = strcmp(randomstats.Name,'PitchN1');
randomeff = randomstats.Estimate(id);
beta = randomeff + fixedeff;
figure;hold on;
subplot(2,1,1);hold on;plot(gapcv,beta,'ok');
xlabel('Gap CV');ylabel('PitchN1 Beta');
[r p] = corrcoef(gapcv,beta);
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

id1 = strcmp(fixedstats.Name,'PitchN2');
id2 = find(strcmp(fixedstats.Name,'PitchN2:GapCV'));
fixedeff = fixedstats.Estimate(id1)+fixedstats.Estimate(id2)*gapcv;
id = strcmp(randomstats.Name,'PitchN2');
randomeff = randomstats.Estimate(id);
beta = randomeff + fixedeff;
subplot(2,1,2);hold on;plot(gapcv,beta,'ok');
xlabel('Gap CV');ylabel('PitchN2 Beta');
[r p] = corrcoef(gapcv,beta);
text(0,1,{['r=',num2str(r(2))];['p=',num2str(p(2))]},'units','normalized');

%% proportion explained by pitch from multilevel model 
formula = 'GapDur ~ Treatment*(PitchN2+VolN1+VolN2+DurN1+DurN2)+(Treatment*(PitchN2+VolN1+VolN2+DurN1+DurN2)|GapID)';
mdl_1_pitchN1 = fitlme(gapdata,formula);

formula = 'GapDur ~ Treatment*(PitchN1+VolN1+VolN2+DurN1+DurN2)+(Treatment*(PitchN1+VolN1+VolN2+DurN1+DurN2)|GapID)';
mdl_1_pitchN2 = fitlme(gapdata,formula);

formula = 'GapDur ~ Treatment*(VolN1+VolN2+DurN1+DurN2)+(Treatment*(VolN1+VolN2+DurN1+DurN2)|GapID)';
mdl_1_pitch = fitlme(gapdata,formula);

disp(['proportion of variance explained by pitchN1: ',num2str(mdl_1.Rsquared.Adjusted-mdl_1_pitchN1.Rsquared.Adjusted)]); %1.1%
disp(['proportion of variance explained by pitchN2: ',num2str(mdl_1.Rsquared.Adjusted-mdl_1_pitchN2.Rsquared.Adjusted)]); %1.5%
disp(['proportion of variance explained by pitch: ',num2str(mdl_1.Rsquared.Adjusted-mdl_1_pitch.Rsquared.Adjusted)]); %3.4%


%% use effective change in treatment as group predictor? 

%add treatment effect as change in pitchN1 (z-score)
treatmenteffect = NaN(size(gapdata,1),1);
gapid = unique(gapdata.GapID);
for i = 1:length(gapid)
    id1 = gapdata.GapID == gapid(i) & gapdata.Treatment == 0;
    id2 = gapdata.GapID == gapid(i) & gapdata.Treatment == 1;
    id = gapdata.GapID == gapid(i);
    treatmenteffect(id) = nanmean(gapdata.PitchN1(id2))-nanmean(gapdata.PitchN1(id1));
end
gapdata.TreatmentEffect = treatmenteffect;
  
formula = 'GapDur ~ TreatmentEffect*Treatment*(PitchN1+PitchN2)+Treatment*(VolN1+VolN2+DurN1+DurN2)+(Treatment*(PitchN1+PitchN2+VolN1+VolN2+DurN1+DurN2)|GapID)';
mdl_treatmenteffect = fitlme(gapdata,formula);

disp(['proportion of variation explained by multilevel model with treatmentsize as group predictor: ',num2str(mdl_treatmenteffect.Rsquared.Adjusted)]);%=0.3939

compare(mdl_1,mdl_treatmenteffect); %adding treatment effect as group predictor does not increase fit 

[~,~,fixedstats] = fixedEffects(mdl_treatmenteffect);%coeffs for treatmenteffect:(treatment):pitch is not significant
%%
formula = 'GapDur ~ Treatment*(PitchN1+PitchN2)+VolN1+VolN2+DurN1+DurN2+RenditionID+BirdID+(Treatment*(PitchN1+PitchN2)+VolN1+VolN2+DurN1+DurN2+RenditionID|GapID)';
mdl = fitlme(gapdata,formula);

formula = 'GapDur ~ Treatment*(PitchN1+PitchN2)+VolN1+VolN2+DurN1+DurN2+BoutID+BirdID+(Treatment*(PitchN1+PitchN2)+VolN1+VolN2+DurN1+DurN2|GapID)';
mdl_1 = fitlme(gapdata,formula);
formula = 'GapDur ~ Treatment*(PitchN1+PitchN2)+VolN1+VolN2+DurN1+DurN2+BoutID+RenditionID+BirdID+(Treatment*(PitchN1+PitchN2)+VolN1+VolN2+DurN1+DurN2+RenditionID|GapID)';
mdl_2 = fitlme(gapdata,formula);

formula = 'GapDur ~ Treatment*(PitchN1+PitchN2)+VolN1+VolN2+DurN1+DurN2+BirdID+(Treatment*(PitchN1+PitchN2)+VolN1+VolN2+DurN1+DurN2|GapID)';
mdl_3 = fitlme(gapdata,formula);

formula = 'GapDur ~ Treatment*(PitchN1+PitchN2)+VolN1+VolN2+DurN1+DurN2+BirdID+(Treatment*(PitchN1+PitchN2)+VolN1+VolN2+DurN1+DurN2|GapID:RenditionID)';
mdl_4 = fitlme(gapdata,formula);


formula = 'GapDur ~ PitchN1 + (PitchN1|GapID)';%positive serial correlation
mdl = fitlme(gapdata,formula);
formula = 'GapDur ~ PitchN1 +(PitchN1|GapID:RenditionID)+(PitchN1|GapID:BoutID)';%negative serial correlation
mdl6 = fitlme(gapdata,formula);

%positive serial correlation
formula = 'GapDur ~ PitchN1 + (PitchN1|GapID:RenditionID)';
mdl1 = fitlme(gapdata,formula);
formula = 'GapDur ~ PitchN1 + RenditionID + (PitchN1|GapID)';%what is difference with mdl1? 
mdl4 = fitlme(gapdata,formula);
formula = 'GapDur ~ PitchN1 + RenditionID + (PitchN1+RenditionID|GapID)';
mdl5 = fitlme(gapdata,formula);
formula = 'GapDur ~ PitchN1 + RenditionID + (PitchN1|GapID)+(RenditionID|GapID)';
mdl10 = fitlme(gapdata,formula);

%negative serial correlation
formula = 'GapDur ~ PitchN1 + (PitchN1|GapID:BoutID)';
mdl2 = fitlme(gapdata,formula);
formula = 'GapDur ~ PitchN1 + RenditionID + (PitchN1|GapID:BoutID)';%how is effect of renditionID held constsant when looking at pitch grouped by bout? 
mdl3 = fitlme(gapdata,formula);
formula = 'GapDur ~ PitchN1 + RenditionID + (PitchN1+RenditionID|GapID:BoutID)';
mdl11 = fitlme(gapdata,formula);

%positive serial correlation 
formula = 'GapDur ~ PitchN1 + BoutID + (PitchN1|GapID)';
mdl7 = fitlme(gapdata,formula);
formula = 'GapDur ~ PitchN1 + BoutID + (PitchN1+BoutID|GapID)';
mdl8 = fitlme(gapdata,formula);
formula = 'GapDur ~ PitchN1 + BoutID + (PitchN1|GapID)+(BoutID|GapID)';
mdl9 = fitlme(gapdata,formula);

%negative serial correlation
formula = 'GapDur ~ PitchN1*RenditionID + (PitchN1*RenditionID|GapID:BoutID)';
mdl12 = fitlme(gapdata,formula);
formula = 'GapDur ~ PitchN1*RenditionID + (PitchN1|GapID:BoutID)';
mdl13 = fitlme(gapdata,formula);
formula = 'GapDur ~ PitchN1*RenditionID + (PitchN1|GapID:BoutID)+(RenditionID|GapID:BoutID)';
mdl14 = fitlme(gapdata,formula);

formula = 'GapDur ~ RenditionID + (RenditionID|GapID:BoutID)';
mdl15 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1+RenditionID + (PitchN1|BirdID:GapID:BoutID)+(RenditionID|BirdID:GapID:BoutID)';
mdl16 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1 + RenditionID + BirdID +(PitchN1|GapID:BoutID)+(RenditionID|GapID:BoutID)';
mdl17 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1 + (PitchN1|BirdID:GapID:BoutID)+(PitchN1|BirdID:GapID:RenditionID)';
mdl18 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1 + RenditionID + (PitchN1+RenditionID|BirdID:GapID:BoutID)';
mdl19 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1 + RenditionID + (PitchN1|BirdID:GapID)';
mdl20 = fitlme(gapdata,formula);

%%%%%%

formula = 'GapDur ~ PitchN1 + Treatment + (PitchN1+Treatment|BirdID:GapID:RenditionID) + (PitchN1+Treatment|BirdID:GapID:BoutID) + (PitchN1+Treatment|BirdID) + (PitchN1+Treatment|BirdID:GapID)';
mdl19 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1 + Treatment + RenditionID + (PitchN1+Treatment+RenditionID|BirdID:GapID:BoutID) + (PitchN1+Treatment+RenditionID|BirdID) + (PitchN1+Treatment+RenditionID|BirdID:GapID)';
mdl20 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1 + Treatment + BoutID + (PitchN1+Treatment+BoutID|BirdID) + (PitchN1+Treatment+BoutID|BirdID:GapID)';
mdl21 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1 + Treatment + RenditionID + (PitchN1+Treatment+RenditionID|BirdID) + (PitchN1+Treatment+RenditionID|BirdID:GapID)';
mdl22 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1 + Treatment + RenditionID + BoutID + (PitchN1+Treatment+RenditionID+BoutID|BirdID) + (PitchN1+Treatment+RenditionID+BoutID|BirdID:GapID)';
mdl23 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1 + Treatment + (PitchN1+Treatment|BirdID) + (PitchN1+Treatment|BirdID:GapID)';
mdl24 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1 + Treatment + (PitchN1|BirdID) + (PitchN1|BirdID:GapID) + (Treatment|BirdID) + (Treatment|BirdID:GapID)';
mdl25 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1 + Treatment + (PitchN1+Treatment|BirdID:GapID:RenditionID) + (PitchN1+Treatment|BirdID) + (PitchN1+Treatment|BirdID:GapID)';
mdl26 = fitlme(gapdata,formula);



formula = 'GapDur ~ PitchN1*Treatment + (PitchN1*Treatment|BirdID:GapID:RenditionID) + (PitchN1*Treatment|BirdID) + (PitchN1*Treatment|BirdID:GapID)';
mdl27 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1*Treatment + BoutID + (PitchN1*Treatment+BoutID|BirdID) + (PitchN1*Treatment+BoutID|BirdID:GapID)';
mdl28 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1*Treatment + RenditionID + (PitchN1*Treatment+RenditionID|BirdID) + (PitchN1*Treatment+RenditionID|BirdID:GapID)';
mdl29 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1*Treatment + RenditionID + (PitchN1*Treatment+RenditionID|BirdID:GapID:BoutID) + (PitchN1*Treatment+RenditionID|BirdID) + (PitchN1*Treatment+RenditionID|BirdID:GapID)';
mdl30 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1*Treatment + (PitchN1*Treatment|BirdID:GapID:BoutID) + (PitchN1*Treatment|BirdID) + (PitchN1*Treatment|BirdID:GapID)';
mdl31 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1*Treatment + (PitchN1*Treatment|BirdID:GapID:RenditionID) + (PitchN1*Treatment|BirdID:GapID:BoutID) + (PitchN1*Treatment|BirdID) + (PitchN1*Treatment|BirdID:GapID)';
mdl32 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1*Treatment + RenditionID + BoutID + (PitchN1+Treatment+RenditionID+BoutID|BirdID) + (PitchN1+Treatment+RenditionID+BoutID|BirdID:GapID)';
mdl34 = fitlme(gapdata,formula);


formula = 'GapDur ~ VolN1*Treatment + RenditionID + (VolN1*Treatment+RenditionID|BirdID) + (VolN1*Treatment+RenditionID|BirdID:GapID)';
mdl33 = fitlme(gapdata,formula);

formula = 'PitchN1 ~ RenditionID + (RenditionID|BirdID) + (RenditionID|BirdID:GapID) + (RenditionID|BirdID:GapID:BoutID)';
mdl34 = fitlme(gapdata,formula);

formula = 'PitchN1 ~ RenditionID + (RenditionID|BirdID) + (RenditionID|BirdID:GapID)';
mdl35 = fitlme(gapdata,formula);

formula = 'PitchN1 ~ RenditionID + BoutID + (RenditionID+BoutID|BirdID) + (RenditionID+BoutID|BirdID:GapID)';
mdl35a = fitlme(gapdata,formula);

%% mixed model for pitch and gap duration controlling for within/across bout variability

gapdata_naspm = gapdata(gapdata.Treatment==1,:);
gapdata_pre = gapdata(gapdata.Treatment==0,:);

formula = 'GapDur ~ PitchN1 + RenditionID + (PitchN1+RenditionID|BirdID) + (PitchN1+RenditionID|BirdID:GapID)';
mdl36_naspm = fitlme(gapdata_naspm,formula);
mdl36_pre = fitlme(gapdata_pre,formula);

formula = 'GapDur ~ PitchN1 + BoutID + (PitchN1+BoutID|BirdID) + (PitchN1+BoutID|BirdID:GapID)';
mdl37_naspm = fitlme(gapdata_naspm,formula);
mdl37_pre = fitlme(gapdata_pre,formula);

formula = 'GapDur ~ PitchN1 + RenditionID + (PitchN1+RenditionID|BirdID:GapID:BoutID) + (PitchN1+RenditionID|BirdID) + (PitchN1+RenditionID|BirdID:GapID)';
mdl38_naspm = fitlme(gapdata_naspm,formula);
mdl38_pre = fitlme(gapdata_pre,formula);

formula = 'GapDur ~ PitchN1 + (PitchN1|BirdID:GapID:RenditionID) + (PitchN1|BirdID:GapID:BoutID) + (PitchN1|BirdID) + (PitchN1|BirdID:GapID)';
mdl39_naspm = fitlme(gapdata_naspm,formula);
mdl39_pre = fitlme(gapdata_pre,formula);

formula = 'GapDur ~ PitchN1 + RenditionID + BoutID + (PitchN1+RenditionID+BoutID|BirdID) + (PitchN1+RenditionID+BoutID|BirdID:GapID)';
mdl40_naspm = fitlme(gapdata_naspm,formula);
mdl40_pre = fitlme(gapdata_pre,formula);


formula = 'GapDur ~ PitchN1*Treatment + RenditionID + (PitchN1*Treatment+RenditionID|BirdID) + (PitchN1*Treatment+RenditionID|BirdID:GapID)';
mdl36 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1*Treatment + BoutID + (PitchN1*Treatment+BoutID|BirdID) + (PitchN1*Treatment+BoutID|BirdID:GapID)';
mdl37 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1*Treatment + RenditionID + (PitchN1*Treatment+RenditionID|BirdID:GapID:BoutID) + (PitchN1*Treatment+RenditionID|BirdID) + (PitchN1*Treatment+RenditionID|BirdID:GapID)';
mdl38 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1*Treatment + (PitchN1*Treatment|BirdID:GapID:RenditionID) + (PitchN1*Treatment|BirdID:GapID:BoutID) + (PitchN1*Treatment|BirdID) + (PitchN1*Treatment|BirdID:GapID)';
mdl39 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1*Treatment + RenditionID + BoutID + (PitchN1*Treatment+RenditionID+BoutID|BirdID) + (PitchN1*Treatment+RenditionID+BoutID|BirdID:GapID)';
mdl40 = fitlme(gapdata,formula);


%add days, and transform renditionID?
%could pitch vs gapdur relationship be obscurred by pitch var, check lman
%lesion/apv data set and also fit model to only treatment data 
%implicit nesting and population pooling? need to include combination
%predictor to make implicit nesting clear? 



for i = 1:28
    ind = gapdata.GapID == i  & gapdata.Treatment == 0;
    res = residuals(mdl32);
    scaled = (res(ind)-nanmean(res(ind)))/nanstd(res(ind));
    scaled(isnan(res(ind))) = 0;
    pr = pacf(scaled,50,1);
end

for i = 1:28
    ind = gapdata.GapID == i  & gapdata.Treatment == 0;
    yi = gapdata.GapDur;
    scaled = (yi(ind)-nanmean(yi(ind)))/nanstd(yi(ind));
    scaled(isnan(yi(ind))) = 0;
    pr = pacf(scaled,50,1)
end


%plot betas for each level 
[~,betanames,fixedstats] = fixedEffects(mdl);
[~,~,randomstats] = randomEffects(mdl_1);
betanames = betanames.Name;
figure;hold on;
for i = 1:length(betanames)
    id = strcmp(randomstats.Name,betanames{i});
    randomeff = randomstats.Estimate(id);
    id = strcmp(fixedstats.Name,betanames{i});
    beta = randomeff + fixedstats.Estimate(id);
    if fixedstats.pValue(id) <= 0.05
        color = [0.8 0.3 0.3];
    else
        color = [0.5 0.5 0.5];
    end
    barh(i,fixedstats.Estimate(id),'facecolor',color,'EdgeColor','none');
    plot(beta,i,'ok','markersize',8);hold on;
end
set(gca,'ytick',[1:length(betanames)],'yticklabel',betanames,'fontweight','bold');
title('multilevel regression with no group predictors');
xlabel('beta');
%% plot scatterplots for pitch vs gapdur for each gapID and regression for each bivariate pair

pitchN1corrs = [];
gapid =  unique(gapdata.GapID);
for n = 1:length(gapid)
    id = gapdata.GapID==gapid(n) & gapdata.Treatment==0;
    id2 = gapdata.GapID==gapid(n) & gapdata.Treatment==1;
    birdnm = unique(gapdata.BirdID(id));
    
    if mod(n,7)==1
        figure;hold on;
    end

    if n > 7
        pltid = mod(n,7);
        if pltid == 0
            pltid = pltid+7;
        end
    else 
        pltid = n;
    end

    h1=subtightplot(2,7,pltid,[0.07 0.03],0.05,0.03);hold on;
    plot(gapdata.PitchN1(id),gapdata.GapDur(id),'k.');hold on;
    h2=subtightplot(2,7,pltid+7,[0.07 0.03],0.05,0.03);hold on;
    plot(gapdata.PitchN1(id2),gapdata.GapDur(id2),'r.');hold on;
    x = xlim(h1);y = ylim(h1);set(h2,'xlim',x,'ylim',y);
    xlabel(h2,'Pitch');ylabel(h1,'Gap Dur');ylabel(h2,'Gap Dur');title(h1,[birdnm{1},' gap ',num2str(gapid(n))]);
    [r1 p1] = corrcoef(gapdata.PitchN1(id),gapdata.GapDur(id),'rows','complete');p = pval(p1(2));
    text(h1,0,1,{['r=',num2str(r1(2))];['p',p]},'units','normalized','verticalalignment','top');
    [r2 p2] = corrcoef(gapdata.PitchN1(id2),gapdata.GapDur(id2),'rows','complete');p = pval(p2(2));
    text(h2,0,1,{['\color{red}r=',num2str(r2(2))];['\color{red}p',p]},'units','normalized','verticalalignment','top');
    pitchN1corrs = [pitchN1corrs; [r1(2) p1(2) r2(2) p2(2)]];
end


%compare distribution of corr values
varnames = {'coeffs','pvals','coeffs_treat','pvals_treat'};
pitchN1corrs = table(pitchN1corrs(:,1),pitchN1corrs(:,2),pitchN1corrs(:,3),...
    pitchN1corrs(:,4),'VariableNames',varnames);
figure;hold on;
ind1 = pitchN1corrs.pvals <=0.05;
ind2 = pitchN1corrs.pvals_treat<=0.05;
bar(1,mean(pitchN1corrs.coeffs),'facecolor',[0.5 0.5 0.5],'EdgeColor','none');
bar(2,mean(pitchN1corrs.coeffs_treat),'facecolor',[0.7 0.3 0.3],'EdgeColor','none');
plot(1,pitchN1corrs.coeffs(ind1),'ok','markersize',8);hold on;
plot(1,pitchN1corrs.coeffs(~ind1),'k.','markersize',10);hold on;
plot(2,pitchN1corrs.coeffs_treat(ind2),'or','markersize',8);hold on;
plot(2,pitchN1corrs.coeffs_treat(~ind2),'r.','markersize',10);hold on;
plot([1 2],[pitchN1corrs.coeffs pitchN1corrs.coeffs_treat],'color',[0.7 0.7 0.7],'linewidth',2);
signranktest = signrank(pitchN1corrs.coeffs);
signranktest2 = signrank(pitchN1corrs.coeffs_treat);
signranktest3 = signrank(pitchN1corrs.coeffs,pitchN1corrs.coeffs_treat);
y = get(gca,'ylim');
if signranktest <=0.05
    text(1,y(2),['p<=0.05']);
end
if signranktest2 <=0.05
    text(2,y(2),['p<=0.05']);
end
if signranktest3 <=0.05
    text(1.5,y(2),['p<=0.05']);
end

set(gca,'xlim',[0 3],'xtick',[1:2],'xticklabel',{'saline','naspm'},'fontweight','bold');
ylabel('correlation');
title('pitch vs gapdur');

disp(['average r for PitchN1 (baseline): ',num2str(mean(pitchN1corrs.coeffs))]);
disp(['average r for PitchN1 (treatment): ',num2str(mean(pitchN1corrs.coeffs_treat))]);
disp(['average Rsq for PitchN1 (baseline): ',num2str(mean(pitchN1corrs.coeffs)^2)]);
disp(['average Rsq for PitchN1 (treatment): ',num2str(mean(pitchN1corrs.coeffs_treat)^2)]);
