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
figure;hold on;signranktest = NaN(12,1);
ind = pitchN1corrs(:,2)<=0.05;
plot(pitchN1corrs(ind,1),1,'ok','markersize',8);
plot(pitchN1corrs(~ind,1),1,'k.','markersize',8);
signranktest(1)=signrank(pitchN1corrs(ind,1));
ind = pitchN1corrs(:,4)<=0.05;
plot(pitchN1corrs(ind,3),1.5,'or','markersize',8);
plot(pitchN1corrs(~ind,3),1.5,'r.','markersize',8);
signranktest(2)=signrank(pitchN1corrs(ind,3));

ind = pitchN2corrs(:,2)<=0.05;
plot(pitchN2corrs(ind,1),2,'ok','markersize',8);
plot(pitchN2corrs(~ind,1),2,'k.','markersize',8);
signranktest(3)=signrank(pitchN2corrs(ind,1));
ind = pitchN2corrs(:,4)<=0.05;
plot(pitchN2corrs(ind,3),2.5,'or','markersize',8);
plot(pitchN2corrs(~ind,3),2.5,'r.','markersize',8);
signranktest(4)=signrank(pitchN2corrs(ind,3));

ind = volN1corrs(:,2)<=0.05;
plot(volN1corrs(ind,1),3,'ok','markersize',8);
plot(volN1corrs(~ind,1),3,'k.','markersize',8);
signranktest(5)=signrank(volN1corrs(ind,1));
ind = volN1corrs(:,4)<=0.05;
plot(volN1corrs(ind,3),3.5,'or','markersize',8);
plot(volN1corrs(~ind,3),3.5,'r.','markersize',8);
signranktest(6)=signrank(volN1corrs(ind,3));
        
ind = volN2corrs(:,2)<=0.05;
plot(volN2corrs(ind,1),4,'ok','markersize',8);
plot(volN2corrs(~ind,1),4,'k.','markersize',8);
signranktest(7)=signrank(volN2corrs(ind,1));
ind = volN2corrs(:,4)<=0.05;
plot(volN2corrs(ind,3),4.5,'or','markersize',8);
plot(volN2corrs(~ind,3),4.5,'r.','markersize',8);   
signranktest(8)=signrank(volN2corrs(ind,3));

ind = durN1corrs(:,2)<=0.05;
plot(durN1corrs(ind,1),5,'ok','markersize',8);
plot(durN1corrs(~ind,1),5,'k.','markersize',8);
signranktest(9)=signrank(durN1corrs(ind,1));
ind = durN1corrs(:,4)<=0.05;
plot(durN1corrs(ind,3),5.5,'or','markersize',8);
plot(durN1corrs(~ind,3),5.5,'r.','markersize',8);
signranktest(10)=signrank(durN1corrs(ind,3));

ind = durN2corrs(:,2)<=0.05;
plot(durN2corrs(ind,1),6,'ok','markersize',8);
plot(durN2corrs(~ind,1),6,'k.','markersize',8);
signranktest(11)=signrank(durN2corrs(ind,1));
ind = durN2corrs(:,4)<=0.05;
plot(durN2corrs(ind,3),6.5,'or','markersize',8);
plot(durN2corrs(~ind,3),6.5,'r.','markersize',8);
signranktest(12)=signrank(durN2corrs(ind,3));

plot([0 0],[0 7],'color',[0.5 0.5 0.5],'linewidth',2);
xlabel('correlation');
set(gca,'ytick',[1.5:6.5],'yticklabel',{'pitchN1','pitchN2','volN1','volN2','durN1','durN2'},'fontweight','bold');

y = 1:0.5:6.5;x = get(gca,'xlim');
for i = 1:length(y)
    if signranktest(i) <=0.05
        text(x(2),y(i),['p<=0.05']);
    end
end


        
        