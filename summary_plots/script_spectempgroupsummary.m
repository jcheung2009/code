%plots group comparison of spectral and temporal features for each condition
%from all birds in directory
%summary structs are from script_spectempsummary

config;
conditions = params.conditions;
xvect = 1:2*length(conditions);
groupvar = repmat([1:length(conditions)],2,1);
colors = params.colors;

batch = uigetfile;
ff = load_batchf(batch);
cmap = hsv(length(ff));
figure;
h1 = subtightplot(4,1,1,[0.07 0.07],0.1,0.15);
h2 = subtightplot(4,1,2,[0.07 0.07],0.1,0.15);
h3 = subtightplot(4,1,3,[0.07 0.07],0.1,0.15);
h4 = subtightplot(4,1,4,[0.07 0.07],0.1,0.15);

figure;
h5 = subtightplot(3,1,1,[0.07 0.07],0.1,0.15);
h6 = subtightplot(3,1,2,[0.07 0.07],0.1,0.15);
h7 = subtightplot(3,1,3,[0.07 0.07],0.1,0.15);

figure;
h8 = gca;
figure;
h9 = gca;

group_pitch = struct();group_vol = struct();group_ent = struct();group_pcv = struct();
group_motifdur = struct();group_sylldur = struct(); group_gapdur = struct();
group_rep = struct();group_bout = struct();
for n = 1:length(conditions)
    group_pitch = setfield(group_pitch,conditions{n},[]);
    group_vol = setfield(group_vol,conditions{n},[]);
    group_ent = setfield(group_ent,conditions{n},[]);
    group_pcv = setfield(group_pcv,conditions{n},[]);
    group_motifdur = setfield(group_motifdur,conditions{n},[]);
    group_sylldur = setfield(group_sylldur,conditions{n},[]);
    group_gapdur = setfield(group_gapdur,conditions{n},[]);
    group_rep = setfield(group_rep,conditions{n},[]);
    group_bout = setfield(group_bout,conditions{n},[]);
end
for i = 1:length(ff)
    load([ff(i).name,'/analysis/data_structures/',ff(i).name,'_summary']);
    birdsummary = eval([ff(i).name,'_summary']);
    if isfield(birdsummary,'spec')
        numsylls = length(fieldnames(birdsummary.spec));
        sylls = fieldnames(birdsummary.spec);
        for indcond = 1:length(conditions)
            for n = 1:numsylls
                ind = strcmp(arrayfun(@(x) x.([sylls{n}]).condition,birdsummary.spec,'unif',0),conditions{indcond});
                pitch = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitch.mean,birdsummary.spec(ind),'unif',0)'),1);
                vol = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).vol.mean,birdsummary.spec(ind),'unif',0)'),1);
                ent = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).ent.mean,birdsummary.spec(ind),'unif',0)'),1);
                pitchcv = mean(cell2mat(arrayfun(@(x) x.([sylls{n}]).pitchcv.cv,birdsummary.spec(ind),'unif',0)'),1);
                axes(h1);hold on;plot(h1,xvect(groupvar==indcond),pitch,'marker','o','color',[0.5 0.5 0.5]);
                axes(h2);hold on;plot(h2,xvect(groupvar==indcond),vol,'marker','o','color',[0.5 0.5 0.5]);
                axes(h3);hold on;plot(h3,xvect(groupvar==indcond),ent,'marker','o','color',[0.5 0.5 0.5]);
                axes(h4);hold on;plot(h4,xvect(groupvar==indcond),pitchcv,'marker','o','color',[0.5 0.5 0.5]);
                group_pitch.(conditions{indcond}) = [group_pitch.(conditions{indcond});pitch];
                group_vol.(conditions{indcond}) = [group_vol.(conditions{indcond});vol];
                group_ent.(conditions{indcond}) = [group_ent.(conditions{indcond});ent];
                group_pcv.(conditions{indcond}) = [group_pcv.(conditions{indcond});pitchcv];
            end
        end
    end
    
    if isfield(birdsummary,'temp')
        nummotifs = length(fieldnames(birdsummary.temp));
        motifs = fieldnames(birdsummary.temp);
        for indcond = 1:length(conditions)
            for n = 1:nummotifs
                ind = strcmp(arrayfun(@(x) x.([motifs{n}]).condition,birdsummary.temp,'unif',0),conditions{indcond});
                motifdur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).motifdur.mean,birdsummary.temp(ind),'unif',0)'),1);
                axes(h5);hold on;plot(h5,xvect(groupvar==indcond),motifdur,'marker','o','color',[0.5 0.5 0.5]);
                group_motifdur.(conditions{indcond}) = [group_motifdur.(conditions{indcond});motifdur];
                
                numsylls = length(motifs{n});
                for syllind = 1:numsylls
                    sylldur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).sylldur.mean(:,syllind)',birdsummary.temp(ind),'unif',0)'),1);
                    axes(h6);hold on;plot(h6,xvect(groupvar==indcond),sylldur,'marker','o','color',[0.5 0.5 0.5]);
                    group_sylldur.(conditions{indcond}) = [group_sylldur.(conditions{indcond});sylldur];
                end
                
                numgaps = numsylls-1;
                for gapind = 1:numgaps
                    gapdur = mean(cell2mat(arrayfun(@(x) x.([motifs{n}]).gapdur.mean(:,gapind)',birdsummary.temp(ind),'unif',0)'),1);
                    axes(h7);hold on;plot(h7,xvect(groupvar==indcond),gapdur,'marker','o','color',[0.5 0.5 0.5]);
                    group_gapdur.(conditions{indcond}) = [group_gapdur.(conditions{indcond});gapdur];
                end    
            end
        end
    end
    
    if isfield(birdsummary,'rep')
        numreps = length(fieldnames(birdsummary.rep));
        reps = fieldnames(birdsummary.rep);
        for indcond = 1:length(conditions)
            for n = 1:numreps
                ind = strcmp(arrayfun(@(x) x.([reps{n}]).condition,birdsummary.rep,'unif',0),conditions{indcond});
                runlength = mean(cell2mat(arrayfun(@(x) x.([reps{n}]).runlength.mean,birdsummary.rep(ind),'unif',0)'),1);
                axes(h8);hold on;plot(h8,xvect(groupvar==indcond),runlength,'marker','o','color',[0.5 0.5 0.5]);
                group_rep.(conditions{indcond}) = [group_rep.(conditions{indcond});runlength];
            end
        end
    end
    
    if isfield(birdsummary,'bout')
        numbouts = length(fieldnames(birdsummary.bout));
        bouts = fieldnames(birdsummary.bout);
        for indcond = 1:length(conditions)
            for n = 1:numreps
                ind = strcmp(arrayfun(@(x) x.([bouts{n}]).condition,birdsummary.bout,'unif',0),conditions{indcond});
                meansingingrate = mean(cell2mat(arrayfun(@(x) x.([bouts{n}]).meansingingrate.mean,birdsummary.bout(ind),'unif',0)'),1);
                axes(h9);hold on;plot(h9,xvect(groupvar==indcond),meansingingrate,'marker','o','color',[0.5 0.5 0.5]);
                group_bout.(conditions{indcond}) = [group_bout.(conditions{indcond});meansingingrate];
            end
        end
    end
end
lbls = {};
for n = 1:length(conditions)
    x = xvect(groupvar==n);
    b = bar(h1,x(1),mean(group_pitch.(conditions{n})(:,1))','facecolor','none');uistack(b,'bottom')
    b = bar(h1,x(2),mean(group_pitch.(conditions{n})(:,2))','facecolor','none','edgecolor','r','linewidth',2);uistack(b,'bottom')
    
    b = bar(h2,x(1),mean(group_vol.(conditions{n})(:,1))','facecolor','none');uistack(b,'bottom')
    b = bar(h2,x(2),mean(group_vol.(conditions{n})(:,2))','facecolor','none','edgecolor','r','linewidth',2);uistack(b,'bottom')
   
    b = bar(h3,x(1),mean(group_ent.(conditions{n})(:,1))','facecolor','none');uistack(b,'bottom')
    b = bar(h3,x(2),mean(group_ent.(conditions{n})(:,2))','facecolor','none','edgecolor','r','linewidth',2);uistack(b,'bottom')
   
    b = bar(h4,x(1),mean(group_pcv.(conditions{n})(:,1))','facecolor','none');uistack(b,'bottom')
    b = bar(h4,x(2),mean(group_pcv.(conditions{n})(:,2))','facecolor','none','edgecolor','r','linewidth',2);uistack(b,'bottom')
    
    b = bar(h5,x(1),mean(group_motifdur.(conditions{n})(:,1))','facecolor','none');uistack(b,'bottom')
    b = bar(h5,x(2),mean(group_motifdur.(conditions{n})(:,2))','facecolor','none','edgecolor','r','linewidth',2);uistack(b,'bottom')
    
    b = bar(h6,x(1),mean(group_sylldur.(conditions{n})(:,1))','facecolor','none');uistack(b,'bottom')
    b = bar(h6,x(2),mean(group_sylldur.(conditions{n})(:,2))','facecolor','none','edgecolor','r','linewidth',2);uistack(b,'bottom')
    
    b = bar(h7,x(1),mean(group_gapdur.(conditions{n})(:,1))','facecolor','none');uistack(b,'bottom')
    b = bar(h7,x(2),mean(group_gapdur.(conditions{n})(:,2))','facecolor','none','edgecolor','r','linewidth',2);uistack(b,'bottom')
    
    b = bar(h8,x(1),mean(group_rep.(conditions{n})(:,1))','facecolor','none');uistack(b,'bottom')
    b = bar(h8,x(2),mean(group_rep.(conditions{n})(:,2))','facecolor','none','edgecolor','r','linewidth',2);uistack(b,'bottom')
    
    b = bar(h9,x(1),mean(group_bout.(conditions{n})(:,1))','facecolor','none');uistack(b,'bottom')
    b = bar(h9,x(2),mean(group_bout.(conditions{n})(:,2))','facecolor','none','edgecolor','r','linewidth',2);uistack(b,'bottom')
    
    lbls = [lbls,'pre',conditions{n}];
end

for n = 1:length(conditions)
    plot_pval(h1,group_pitch.(conditions{n})(:,1),group_pitch.(conditions{n})(:,2),x(2),'');
    plot_pval(h2,group_vol.(conditions{n})(:,1),group_vol.(conditions{n})(:,2),x(2),'');
    plot_pval(h3,group_ent.(conditions{n})(:,1),group_ent.(conditions{n})(:,2),x(2),'');
    plot_pval(h4,group_pcv.(conditions{n})(:,1),group_pcv.(conditions{n})(:,2),x(2),'');
    plot_pval(h5,group_motifdur.(conditions{n})(:,1),group_motifdur.(conditions{n})(:,2),x(2),'');
    plot_pval(h6,group_sylldur.(conditions{n})(:,1),group_sylldur.(conditions{n})(:,2),x(2),'');
    plot_pval(h7,group_gapdur.(conditions{n})(:,1),group_gapdur.(conditions{n})(:,2),x(2),'');
    plot_pval(h8,group_rep.(conditions{n})(:,1),group_rep.(conditions{n})(:,2),x(2),'');
    plot_pval(h9,group_bout.(conditions{n})(:,1),group_bout.(conditions{n})(:,2),x(2),'');
end
ylabel(h1,'pitch (hz)');
ylabel(h2,'log amplitude');
ylabel(h3,'entropy');
ylabel(h4,'pitch cv');
ylabel(h5,'motif duration (s)');
ylabel(h6,'syll duration (s)');
ylabel(h7,'gap duration (s)');
ylabel(h8,'repeat length');
ylabel(h9,'singing rate');
set([h1,h2,h3,h4,h5,h6,h7,h8,h9],'xlim',[0 2*length(conditions)+1],'xtick',xvect,'xticklabel',lbls,'fontweight','bold');
    
    