config;
batch = 'batch';

%load correlation data in summary table from each bird
ff = load_batchf(batch);
pitchvolsylldur_corrsummary = table([],[],[],[],[],[],[],[],[],'VariableNames',...
    {'birdname','syllID','condition','pitchvol','pitchsylldur',...
    'volsylldur','pitchvol_shuff','pitchsylldur_shuff','volsylldur_shuff'});
pitchvolsylldur_data = table([],[],[],[],[],[],'VariableNames',{'birdname','syllID',...
    'condition','pitch','volume','sylldur'});
for i = 1:length(ff)
    if ~exist(ff(i).name)
        load([params.subfolders{1},'/',ff(i).name,...
            '/analysis/data_structures/pitchvolsylldur_correlation_',ff(i).name]);
    else
        try 
            load([ff(i).name,...
                '/analysis/data_structures/pitchvolsylldur_correlation_',ff(i).name]);
        catch
            continue
        end
    end
    pitchvolsylldur_corrsummary = [pitchvolsylldur_corrsummary; pitchvolsylldur_corr];
    pitchvolsylldur_data = [pitchvolsylldur_data; pitchvolsylldur_tbl];
end
    
%% test significance of frequency of correlations for pitch vs volume
aph = 0.01;ntrials=1000;
bardata = NaN(2,4);
significancelevel = NaN(1,8);
%pitch vs vol (naspm baseline)
ind = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline'));
negcorr = length(find(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1)< 0));
poscorr = length(find(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1)> 0));
sigcorr = length(find(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolsylldur_corrsummary(ind,:).pitchvol_shuff{:,1}];
shuffpval =  [pitchvolsylldur_corrsummary(ind,:).pitchvol_shuff{:,2}];
randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);
significancelevel(1:2) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

figure;subplot(2,4,1);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
% text(0,1,{['total cases:',num2str(numcases)];...
%     ['proportion significant cases:',num2str(sigcorr/numcases)];...
%     ['proportion negative:',num2str(negcorr/numcases)];...
%     ['proportion positive:',num2str(poscorr/numcases)];...
%     ['p(t)=',num2str(p)];['p(ks)=',num2str(p2)];...
%     ['p(sig)=',num2str(p4)];['p(pos)=',num2str(p5)];['p(neg)=',num2str(p6)];...
%     ['p(neg-pos)=',num2str(p3)]},'units','normalized','verticalalignment','top');
xlabel('correlation');ylabel('probability');title('pitch vs volume (saline)');
bardata(1,1:2) = [poscorr/numcases,negcorr/numcases];

%pitch vs vol (treatment)
ind2 = find(strcmp(pitchvolsylldur_corrsummary.condition,'naspm'));
negcorr = length(find(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1)< 0));
poscorr = length(find(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1)> 0));
sigcorr = length(find(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,2)<= 0.05));
numcases = length(ind2);

shuffcorr =  [pitchvolsylldur_corrsummary(ind2,:).pitchvol_shuff{:,1}];
shuffpval =  [pitchvolsylldur_corrsummary(ind2,:).pitchvol_shuff{:,2}];
randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);
significancelevel(3:4) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subplot(2,4,2);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor','r','linewidth',2,'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1)),0,'r^','markersize',8,'linewidth',2);

[h p] = ttest2(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
% text(0,1,{['total cases:',num2str(numcases)];...
%     ['proportion significant cases:',num2str(sigcorr/numcases)];...
%     ['proportion negative:',num2str(negcorr/numcases)];...
%     ['proportion positive:',num2str(poscorr/numcases)];...
%     ['p(t)=',num2str(p)];['p(ks)=',num2str(p2)];...
%     ['p(sig)=',num2str(p4)];['p(pos)=',num2str(p5)];['p(neg)=',num2str(p6)];...
%     ['p(neg-pos)=',num2str(p3)]},'units','normalized','verticalalignment','top');
xlabel('correlation');ylabel('probability');title('pitch vs volume (NASPM)');
bardata(1,3:4) = [poscorr/numcases,negcorr/numcases];

%pitch vs vol (salinectrl baseline)
ind = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline1'));
negcorr = length(find(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1)< 0));
poscorr = length(find(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1)> 0));
sigcorr = length(find(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolsylldur_corrsummary(ind,:).pitchvol_shuff{:,1}];
shuffpval =  [pitchvolsylldur_corrsummary(ind,:).pitchvol_shuff{:,2}];
randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);
significancelevel(5:6) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subplot(2,4,5);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
% text(0,1,{['total cases:',num2str(numcases)];...
%     ['proportion significant cases:',num2str(sigcorr/numcases)];...
%     ['proportion negative:',num2str(negcorr/numcases)];...
%     ['proportion positive:',num2str(poscorr/numcases)];...
%     ['p(t)=',num2str(p)];['p(ks)=',num2str(p2)];...
%     ['p(sig)=',num2str(p4)];['p(pos)=',num2str(p5)];['p(neg)=',num2str(p6)];...
%     ['p(neg-pos)=',num2str(p3)]},'units','normalized','verticalalignment','top');
xlabel('correlation');ylabel('probability');title('pitch vs volume (saline1)');
bardata(2,1:2) = [poscorr/numcases,negcorr/numcases];

%pitch vs vol (salienctrl treatment)
ind2 = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline2'));
negcorr = length(find(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1)< 0));
poscorr = length(find(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1)> 0));
sigcorr = length(find(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,2)<= 0.05));
numcases = length(ind2);

shuffcorr =  [pitchvolsylldur_corrsummary(ind2,:).pitchvol_shuff{:,1}];
shuffpval =  [pitchvolsylldur_corrsummary(ind2,:).pitchvol_shuff{:,2}];
randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);
significancelevel(7:8) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subplot(2,4,6);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);

[h p] = ttest2(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
% text(0,1,{['total cases:',num2str(numcases)];...
%     ['proportion significant cases:',num2str(sigcorr/numcases)];...
%     ['proportion negative:',num2str(negcorr/numcases)];...
%     ['proportion positive:',num2str(poscorr/numcases)];...
%     ['p(t)=',num2str(p)];['p(ks)=',num2str(p2)];...
%     ['p(sig)=',num2str(p4)];['p(pos)=',num2str(p5)];['p(neg)=',num2str(p6)];...
%     ['p(neg-pos)=',num2str(p3)]},'units','normalized','verticalalignment','top');
xlabel('correlation');ylabel('probability');title('pitch vs volume (saline2)');
bardata(2,3:4) = [poscorr/numcases,negcorr/numcases];

subplot(2,4,[3 4 7 8]);hold on;
b = bar(bardata,'facecolor','none','linewidth',2);hold on;
xl = get(gca,'xlim');
plot(xl,[max(significancelevel) max(significancelevel)],'--','color',[0.5 0.5 0.5],'linewidth',2);
xticks([0.8, 1.2, 1.8, 2.2]);
xticklabels({'saline','NASPM','saline1','saline2'});
ylabel('% cases with significant correlations');
    
%% test frequency of correlations for pitch vs sylldur 
aph = 0.01;ntrials=1000;
bardata = NaN(2,4);
significancelevel = NaN(1,8);

%pitch vs sylldur (naspm baseline)
ind = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline'));
negcorr = length(find(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,1)< 0));
poscorr = length(find(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,1)> 0));
sigcorr = length(find(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolsylldur_corrsummary(ind,:).pitchsylldur_shuff{:,1}];
shuffpval =  [pitchvolsylldur_corrsummary(ind,:).pitchsylldur_shuff{:,2}];
randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);
significancelevel(1:2) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

figure;subplot(2,4,1);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
text(0,1,{['total cases:',num2str(numcases)];...
    ['proportion significant cases:',num2str(sigcorr/numcases)];...
    ['proportion negative:',num2str(negcorr/numcases)];...
    ['proportion positive:',num2str(poscorr/numcases)];...
    ['p(t)=',num2str(p)];['p(ks)=',num2str(p2)];...
    ['p(sig)=',num2str(p4)];['p(pos)=',num2str(p5)];['p(neg)=',num2str(p6)];...
    ['p(neg-pos)=',num2str(p3)]},'units','normalized','verticalalignment','top');
xlabel('correlation');ylabel('probability');title('pitch vs sylldur (saline)');
bardata(1,1:2) = [poscorr/numcases,negcorr/numcases];

%pitch vs sylldur (treatment)
ind2 = find(strcmp(pitchvolsylldur_corrsummary.condition,'naspm'));
negcorr = length(find(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,1)< 0));
poscorr = length(find(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,1)> 0));
sigcorr = length(find(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,2)<= 0.05));
numcases = length(ind2);

shuffcorr =  [pitchvolsylldur_corrsummary(ind2,:).pitchsylldur_shuff{:,1}];
shuffpval =  [pitchvolsylldur_corrsummary(ind2,:).pitchsylldur_shuff{:,2}];
randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);
significancelevel(3:4) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subplot(2,4,2);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor','r','linewidth',2,'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,1)),0,'r^','markersize',8,'linewidth',2);

[h p] = ttest2(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
text(0,1,{['total cases:',num2str(numcases)];...
    ['proportion significant cases:',num2str(sigcorr/numcases)];...
    ['proportion negative:',num2str(negcorr/numcases)];...
    ['proportion positive:',num2str(poscorr/numcases)];...
    ['p(t)=',num2str(p)];['p(ks)=',num2str(p2)];...
    ['p(sig)=',num2str(p4)];['p(pos)=',num2str(p5)];['p(neg)=',num2str(p6)];...
    ['p(neg-pos)=',num2str(p3)]},'units','normalized','verticalalignment','top');
xlabel('correlation');ylabel('probability');title('pitch vs sylldur (NASPM)');
bardata(1,3:4) = [poscorr/numcases,negcorr/numcases];

%pitch vs sylldur (salinectrl baseline)
ind = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline1'));
negcorr = length(find(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,1)< 0));
poscorr = length(find(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,1)> 0));
sigcorr = length(find(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolsylldur_corrsummary(ind,:).pitchsylldur_shuff{:,1}];
shuffpval =  [pitchvolsylldur_corrsummary(ind,:).pitchsylldur_shuff{:,2}];
randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);
significancelevel(5:6) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subplot(2,4,5);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
text(0,1,{['total cases:',num2str(numcases)];...
    ['proportion significant cases:',num2str(sigcorr/numcases)];...
    ['proportion negative:',num2str(negcorr/numcases)];...
    ['proportion positive:',num2str(poscorr/numcases)];...
    ['p(t)=',num2str(p)];['p(ks)=',num2str(p2)];...
    ['p(sig)=',num2str(p4)];['p(pos)=',num2str(p5)];['p(neg)=',num2str(p6)];...
    ['p(neg-pos)=',num2str(p3)]},'units','normalized','verticalalignment','top');
xlabel('correlation');ylabel('probability');title('pitch vs sylldur (saline1)');
bardata(2,1:2) = [poscorr/numcases,negcorr/numcases];

%pitch vs sylldur (salienctrl treatment)
ind2 = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline2'));
negcorr = length(find(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,1)< 0));
poscorr = length(find(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,1)> 0));
sigcorr = length(find(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,2)<= 0.05));
numcases = length(ind2);

shuffcorr =  [pitchvolsylldur_corrsummary(ind2,:).pitchsylldur_shuff{:,1}];
shuffpval =  [pitchvolsylldur_corrsummary(ind2,:).pitchsylldur_shuff{:,2}];
randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);
significancelevel(7:8) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subplot(2,4,6);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);

[h p] = ttest2(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
text(0,1,{['total cases:',num2str(numcases)];...
    ['proportion significant cases:',num2str(sigcorr/numcases)];...
    ['proportion negative:',num2str(negcorr/numcases)];...
    ['proportion positive:',num2str(poscorr/numcases)];...
    ['p(t)=',num2str(p)];['p(ks)=',num2str(p2)];...
    ['p(sig)=',num2str(p4)];['p(pos)=',num2str(p5)];['p(neg)=',num2str(p6)];...
    ['p(neg-pos)=',num2str(p3)]},'units','normalized','verticalalignment','top');
xlabel('correlation');ylabel('probability');title('pitch vs sylldur (saline2)');
bardata(2,3:4) = [poscorr/numcases,negcorr/numcases];

subplot(2,4,[3 4 7 8]);hold on;
b = bar(bardata,'facecolor','none','linewidth',2);hold on;
xl = get(gca,'xlim');
plot(xl,[max(significancelevel) max(significancelevel)],'--','color',[0.5 0.5 0.5],'linewidth',2);
xticks([0.8, 1.2, 1.8, 2.2]);
xticklabels({'saline','NASPM','saline1','saline2'});
ylabel('% cases with significant correlations');
%% test frequency of correlations for vol vs sylldur 
aph = 0.01;ntrials=1000;
bardata = NaN(2,4);
significancelevel = NaN(1,8);

%vol vs sylldur (naspm baseline)
ind = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline'));
negcorr = length(find(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1)< 0));
poscorr = length(find(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1)> 0));
sigcorr = length(find(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolsylldur_corrsummary(ind,:).volsylldur_shuff{:,1}];
shuffpval =  [pitchvolsylldur_corrsummary(ind,:).volsylldur_shuff{:,2}];
randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);
significancelevel(1:2) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

figure;subplot(2,4,1);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
% text(0,1,{['total cases:',num2str(numcases)];...
%     ['proportion significant cases:',num2str(sigcorr/numcases)];...
%     ['proportion negative:',num2str(negcorr/numcases)];...
%     ['proportion positive:',num2str(poscorr/numcases)];...
%     ['p(t)=',num2str(p)];['p(ks)=',num2str(p2)];...
%     ['p(sig)=',num2str(p4)];['p(pos)=',num2str(p5)];['p(neg)=',num2str(p6)];...
%     ['p(neg-pos)=',num2str(p3)]},'units','normalized','verticalalignment','top');
xlabel('correlation');ylabel('probability');title('vol vs sylldur (saline)');
bardata(1,1:2) = [poscorr/numcases,negcorr/numcases];

%vol vs sylldur (treatment)
ind2 = find(strcmp(pitchvolsylldur_corrsummary.condition,'naspm'));
negcorr = length(find(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1)< 0));
poscorr = length(find(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1)> 0));
sigcorr = length(find(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,2)<= 0.05));
numcases = length(ind2);

shuffcorr =  [pitchvolsylldur_corrsummary(ind2,:).volsylldur_shuff{:,1}];
shuffpval =  [pitchvolsylldur_corrsummary(ind2,:).volsylldur_shuff{:,2}];
randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);
significancelevel(3:4) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subplot(2,4,2);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor','r','linewidth',2,'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1)),0,'r^','markersize',8,'linewidth',2);

[h p] = ttest2(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
% text(0,1,{['total cases:',num2str(numcases)];...
%     ['proportion significant cases:',num2str(sigcorr/numcases)];...
%     ['proportion negative:',num2str(negcorr/numcases)];...
%     ['proportion positive:',num2str(poscorr/numcases)];...
%     ['p(t)=',num2str(p)];['p(ks)=',num2str(p2)];...
%     ['p(sig)=',num2str(p4)];['p(pos)=',num2str(p5)];['p(neg)=',num2str(p6)];...
%     ['p(neg-pos)=',num2str(p3)]},'units','normalized','verticalalignment','top');
xlabel('correlation');ylabel('probability');title('vol vs sylldur (NASPM)');
bardata(1,3:4) = [poscorr/numcases,negcorr/numcases];

%vol vs sylldur (salinectrl baseline)
ind = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline1'));
negcorr = length(find(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1)< 0));
poscorr = length(find(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1)> 0));
sigcorr = length(find(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolsylldur_corrsummary(ind,:).volsylldur_shuff{:,1}];
shuffpval =  [pitchvolsylldur_corrsummary(ind,:).volsylldur_shuff{:,2}];
randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);
significancelevel(5:6) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subplot(2,4,5);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
% text(0,1,{['total cases:',num2str(numcases)];...
%     ['proportion significant cases:',num2str(sigcorr/numcases)];...
%     ['proportion negative:',num2str(negcorr/numcases)];...
%     ['proportion positive:',num2str(poscorr/numcases)];...
%     ['p(t)=',num2str(p)];['p(ks)=',num2str(p2)];...
%     ['p(sig)=',num2str(p4)];['p(pos)=',num2str(p5)];['p(neg)=',num2str(p6)];...
%     ['p(neg-pos)=',num2str(p3)]},'units','normalized','verticalalignment','top');
xlabel('correlation');ylabel('probability');title('vol vs sylldur (saline1)');
bardata(2,1:2) = [poscorr/numcases,negcorr/numcases];

%vol vs sylldur (salienctrl treatment)
ind2 = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline2'));
negcorr = length(find(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1)< 0));
poscorr = length(find(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,2)<= 0.05 & ...
    pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1)> 0));
sigcorr = length(find(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,2)<= 0.05));
numcases = length(ind2);

shuffcorr =  [pitchvolsylldur_corrsummary(ind2,:).volsylldur_shuff{:,1}];
shuffpval =  [pitchvolsylldur_corrsummary(ind2,:).volsylldur_shuff{:,2}];
randnumsignificant = sum(shuffpval<=0.05,2);    
randpropsignificant = randnumsignificant/size(shuffpval,2);
randpropsignificant_sorted = sort(randpropsignificant);
randnumsignificantnegcorr = sum((shuffpval<=0.05).*(shuffcorr<0),2);
randpropsignificantnegcorr = randnumsignificantnegcorr./size(shuffpval,2);
randpropsignificantnegcorr_sorted = sort(randpropsignificantnegcorr);
randpropsignificantnegcorr_hi = randpropsignificantnegcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);
randpropsignificantposcorr_hi = randpropsignificantposcorr_sorted(ceil(ntrials-(aph*ntrials/2)));
randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);
significancelevel(7:8) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subplot(2,4,6);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);

[h p] = ttest2(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
% text(0,1,{['total cases:',num2str(numcases)];...
%     ['proportion significant cases:',num2str(sigcorr/numcases)];...
%     ['proportion negative:',num2str(negcorr/numcases)];...
%     ['proportion positive:',num2str(poscorr/numcases)];...
%     ['p(t)=',num2str(p)];['p(ks)=',num2str(p2)];...
%     ['p(sig)=',num2str(p4)];['p(pos)=',num2str(p5)];['p(neg)=',num2str(p6)];...
%     ['p(neg-pos)=',num2str(p3)]},'units','normalized','verticalalignment','top');
xlabel('correlation');ylabel('probability');title('vol vs sylldur (saline2)');
bardata(2,3:4) = [poscorr/numcases,negcorr/numcases];

subplot(2,4,[3 4 7 8]);hold on;
b = bar(bardata,'facecolor','none','linewidth',2);hold on;
xl = get(gca,'xlim');
plot(xl,[max(significancelevel) max(significancelevel)],'--','color',[0.5 0.5 0.5],'linewidth',2);
xticks([0.8, 1.2, 1.8, 2.2]);
xticklabels({'saline','NASPM','saline1','saline2'});
ylabel('% cases with significant correlations');

%% plot correlation in saline vs naspm
ind = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline'));
ind2 = find(strcmp(pitchvolsylldur_corrsummary.condition,'naspm'));
pitchvolcorrs_sal = pitchvolsylldur_corrsummary{ind,'pitchvol'}(:,1);
pitchvolcorrs_naspm = pitchvolsylldur_corrsummary{ind2,'pitchvol'}(:,1);
ind = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline1'));
ind2 = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline2'));
pitchvolcorrs_sal1 = pitchvolsylldur_corrsummary{ind,'pitchvol'}(:,1);
pitchvolcorrs_sal2 = pitchvolsylldur_corrsummary{ind2,'pitchvol'}(:,1);
figure;hold on;
plot([1 2],[pitchvolcorrs_sal pitchvolcorrs_naspm],'k','marker','o');hold on;
plot([3 4],[pitchvolcorrs_sal1 pitchvolcorrs_sal2],'k','marker','o');hold on;
xlim([0 5]);refline(0,0);title('pitch vs vol');
ylabel('correlation');xticks([1:4]);xticklabels({'saline','NASPM','saline1','saline2'});

ind = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline'));
ind2 = find(strcmp(pitchvolsylldur_corrsummary.condition,'naspm'));
pitchsylldurcorrs_sal = pitchvolsylldur_corrsummary{ind,'pitchsylldur'}(:,1);
pitchsylldurcorrs_naspm = pitchvolsylldur_corrsummary{ind2,'pitchsylldur'}(:,1);
ind = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline1'));
ind2 = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline2'));
pitchsylldurcorrs_sal1 = pitchvolsylldur_corrsummary{ind,'pitchsylldur'}(:,1);
pitchsylldurcorrs_sal2 = pitchvolsylldur_corrsummary{ind2,'pitchsylldur'}(:,1);
figure;hold on;
plot([1 2],[pitchsylldurcorrs_sal pitchsylldurcorrs_naspm],'k','marker','o');hold on;
plot([3 4],[pitchsylldurcorrs_sal1 pitchsylldurcorrs_sal2],'k','marker','o');hold on;
xlim([0 5]);refline(0,0);title('pitch vs sylldur');
ylabel('correlation');xticks([1:4]);xticklabels({'saline','NASPM','saline1','saline2'});

ind = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline'));
ind2 = find(strcmp(pitchvolsylldur_corrsummary.condition,'naspm'));
volsylldurcorrs_sal = pitchvolsylldur_corrsummary{ind,'volsylldur'}(:,1);
volsylldurcorrs_naspm = pitchvolsylldur_corrsummary{ind2,'volsylldur'}(:,1);
ind = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline1'));
ind2 = find(strcmp(pitchvolsylldur_corrsummary.condition,'saline2'));
volsylldurcorrs_sal1 = pitchvolsylldur_corrsummary{ind,'volsylldur'}(:,1);
volsylldurcorrs_sal2 = pitchvolsylldur_corrsummary{ind2,'volsylldur'}(:,1);
figure;hold on;
plot([1 2],[volsylldurcorrs_sal volsylldurcorrs_naspm],'k','marker','o');hold on;
plot([3 4],[volsylldurcorrs_sal1 volsylldurcorrs_sal2],'k','marker','o');hold on;
xlim([0 5]);refline(0,0);title('vol vs sylldur');
ylabel('correlation');xticks([1:4]);xticklabels({'saline','NASPM','saline1','saline2'});

%% is there an effect of naspm on pitch vs volume? 
%estimate the interaction effect of treatment (naspm or saline ctrl) on
%pitch vs volume
c = unique(pitchvolsylldur_data(:,{'birdname','syllID'}));
naspmbeta = [];salinectrlbeta = [];
for i = 1:height(c)
    %extract data for each syllable for naspm trial
    ind = find(strcmp(pitchvolsylldur_data.birdname,c(i,:).birdname) & ...
        strcmp(pitchvolsylldur_data.syllID,c(i,:).syllID) & ...
        (strcmp(pitchvolsylldur_data.condition,'saline') | ...
        strcmp(pitchvolsylldur_data.condition,'naspm')));
    subset = pitchvolsylldur_data(ind,:);
    formula = 'volume ~ pitch*condition';
    mdl = fitlm(subset,formula);
    naspmbeta = [naspmbeta; mdl.Coefficients{'pitch',{'Estimate','pValue'}} ...
        mdl.Coefficients{'condition_naspm:pitch',{'Estimate','pValue'}}];
    
    %extract data for each syllable in saline ctrl trial
    ind = find(strcmp(pitchvolsylldur_data.birdname,c(i,:).birdname) & ...
        strcmp(pitchvolsylldur_data.syllID,c(i,:).syllID) & ...
        (strcmp(pitchvolsylldur_data.condition,'saline1') | ...
        strcmp(pitchvolsylldur_data.condition,'saline2')));
    subset = pitchvolsylldur_data(ind,:);
    formula = 'volume ~ pitch*condition';
    mdl = fitlm(subset,formula);
    salinectrlbeta = [salinectrlbeta; mdl.Coefficients{'pitch',{'Estimate','pValue'}} ...
        mdl.Coefficients{'condition_saline2:pitch',{'Estimate','pValue'}}];
end
%test if slopes are different
naspmbeta = array2table(naspmbeta,'VariableNames',{'pitch_beta','pitch_pval',...
    'pitchinteraction','pitchinteraction_pval'});
naspmbeta.condition = repmat({'naspm'},height(naspmbeta),1);
salinectrlbeta = array2table(salinectrlbeta,'VariableNames',{'pitch_beta','pitch_pval',...
    'pitchinteraction','pitchinteraction_pval'});
salinectrlbeta.condition = repmat({'saline'},height(naspmbeta),1);
allbetas = [naspmbeta;salinectrlbeta];
formula = 'pitchinteraction ~ pitch_beta*condition';
mdl = fitlm(allbetas,formula);
pVal = mdl.Coefficients{'pitch_beta:condition_saline','pValue'};

%plot effect of treatment on pitch vs volume 
figure;plot(naspmbeta.pitch_beta,naspmbeta.pitchinteraction,'r.','markersize',10);hold on;lsline
plot(salinectrlbeta.pitch_beta,salinectrlbeta.pitchinteraction,'k.','markersize',10);lsline
xlabel('pitch beta');ylabel('interaction effect on pitch');
legend({'naspm','','saline',''});title('pitch vs volume');
text(0,1,['p=',num2str(pVal)],'units','normalized','verticalalignment','top');

%plot pitch vs vol correlation at baseline vs treatment (naspm or saline
%ctrl)
c = unique(pitchvolsylldur_corrsummary(:,{'birdname','syllID'}));
naspmcorr = [];salinectrlcorr= [];
for i = 1:height(c)
    %extract data for each syllable for naspm trial
    ind = find(strcmp(pitchvolsylldur_corrsummary.birdname,c(i,:).birdname) & ...
        strcmp(pitchvolsylldur_corrsummary.syllID,c(i,:).syllID));
    subset = pitchvolsylldur_corrsummary(ind,:);
    
    naspmcorr = [naspmcorr; subset{strcmp(subset.condition,'saline'),'pitchvol'} ...
        subset{strcmp(subset.condition,'naspm'),'pitchvol'}];
    salinectrlcorr = [salinectrlcorr; subset{strcmp(subset.condition,'saline1'),'pitchvol'} ...
        subset{strcmp(subset.condition,'saline2'),'pitchvol'}];
end

%test if slopes are different
naspmcorr = array2table(naspmcorr,'VariableNames',{'baseline_corr','baseline_corr_pval',...
    'treatment_corr','treatment_corr_pval'});
naspmcorr.condition = repmat({'naspm'},height(naspmcorr),1);
salinectrlcorr = array2table(salinectrlcorr,'VariableNames',{'baseline_corr','baseline_corr_pval',...
    'treatment_corr','treatment_corr_pval'});
salinectrlcorr.condition = repmat({'saline'},height(salinectrlcorr),1);
allbetas = [naspmcorr;salinectrlcorr];
formula = 'treatment_corr ~ baseline_corr*condition';
mdl = fitlm(allbetas,formula);
pVal = mdl.Coefficients{'baseline_corr:condition_saline','pValue'};

figure;plot(naspmcorr.baseline_corr,naspmcorr.treatment_corr,'r.','markersize',10);hold on;lsline
plot(salinectrlcorr.baseline_corr,salinectrlcorr.treatment_corr,'k.','markersize',10);hold on;lsline
xlabel('baseline correlation');ylabel('treatment correlation') 
legend({'naspm','','saline',''});title('pitch vs volume');
text(0,1,['p=',num2str(pVal)],'units','normalized','verticalalignment','top');

%% is there an effect of naspm on pitch vs sylldur? 

%estimate the interaction effect of treatment (naspm or saline ctrl) on
%pitch vs sylldur
c = unique(pitchvolsylldur_data(:,{'birdname','syllID'}));
naspmbeta = [];salinectrlbeta = [];
for i = 1:height(c)
    %extract data for each syllable for naspm trial
    ind = find(strcmp(pitchvolsylldur_data.birdname,c(i,:).birdname) & ...
        strcmp(pitchvolsylldur_data.syllID,c(i,:).syllID) & ...
        (strcmp(pitchvolsylldur_data.condition,'saline') | ...
        strcmp(pitchvolsylldur_data.condition,'naspm')));
    subset = pitchvolsylldur_data(ind,:);
    formula = 'sylldur ~ pitch*condition';
    mdl = fitlm(subset,formula);
    naspmbeta = [naspmbeta; mdl.Coefficients{'pitch',{'Estimate','pValue'}} ...
        mdl.Coefficients{'condition_naspm:pitch',{'Estimate','pValue'}}];
    
    %extract data for each syllable in saline ctrl trial
    ind = find(strcmp(pitchvolsylldur_data.birdname,c(i,:).birdname) & ...
        strcmp(pitchvolsylldur_data.syllID,c(i,:).syllID) & ...
        (strcmp(pitchvolsylldur_data.condition,'saline1') | ...
        strcmp(pitchvolsylldur_data.condition,'saline2')));
    subset = pitchvolsylldur_data(ind,:);
    formula = 'sylldur ~ pitch*condition';
    mdl = fitlm(subset,formula);
    salinectrlbeta = [salinectrlbeta; mdl.Coefficients{'pitch',{'Estimate','pValue'}} ...
        mdl.Coefficients{'condition_saline2:pitch',{'Estimate','pValue'}}];
end
%test if slopes are different
naspmbeta = array2table(naspmbeta,'VariableNames',{'pitch_beta','pitch_pval',...
    'pitchinteraction','pitchinteraction_pval'});
naspmbeta.condition = repmat({'naspm'},height(naspmbeta),1);
salinectrlbeta = array2table(salinectrlbeta,'VariableNames',{'pitch_beta','pitch_pval',...
    'pitchinteraction','pitchinteraction_pval'});
salinectrlbeta.condition = repmat({'saline'},height(naspmbeta),1);
allbetas = [naspmbeta;salinectrlbeta];
formula = 'pitchinteraction ~ pitch_beta*condition';
mdl = fitlm(allbetas,formula);
pVal = mdl.Coefficients{'pitch_beta:condition_saline','pValue'};

%plot effect of treatment on pitch vs volume
figure;plot(naspmbeta.pitch_beta,naspmbeta.pitchinteraction,'r.','markersize',10);hold on;lsline
plot(salinectrlbeta.pitch_beta,salinectrlbeta.pitchinteraction,'k.','markersize',10);lsline
xlabel('pitch beta');ylabel('interaction effect on pitch');
legend({'naspm','','saline',''});title('pitch vs sylldur');
text(0,1,['p=',num2str(pVal)],'units','normalized','verticalalignment','top');

%plot pitch vs sylldur correlation at baseline vs treatment (naspm or saline
%ctrl)
c = unique(pitchvolsylldur_corrsummary(:,{'birdname','syllID'}));
naspmcorr = [];salinectrlcorr= [];
for i = 1:height(c)
    %extract data for each syllable for naspm trial
    ind = find(strcmp(pitchvolsylldur_corrsummary.birdname,c(i,:).birdname) & ...
        strcmp(pitchvolsylldur_corrsummary.syllID,c(i,:).syllID));
    subset = pitchvolsylldur_corrsummary(ind,:);
    
    naspmcorr = [naspmcorr; subset{strcmp(subset.condition,'saline'),'pitchsylldur'} ...
        subset{strcmp(subset.condition,'naspm'),'pitchsylldur'}];
    salinectrlcorr = [salinectrlcorr; subset{strcmp(subset.condition,'saline1'),'pitchsylldur'} ...
        subset{strcmp(subset.condition,'saline2'),'pitchsylldur'}];
end

%test if slopes are different
naspmcorr = array2table(naspmcorr,'VariableNames',{'baseline_corr','baseline_corr_pval',...
    'treatment_corr','treatment_corr_pval'});
naspmcorr.condition = repmat({'naspm'},height(naspmcorr),1);
salinectrlcorr = array2table(salinectrlcorr,'VariableNames',{'baseline_corr','baseline_corr_pval',...
    'treatment_corr','treatment_corr_pval'});
salinectrlcorr.condition = repmat({'saline'},height(salinectrlcorr),1);
allbetas = [naspmcorr;salinectrlcorr];
formula = 'treatment_corr ~ baseline_corr*condition';
mdl = fitlm(allbetas,formula);
pVal = mdl.Coefficients{'baseline_corr:condition_saline','pValue'};

figure;plot(naspmcorr.baseline_corr,naspmcorr.treatment_corr,'r.','markersize',10);hold on;lsline
plot(salinectrlcorr.baseline_corr,salinectrlcorr.treatment_corr,'k.','markersize',10);hold on;lsline
xlabel('baseline correlation');ylabel('treatment correlation') 
legend({'naspm','','saline',''});title('pitch vs sylldur');
text(0,1,['p=',num2str(pVal)],'units','normalized','verticalalignment','top');
%% is there an effect of naspm on vol vs sylldur? 

%estimate the interaction effect of treatment (naspm or saline ctrl) on
%vol vs sylldur
c = unique(pitchvolsylldur_data(:,{'birdname','syllID'}));
naspmbeta = [];salinectrlbeta = [];
for i = 1:height(c)
    %extract data for each syllable for naspm trial
    ind = find(strcmp(pitchvolsylldur_data.birdname,c(i,:).birdname) & ...
        strcmp(pitchvolsylldur_data.syllID,c(i,:).syllID) & ...
        (strcmp(pitchvolsylldur_data.condition,'saline') | ...
        strcmp(pitchvolsylldur_data.condition,'naspm')));
    subset = pitchvolsylldur_data(ind,:);
    formula = 'sylldur ~ volume*condition';
    mdl = fitlm(subset,formula);
    naspmbeta = [naspmbeta; mdl.Coefficients{'volume',{'Estimate','pValue'}} ...
        mdl.Coefficients{'condition_naspm:volume',{'Estimate','pValue'}}];
    
    %extract data for each syllable in saline ctrl trial
    ind = find(strcmp(pitchvolsylldur_data.birdname,c(i,:).birdname) & ...
        strcmp(pitchvolsylldur_data.syllID,c(i,:).syllID) & ...
        (strcmp(pitchvolsylldur_data.condition,'saline1') | ...
        strcmp(pitchvolsylldur_data.condition,'saline2')));
    subset = pitchvolsylldur_data(ind,:);
    formula = 'sylldur ~ volume*condition';
    mdl = fitlm(subset,formula);
    salinectrlbeta = [salinectrlbeta; mdl.Coefficients{'volume',{'Estimate','pValue'}} ...
        mdl.Coefficients{'condition_saline2:volume',{'Estimate','pValue'}}];
end
%test if slopes are different
naspmbeta = array2table(naspmbeta,'VariableNames',{'volume_beta','volume_pval',...
    'volumeinteraction','volumeinteraction_pval'});
naspmbeta.condition = repmat({'naspm'},height(naspmbeta),1);
salinectrlbeta = array2table(salinectrlbeta,'VariableNames',{'volume_beta','volume_pval',...
    'volumeinteraction','volumeinteraction_pval'});
salinectrlbeta.condition = repmat({'saline'},height(naspmbeta),1);
allbetas = [naspmbeta;salinectrlbeta];
formula = 'volumeinteraction ~ volume_beta*condition';
mdl = fitlm(allbetas,formula);
pVal = mdl.Coefficients{'volume_beta:condition_saline','pValue'};

%plot effect of treatment on pitch vs volume
figure;plot(naspmbeta.volume_beta,naspmbeta.volumeinteraction,'r.','markersize',10);hold on;lsline
plot(salinectrlbeta.volume_beta,salinectrlbeta.volumeinteraction,'k.','markersize',10);lsline
xlabel('volume beta');ylabel('interaction effect on volume');
legend({'naspm','','saline',''});title('volume vs sylldur');
text(0,1,['p=',num2str(pVal)],'units','normalized','verticalalignment','top');

%plot pitch vs sylldur correlation at baseline vs treatment (naspm or saline
%ctrl)
c = unique(pitchvolsylldur_corrsummary(:,{'birdname','syllID'}));
naspmcorr = [];salinectrlcorr= [];
for i = 1:height(c)
    %extract data for each syllable for naspm trial
    ind = find(strcmp(pitchvolsylldur_corrsummary.birdname,c(i,:).birdname) & ...
        strcmp(pitchvolsylldur_corrsummary.syllID,c(i,:).syllID));
    subset = pitchvolsylldur_corrsummary(ind,:);
    
    naspmcorr = [naspmcorr; subset{strcmp(subset.condition,'saline'),'volsylldur'} ...
        subset{strcmp(subset.condition,'naspm'),'volsylldur'}];
    salinectrlcorr = [salinectrlcorr; subset{strcmp(subset.condition,'saline1'),'volsylldur'} ...
        subset{strcmp(subset.condition,'saline2'),'volsylldur'}];
end

%test if slopes are different
naspmcorr = array2table(naspmcorr,'VariableNames',{'baseline_corr','baseline_corr_pval',...
    'treatment_corr','treatment_corr_pval'});
naspmcorr.condition = repmat({'naspm'},height(naspmcorr),1);
salinectrlcorr = array2table(salinectrlcorr,'VariableNames',{'baseline_corr','baseline_corr_pval',...
    'treatment_corr','treatment_corr_pval'});
salinectrlcorr.condition = repmat({'saline'},height(salinectrlcorr),1);
allbetas = [naspmcorr;salinectrlcorr];
formula = 'treatment_corr ~ baseline_corr*condition';
mdl = fitlm(allbetas,formula);
pVal = mdl.Coefficients{'baseline_corr:condition_saline','pValue'};

figure;plot(naspmcorr.baseline_corr,naspmcorr.treatment_corr,'r.','markersize',10);hold on;lsline
plot(salinectrlcorr.baseline_corr,salinectrlcorr.treatment_corr,'k.','markersize',10);hold on;lsline
xlabel('baseline correlation');ylabel('treatment correlation') 
legend({'naspm','','saline',''});title('volume vs sylldur');
text(0,1,['p=',num2str(pVal)],'units','normalized','verticalalignment','top');

%% plot trial lag correlation 
shufftrials = 1000;
subset = pitchvolsylldur_data(strcmp(pitchvolsylldur_data.condition,'saline'),:);
[cases ia ib] = unique(subset(:,{'birdname','syllID'}));
lagtrialcorr = {};lagtrialshuffcorr = {};
for i = 1:height(cases)
    ind = find(ib == i);
    data = subset{ind,{'pitch','sylldur'}};
    data(any(isnan(data),2),:) = [];
    [~,p] = corrcoef(data(:,1),data(:,2));
    if p(2) <= 0.05
        [r l] = xcov(data(:,1),data(:,2),'biased');
        lagtrialcorr = [lagtrialcorr; [l' r]];
        [shuffr shuffl] = shuffletrialcorr(data(:,1),data(:,2),shufftrials);
        lagtrialshuffcorr = [lagtrialshuffcorr; [shuffl shuffr]];
    end
end

[~,maxind] = max(cellfun(@(x) size(x,1),lagtrialcorr));
maxlag = lagtrialcorr{maxind}(:,1);
lagtrialcorr = cellfun(@(x) [NaN(x(1,1)-maxlag(1),1);x(:,2);...
    NaN(maxlag(end)-x(end,1),1)],lagtrialcorr,'un',0);
lagtrialcorr = abs(cell2mat(lagtrialcorr'));
figure;hold on;
for i = 1:size(lagtrialcorr,2)
    plot(maxlag,lagtrialcorr(:,i),'color',[1 0.8 0.8]);hold on;
end
patch([maxlag' fliplr(maxlag')],[(nanmean(lagtrialcorr,2)+nanstderr(lagtrialcorr,2))' ...
    fliplr((nanmean(lagtrialcorr,2)-nanstderr(lagtrialcorr,2))')],'r',...
    'edgecolor','none','facealpha',0.7);hold on;

[~,maxind] = max(cellfun(@(x) length(x(:,1)),lagtrialshuffcorr));
maxlag = lagtrialshuffcorr{maxind}(:,1);
lagtrialshuffcorr = cellfun(@(x) [NaN(x(1,1)-maxlag(1),shufftrials);x(:,2:end);...
    NaN(maxlag(end)-x(end,1),shufftrials)],lagtrialshuffcorr,'un',0);
lagtrialshuffcorr = abs(cell2mat(lagtrialshuffcorr'));
hi = NaN(1,length(maxlag));lo = NaN(1,length(maxlag));
for i = 1:length(maxlag)
    id = find(~isnan(lagtrialshuffcorr(i,:)));
    x = sort(lagtrialshuffcorr(i,id));
    if length(x) <= 1000
        continue
    else
        hi(i) = x(fix(length(x)*0.95));
        lo(i) = x(fix(length(x)*0.05));
    end
end
id = find(isnan(hi));
hi(id) = [];lo(id) = [];maxlag(id) = [];
patch([maxlag' fliplr(maxlag')],[lo fliplr(hi)],[0.2 0.2 0.2],...
    'edgecolor','none','facealpha',0.7);hold on;

function [shuffr shuffl] = shuffletrialcorr(x,y,shufftrials);
    x_shuff = repmat(x',shufftrials,1);
    x_shuff = permute_rowel(x_shuff);
    shuffr = cell(shufftrials,1);
    shuffl = cell(shufftrials,1);
    for n = 1:shufftrials
        shuffdat = [x_shuff(n,:)',y];
        shuffdat(any(isnan(shuffdat),2),:) = [];
        [rx lx] = xcov(shuffdat(:,1),shuffdat(:,2),'biased');
        shuffr{n} = rx;
        shuffl{n} = lx';
    end
    [~,maxind] = max(cellfun(@length,shuffl));
    maxlag = shuffl{maxind};
    shuffr = cellfun(@(x,y) [NaN(x(1)-maxlag(1),1);y;NaN(maxlag(end)-x(end),1)],...
        shuffl,shuffr,'un',0);
    shuffr = cell2mat(shuffr');
    shuffl = maxlag;
end
    
    