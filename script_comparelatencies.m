%plot time course of pitch, volume, and acorr changes
shiftsal = 0;
ff = load_batchf('batch2');
if exist('naspmtreatmenttime')
    ff2 = load_batchf('treatmenttime');
else
    ff2 = '';
end

syllables = {'A','B','D'};
motif = 'bcd';


fv_runavg = struct();
vol_runavg = struct();
motif_runavg = struct();
singingrate_runavg = struct();
trialcnt = 1;


for i = 1:4:length(ff)
    
    fv_cond_avg = {};
    vol_cond_avg = {};
    motif_cond_avg = {};
    singingrate_cond_avg = {};
    
    load(['analysis/data_structures/motif_',motif,'_',ff(i+1).name]);
    load(['analysis/data_structures/motif_',motif,'_',ff(i+2).name]);
    cmd3 = ['motif_sal = motif_',motif,'_',ff(i+1).name,';'];
    cmd4 = ['motif_cond = motif_',motif,'_',ff(i+2).name,';'];
    eval(cmd3);
    eval(cmd4);    
    
    
    acorr_sal = [motif_sal(:).firstpeakdistance]';
    acorr_cond = [motif_cond(:).firstpeakdistance]';
    acorr = [acorr_sal; acorr_cond];
    acorr = 100*((acorr-nanmean(acorr_sal))./nanmean(acorr_sal));
    
    tb_sal = jc_tb([motif_sal(:).datenm]',7,0);
    tb_cond = jc_tb([motif_cond(:).datenm]',7,0);
    if shiftsal == 1
        tb_sal = tb_sal-(24*3600);
        numseconds = (48*3600);
        timept1 = 0-(24*3600);
    else
        numseconds = (14*3600);
        timept1 = 0;
    end
    tb = [tb_sal; tb_cond];

    jogsize = 900;%15 mins
    windowsize = 1800;%half hour
    numtimewindows = 2*floor(numseconds/windowsize)-1;
    run_avg_m = [];
    run_avg_s = [];
    timebase = [];
    for p = 1:numtimewindows
        timept2 = timept1 + windowsize;
        ind = find(tb>= timept1 & tb < timept2);
        run_avg_m = [run_avg_m; timept1+jogsize nanmean([acorr(ind)])];
        run_avg_s = [run_avg_s; timept1+jogsize length(ind)*2]; 
        timebase = [timebase;timept1+jogsize];
        timept1 = timept1+jogsize;
    end
    run_avg_m(:,1) = run_avg_m(:,1)/3600;
    srind = find(run_avg_s(:,1) <= tb_sal(end));
    run_avg_s(:,2) = (run_avg_s(:,2)-mean(run_avg_s(srind,2)))/mean(run_avg_s(srind,2));
    run_avg_s(:,1) = run_avg_s(:,1)/3600;
    motif_cond_avg = [motif_cond_avg; {run_avg_m}];
    singingrate_cond_avg = [singingrate_cond_avg; {run_avg_s}];
   
    for ii = 1:length(syllables)
        load(['analysis/data_structures/fv_syll',syllables{ii},'_',ff(i+1).name]);
        load(['analysis/data_structures/fv_syll',syllables{ii},'_',ff(i+2).name]);

        cmd = ['fv_sal = fv_syll',syllables{ii},'_',ff(i+1).name,';'];
        cmd2 = ['fv_cond = fv_syll',syllables{ii},'_',ff(i+2).name,';'];
        eval(cmd);
        eval(cmd2);

        pitch_sal = [fv_sal(:).mxvals]';
        pitch_cond = [fv_cond(:).mxvals]';
        vol_sal = log10([fv_sal(:).maxvol]');
        vol_cond = log10([fv_cond(:).maxvol]');  
        pitch = [pitch_sal; pitch_cond];
        vol = [vol_sal; vol_cond];

        pitch = 100*((pitch-nanmean(pitch_sal))./nanmean(pitch_sal));
        vol= 100*((abs(vol)-nanmean(abs(vol_sal))))./nanmean(abs(vol_sal));
        
        if shiftsal == 1
            tb = [jc_tb([fv_sal(:).datenm]',7,0)-(24*3600); jc_tb([fv_cond(:).datenm]',7,0)];
            numseconds = 48*3600;
            timept1 = 0-(24*3600);
        else
            tb = [jc_tb([fv_sal(:).datenm]',7,0); jc_tb([fv_cond(:).datenm]',7,0)];
            numseconds = (14*3600);
            timept1 = 0;
        end

        timewindow = 1800; %half hr in seconds
        jogsize = 900;%15 minutes
        numtimewindows = 2*floor(numseconds/timewindow)-1;
        if numtimewindows < 0
            numtimewindows = 1;
        end

        run_avg_fv = [];
        run_avg_vol = [];
        for p = 1:numtimewindows
            timept2 = timept1+timewindow;
            ind = find(tb >= timept1 & tb < timept2);
            run_avg_fv = [run_avg_fv; timept1+jogsize nanmean([pitch(ind)])];
            run_avg_vol = [run_avg_vol;timept1+jogsize nanmean([vol(ind)])];
            timept1 = timept1+jogsize;
        end
        run_avg_fv(:,1) = run_avg_fv(:,1)/3600;
        run_avg_vol(:,1) = run_avg_vol(:,1)/3600;
        fv_cond_avg = [fv_cond_avg; {run_avg_fv}];
        vol_cond_avg = [vol_cond_avg; {run_avg_vol}];
    end
    
    timebase = timebase/3600;

    %get rid of NaN
    fv_cond_avg = cellfun(@(x) x(~isnan(x(:,2)),:),fv_cond_avg,'unif',0);
    vol_cond_avg = cellfun(@(x) x(~isnan(x(:,2)),:),vol_cond_avg,'unif',0);
    motif_cond_avg = cellfun(@(x) x(~isnan(x(:,2)),:),motif_cond_avg,'unif',0);

    %interpolate and average across syllables
    fv = cellfun(@(x) interp1(x(:,1),x(:,2),timebase)',fv_cond_avg,'unif',0)';
    fv = nanmean(cell2mat(fv'),1);
    vol = cellfun(@(x) interp1(x(:,1),x(:,2),timebase)',vol_cond_avg,'unif',0)';
    vol = nanmean(cell2mat(vol'),1);
    mot = cellfun(@(x) interp1(x(:,1),x(:,2),timebase)',motif_cond_avg,'unif',0)';
    mot = nanmean(cell2mat(mot'),1);
    sr = cellfun(@(x) interp1(x(:,1),x(:,2),timebase)',singingrate_cond_avg,'unif',0)';
    sr = nanmean(cell2mat(sr'),1);
    
%     fv = (fv-min(fv))/(max(fv)-min(fv));
%     vol = (vol-min(vol))/(max(vol)-min(vol));
%     mot = (abs(mot)-min(abs(mot)))/(max(abs(mot))-min(abs(mot)));
    
    fv = abs(fv);
    vol = abs(vol);
    mot = abs(mot);
    nanind = find(isnan(fv));
    sr(nanind) = NaN;
    sr = abs(sr);

    figure;hold on;
    ax = gca;
    h1 = plot(ax,timebase,fv,'k','linewidth',2,'marker','o','markersize',6);hold on;
    h2 = plot(ax,timebase,vol,'r','linewidth',2,'marker','o','markersize',6);hold on;
    h3 = plot(ax,timebase,mot,'b','linewidth',2,'marker','o','markersize',6);hold on;
    h4 = plot(ax,timebase,sr,'m','linewidth',2,'marker','o','markersize',6);hold on;
    legend([h1,h2,h3,h4],'pitch','volume','motif acorr','singing rate');
    
    if ~isempty(ff2)
        [a b] = regexp(ff2(i+2).name,'[0-9]+:[0-9]+');
        st_time = ff2(i+2).name(a:b);
        st_time = datevec(st_time,'HH:MM');
        day_st = datevec('07:00','HH:MM');
        st_time = etime(st_time,day_st);
    else
        st_time = tb_cond(1);
    end
    st_time = st_time/3600;
    ylim = get(gca,'ylim');
    plot(ax,st_time,ylim(2),'g*','markersize',12);hold on;
    plot(ax,[st_time st_time],[0 ylim(2)],'g','linewidth',2);hold on;
    set(ax,'fontweight','bold');
    xlabel('Hours since 7 AM');
    ylabel('absolute percent change');
    title(ff(i+2).name,'interpreter','none');
    
    fv_runavg.(['trial',num2str(trialcnt)]) = fv;
    vol_runavg.(['trial',num2str(trialcnt)]) = vol;
    motif_runavg.(['trial',num2str(trialcnt)]) = mot;
    singingrate_runavg.(['trial',num2str(trialcnt)]) = sr;
    trialcnt = trialcnt+1;
    
end

%plot average rate trajectory
load('analysis/data_structures/naspmvolumelatency.mat');
trial = fieldnames(naspmvolumelatency);
newtimebases = [];
for i = 1:length(trial)
    st_time = naspmvolumelatency.(trial{i}).treattime;
    [c ind] = min(abs(timebase-st_time));
    newtimebases = [newtimebases timebase-timebase(ind)];
end

zeroind = [];
for i = 1:length(trial)
    zeroind = [zeroind;find(newtimebases(:,i)==0)];
end
[maxval indbase] = max(zeroind);    

trial = fieldnames(fv_runavg);
for i = 1:length(trial)
    fv_runavg.(trial{i}) = [NaN(maxval-zeroind(i),1);fv_runavg.(trial{i})(1:end-(maxval-zeroind(i)))'];
    vol_runavg.(trial{i}) = [NaN(maxval-zeroind(i),1);vol_runavg.(trial{i})(1:end-(maxval-zeroind(i)))'];
    motif_runavg.(trial{i}) = [NaN(maxval-zeroind(i),1);motif_runavg.(trial{i})(1:end-(maxval-zeroind(i)))'];
    singingrate_runavg.(trial{i}) = [NaN(maxval-zeroind(i),1);singingrate_runavg.(trial{i})(1:end-(maxval-zeroind(i)))'];
end

newtimebase = newtimebases(:,indbase);

figure;hold on;
ax = gca;
h1 = plot(ax,newtimebase,nanmean(struct2array(fv_runavg),2),'k','linewidth',2,...
    'marker','o','markersize',6);hold on;
h2 = plot(ax,newtimebase,nanmean(struct2array(vol_runavg),2),'r','linewidth',2,...
    'marker','o','markersize',6);hold on;
h3 = plot(ax,newtimebase,nanmean(struct2array(motif_runavg),2),'b','linewidth',2,...
    'marker','o','markersize',6);hold on;
h4 = plot(ax,newtimebase,nanmean(struct2array(singingrate_runavg),2),'m','linewidth',2,...
    'marker','o','markersize',6);hold on;
legend([h1,h2,h3,h4],'pitch','volume','motif acorr','singing rate');
title('Average rate trajectory');
xlabel('Hours since treatment time');
ylabel('absolute percent change');
set(ax,'fontweight','bold');

% compute pairwise cross correlation values
crosscorrlatency = {};
for i = 1:length(trial)
    r = corrcoef(fv_runavg.(trial{i}),motif_runavg.(trial{i}),'rows','complete');
    crosscorrlatency.(trial{i}).fv_motif = r(2);
    r = corrcoef(vol_runavg.(trial{i}),motif_runavg.(trial{i}),'rows','complete');
    crosscorrlatency.(trial{i}).vol_motif = r(2);
    r = corrcoef(fv_runavg.(trial{i}),singingrate_runavg.(trial{i}),'rows','complete');
    crosscorrlatency.(trial{i}).fv_singingrate = r(2);
    r = corrcoef(vol_runavg.(trial{i}),singingrate_runavg.(trial{i}),'rows','complete');
    crosscorrlatency.(trial{i}).vol_singingrate = r(2);
end



    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  
    
    