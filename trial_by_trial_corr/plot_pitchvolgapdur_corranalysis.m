config;
batch = 'batch';

%load correlation data in summary table from each bird
ff = load_batchf(batch);
pitchvolgapdur_corrsummary = table([],[],[],[],[],[],[],[],'VariableNames',...
        {'birdname','syllID','condition','gaptype','pitchgap',...
        'volgap','pitchgap_shuff','volgap_shuff'});
pitchvolgapdur_data = table([],[],[],[],[],[],[],'VariableNames',{'birdname','syllID',...
        'condition','gaptype','pitch','volume','gapdur'});
for i = 1:length(ff)
    if ~exist(ff(i).name)
        try
            load([params.subfolders{1},'/',ff(i).name,...
                '/analysis/data_structures/pitchvolgap_correlation_',ff(i).name]);
        catch
            continue
        end
    else
        try 
            load([ff(i).name,...
                '/analysis/data_structures/pitchvolgap_correlation_',ff(i).name]);
        catch
            continue
        end
    end
    pitchvolgapdur_corrsummary = [pitchvolgapdur_corrsummary; pitchvolgap_corr];
    pitchvolgapdur_data = [pitchvolgapdur_data; pitchvolgap_tbl];
end
%% test significance of frequency of correlations for pitch vs gapdur
aph = 0.01;ntrials=1000;
bardata = NaN(4,4);
significancelevel = NaN(1,16);
%pitch vs gap dur back (naspm baseline)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,2}];
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

figure;subtightplot(2,8,1,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap back (saline)');
bardata(1,1:2) = [poscorr/numcases,negcorr/numcases];

%pitch vs gap dur front (naspm baseline)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,2}];
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

subtightplot(2,8,2,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap front (saline)');
bardata(1,3:4) = [poscorr/numcases,negcorr/numcases];

%pitch vs gap dur back (naspm)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'naspm') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,2}];
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

subtightplot(2,8,3,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor','r','linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)),0,'r^','markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap back (naspm)');
bardata(2,1:2) = [poscorr/numcases,negcorr/numcases];

%pitch vs gap dur front (naspm baseline)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'naspm') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,2}];
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

subtightplot(2,8,4,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor','r','linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)),0,'r^',...
    'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap front (naspm)');
bardata(2,3:4) = [poscorr/numcases,negcorr/numcases];

%pitch vs gap dur back (saline1)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline1') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,2}];
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
significancelevel(9:10) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subtightplot(2,8,9,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap back (saline1)');
bardata(3,1:2) = [poscorr/numcases,negcorr/numcases];

%pitch vs gap dur front (saline1)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline1') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,2}];
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
significancelevel(11:12) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subtightplot(2,8,10,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap front (saline1)');
bardata(3,3:4) = [poscorr/numcases,negcorr/numcases];

%pitch vs gap dur back (saline2)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline2') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,2}];
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
significancelevel(13:14) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subtightplot(2,8,11,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap back (saline2)');
bardata(4,1:2) = [poscorr/numcases,negcorr/numcases];

%pitch vs gap dur back (saline2)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline2') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).pitchgap_shuff{:,2}];
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
significancelevel(15:16) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subtightplot(2,8,12,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).pitchgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap front (saline2)');
bardata(4,3:4) = [poscorr/numcases,negcorr/numcases];

subtightplot(2,8,[5:8 13:16],[0.09 0.04],0.07,0.05);hold on;
b = bar(bardata,'facecolor','none','linewidth',2);hold on;
xl = get(gca,'xlim');
plot(xl,[max(significancelevel) max(significancelevel)],'--','color',[0.5 0.5 0.5],'linewidth',2);
xticks([1, 2, 3, 4]);
xticklabels({'saline','NASPM','saline1','saline2'});
ylabel('% cases with significant correlations');

%% test significance of frequency of correlations for vol vs gapdur
aph = 0.01;ntrials=1000;
bardata = NaN(4,4);
significancelevel = NaN(1,16);
%vol vs gap dur back (naspm baseline)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,2}];
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

figure;subtightplot(2,8,1,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).volgap(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap back (saline)');
bardata(1,1:2) = [poscorr/numcases,negcorr/numcases];

%vol vs gap dur front (naspm baseline)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,2}];
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

subtightplot(2,8,2,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).volgap(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap front (saline)');
bardata(1,3:4) = [poscorr/numcases,negcorr/numcases];

%vol vs gap dur back (naspm)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'naspm') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,2}];
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

subtightplot(2,8,3,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor','r','linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).volgap(:,1)),0,'r^','markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap back (naspm)');
bardata(2,1:2) = [poscorr/numcases,negcorr/numcases];

%vol vs gap dur front (naspm baseline)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'naspm') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,2}];
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

subtightplot(2,8,4,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor','r','linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).volgap(:,1)),0,'r^',...
    'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap front (naspm)');
bardata(2,3:4) = [poscorr/numcases,negcorr/numcases];

%vol vs gap dur back (saline1)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline1') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,2}];
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
significancelevel(9:10) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subtightplot(2,8,9,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).volgap(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap back (saline1)');
bardata(3,1:2) = [poscorr/numcases,negcorr/numcases];

%vol vs gap dur front (saline1)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline1') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,2}];
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
significancelevel(11:12) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subtightplot(2,8,10,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).volgap(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap front (saline1)');
bardata(3,3:4) = [poscorr/numcases,negcorr/numcases];

%vol vs gap dur back (saline2)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline2') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,2}];
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
significancelevel(13:14) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subtightplot(2,8,11,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).volgap(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap back (saline2)');
bardata(4,1:2) = [poscorr/numcases,negcorr/numcases];

%vol vs gap dur back (saline2)
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline2') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
negcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)< 0));
poscorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05 & ...
    pitchvolgapdur_corrsummary(ind,:).volgap(:,1)> 0));
sigcorr = length(find(pitchvolgapdur_corrsummary(ind,:).volgap(:,2)<= 0.05));
numcases = length(ind);

shuffcorr =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,1}];
shuffpval =  [pitchvolgapdur_corrsummary(ind,:).volgap_shuff{:,2}];
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
significancelevel(15:16) = [randpropsignificantposcorr_hi randpropsignificantnegcorr_hi];

subtightplot(2,8,12,[0.09 0.04],0.07,0.05);hold on;
histogram(shuffcorr(:),[-0.6:0.05:0.6],'Displaystyle','stairs','edgecolor',...
    'k','linewidth',2,'normalization','probability');hold on;
histogram(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),[-0.6:0.05:0.6],...
    'Displaystyle','stairs','edgecolor',[0.5 0.5 0.5],'linewidth',2,...
    'normalization','probability');
plot(mean(shuffcorr(:)),0,'k^','markersize',8,'linewidth',2);hold on;
plot(mean(pitchvolgapdur_corrsummary(ind,:).volgap(:,1)),0,'^','color',...
    [0.5 0.5 0.5],'markersize',8,'linewidth',2);
[h p] = ttest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolgapdur_corrsummary(ind,:).volgap(:,1),shuffcorr(:));
p3 = length(find(randdiffprop>=abs((negcorr/numcases)-(poscorr/numcases))))/ntrials;
p4 = length(find(randpropsignificant>=sigcorr/numcases))/ntrials;
p5 = length(find(randpropsignificantposcorr>=poscorr/numcases))/ntrials;
p6 = length(find(randpropsignificantnegcorr>=negcorr/numcases))/ntrials;
xlabel('correlation');ylabel('probability');title('gap front (saline2)');
bardata(4,3:4) = [poscorr/numcases,negcorr/numcases];

subtightplot(2,8,[5:8 13:16],[0.09 0.04],0.07,0.05);hold on;
b = bar(bardata,'facecolor','none','linewidth',2);hold on;
xl = get(gca,'xlim');
plot(xl,[max(significancelevel) max(significancelevel)],'--','color',[0.5 0.5 0.5],'linewidth',2);
xticks([1, 2, 3, 4]);
xticklabels({'saline','NASPM','saline1','saline2'});
ylabel('% cases with significant correlations');

%% plot correlation in saline vs naspm
%pitch vs gap
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
ind2 = find(strcmp(pitchvolgapdur_corrsummary.condition,'naspm') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
pitchgapcorrs_sal = pitchvolgapdur_corrsummary{ind,'pitchgap'}(:,1);
pitchgapcorrs_naspm = pitchvolgapdur_corrsummary{ind2,'pitchgap'}(:,1);
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline1') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
ind2 = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline2') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
pitchgapcorrs_sal1 = pitchvolgapdur_corrsummary{ind,'pitchgap'}(:,1);
pitchgapcorrs_sal2 = pitchvolgapdur_corrsummary{ind2,'pitchgap'}(:,1);
figure;hold on;
plot([1 2],[pitchgapcorrs_sal pitchgapcorrs_naspm],'k','marker','o');hold on;
plot([3 4],[pitchgapcorrs_sal1 pitchgapcorrs_sal2],'k','marker','o');hold on;
xlim([0 5]);refline(0,0);title('pitch vs gap back');
ylabel('correlation');xticks([1:4]);xticklabels({'saline','NASPM','saline1','saline2'});

ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
ind2 = find(strcmp(pitchvolgapdur_corrsummary.condition,'naspm') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
pitchgapcorrs_sal = pitchvolgapdur_corrsummary{ind,'pitchgap'}(:,1);
pitchgapcorrs_naspm = pitchvolgapdur_corrsummary{ind2,'pitchgap'}(:,1);
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline1') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
ind2 = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline2') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
pitchgapcorrs_sal1 = pitchvolgapdur_corrsummary{ind,'pitchgap'}(:,1);
pitchgapcorrs_sal2 = pitchvolgapdur_corrsummary{ind2,'pitchgap'}(:,1);
figure;hold on;
plot([1 2],[pitchgapcorrs_sal pitchgapcorrs_naspm],'k','marker','o');hold on;
plot([3 4],[pitchgapcorrs_sal1 pitchgapcorrs_sal2],'k','marker','o');hold on;
xlim([0 5]);refline(0,0);title('pitch vs gap front');
ylabel('correlation');xticks([1:4]);xticklabels({'saline','NASPM','saline1','saline2'});

%vol vs gap
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
ind2 = find(strcmp(pitchvolgapdur_corrsummary.condition,'naspm') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
volgapcorrs_sal = pitchvolgapdur_corrsummary{ind,'volgap'}(:,1);
volgapcorrs_naspm = pitchvolgapdur_corrsummary{ind2,'volgap'}(:,1);
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline1') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
ind2 = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline2') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
volgapcorrs_sal1 = pitchvolgapdur_corrsummary{ind,'volgap'}(:,1);
volgapcorrs_sal2 = pitchvolgapdur_corrsummary{ind2,'volgap'}(:,1);
figure;hold on;
plot([1 2],[volgapcorrs_sal volgapcorrs_naspm],'k','marker','o');hold on;
plot([3 4],[volgapcorrs_sal1 volgapcorrs_sal2],'k','marker','o');hold on;
xlim([0 5]);refline(0,0);title('vol vs gap back');
ylabel('correlation');xticks([1:4]);xticklabels({'saline','NASPM','saline1','saline2'});

ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
ind2 = find(strcmp(pitchvolgapdur_corrsummary.condition,'naspm') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
volgapcorrs_sal = pitchvolgapdur_corrsummary{ind,'volgap'}(:,1);
volgapcorrs_naspm = pitchvolgapdur_corrsummary{ind2,'volgap'}(:,1);
ind = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline1') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
ind2 = find(strcmp(pitchvolgapdur_corrsummary.condition,'saline2') & ...
    strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
volgapcorrs_sal1 = pitchvolgapdur_corrsummary{ind,'volgap'}(:,1);
volgapcorrs_sal2 = pitchvolgapdur_corrsummary{ind2,'volgap'}(:,1);
figure;hold on;
plot([1 2],[volgapcorrs_sal volgapcorrs_naspm],'k','marker','o');hold on;
plot([3 4],[volgapcorrs_sal1 volgapcorrs_sal2],'k','marker','o');hold on;
xlim([0 5]);refline(0,0);title('vol vs gap front');
ylabel('correlation');xticks([1:4]);xticklabels({'saline','NASPM','saline1','saline2'});

%% is there an effect of naspm on pitch vs gap? 
%plot pitch vs vol correlation at baseline vs treatment (naspm or saline
%ctrl) for gap back
ix = find(strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
gaptypesubset = pitchvolgapdur_corrsummary(ix,:);
c = unique(gaptypesubset(:,{'birdname','syllID'}));
naspmcorr = [];salinectrlcorr= [];
for i = 1:height(c)
    %extract data for each syllable for naspm trial
    ind = find(strcmp(gaptypesubset.birdname,c(i,:).birdname) & ...
        strcmp(gaptypesubset.syllID,c(i,:).syllID));
    subset = gaptypesubset(ind,:);
    
    naspmcorr = [naspmcorr; subset{strcmp(subset.condition,'saline'),'pitchgap'} ...
        subset{strcmp(subset.condition,'naspm'),'pitchgap'}];
    salinectrlcorr = [salinectrlcorr; subset{strcmp(subset.condition,'saline1'),'pitchgap'} ...
        subset{strcmp(subset.condition,'saline2'),'pitchgap'}];
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
legend({'naspm','','saline',''});title('pitch vs gap back');
text(0,1,['p=',num2str(pVal)],'units','normalized','verticalalignment','top');

%plot pitch vs vol correlation at baseline vs treatment (naspm or saline
%ctrl) for gap front
ix = find(strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
gaptypesubset = pitchvolgapdur_corrsummary(ix,:);
c = unique(gaptypesubset(:,{'birdname','syllID'}));
naspmcorr = [];salinectrlcorr= [];
for i = 1:height(c)
    %extract data for each syllable for naspm trial
    ind = find(strcmp(gaptypesubset.birdname,c(i,:).birdname) & ...
        strcmp(gaptypesubset.syllID,c(i,:).syllID));
    subset = gaptypesubset(ind,:);
    
    naspmcorr = [naspmcorr; subset{strcmp(subset.condition,'saline'),'pitchgap'} ...
        subset{strcmp(subset.condition,'naspm'),'pitchgap'}];
    salinectrlcorr = [salinectrlcorr; subset{strcmp(subset.condition,'saline1'),'pitchgap'} ...
        subset{strcmp(subset.condition,'saline2'),'pitchgap'}];
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
legend({'naspm','','saline',''});title('pitch vs gap front');
text(0,1,['p=',num2str(pVal)],'units','normalized','verticalalignment','top');

%plot vol vs vol correlation at baseline vs treatment (naspm or saline
%ctrl) for gap back
ix = find(strcmp(pitchvolgapdur_corrsummary.gaptype,'back'));
gaptypesubset = pitchvolgapdur_corrsummary(ix,:);
c = unique(gaptypesubset(:,{'birdname','syllID'}));
naspmcorr = [];salinectrlcorr= [];
for i = 1:height(c)
    %extract data for each syllable for naspm trial
    ind = find(strcmp(gaptypesubset.birdname,c(i,:).birdname) & ...
        strcmp(gaptypesubset.syllID,c(i,:).syllID));
    subset = gaptypesubset(ind,:);
    
    naspmcorr = [naspmcorr; subset{strcmp(subset.condition,'saline'),'volgap'} ...
        subset{strcmp(subset.condition,'naspm'),'volgap'}];
    salinectrlcorr = [salinectrlcorr; subset{strcmp(subset.condition,'saline1'),'volgap'} ...
        subset{strcmp(subset.condition,'saline2'),'volgap'}];
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
legend({'naspm','','saline',''});title('vol vs gap back');
text(0,1,['p=',num2str(pVal)],'units','normalized','verticalalignment','top');

%plot pitch vs vol correlation at baseline vs treatment (naspm or saline
%ctrl) for gap front
ix = find(strcmp(pitchvolgapdur_corrsummary.gaptype,'forward'));
gaptypesubset = pitchvolgapdur_corrsummary(ix,:);
c = unique(gaptypesubset(:,{'birdname','syllID'}));
naspmcorr = [];salinectrlcorr= [];
for i = 1:height(c)
    %extract data for each syllable for naspm trial
    ind = find(strcmp(gaptypesubset.birdname,c(i,:).birdname) & ...
        strcmp(gaptypesubset.syllID,c(i,:).syllID));
    subset = gaptypesubset(ind,:);
    
    naspmcorr = [naspmcorr; subset{strcmp(subset.condition,'saline'),'volgap'} ...
        subset{strcmp(subset.condition,'naspm'),'volgap'}];
    salinectrlcorr = [salinectrlcorr; subset{strcmp(subset.condition,'saline1'),'volgap'} ...
        subset{strcmp(subset.condition,'saline2'),'volgap'}];
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
legend({'naspm','','saline',''});title('vol vs gap front');
text(0,1,['p=',num2str(pVal)],'units','normalized','verticalalignment','top');

%% plot trial lag correlation 
shufftrials = 1000;
subset = pitchvolgapdur_data(strcmp(pitchvolgapdur_data.condition,'saline') & ...
    strcmp(pitchvolgapdur_data.gaptype,'forward'),:);
[cases ia ib] = unique(subset(:,{'birdname','syllID'}));
lagtrialcorr = {};lagtrialshuffcorr = {};
for i = 1:height(cases)
    ind = find(ib == i);
    data = subset{ind,{'pitch','gapdur'}};
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
    
    