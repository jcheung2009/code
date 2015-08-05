%Here is the data.

strnam=fvmas3;


%first use getvals to set day and 2nd harmonic value for the data

vals=getvals(fvmas3,2,'TRIG');
NN=1
size(vals)

add a column for day.
dayvec=[];
for (ii=1:length(vals))
    dayvec=[dayvec fvmas3(ii).day];
end
vals=[vals dayvec'];



%there were notes 382'b' and then three things out put, time index, the frequency, and whether it triggered or not 
%plots the frequency of the 1st harmonic with the time passed since the
%first song sung
plot(vals(:,1)-fix(vals(1,1)),vals(:,2)/2,'ro')

%to make a histogram
daylist=unique(vals(:,4));
edges=1400:10:1800;
for ii=1:length(daylist)
    ind=find(vals(:,4)==daylist(ii));
    daystats(ii).histvals=histc(vals(ind,2)/2,edges)  
    daystats(ii).day=daylist(ii)
    daystats(ii).mn=mean(vals(ind,2)/2);
    daystats(ii).stdv=std(vals(ind,2)/2);
end

%for each day, plot the mean and standard deviation
meanvec=[];
stdvec=[];
dayvec=[];
for ii=1:length(daylist)
    meanvec=[meanvec daystats(ii).mn];
    stdvec=[stdvec daystats(ii).stdv];
    dayvec=[dayvec daystats(ii).day];
end
figure;errorbar(dayvec, meanvec, stdvec,'+')
    
    