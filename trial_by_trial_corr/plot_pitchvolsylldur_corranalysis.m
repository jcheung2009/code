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
    
%% test significance of frequency of correlations
aph = 0.01;ntrials=1000;

%pitch vs vol (saline)
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
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);

randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);

figure;subplot(1,2,1);hold on;
[n b] = hist(shuffcorr(:),[-0.6:0.05:0.6]);
stairs(b,n/sum(n),'k','linewidth',2);hold on;
[n b] = hist(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1),[-0.6:0.05:0.6]);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
[h p] = ttest2(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind,:).pitchvol(:,1),shuffcorr(:));
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
xlabel('correlation');ylabel('probability');title('pitch vs volume (saline)');

%pitch vs vol (naspm)
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
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);

randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);

subplot(1,2,2);hold on;
[n b] = hist(shuffcorr(:),[-0.6:0.05:0.6]);
stairs(b,n/sum(n),'k','linewidth',2);hold on;
[n b] = hist(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1),[-0.6:0.05:0.6]);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
[h p] = ttest2(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind2,:).pitchvol(:,1),shuffcorr(:));
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
xlabel('correlation');ylabel('probability');title('pitch vs volume (naspm)');

%pitch vs sylldur (saline)
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
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);

randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);

figure;subplot(1,2,1);hold on;
[n b] = hist(shuffcorr(:),[-0.6:0.05:0.6]);
stairs(b,n/sum(n),'k','linewidth',2);hold on;
[n b] = hist(pitchvolsylldur_corrsummary(ind,:).pitchsylldur(:,1),[-0.6:0.05:0.6]);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
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

%pitch vs sylldur (naspm)
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
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);

randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);

subplot(1,2,2);hold on;
[n b] = hist(shuffcorr(:),[-0.6:0.05:0.6]);
stairs(b,n/sum(n),'k','linewidth',2);hold on;
[n b] = hist(pitchvolsylldur_corrsummary(ind2,:).pitchsylldur(:,1),[-0.6:0.05:0.6]);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
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
xlabel('correlation');ylabel('probability');title('pitch vs sylldur (naspm)');

%vol vs sylldur (saline)
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
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);

randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);

figure;subplot(1,2,1);hold on;
[n b] = hist(shuffcorr(:),[-0.6:0.05:0.6]);
stairs(b,n/sum(n),'k','linewidth',2);hold on;
[n b] = hist(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1),[-0.6:0.05:0.6]);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
[h p] = ttest2(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind,:).volsylldur(:,1),shuffcorr(:));
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
xlabel('correlation');ylabel('probability');title('vol vs sylldur (saline)');

%vol vs sylldur (naspm)
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
randnumsignificantposcorr = sum((shuffpval<=0.05).*(shuffcorr>0),2);
randpropsignificantposcorr = randnumsignificantposcorr./size(shuffpval,2);
randpropsignificantposcorr_sorted = sort(randpropsignificantposcorr);

randdiffprop = abs(randpropsignificantnegcorr-randpropsignificantposcorr);

subplot(1,2,2);hold on;
[n b] = hist(shuffcorr(:),[-0.6:0.05:0.6]);
stairs(b,n/sum(n),'k','linewidth',2);hold on;
[n b] = hist(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1),[-0.6:0.05:0.6]);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
[h p] = ttest2(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1),shuffcorr(:));
[h p2] = kstest2(pitchvolsylldur_corrsummary(ind2,:).volsylldur(:,1),shuffcorr(:));
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
xlabel('correlation');ylabel('probability');title('vol vs sylldur (naspm)');

%% plot correlation in saline vs naspm
pitchvolcorrs = pitchvolsylldur_corrsummary{:,'pitchvol'}(:,1);
pitchvolcorrs_sal = pitchvolcorrs(1:2:end);
pitchvolcorrs_naspm = pitchvolcorrs(2:2:end);
figure;hold on;
plot([1 2],[pitchvolcorrs_sal pitchvolcorrs_naspm],'k')
xlim([0 3]);title('pitch vs vol');
    
pitchsylldurcorrs = pitchvolsylldur_corrsummary{:,'pitchsylldur'}(:,1);
pitchsylldurcorrs_sal = pitchsylldurcorrs(1:2:end);
pitchsylldurcorrs_naspm = pitchsylldurcorrs(2:2:end);
figure;hold on;
plot([1 2],[pitchsylldurcorrs_sal pitchsylldurcorrs_naspm],'k')
xlim([0 3]);title('pitch vs sylldur');

volsylldurcorrs = pitchvolsylldur_corrsummary{:,'volsylldur'}(:,1);
volsylldurcorrs_sal = volsylldurcorrs(1:2:end);
volsylldurcorrs_naspm = volsylldurcorrs(2:2:end);
figure;hold on;
plot([1 2],[volsylldurcorrs_sal volsylldurcorrs_naspm],'k')
xlim([0 3]);title('vol vs sylldur');
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