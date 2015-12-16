function [fv v et pcv] = jc_plotfvsummary2(fv_syll_sal, fv_syll_cond, marker,linecolor,xpt);
%fv_syll from jc_findwnote5
%for blocked design to compare matched time
%fits logistic function to pitch change and takes top 80% points and compares with matched
%time window in saline


if iscell(fv_syll_sal)
    tb_sal=[];
    fv_syll = [];
    for i = 1:length(fv_syll_sal)
        tb_sal = [tb_sal; jc_tb([fv_syll_sal{i}(:).datenm]',7,0)];
        fv_syll = [fv_syll fv_syll_sal{i}];
    end
    fv_syll_sal = fv_syll;
end
if iscell(fv_syll_cond)
    tb_cond=[];
    fv_syll = [];
    for i = 1:length(fv_syll_cond)
        tb_cond = [tb_cond; jc_tb([fv_syll_cond{i}(:).datenm]',7,0)];
        fv_syll =[fv_syll fv_syll_cond{i}];
    end
    fv_syll_cond = fv_syll;
end

pitch = [fv_syll_sal(:).mxvals];
vol = log([fv_syll_sal(:).maxvol]);
ent = [fv_syll_sal(:).spent];
if ~iscell(fv_syll_sal) 
    tb_sal = jc_tb([fv_syll_sal(:).datenm]',7,0);
end
if ~iscell(fv_syll_cond)
    tb_cond = jc_tb([fv_syll_cond(:).datenm]',7,0);
end

fignum = input('figure number for checking outliers:');
figure(fignum);
plot(tb_sal,pitch,'k.');
removeoutliers = input('remove outliers (y/n):','s');
while removeoutliers == 'y'
    cla;
    nstd = input('nstd:');
    removeind = jc_findoutliers(pitch',nstd);
    pitch(removeind) = [];
    vol(removeind) = [];
    ent(removeind) = [];
    tb_sal(removeind) = [];
    plot(tb_sal,pitch,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla

plot(tb_sal,vol,'k.');
removeoutliers = input('remove outliers:','s');
while removeoutliers == 'y'
    cla;
    nstd = input('nstd:');
    removeind = jc_findoutliers(vol',nstd);
    pitch(removeind) = [];
    vol(removeind) = [];
    ent(removeind) = [];
    tb_sal(removeind) = [];
    plot(tb_sal,vol,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla

plot(tb_sal,ent,'k.');
removeoutliers = input('remove outliers:','s');
while removeoutliers == 'y'
    cla;
    nstd = input('nstd:');
    removeind = jc_findoutliers(ent',nstd);
    pitch(removeind) = [];
    vol(removeind) = [];
    ent(removeind) = [];
    tb_sal(removeind) = [];
    plot(tb_sal,ent,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla

pitch2 = [fv_syll_cond(:).mxvals];
vol2 = log([fv_syll_cond(:).maxvol]);
ent2 = [fv_syll_cond(:).spent];

plot(tb_cond,pitch2,'k.');
removeoutliers = input('remove outliers:','s');
while removeoutliers == 'y'
    cla;
    nstd = input('nstd:');
    removeind = jc_findoutliers(pitch2',nstd);
    pitch2(removeind) = [];
    vol2(removeind) = [];
    ent2(removeind) = [];
    tb_cond(removeind) = [];
    plot(tb_cond,pitch2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla

plot(tb_cond,vol2,'k.');
removeoutliers = input('remove outliers:','s');
while removeoutliers == 'y'
    cla;
    nstd = input('nstd:');
    removeind = jc_findoutliers(vol2',nstd);
    pitch2(removeind) = [];
    vol2(removeind) = [];
    ent2(removeind) = [];
    tb_cond(removeind) = [];
    plot(tb_cond,vol2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla

plot(tb_cond,ent2,'k.');
removeoutliers = input('remove outliers:','s');
while removeoutliers == 'y'
    cla;
    nstd = input('nstd:');
    removeind = jc_findoutliers(ent2',nstd);
    pitch2(removeind) = [];
    vol2(removeind) = [];
    ent2(removeind) = [];
    tb_cond(removeind) = [];
    plot(tb_cond,ent2,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
end
cla;

if ~isempty(find(isnan(pitch2)))
    removeind = find(isnan(pitch2));
    pitch2(removeind) = [];
    vol2(removeind) = [];
    ent2(removeind) = [];
    tb_cond(removeind) = [];
elseif ~isempty(find(isnan(vol2)))
    removeind = find(isnan(vol2));
    pitch2(removeind) = [];
    vol2(removeind) = [];
    ent2(removeind) = [];
    tb_cond(removeind) = [];
elseif ~isempty(find(isnan(ent2)))
    removeind = find(isnan(ent2));
    pitch2(removeind) = [];
    vol2(removeind) = [];
    ent2(removeind) = [];
    tb_cond(removeind) = [];
end

if ~isempty(find(isnan(pitch)))
    removeind = find(isnan(pitch));
    pitch(removeind) = [];
    vol(removeind) = [];
    ent(removeind) = [];
    tb_sal(removeind) = [];
elseif ~isempty(find(isnan(vol)))
    removeind = find(isnan(vol));
    pitch(removeind) = [];
    vol(removeind) = [];
    ent(removeind) = [];
    tb_sal(removeind) = [];
elseif ~isempty(find(isnan(ent)))
    removeind = find(isnan(ent));
    pitch(removeind) = [];
    vol(removeind) = [];
    ent(removeind) = [];
    tb_sal(removeind) = [];
end



%fit logistic to pitch 
pitch2n = (pitch2-min(pitch2))/(max(pitch2)-min(pitch2));%rescale to be between 0 and 1
tb_condn = tb_cond - mean(tb_cond); % center at 0
tb_condn = tb_condn/3600; %rescaling 
sigfunc = @(A,x)(A(4)+(A(1)./(A(2)+exp(-A(3).*x))));
A0 = ones(4,1);
A_fit = nlinfit(tb_condn,pitch2n',sigfunc,A0);
plot(tb_condn,pitch2n,'k.');hold on;
plot(tb_condn,sigfunc(A_fit,tb_condn),'g');
goodfit = input('is the fit to pitch good?','s');
if goodfit == 'n'
    debut = input('dbug?:','s');
    if debut == 'y'
        error('bad fit, change sigfunc');
    else
        timewindow = input('how many hours from the end:');
        ind = find(tb_cond>= tb_cond(end)-timewindow*3600 &tb_cond <=tb_cond(end));
        tb_cond_sub = tb_cond(ind);
        indsal = find(tb_sal >= tb_cond_sub(1) & tb_sal <= tb_cond_sub(end));
    end
else
    cla;
    predy = sigfunc(A_fit,tb_condn);
    predy = (predy-min(predy))/(max(predy)-min(predy)); 
    ind = find(predy >= 0.8);
    tb_cond_sub = tb_cond(ind);%subset of condition points that you will match time with saline
    indsal = find(tb_sal>=tb_cond_sub(1) & tb_sal <= tb_cond_sub(end)); 
end

if length(ind) < 20 | length(indsal) < 20
    return
end
% percent change
% pitchn = pitch2(ind)./mean(pitch(indsal));
% voln = vol2(ind)./mean(vol(indsal));
% entn = ent2(ind)./mean(ent(indsal));    

% z-score
pitchn = (pitch2(ind)-mean(pitch(indsal)))./std(pitch(indsal));
voln = (vol2(ind)-mean(vol(indsal)))./std(vol(indsal));
entn = (ent2(ind)-mean(ent(indsal)))./std(ent(indsal));

fignum = input('figure for all normalized data:');
figure(fignum);hold on;

subtightplot(4,1,1,0.07,0.07,0.1);hold on;
[hi lo mn1] = mBootstrapCI(pitchn);
jitter = (-1+2*rand)/4;
xpt = xpt+jitter;
plot(xpt,mn1,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
set(gca,'xlim',[0 4],'xtick',[0.5,1.5,2.5,3.5],'xticklabel',...
    {'probe 1','probe 2','probe 3','probe 4'});
ylabel('Pitch change');
title('Change in pitch relative to saline');
fv = mn1;

subtightplot(4,1,2,0.07,0.07,0.1);hold on;
[hi lo mn1] = mBootstrapCI(voln);
plot(xpt,mn1,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
set(gca,'xlim',[0 4],'xtick',[0.5,1.5,2.5,3.5],'xticklabel',...
    {'probe 1','probe 2','probe 3','probe 4'});
ylabel('Volume change');
title('Change in volume relative to saline');
v = mn1;

subtightplot(4,1,3,0.07,0.07,0.1);hold on;
[hi lo mn1] = mBootstrapCI(entn);
plot(xpt,mn1,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
set(gca,'xlim',[0 4],'xtick',[0.5,1.5,2.5,3.5],'xticklabel',...
    {'probe 1','probe 2','probe 3','probe 4'});
ylabel('Entropy change');
title('Change in entropy relative to saline');
et = mn1;


subtightplot(4,1,4,0.07,0.07,0.1);hold on;
mn1 = mBootstrapCI_CV(pitch(indsal));
[mn2 hi lo] = mBootstrapCI_CV(pitch2(ind));
mn3 = mn2/mn1;
hi = mn3+((hi-mn2)/mn1);
lo = mn3-((mn2-lo)/mn1);
plot(xpt,mn3,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
set(gca,'xlim',[0 4],'xtick',[0.5,1.5,2.5,3.5],'xticklabel',...
    {'probe 1','probe 2','probe 3', 'probe 4'});
ylabel('Pitch CV change');
title('Change in pitch CV relative to saline');
pcv = mn3;




