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

c = unique(pitchvolsylldur_data(:,{'birdname','syllID'}));
naspmeffect = [];
pitchbeta = [];
for i = 1:height(c)
%     ind = find(strcmp(pitchvolsylldur_data.birdname,c(i,:).birdname) & ...
%         strcmp(pitchvolsylldur_data.syllID,c(i,:).syllID) & ...
%         strcmp(pitchvolsylldur_data.condition,'saline'));
%     ind2 = find(strcmp(pitchvolsylldur_data.birdname,c(i,:).birdname) & ...
%         strcmp(pitchvolsylldur_data.syllID,c(i,:).syllID) & ...
%         strcmp(pitchvolsylldur_data.condition,'naspm'));
%     figure;hold on;
%     plot(pitchvolsylldur_data{ind,'pitch'},...
%         pitchvolsylldur_data{ind,'volume'},'k.');hold on;
%     plot(pitchvolsylldur_data{ind2,'pitch'},...
%         pitchvolsylldur_data{ind2,'volume'},'r.');hold on;
    
    ind = find(strcmp(pitchvolsylldur_data.birdname,c(i,:).birdname) & ...
        strcmp(pitchvolsylldur_data.syllID,c(i,:).syllID));
%     numsaltrials = length(find(strcmp(pitchvolsylldur_data.birdname,c(i,:).birdname) & ...
%         strcmp(pitchvolsylldur_data.syllID,c(i,:).syllID) & ...
%         strcmp(pitchvolsylldur_data.condition,'saline')));
%     numdrugtrials = length(ind)-numsaltrials;
    subset = pitchvolsylldur_data(ind,:);
%     shuffsubset = subset(randi(height(subset),1,height(subset)),:)
%     figure;plot(shuffsubset{1:numsaltrials,'pitch'},...
%         shuffsubset{1:numsaltrials,'volume'},'k.');hold on;
%     plot(shuffsubset{numsaltrials+1:end,'pitch'},...
%         shuffsubset{numsaltrials+1:end,'volume'},'r.');hold on;
%     [r p] = corrcoef(shuffsubset{1:numsaltrials,{'pitch','volume'}},'rows','complete');
%     [r p] = corrcoef(shuffsubset{numsaltrials+1:end,{'pitch','volume'}},'rows','complete')
    
    formula = 'volume ~ pitch*condition';
    mdl = fitlm(subset,formula);
    naspmeffect = [naspmeffect; mdl.Coefficients{end,{'Estimate','pValue'}}];
    pitchbeta = [pitchbeta; mdl.Coefficients{3,{'Estimate','pValue'}}];
end

figure;plot(pitchbeta(:,1),naspmeffect(:,1),'k.');