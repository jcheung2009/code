%plot results for repeat analysis 
load('rep_correlation1.mat');

%% linear regression on each burst individually with length
aph = 0.01;%significance level

r = cat(1,bursttable.linear{:,1});
p = cat(1,bursttable.linear{:,2});
shuffr = cat(2,bursttable.linear{:,3});
shuffp = cat(2,bursttable.linear{:,4});
assert(length(r)==length(p));
assert(size(shuffr,1)==size(shuffp,1));
assert(size(shuffr,2)==length(r));

%pvalues for empircal data
numcases = length(r);
shufftrials = size(shuffr,1);
sigcorr = length(find(p<=0.05))/numcases;
negcorr = length(find(r<0 & p <=0.05))/numcases;
poscorr = length(find(r>0 & p<=0.05))/numcases;
shuffsigcorr = sum(shuffp<=0.05,2)./numcases;
shuffnegcorr = sum(shuffr<0 & shuffp<=0.05,2)./numcases;
shuffposcorr = sum(shuffr>0 & shuffp<=0.05,2)./numcases;
shuffdiffcorr = abs(shuffnegcorr-shuffposcorr);
pnegcorr = length(find(shuffnegcorr > negcorr))/shufftrials;
pposcorr = length(find(shuffposcorr > poscorr))/shufftrials;
[h p1] = vartest2(r,shuffr(:));
[h p2] = ttest2(r,shuffr(:));
p3 = length(find(shuffsigcorr>sigcorr))/shufftrials;%pval for prop of significant cases
p4 = length(find(shuffnegcorr>negcorr))/shufftrials;%pval for prop of sig neg cases
p5 = length(find(shuffposcorr>poscorr))/shufftrials;%pval for prop of sig pos cases
p6 = length(find(shuffdiffcorr > abs(negcorr-poscorr)))/shufftrials;%pval for diff in prop of neg vs pos 

shuffsigcorr_sorted = sort(shuffsigcorr);
shuffsigcorr_lo = shuffsigcorr_sorted(floor(aph*shufftrials/2));
shuffsigcorr_hi = shuffsigcorr_sorted(ceil(shufftrials-(aph*shufftrials/2)));
shuffnegcorr_sorted = sort(shuffnegcorr);
shuffnegcorr_lo = shuffnegcorr_sorted(floor(aph*shufftrials/2));
shuffnegcorr_hi = shuffnegcorr_sorted(ceil(shufftrials-(aph*shufftrials/2)));
shuffposcorr_sorted = sort(shuffposcorr);
shuffposcorr_lo = shuffposcorr_sorted(floor(aph*shufftrials/2));
shuffposcorr_hi = shuffposcorr_sorted(ceil(shufftrials-(aph*shufftrials/2)));

%plot distribution of proportion of significant, negative, positive correlations 
figure;subplot(1,3,1);hold on;
[n b] = hist(shuffsigcorr,[0:0.01:max(shuffsigcorr)]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(shuffsigcorr_hi,y(1),'k^','markersize',8);hold on;
plot(shuffsigcorr_lo,y(1),'k^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(p<=0.05);
plot(mn,y(1),'kd','markersize',8,'markerfacecolor','k');hold on;
plot([lo  hi],[y(1) y(1)],'k','linewidth',4)
title('shuffled vs empirical single units');
xlabel('proportion of significant correlations');ylabel('probability');
set(gca,'fontweight','bold');

subplot(1,3,2);hold on;
[n b] = hist(shuffnegcorr,[0:0.01:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(shuffnegcorr_hi,y(1),'b^','markersize',8);hold on;
plot(shuffnegcorr_lo,y(1),'b^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(p<=0.05 & r<0);
plot(mn,y(1),'bd','markersize',8,'markerfacecolor','b');hold on;
plot([lo  hi],[y(1) y(1)],'b','linewidth',4)
title('shuffled vs empirical single units');
xlabel('proportion of significantly negative correlations');ylabel('probability');
set(gca,'fontweight','bold');

subplot(1,3,3);hold on;
[n b] = hist(shuffposcorr,[0:0.01:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(shuffposcorr_hi,y(1),'r^','markersize',8);hold on;
plot(shuffposcorr_lo,y(1),'r^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(p<=0.05 & r>0);
plot(mn,y(1),'bd','markersize',8,'markerfacecolor','r');hold on;
plot([lo  hi],[y(1) y(1)],'r','linewidth',4)
title('shuffled vs empirical single units');
xlabel('proportion of significantly positive correlations');ylabel('probability');
set(gca,'fontweight','bold');

%plot distribution of empirical and shuffled correlations
figure;hold on;
[n b] = hist(r,[min(shuffr(:)):0.05:max(shuffr(:))]);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
[n b] = hist(shuffr(:),[min(shuffr(:)):0.05:max(shuffr(:))]);
stairs(b,n/sum(n),'k','linewidth',2);
xlabel('correlation');ylabel('probability');y = get(gca,'ylim');
plot(mean(r),y(1),'r^','markersize',8);hold on;
plot(mean(shuffr(:)),y(1),'k^','markersize',8);hold on;
title('burst with repeat length');
text(0,1,{['total active cases:',num2str(numcases)];...
    ['proportion significant cases:',num2str(sigcorr)];...
    ['proportion significantly negative:',num2str(negcorr)];...
    ['proportion significantly positive:',num2str(poscorr)];...
    ['p(t)=',num2str(p2)];['p(F)=',num2str(p1)];['p(sig)=',num2str(p3)];...
    ['p(neg)=',num2str(p4)];['p(pos)=',num2str(p5)];['p(neg-pos)=',num2str(p6)]},...
    'units','normalized','verticalalignment','top');

%% linear regression on each burst individually with stop vs continue
aph = 0.01;%significance level

r = cat(1,bursttable.linear2{:,1});
p = cat(1,bursttable.linear2{:,2});
shuffr = cat(2,bursttable.linear2{:,3});
shuffp = cat(2,bursttable.linear2{:,4});
assert(length(r)==length(p));
assert(size(shuffr,1)==size(shuffp,1));
assert(size(shuffr,2)==length(r));

%pvalues for empircal data
numcases = length(r);
shufftrials = size(shuffr,1);
sigcorr = length(find(p<=0.05))/numcases;
negcorr = length(find(r<0 & p <=0.05))/numcases;
poscorr = length(find(r>0 & p<=0.05))/numcases;
shuffsigcorr = sum(shuffp<=0.05,2)./numcases;
shuffnegcorr = sum(shuffr<0 & shuffp<=0.05,2)./numcases;
shuffposcorr = sum(shuffr>0 & shuffp<=0.05,2)./numcases;
shuffdiffcorr = abs(shuffnegcorr-shuffposcorr);
pnegcorr = length(find(shuffnegcorr > negcorr))/shufftrials;
pposcorr = length(find(shuffposcorr > poscorr))/shufftrials;
[h p1] = vartest2(r,shuffr(:));
[h p2] = ttest2(r,shuffr(:));
p3 = length(find(shuffsigcorr>sigcorr))/shufftrials;%pval for prop of significant cases
p4 = length(find(shuffnegcorr>negcorr))/shufftrials;%pval for prop of sig neg cases
p5 = length(find(shuffposcorr>poscorr))/shufftrials;%pval for prop of sig pos cases
p6 = length(find(shuffdiffcorr > abs(negcorr-poscorr)))/shufftrials;%pval for diff in prop of neg vs pos 

shuffsigcorr_sorted = sort(shuffsigcorr);
shuffsigcorr_lo = shuffsigcorr_sorted(floor(aph*shufftrials/2));
shuffsigcorr_hi = shuffsigcorr_sorted(ceil(shufftrials-(aph*shufftrials/2)));
shuffnegcorr_sorted = sort(shuffnegcorr);
shuffnegcorr_lo = shuffnegcorr_sorted(floor(aph*shufftrials/2));
shuffnegcorr_hi = shuffnegcorr_sorted(ceil(shufftrials-(aph*shufftrials/2)));
shuffposcorr_sorted = sort(shuffposcorr);
shuffposcorr_lo = shuffposcorr_sorted(floor(aph*shufftrials/2));
shuffposcorr_hi = shuffposcorr_sorted(ceil(shufftrials-(aph*shufftrials/2)));

%plot distribution of proportion of significant, negative, positive correlations 
figure;subplot(1,3,1);hold on;
[n b] = hist(shuffsigcorr,[0:0.01:max(shuffsigcorr)]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(shuffsigcorr_hi,y(1),'k^','markersize',8);hold on;
plot(shuffsigcorr_lo,y(1),'k^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(p<=0.05);
plot(mn,y(1),'kd','markersize',8,'markerfacecolor','k');hold on;
plot([lo  hi],[y(1) y(1)],'k','linewidth',4)
title('shuffled vs empirical single units');
xlabel('proportion of significant correlations');ylabel('probability');
set(gca,'fontweight','bold');

subplot(1,3,2);hold on;
[n b] = hist(shuffnegcorr,[0:0.01:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(shuffnegcorr_hi,y(1),'b^','markersize',8);hold on;
plot(shuffnegcorr_lo,y(1),'b^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(p<=0.05 & r<0);
plot(mn,y(1),'bd','markersize',8,'markerfacecolor','b');hold on;
plot([lo  hi],[y(1) y(1)],'b','linewidth',4)
title('shuffled vs empirical single units');
xlabel('proportion of significantly negative correlations');ylabel('probability');
set(gca,'fontweight','bold');

subplot(1,3,3);hold on;
[n b] = hist(shuffposcorr,[0:0.01:0.2]);
stairs(b,n/sum(n),'k','linewidth',2);y=get(gca,'ylim');
plot(shuffposcorr_hi,y(1),'r^','markersize',8);hold on;
plot(shuffposcorr_lo,y(1),'r^','markersize',8);hold on;
[mn hi lo] = jc_BootstrapfreqCI(p<=0.05 & r>0);
plot(mn,y(1),'bd','markersize',8,'markerfacecolor','r');hold on;
plot([lo  hi],[y(1) y(1)],'r','linewidth',4)
title('shuffled vs empirical single units');
xlabel('proportion of significantly positive correlations');ylabel('probability');
set(gca,'fontweight','bold');

%plot distribution of empirical and shuffled correlations
figure;hold on;
[n b] = hist(r,[min(shuffr(:)):0.05:max(shuffr(:))]);
stairs(b,n/sum(n),'r','linewidth',2);hold on;
[n b] = hist(shuffr(:),[min(shuffr(:)):0.05:max(shuffr(:))]);
stairs(b,n/sum(n),'k','linewidth',2);
xlabel('correlation');ylabel('probability');y = get(gca,'ylim');
plot(mean(r),y(1),'r^','markersize',8);hold on;
plot(mean(shuffr(:)),y(1),'k^','markersize',8);hold on;
title('burst with repeat length');
text(0,1,{['total active cases:',num2str(numcases)];...
    ['proportion significant cases:',num2str(sigcorr)];...
    ['proportion significantly negative:',num2str(negcorr)];...
    ['proportion significantly positive:',num2str(poscorr)];...
    ['p(t)=',num2str(p2)];['p(F)=',num2str(p1)];['p(sig)=',num2str(p3)];...
    ['p(neg)=',num2str(p4)];['p(pos)=',num2str(p5)];['p(neg-pos)=',num2str(p6)]},...
    'units','normalized','verticalalignment','top');
%% do all repeat renditions end or start at the same FR level? 
[cases ix] = unique(mmtable(:,{'unitid','seqid'}));
ix = [ix;size(mmtable,1)];
cmap = jet(size(cases,1));
figure;h1 = gca;
figure;h2 = gca;
for i = 1:length(ix)-1
    len = mmtable(ix(i):ix(i+1)-1,:).length;
    pos = mmtable(ix(i):ix(i+1)-1,:).position;
    fr = mmtable(ix(i):ix(i+1)-1,:).FR;
    firstFR = [];lastFR = [];tb1=[];tb2=[];
    for nlen = min(len):max(len)
        ind = find(len==nlen & pos==1);
        if ~isempty(find(~isnan(fr(ind))))
            [hi lo mn] = mBootstrapCI(fr(ind));
            firstFR = [firstFR [hi lo mn]'];
            tb1 = [tb1;nlen];
        end
        ind = find(len==nlen & pos==nlen);
        if ~isempty(find(~isnan(fr(ind))))
            [hi lo mn] = mBootstrapCI(fr(ind));
            lastFR = [lastFR [hi lo mn]'];
            tb2=[tb2;nlen];
        end
    end
    if ~isempty(firstFR)
        hold(h1,'on');
        plot(h1,tb1,firstFR(3,:),'o','color',cmap(i,:));hold on;
        errorbar(h1,tb1,firstFR(3,:),firstFR(1,:)-firstFR(3,:),'color',cmap(i,:),'linewidth',2);
    end
    if ~isempty(lastFR)
        hold(h2,'on');
        plot(h2,tb2,lastFR(3,:),'o','color',cmap(i,:));hold on;
        errorbar(h2,tb2,lastFR(3,:),lastFR(1,:)-lastFR(3,:),'color',cmap(i,:),'linewidth',2);
    end
end
xlabel(h1,'length');ylabel(h1,'starting FR');set(h1,'fontweight','bold');
xlabel(h2,'length');ylabel(h2,'ending FR');set(h2,'fontweight','bold');

%% mixed model to determine relationship between IFR ~ position + length

%%  Is there a relationship between position and IFR? 
%length, position, and FR are not normalized 
%assumptions/caveats: 
%1) that there are uncorrelated random effects on intercept and
%slopes for different factors. 
%2) did not add random effects for bird id 

%test whether to add random effects from length on varying intercept. Yes
formula = 'FR ~ position'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + (1|unitid:seqid:length)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effects from seqid on varying intercept. Yes
formula = 'FR ~ position + (1|unitid:seqid:length)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effects from unitid on varying intercept. No
formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effects from length on varying slope. Yes.
formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid) + (position-1|unitid:seqid:length)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effects from seqid on varying slope. Yes.
formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid) + (position-1|unitid:seqid:length)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid) + (position-1|unitid:seqid:length) + (position-1|unitid:seqid) ';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%position is not related to FR when grouping by length and sequence id 
mdl2

%test whether to add length as another factor. Yes
formula = 'FR ~ position'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + length';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect of seqid on intercept.Yes
formula = 'FR ~ position + length'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + length + (1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect of seqid on slope for position. Yes.
formula = 'FR ~ position + length + (1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect of seqid on slope for length. Yes. 
formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid) + (length-1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%position is not related to FR when controlling for length and grouping by
%seqid 



%test whether to add varying slope grouped by case. Yes.
formula = 'FR ~ position + (1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + (1|unitid:seqid) + (position-1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effects from unitid on varying intercept and
%slope. No. 
formula = 'FR ~ position + (1|unitid:seqid) + (position-1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + (1|unitid:seqid) + (position-1|unitid:seqid) + (position-1|unitid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effects on intercept grouped by case:length. Yes
formula = 'FR ~ position + (1|unitid:seqid) + (position-1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + (1|unitid:seqid) + (position-1|unitid:seqid) + (1|unitid:seqid:length)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effects on slope grouped by case:length. No.
formula = 'FR ~ position + (1|unitid:seqid) + (position-1|unitid:seqid) + (1|unitid:seqid:length)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + (1|unitid:seqid) + (position-1|unitid:seqid) + (1|unitid:seqid:length) + (position-1|unitid:seqid:length)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

formula = 'FR ~ position + (1|unitid:seqid:length) + (position-1|unitid:seqid:length) + (position-1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + (1|unitid:seqid:length) + (position-1|unitid:seqid:length) + (position-1|unitid:seqid) + (1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);



%test whether to add varying intercept grouped by case:rendition. Yes
formula = 'FR ~ position'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + (1|unitid:seqid:rendition)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add varying intercept grouped by case:rendition. Yes
formula = 'FR ~ position + (1|unitid:seqid:rendition)';
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + (1|unitid:seqid:rendition) + (position-1|unitid:seqid:rendition)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add length as fixed effect factor. No
%this model occludes the significant effect of position possibly because 
%position and length are correlated with each other and they might be
%differently correlated with FR. That's why it's ok to group by length? 
formula = 'FR ~ position + (1|unitid:seqid) + (position|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + length + (1|unitid:seqid) + (position|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%Within each repeat rendition or within repeats of the same length, FR
%tends to decrease over position when grouped by length or rendition
%but when only grouped by case, position is not related to FR. 
%Even thought Loglihood for mdl3 is highest, should group by length/rendition 
%it is likely that position and length obscure each other. 
formula = 'FR ~ position + (position-1|unitid:seqid:length) + (1|unitid:seqid:length)';
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ position + (position-1|unitid:seqid:rendition) + (1|unitid:seqid:rendition)';
mdl2 = fitlme(mmtable,formula);
formula = 'FR ~ position + (position-1|unitid:seqid) + (1|unitid:seqid)';
mdl3 = fitlme(mmtable,formula);

%plot fixed estimates + random effects on position for mdl1
[~,~,stats] = randomEffects(mdl1);
beta = fixedEffects(mdl1);beta=beta(2);
ind = find(strcmp(stats.Name,'position'));
figure;hold on;
plot([stats(ind,:).Estimate]+beta,1:length(ind),'k.','markersize',8);hold on;
plot([stats(ind,:).Lower stats(ind,:).Upper]'+beta,repmat((1:length(ind)),2,1),'k');hold on;
plot([0 0],[1 length(ind)],'r','linewidth',2);
xlabel('position beta');ylabel('unitid:seqid:length');
ylim([1 length(ind)]);set(gca,'fontweight','bold');

%% is there a relationship between length and IFR? 

%test whether to add varying intercept grouped by case. Yes
formula = 'FR ~ length'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ length + (1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add varying slope grouped by case. Yes
formula = 'FR ~ length + (1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ length + (1|unitid:seqid) + (length-1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add varying intercept grouped by position. Yes
formula = 'FR ~ length'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ length + (1|unitid:seqid:position)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add varying slope grouped by position. Yes
formula = 'FR ~ length + (1|unitid:seqid:position)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ length + (1|unitid:seqid:position) + (length-1|unitid:seqid:position)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%length is not related to FR either grouped by case or by position (the
%sign is positive)
%grouped by position has higher Log Likelihood 
formula = 'FR ~ length + (length-1|unitid:seqid:position) + (1|unitid:seqid:position)';
mdl5 = fitlme(mmtable,formula);
formula = 'FR ~ length + (length-1|unitid:seqid) + (1|unitid:seqid)';
mdl6 = fitlme(mmtable,formula);

%% is there a relationship between stop vs nostop and IFR? 
nostp = mmtable{:,{'position','length'}};
nostp = nostp(:,1)<nostp(:,2);
mmtable.NoStop = nostp;

%test whether to add varying intercept grouped by case. Yes
formula = 'FR ~ NoStop'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ NoStop + (1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add varying slope grouped by case. Yes
formula = 'FR ~ NoStop + (1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ NoStop + (1|unitid:seqid) + (NoStop-1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add position factor. Yes. 
%position slope is significantly negative
formula = 'FR ~ NoStop + (1|unitid:seqid) + (NoStop-1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ NoStop + position + (1|unitid:seqid) + (NoStop-1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect on position slope grouped by case. Yes. 
%position slope no longer significantly negative. Occlusion from NoStop? 
formula = 'FR ~ NoStop + position + (1|unitid:seqid) + (NoStop-1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ NoStop + position + (1|unitid:seqid) + (NoStop-1|unitid:seqid) + (position-1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%Test whether to add 
formula = 'FR ~ NoStop + (1|unitid:seqid) + (NoStop-1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ NoStop + (1|unitid:seqid:position) + (NoStop-1|unitid:seqid:position) + (1|unitid:seqid) + (NoStop-1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);


formula = 'FR ~ position + NoStop + (position-1|unitid:seqid) + (1|unitid:seqid) + (NoStop-1|unitid:seqid)';
mdl7 = fitlme(mmtable,formula);
formula = 'FR ~ NoStop + (1|unitid:seqid:position) + (NoStop-1|unitid:seqid:position)';
mdl7 = fitlme(mmtable,formula);
formula = 'FR ~ NoStop + (1|unitid:seqid)';
mdl7 = fitlme(mmtable,formula);


%% regress FR at beginning or end with repeat length 
%FR at position 1 ~ length
%FR at last position ~ length
formula = 'FR ~ length + (length-1|unitid:seqid) + (1|unitid:seqid)';
ind1 = mmtable{:,{'position'}}==1;
mdl1 = fitlme(mmtable(ind1,{'unitid','seqid','length','FR'}),formula);

formula = 'FR ~ length + (length-1|unitid:seqid) + (1|unitid:seqid)';
ind2 = mmtable{:,{'position'}}==mmtable{:,{'length'}};
mdl2 = fitlme(mmtable(ind1,{'unitid','seqid','length','FR'}),formula);


