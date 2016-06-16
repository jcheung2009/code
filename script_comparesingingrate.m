%plot singing rate trajectories for saline and naspm days, pooled, exclude,
%average excludes bins with 0 songs 

%pooling saline days
ff = load_batchf('batchnaspm');
ff2 = load_batchf('batchsal');

tb_sal = [];
for i = 1:2:length(ff)
    load(['analysis/data_structures/bout_',ff(i).name]);
    fvsal = eval(['bout_',ff(i).name]);
    tb_sal = [tb_sal; jc_tb([fvsal(:).datenm]',7,0)];
end

for i = 1:length(ff2);
    load(['analysis/data_structures/bout_',ff2(i).name]);
    fvsal = eval(['bout_',ff2(i).name]);
    tb_sal = [tb_sal; jc_tb([fvsal(:).datenm]',7,0)];
end

mintm = min(tb_sal);
maxtm = max(tb_sal);
numseconds = maxtm-mintm;
timewindow = 3600;
jogsize = 900;
numtimewindows = floor(numseconds/jogsize)-(timewindow/jogsize)/2;
singingrate_sal = [];
for i = 1:2:length(ff)
    load(['analysis/data_structures/bout_',ff(i).name]);
    fvsal = eval(['bout_',ff(i).name]);
    tb = jc_tb([fvsal(:).datenm]',7,0);
    
    timept1 = mintm; 
    timebase_sal = [];
    numsongs = [];
    for ii = 1:numtimewindows
        timept2 = timept1+timewindow;
        ind = find(tb >= timept1 & tb < timept2);
        numsongs = [numsongs; length(ind)];
        timebase_sal = [timebase_sal; timept1+jogsize];
        timept1 = timept1+jogsize;
    end
    
    singingrate_sal = [singingrate_sal numsongs];
end

for i = 1:length(ff2)
    load(['analysis/data_structures/bout_',ff2(i).name]);
    fvsal = eval(['bout_',ff2(i).name]);
    tb = jc_tb([fvsal(:).datenm]',7,0);
    
    timept1 = mintm; 
    timebase_sal = [];
    numsongs = [];
    for ii = 1:numtimewindows
        timept2 = timept1+timewindow;
        ind = find(tb >= timept1 & tb < timept2);
        numsongs = [numsongs; length(ind)];
        timebase_sal = [timebase_sal; timept1+jogsize];
        timept1 = timept1+jogsize;
    end
    
    singingrate_sal = [singingrate_sal numsongs];
end

singingrate_sal(find(singingrate_sal == 0)) = NaN;

%pooling drug days
tb_cond = [];
for i = 1:4:length(ff)
    load(['analysis/data_structures/bout_',ff(i+2).name]);
    if ~isempty(strfind(['bout_',ff(i+2).name],'naspm'))
       fvnaspm = eval(['bout_',ff(i+2).name]);
       tb_cond = [tb_cond; jc_tb([fvnaspm(:).datenm]',7,0)];
    else
       fviem = eval(['bout_',ff(i+2).name]);
       tb_cond = [tb_cond; jc_tb([fviem(:).datenm]',7,0)];
    end
end
mintm = min(tb_cond);
maxtm = max(tb_cond);
numseconds = maxtm-mintm;
timewindow = 1800;
jogsize = 900;
numtimewindows = 2*floor(numseconds/timewindow)-1;
singingrate_iem = [];singingrate_naspm = [];
for i = 1:4:length(ff)
    load(['analysis/data_structures/bout_',ff(i+2).name]);
    
    if ~isempty(strfind(['bout_',ff(i+2).name],'naspm'))
       fvnaspm = eval(['bout_',ff(i+2).name]);
       tb = jc_tb([fvnaspm(:).datenm]',7,0); 
    else
       fviem = eval(['bout_',ff(i+2).name]);
       tb = jc_tb([fviem(:).datenm]',7,0);
    end
    
    timept1 = mintm; 
    timebase_cond = [];
    numsongs = [];
    for ii = 1:numtimewindows
        timept2 = timept1+timewindow;
        ind = find(tb >= timept1 & tb < timept2);
        numsongs = [numsongs; length(ind)];
        timebase_cond = [timebase_cond; timept1+jogsize];
        timept1 = timept1+jogsize;
    end
    
    if ~isempty(strfind(['bout_',ff(i+2).name],'naspm'))
        singingrate_naspm = [singingrate_naspm numsongs];
    else
        singingrate_iem = [singingrate_iem numsongs];
    end
end

singingrate_naspm(find(singingrate_naspm == 0)) = NaN;
singingrate_iem(find(singingrate_iem == 0)) = NaN;

%plot average singing rate trajectories for saline and drug
if ~isempty(singingrate_naspm) & ~isempty(singingrate_iem)
    figure;subtightplot(3,1,1,[0.12 0.08],0.08,0.08);hold on;
    createPatches(timebase_sal/3600,nanmean(singingrate_sal,2),0.125,'k',0.7);hold on;
    createPatches(timebase_cond/3600,nanmean(singingrate_naspm,2),0.125,'r',0.7);hold on;
    xlabel('Hours since 7 AM');
    ylabel('Number of songs per half hour');
    title('Average NASPM singing rate trajectory');
    set(gca,'fontweight','bold');
    
    subtightplot(3,1,2,[0.12 0.08],0.08,0.08);hold on;
    createPatches(timebase_sal/3600,nanmean(singingrate_sal,2),0.125,'k',0.7);hold on;
    createPatches(timebase_cond/3600,nanmean(singingrate_iem,2),0.125,'r',0.7);hold on;
    xlabel('Hours since 7 AM');
    ylabel('Number of songs per half hour');
    title('Average IEM singing rate trajectory');
    set(gca,'fontweight','bold');
    
    subtightplot(3,1,3,[0.12 0.08],0.08,0.08);hold on;
elseif ~isempty(singingrate_naspm) & isempty(singingrate_iem)
    figure;subtightplot(2,1,1,[0.12 0.08],0.08,0.08);hold on;
    createPatches(timebase_sal/3600,nanmean(singingrate_sal,2),0.125,'k',0.7);hold on;
    createPatches(timebase_cond/3600,nanmean(singingrate_naspm,2),0.125,'r',0.7);hold on;
    xlabel('Hours since 7 AM');
    ylabel('Number of songs per half hour');
    title('Average NASPM singing rate trajectory');
    set(gca,'fontweight','bold');
    
    subtightplot(2,1,2,[0.12 0.08],0.08,0.08);hold on;
elseif isempty(singingrate_naspm) & ~isempty(singingrate_iem)
    figure;subtightplot(2,1,1,[0.12 0.08],0.08,0.08);hold on;
    createPatches(timebase_sal/3600,nanmean(singingrate_sal,2),0.125,'k',0.7);hold on;
    createPatches(timebase_cond/3600,nanmean(singingrate_iem,2),0.125,'r',0.7);hold on;
    xlabel('Hours since 7 AM');
    ylabel('Number of songs per half hour');
    title('Average IEM singing rate trajectory');
    set(gca,'fontweight','bold');
    
    subtightplot(2,1,2,[0.12 0.08],0.08,0.08);hold on;
end

%distribution of number of songs/half hour 
if (~isempty(singingrate_naspm) & ~isempty(singingrate_iem)) 
    subtightplot(3,1,3,[0.12 0.08],0.08,0.08);hold on;
    
    singingrate_sal = singingrate_sal(:);
    singingrate_sal = singingrate_sal(~isnan(singingrate_sal));
    singingrate_naspm = singingrate_naspm(:);
    singingrate_naspm = singingrate_naspm(~isnan(singingrate_naspm));
    minval = min([singingrate_sal; singingrate_naspm]);
    maxval = max([singingrate_sal; singingrate_naspm]);

    [n b] = hist(singingrate_sal,[minval:1:maxval]);
    createPatches(b,n/sum(n),0.5,'k',0.7);hold on;
    [n b] = hist(singingrate_naspm,[minval:1:maxval]);
    createPatches(b,n/sum(n),0.5,'r',0.7);hold on;
    xlabel('Number of songs per half hour');
    ylabel('Probability');
    [h p ci stats] = ttest2(singingrate_sal,singingrate_naspm,'vartype','unequal');
    str = {['NASPM'],['t=',num2str(stats.tstat)],['p=',num2str(p)]};
    title(str);
    set(gca,'fontweight','bold');
elseif (~isempty(singingrate_naspm) & isempty(singingrate_iem))
    subtightplot(2,1,2,[0.12 0.08],0.08,0.08);hold on;
    singingrate_sal = singingrate_sal(:);
    singingrate_sal = singingrate_sal(~isnan(singingrate_sal));
    singingrate_naspm = singingrate_naspm(:);
    singingrate_naspm = singingrate_naspm(~isnan(singingrate_naspm));
    minval = min([singingrate_sal; singingrate_naspm]);
    maxval = max([singingrate_sal; singingrate_naspm]);

    [n b] = hist(singingrate_sal,[minval:1:maxval]);
    createPatches(b,n/sum(n),0.5,'k',0.7);hold on;
    [n b] = hist(singingrate_naspm,[minval:1:maxval]);
    createPatches(b,n/sum(n),0.5,'r',0.7);hold on;
    xlabel('Number of songs per half hour');
    ylabel('Probability');
    [h p ci stats] = ttest2(singingrate_sal,singingrate_naspm,'vartype','unequal');
    str = {['NASPM'],['t=',num2str(stats.tstat)],['p=',num2str(p)]};
    title(str);
    set(gca,'fontweight','bold');
elseif isempty(singingrate_naspm) & ~isempty(singingrate_iem)
    singingrate_sal = singingrate_sal(:);
    singingrate_sal = singingrate_sal(~isnan(singingrate_sal));
    singingrate_iem = singingrate_iem(:);
    singingrate_iem = singingrate_iem(~isnan(singingrate_iem));
    minval = min([singingrate_sal; singingrate_iem]);
    maxval = max([singingrate_sal; singingrate_iem]);

    subtightplot(2,1,2,[0.12 0.08],0.08,0.08);hold on;
    [n b] = hist(singingrate_sal,[minval:1:maxval]);
    createPatches(b,n/sum(n),0.5,'k',0.7);hold on;
    [n b] = hist(singingrate_iem,[minval:1:maxval]);
    createPatches(b,n/sum(n),0.5,'r',0.7);hold on;
    xlabel('Number of songs per half hour');
    ylabel('Probability');
    [h p ci stats] = ttest2(singingrate_sal,singingrate_iem,'vartype','unequal');
    str = {['IEM'],['t=',num2str(stats.tstat)],['p=',num2str(p)]};
    title(str);
    set(gca,'fontweight','bold');
end

meansingingrate.saline = mean(singingrate_sal);
if ~isempty(singingrate_naspm)
    meansingingrate.naspm = mean(singingrate_naspm);
end
if ~isempty(singingrate_iem)
    singingrate_iem = singingrate_iem(:);
    singingrate_iem = singingrate_iem(~isnan(singingrate_iem));
    meansingingrate.iem = mean(singingrate_iem);
end



