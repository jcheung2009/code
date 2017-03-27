%plot singing rate trajectories for saline and naspm days, pooled, exclude,
%average excludes bins with 0 songs 

%pooling saline days
batchname = 'batchiemapv';
batchname2 = 'batchsal';
ff = load_batchf(batchname);
ff2 = load_batchf(batchname2);
if ~isempty(strfind(batchname,'iem')) & ~isempty(strfind(batchname,'apv'))
    mcolor = 'g';
elseif ~isempty(strfind(batchname,'IEM'))
    mcolor = 'r';
elseif ~isempty(strfind(batchname,'musc'))
    mcolor = 'm';
elseif ~isempty(strfind(batchname,'APV'))
    mcolor = 'g';
end


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
for i = 1:2:length(ff)
    load(['analysis/data_structures/bout_',ff(i+1).name]);
    if ~isempty(strfind(['bout_',ff(i+1).name],'naspm'))
       fvnaspm = eval(['bout_',ff(i+1).name]);
       tb_cond = [tb_cond; jc_tb([fvnaspm(:).datenm]',7,0)];
    else
       fviem = eval(['bout_',ff(i+1).name]);
       tb_cond = [tb_cond; jc_tb([fviem(:).datenm]',7,0)];
    end
end
mintm = min(tb_cond);
maxtm = max(tb_cond);
numseconds = maxtm-mintm;
timewindow = 1800;
jogsize = 900;
numtimewindows = 2*floor(numseconds/timewindow)-1;
singingrate_cond = [];
for i = 1:4:length(ff)
    load(['analysis/data_structures/bout_',ff(i+1).name]);
    fvcond = eval(['bout_',ff(i+1).name]);
    tb = jc_tb([fvcond(:).datenm]',7,0); 
    
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
   
    singingrate_cond = [singingrate_cond numsongs];
   
end

singingrate_cond(find(singingrate_cond == 0)) = NaN;


%plot average singing rate trajectories for saline and drug
figure(18);hold on;subtightplot(3,1,3,[0.12 0.08],0.08,0.08);hold on;
createPatches(timebase_sal/3600,nanmean(singingrate_sal,2),0.125,'k',0.7);hold on;
createPatches(timebase_cond/3600,nanmean(singingrate_cond,2),0.125,mcolor,0.7);hold on;
xlabel('Hours since 7 AM');
ylabel('songs per hour');
title('Average singing rate trajectory');
set(gca,'fontweight','bold');


%distribution of number of songs/half hour 
% if (~isempty(singingrate_naspm) & ~isempty(singingrate_iem)) 
%     subtightplot(3,1,3,[0.12 0.08],0.08,0.08);hold on;
%     
%     singingrate_sal = singingrate_sal(:);
%     singingrate_sal = singingrate_sal(~isnan(singingrate_sal));
%     singingrate_naspm = singingrate_naspm(:);
%     singingrate_naspm = singingrate_naspm(~isnan(singingrate_naspm));
%     minval = min([singingrate_sal; singingrate_naspm]);
%     maxval = max([singingrate_sal; singingrate_naspm]);
% 
%     [n b] = hist(singingrate_sal,[minval:1:maxval]);
%     createPatches(b,n/sum(n),0.5,'k',0.7);hold on;
%     [n b] = hist(singingrate_naspm,[minval:1:maxval]);
%     createPatches(b,n/sum(n),0.5,'r',0.7);hold on;
%     xlabel('Number of songs per half hour');
%     ylabel('Probability');
%     [h p ci stats] = ttest2(singingrate_sal,singingrate_naspm,'vartype','unequal');
%     str = {['NASPM'],['t=',num2str(stats.tstat)],['p=',num2str(p)]};
%     title(str);
%     set(gca,'fontweight','bold');
% elseif (~isempty(singingrate_naspm) & isempty(singingrate_iem))
%     subtightplot(2,1,2,[0.12 0.08],0.08,0.08);hold on;
%     singingrate_sal = singingrate_sal(:);
%     singingrate_sal = singingrate_sal(~isnan(singingrate_sal));
%    eif isempty(singingrate_naspm) & ~isempty(singingrate_iem)
%     singingrate_sal = singingrate_sal(:);
%     singingrate_sal = singingrate_sal(~isnan(singingrate_sal));
%     singingrate_iem = singingrate_iem(:);
%     singingrate_iem = singingrate_iem(~isnan(singingrate_iem));
%     minval = min([singingrate_sal; singingrate_iem]);
%     maxval = max([singingrate_sal; singingrate_iem]);
% 
%     subtightplot(2,1,2,[0.12 0.08],0.08,0.08);hold on;
%     [n b] = hist(singingrate_sal,[minval:1:maxval]);
%     createPatches(b,n/sum(n),0.5,'k',0.7);hold on;
%     [n b] = hist(singingrate_iem,[minval:1:maxval]);
%     createPatches(b,n/sum(n),0.5,'r',0.7);hold on;
%     xlabel('Number of songs per half hour');
%     ylabel('Probability');
%     [h p ci stats] = ttest2(singingrate_sal,singingrate_iem,'vartype','unequal');
%     str = {['IEM'],['t=',num2str(stats.tstat)],['p=',num2str(p)]};
%     title(str);
%     set(gca,'fontweight','bold');
% end
% 
% meansingingrate.saline = mean(singingrate_sal);
% if ~isempty(singingrate_naspm)
%     meansingingrate.naspm = mean(singingrate_naspm);
% end
% if ~isempty(singingrate_iem)
%     singingrate_iem = singingrate_iem(:);
%     singingrate_iem = singingrate_iem(~isnan(singingrate_iem));
%     meansingingrate.iem = mean(singingrate_iem);
% end
% 
%  singingrate_naspm = singingrate_naspm(:);
%     singingrate_naspm = singingrate_naspm(~isnan(singingrate_naspm));
%     minval = min([singingrate_sal; singingrate_naspm]);
%     maxval = max([singingrate_sal; singingrate_naspm]);
% 
%     [n b] = hist(singingrate_sal,[minval:1:maxval]);
%     createPatches(b,n/sum(n),0.5,'k',0.7);hold on;
%     [n b] = hist(singingrate_naspm,[minval:1:maxval]);
%     createPatches(b,n/sum(n),0.5,'r',0.7);hold on;
%     xlabel('Number of songs per half hour');
%     ylabel('Probability');
%     [h p ci stats] = ttest2(singingrate_sal,singingrate_naspm,'vartype','unequal');
%     str = {['NASPM'],['t=',num2str(stats.tstat)],['p=',num2str(p)]};
%     title(str);
%     set(gca,'fontweight','bold');
% elseif isempty(singingrate_naspm) & ~isempty(singingrate_iem)
%     singingrate_sal = singingrate_sal(:);
%     singingrate_sal = singingrate_sal(~isnan(singingrate_sal));
%     singingrate_iem = singingrate_iem(:);
%     singingrate_iem = singingrate_iem(~isnan(singingrate_iem));
%     minval = min([singingrate_sal; singingrate_iem]);
%     maxval = max([singingrate_sal; singingrate_iem]);
% 
%     subtightplot(2,1,2,[0.12 0.08],0.08,0.08);hold on;
%     [n b] = hist(singingrate_sal,[minval:1:maxval]);
%     createPatches(b,n/sum(n),0.5,'k',0.7);hold on;
%     [n b] = hist(singingrate_iem,[minval:1:maxval]);
%     createPatches(b,n/sum(n),0.5,'r',0.7);hold on;
%     xlabel('Number of songs per half hour');
%     ylabel('Probability');
%     [h p ci stats] = ttest2(singingrate_sal,singingrate_iem,'vartype','unequal');
%     str = {['IEM'],['t=',num2str(stats.tstat)],['p=',num2str(p)]};
%     title(str);
%     set(gca,'fontweight','bold');
% end
% 
% meansingingrate.saline = mean(singingrate_sal);
% if ~isempty(singingrate_naspm)
%     meansingingrate.naspm = mean(singingrate_naspm);
% end
% if ~isempty(singingrate_iem)
%     singingrate_iem = singingrate_iem(:);
%     singingrate_iem = singingrate_iem(~isnan(singingrate_iem));
%     meansingingrate.iem = mean(singingrate_iem);
% end
% 
% 
% 
