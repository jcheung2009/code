%plot pitch, entropy, EV, and motifdur oscillations over time of day, by
%deviation from mean

config;

%% pitch

for  n = 1:length(params.findnote)
    fvfig(n)=figure;
end

for n = 1:length(params.findnote)
    syllable = params.findnote(n).syllable;
    pre = []; post = [];hrs=0:15;
    for i = 1:length(params.trial)
        if ~exist([params.findnote(n).fvstruct,params.trial(i).name])
            load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).name]);
        end
        fv = eval([params.findnote(n).fvstruct,params.trial(i).name]); 
        tb = jc_tb([fv(:).datenm]',7,0)/3600;
        if strcmp(params.trial(i).condition,params.timeshift{1})
            tb = tb-params.timeshift{2};
        end
        mxvals = [fv(:).mxvals];
        mxvals = 100*(mxvals-mean(mxvals))./mean(mxvals);
        spent = [fv(:).spent];
        spent = 100*(spent-mean(spent))./mean(spent);
        ev = [fv(:).entropyvar];
        ev = 100*(ev-mean(ev))./mean(ev);
        
        hour = NaN(length(hrs),3);
        for ind = 1:length(hrs)-1
            intv = find(tb>=hrs(ind) & tb<hrs(ind+1));   
            if length(intv) >= 15
                hour(ind,:) = [mean(mxvals(intv)) mean(spent(intv)) mean(ev(intv))];
            else
                continue
            end
        end
        if strcmp(params.trial(i).condition,'pre')
            pre = [pre hour];
        else
            post = [post hour];
        end
    end
    figure(fvfig(n));hold on;
    %pitch
    subtightplot(3,1,1,[0.07 0.05],0.08,0.12);
    sem_pre = nanstderr(pre(:,[1:3:end]),2)';
    sem_post = nanstderr(post(:,[1:3:end]),2)';
    mn_pre = nanmean(pre(:,[1:3:end]),2)';
    mn_post = nanmean(post(:,[1:3:end]),2)';
    plot(hrs,mn_pre,'k','linewidth',2,'marker','o','markersize',4);hold on;
    plot([hrs;hrs],[mn_pre+sem_pre; mn_pre-sem_pre],'k','linewidth',2);hold on;
    plot(hrs,mn_post,'r','linewidth',2,'marker','o','markersize',4);hold on;
    plot([hrs;hrs],[mn_post+sem_post; mn_post-sem_post],'r','linewidth',2);hold on;
    xlabel('Time of day');ylabel('percent change');
    title([syllable,' pitch']);
    %entropy
    subtightplot(3,1,2,[0.07 0.05],0.08,0.12);
    sem_pre = nanstderr(pre(:,[2:3:end]),2)';
    sem_post = nanstderr(post(:,[2:3:end]),2)';
    mn_pre = nanmean(pre(:,[2:3:end]),2)';
    mn_post = nanmean(post(:,[2:3:end]),2)';
    plot(hrs,mn_pre,'k','linewidth',2,'marker','o','markersize',4);hold on;
    plot([hrs;hrs],[mn_pre+sem_pre; mn_pre-sem_pre],'k','linewidth',2);hold on;
    plot(hrs,mn_post,'r','linewidth',2,'marker','o','markersize',4);hold on;
    plot([hrs;hrs],[mn_post+sem_post; mn_post-sem_post],'r','linewidth',2);hold on;
    xlabel('Time of day');ylabel('percent change');
    title([syllable,' entropy']);
    %entropy variance
    subtightplot(3,1,3,[0.07 0.05],0.08,0.12);
    sem_pre = nanstderr(pre(:,[3:3:end]),2)';
    sem_post = nanstderr(post(:,[3:3:end]),2)';
    mn_pre = nanmean(pre(:,[3:3:end]),2)';
    mn_post = nanmean(post(:,[3:3:end]),2)';
    plot(hrs,mn_pre,'k','linewidth',2,'marker','o','markersize',4);hold on;
    plot([hrs;hrs],[mn_pre+sem_pre; mn_pre-sem_pre],'k','linewidth',2);hold on;
    plot(hrs,mn_post,'r','linewidth',2,'marker','o','markersize',4);hold on;
    plot([hrs;hrs],[mn_post+sem_post; mn_post-sem_post],'r','linewidth',2);hold on;
    xlabel('Time of day');ylabel('percent change');
    title([syllable,' entropy variance']);
end

%% motif duration

for  n = 1:length(params.findmotif)
    fvfig(n)=figure;
end

for n = 1:length(params.findmotif)
    motif = params.findmotif(n).motif;
    pre = []; post = [];hrs=0:15;
    for i = 1:length(params.trial)
        if ~exist([params.findmotif(n).motifstruct,params.trial(i).name])
            load(['analysis/data_structures/',params.findmotif(n).motifstruct,params.trial(i).name]);
        end
        mt = eval([params.findmotif(n).motifstruct,params.trial(i).name]); 
        tb = jc_tb([mt(:).datenm]',7,0)/3600;
        if strcmp(params.trial(i).condition,params.timeshift{1})
            tb = tb-params.timeshift{2};
        end
        mdur = [mt(:).motifdur];
        mdur = 100*(mdur-mean(mdur))./mean(mdur);
        
        hour = NaN(length(hrs),1);
        for ind = 1:length(hrs)-1
            intv = find(tb>=hrs(ind) & tb<hrs(ind+1));   
            if length(intv) >= 15
                hour(ind) = mean(mdur(intv));
            else
                continue
            end
        end
        if strcmp(params.trial(i).condition,'pre')
            pre = [pre hour];
        else
            post = [post hour];
        end
    end
    figure(fvfig(n));hold on;
    sem_pre = nanstderr(pre,2)';
    sem_post = nanstderr(post,2)';
    mn_pre = nanmean(pre,2)';
    mn_post = nanmean(post,2)';
    plot(hrs,mn_pre,'k','linewidth',2,'marker','o','markersize',4);hold on;
    plot([hrs;hrs],[mn_pre+sem_pre; mn_pre-sem_pre],'k','linewidth',2);hold on;
    plot(hrs,mn_post,'r','linewidth',2,'marker','o','markersize',4);hold on;
    plot([hrs;hrs],[mn_post+sem_post; mn_post-sem_post],'r','linewidth',2);hold on;
    xlabel('Time of day');ylabel('percent change');
    title([motif,' motif duration']);
end
