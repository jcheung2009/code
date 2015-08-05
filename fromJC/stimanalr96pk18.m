%master script, load and combine various fvs, from postscreen./50microstim,
%and 10 microstim

pathvl{1}='prestim/batchcomb.keep.rand.mat'
pathvl{2}='stim/batch.catch.mat'
pathvl{3}='stim/batch.keep.catch.mat'
fvcomb=[];


%stimstart 1/30 12pm

%2/2 1355 - switch to make template earlier.
%2/5 1635 - switch to make cutoff higher.

clear switchdts
switchdt{1}='2007-02-04 12:50:00';
switchdt{2}='2007-02-05 18:00:00';
switchdt{3}='2007-02-07 12:00:00';
switchdt{4}='2007-02-22 17:00:00';

for ii=1:length(switchdt)
     switchdts(ii)=datenum(switchdt{ii},'yyyy-mm-dd HH:MM:SS');
end
%combine the fvs and plot.

for ii=1:length(pathvl)
    strcmd=['load ' pathvl{ii} ]
    eval(strcmd);
    fvtmp=fv;
    fvcomb=[fvcomb fvtmp];
end
 vals=getvals(fvcomb,2,'TRIG');
%now make a basic plot of all the fvs.

vlot=reduce_dates(vals(:,1),floor(min(vals(:,1))));
switchdays=reduce_dates(switchdts,floor(min(vals(:,1))));

figure

%plot(vlot, vals(:,2),'.')
%box off;
hold on;
%overlay mean and standard deviation
days=unique(vlot);

for ii=1:length(days)
    indtmp=find(vlot==days(ii))
    mnvl(ii)=mean(vals(indtmp,2))
    stdv(ii)=std(vals(indtmp,2))
%to add means and standard deviations.
end

figure

x=[switchdays switchdays];
y=[3700 3900];
plot(x,y,'r','Linewidth',3)

hold on;
errorbar(days, mnvl, stdv,'k+','Linewidth',3)





%plotting hit rates
%distributions of hits and misses

indhit=find(vals(:,3)==1)
indmiss=find(vals(:,3)==0)
daystm=unique(vlot(indhit));

for ii=1:length(daystm)
    indyht=find(vlot(indhit)==daystm(ii));
    indyms=find(vlot(indmiss)==daystm(ii));
    htrt(ii)=length(indyht)/(length(indyms)+length(indyht));
end
figure
plot(daystm,htrt,'o','Linewidth',5);
hold on;
y=[.8 1]
plot(x,y,'r','Linewidth',3)


%probability of transition
acnt=0;
endcnt=0;
concnt=0;
bcnt=0;
for ntcnt=1:length(fv)
    if(fv(ntcnt).trans=='-a')
        acnt=acnt+1;
    elseif (fv(ntcnt).trans=='nd')
            endcnt=endcnt+1;
    elseif (fv(ntcnt).trans=='ii')
        endcnt=endcnt+1;
    elseif (fv(ntcnt).trans(1)=='b'|fv(ntcnt).trans(2)=='b')
        bcnt=bcnt+1;
    else
        concnt=concnt+1;
    end
end
            
%total number of hits    
figure
x=[switchdays switchdays]
y=[1000 3000]
plot(x,y,'r', 'Linewidth',3)
hold on;
newdt=datevec(vals(:,1));
plot(newdt(:,3), vals(:,3),'o')

