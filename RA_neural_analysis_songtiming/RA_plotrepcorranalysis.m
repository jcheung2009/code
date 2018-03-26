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
[~,ixd] = unique(mmtable(:,{'unitid','seqid'}),'last');
cmap = jet(size(cases,1));
figure;h1 = gca;
figure;h2 = gca;
for i = 1:length(ix)-1
    len = mmtable(ix(i):ixd(i),:).length;
    pos = mmtable(ix(i):ixd(i),:).position;
    fr = mmtable(ix(i):ixd(i),:).FR;
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
%2) test random effects with most (lowest) levels before expanding out

    % model with length as a random effect
    %test whether to add random effects from length on varying intercept. Yes
    formula = 'FR ~ position'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + (1|unitid:seqid:length)';%position is significantly negative
    mdl2 = fitlme(mmtable,formula);
    compare(mdl1,mdl2,'CheckNesting',true);

    %test whether to add random effects from seqid on varying intercept. Yes
    formula = 'FR ~ position + (1|unitid:seqid:length)'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid)';%position is significantly negative
    mdl2 = fitlme(mmtable,formula);
    compare(mdl1,mdl2,'CheckNesting',true);

    %test whether to add random effects from unitid on varying intercept. No
    formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid)'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid) + (1|unitid)';
    mdl2 = fitlme(mmtable,formula);
    compare(mdl1,mdl2,'CheckNesting',true);

    %No difference in log likelihood of adding random effects from birdid on
    %varying intercept. 
    formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid)';
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid) + (1|birdid)';
    mdl2 = fitlme(mmtable,formula);

    %test whether to add random effects from length on varying slope. Yes.
    formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid)'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid) + (position-1|unitid:seqid:length)';%position is significantly negative
    mdl2 = fitlme(mmtable,formula);
    compare(mdl1,mdl2,'CheckNesting',true);

    %test whether to add random effects from seqid on varying slope. Yes.
    formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid) + (position-1|unitid:seqid:length)'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid) + (position-1|unitid:seqid:length) + (position-1|unitid:seqid) ';%position is NOT significantly negative
    mdl2 = fitlme(mmtable,formula);
    compare(mdl1,mdl2,'CheckNesting',true);

    %test whether to add random effects from birdid on varying slope. No.
    formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid) + (position-1|unitid:seqid:length) + (position-1|unitid:seqid) '
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid) + (position-1|unitid:seqid:length) + (position-1|unitid:seqid) + (position-1|birdid)';
    mdl2 = fitlme(mmtable,formula);
    compare(mdl1,mdl2,'CheckNesting',true);

%Therefore, position is not related to FR when grouping by length and sequence id 
formula = 'FR ~ position + (1|unitid:seqid:length) + (1|unitid:seqid) + (position-1|unitid:seqid:length) + (position-1|unitid:seqid) '
mdl1 = fitlme(mmtable,formula);
%plot fixed estimates + random effects on position for mdl1
[~,~,stats] = randomEffects(mdl1);
beta = fixedEffects(mdl1);beta=beta(2);
ind = find(strcmp(stats.Name,'position') & strcmp(stats.Group,'unitid:seqid'));
figure;subplot(1,2,1);hold on;
plot([stats(ind,:).Estimate]+beta,1:length(ind),'k.','markersize',8);hold on;
plot([stats(ind,:).Lower stats(ind,:).Upper]'+beta,repmat((1:length(ind)),2,1),'k');hold on;
plot([0 0],[1 length(ind)],'r','linewidth',2);
xlabel('position beta');ylabel('unitid:seqid');
ylim([1 length(ind)]);set(gca,'fontweight','bold');
ind = find(strcmp(stats.Name,'position') & strcmp(stats.Group,'unitid:seqid:length'));
subplot(1,2,2);hold on;
plot([stats(ind,:).Estimate]+beta,1:length(ind),'k.','markersize',8);hold on;
plot([stats(ind,:).Lower stats(ind,:).Upper]'+beta,repmat((1:length(ind)),2,1),'k');hold on;
plot([0 0],[1 length(ind)],'r','linewidth',2);
xlabel('position beta');ylabel('unitid:seqid:length');
ylim([1 length(ind)]);set(gca,'fontweight','bold');

    %model with length as a fixed effect
    %test whether to add length as another factor. Yes
    formula = 'FR ~ position'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + length';
    mdl2 = fitlme(mmtable,formula);%position is significantly negative, length is significantly positive
    compare(mdl1,mdl2,'CheckNesting',true);

    %test whether to add random effect of seqid on intercept.Yes
    formula = 'FR ~ position + length'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + length + (1|unitid:seqid)';
    mdl2 = fitlme(mmtable,formula);%position is significantly negative, length is significantly positive
    compare(mdl1,mdl2,'CheckNesting',true);

    %test whether to add random effect of unitid on intercept. No. 
    formula = 'FR ~ position + length  + (1|unitid:seqid)'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + length + (1|unitid:seqid) + (1|unitid)';
    mdl2 = fitlme(mmtable,formula);
    compare(mdl1,mdl2,'CheckNesting',true);

    %test whether to add random effect of birdid on intercept. No. 
    formula = 'FR ~ position + length  + (1|unitid:seqid)'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + length + (1|unitid:seqid) + (1|birdid)';
    mdl2 = fitlme(mmtable,formula);
    compare(mdl1,mdl2,'CheckNesting',true);

    %test whether to add random effect of seqid on slope for position. Yes.
    formula = 'FR ~ position + length + (1|unitid:seqid)'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid)';
    mdl2 = fitlme(mmtable,formula);%position and length are NOT significant
    compare(mdl1,mdl2,'CheckNesting',true);

    %test whether to add random effect of seqid on slope for length. Yes. 
    formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid)'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid) + (length-1|unitid:seqid)';
    mdl2 = fitlme(mmtable,formula);%position and length are NOT significant
    compare(mdl1,mdl2,'CheckNesting',true);

    %test whether to add random effect of unitid on slope for position. No.
    formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid) + (length-1|unitid:seqid)'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid) + (length-1|unitid:seqid) + (position-1|unitid)';
    mdl2 = fitlme(mmtable,formula);
    compare(mdl1,mdl2,'CheckNesting',true);

    %test whether to add random effect of unitid on slope for length. No.
    formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid) + (length-1|unitid:seqid)'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid) + (length-1|unitid:seqid) + (length-1|unitid)';
    mdl2 = fitlme(mmtable,formula);
    compare(mdl1,mdl2,'CheckNesting',true);

    %test whether to add random effect of birdid on slope for position. No
    formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid) + (length-1|unitid:seqid)'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid) + (length-1|unitid:seqid) + (position-1|birdid)';
    mdl2 = fitlme(mmtable,formula);
    compare(mdl1,mdl2,'CheckNesting',true);

    %test whether to add random effect of birdid on slope for length. No
    formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid) + (length-1|unitid:seqid)'
    mdl1 = fitlme(mmtable,formula);
    formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid) + (length-1|unitid:seqid) + (length-1|birdid)';
    mdl2 = fitlme(mmtable,formula);
    compare(mdl1,mdl2,'CheckNesting',true);

    %position is not related to FR when controlling for length and grouping by
    %seqid 
    %length is not related to FR when controlling for position and grouping by
    %seqid
    formula = 'FR ~ position + length + (1|unitid:seqid) + (position-1|unitid:seqid) + (length-1|unitid:seqid)'
    mdl1 = fitlme(mmtable,formula);

%plot FR across positions grouped by length and seqid 
[cases ix] = unique(mmtable(:,{'unitid','seqid'}));
[~,ixd] = unique(mmtable(:,{'unitid','seqid'}),'last');
cmap = jet(size(cases,1));
figure;h1 = subplot(1,2,1);h2=subplot(1,2,2);
for i = 1:length(ix)
    len = mmtable(ix(i):ixd(i),:).length;
    pos = mmtable(ix(i):ixd(i),:).position;
    fr = mmtable(ix(i):ixd(i),:).FR;
    rendition = mmtable(ix(i):ixd(i),:).rendition;
    for nlen = min(len):max(len)
        ind = find(len==nlen);
        rendid = unique(rendition(ind));
        if ~isempty(ind)
            FRpattern = NaN(length(rendid),nlen);
            for numrend = 1:length(rendid)
               FRpattern(numrend,pos(rendition==rendid(numrend))) = fr(rendition==rendid(numrend));
            end
            FRpattern = nanmean(FRpattern);
            hold(h1,'on');
            plot(h1,FRpattern','color',cmap(i,:),'linewidth',2);
             if ~isnan(FRpattern(1))
                FRpattern = FRpattern./FRpattern(:,1);
                hold(h2,'on');
                plot(h2,FRpattern','color',cmap(i,:),'linewidth',2);
             end
        end
    end
end
xlabel(h1,'position');ylabel('Hz');set(h1,'fontweight','bold');
xlabel(h2,'position');ylabel(h2,'normalized FR');set(h2,'fontweight','bold');
title(h1,'grouped by length and case');

%% is there a relationship between length and IFR? 

%test whether to add random effect of position on intercept. Yes
formula = 'FR ~ length'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ length + (1|unitid:seqid:position)';
mdl2 = fitlme(mmtable,formula);%length is not significant
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect of seqid on intercept. Yes
formula = 'FR ~ length + (1|unitid:seqid:position)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ length + (1|unitid:seqid:position) + (1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);%length is not significant
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect of unitid on intercept. No
formula = 'FR ~ length + (1|unitid:seqid:position) + (1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ length + (1|unitid:seqid:position) + (1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(mmtable,formula);%length is not significant
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect of birdid on intercept. No
formula = 'FR ~ length + (1|unitid:seqid:position) + (1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ length + (1|unitid:seqid:position) + (1|unitid:seqid) + (1|birdid)';
mdl2 = fitlme(mmtable,formula);%length is not significant
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect of position on slope. Yes
formula = 'FR ~ length + (1|unitid:seqid:position) + (1|unitid:seqid)';
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ length + (1|unitid:seqid:position) + (1|unitid:seqid) + (length-1|unitid:seqid:position)';
mdl2 = fitlme(mmtable,formula);%length is not significant
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect of seqid on slope. Yes
formula = 'FR ~ length + (1|unitid:seqid:position) + (1|unitid:seqid) + (length-1|unitid:seqid:position)';
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ length + (1|unitid:seqid:position) + (1|unitid:seqid) + (length-1|unitid:seqid:position) + (length-1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);%length is not significant
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect of unitid on slope. No
formula = 'FR ~ length + (1|unitid:seqid:position) + (1|unitid:seqid) + (length-1|unitid:seqid:position) + (length-1|unitid:seqid)';
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ length + (1|unitid:seqid:position) + (1|unitid:seqid) + (length-1|unitid:seqid:position) + (length-1|unitid:seqid) + (length-1|unitid)';
mdl2 = fitlme(mmtable,formula);%length is not significant
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect of birdid on slope. No. Mdl2 has lower
%log likelihood
formula = 'FR ~ length + (1|unitid:seqid:position) + (1|unitid:seqid) + (length-1|unitid:seqid:position) + (length-1|unitid:seqid)';
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ length + (1|unitid:seqid:position) + (1|unitid:seqid) + (length-1|unitid:seqid:position) + (length-1|unitid:seqid) + (length-1|birdid)';
mdl2 = fitlme(mmtable,formula);%length is not significant

%Therefore, length is not significantly related to FR 
formula = 'FR ~ length + (1|unitid:seqid:position) + (1|unitid:seqid) + (length-1|unitid:seqid:position) + (length-1|unitid:seqid)';
mdl1 = fitlme(mmtable,formula);
%plot fixed estimates + random effects on position for mdl1
[~,~,stats] = randomEffects(mdl1);
beta = fixedEffects(mdl1);beta=beta(2);
ind = find(strcmp(stats.Name,'length') & strcmp(stats.Group,'unitid:seqid'));
figure;subplot(1,2,1);hold on;
plot([stats(ind,:).Estimate]+beta,1:length(ind),'k.','markersize',8);hold on;
plot([stats(ind,:).Lower stats(ind,:).Upper]'+beta,repmat((1:length(ind)),2,1),'k');hold on;
plot([0 0],[1 length(ind)],'r','linewidth',2);
xlabel('length beta');ylabel('unitid:seqid');
ylim([1 length(ind)]);set(gca,'fontweight','bold');
ind = find(strcmp(stats.Name,'length') & strcmp(stats.Group,'unitid:seqid:position'));
subplot(1,2,2);hold on;
plot([stats(ind,:).Estimate]+beta,1:length(ind),'k.','markersize',8);hold on;
plot([stats(ind,:).Lower stats(ind,:).Upper]'+beta,repmat((1:length(ind)),2,1),'k');hold on;
plot([0 0],[1 length(ind)],'r','linewidth',2);
xlabel('length beta');ylabel('unitid:seqid:length');
ylim([1 length(ind)]);set(gca,'fontweight','bold');

%plot FR over length grouped by position and seqid 
[cases ix] = unique(mmtable(:,{'unitid','seqid'}));
[~,ixd] = unique(mmtable(:,{'unitid','seqid'}),'last');
cmap = jet(size(cases,1));
figure;h1 = subplot(1,2,1);h2=subplot(1,2,2);
for i = 1:length(ix)
    len = mmtable(ix(i):ixd(i),:).length;
    pos = mmtable(ix(i):ixd(i),:).position;
    fr = mmtable(ix(i):ixd(i),:).FR;
    rendition = mmtable(ix(i):ixd(i),:).rendition;
    for npos = 1:max(len)
        ind = find(pos==npos);
        rendid = unique(rendition(ind));
        if ~isempty(ind)
            FRpattern = NaN(length(rendid),length(unique(len(ind))));
            for numrend = 1:length(rendid)
                FRpattern(numrend,len(rendition==rendid(numrend))) = fr(rendition==rendid(numrend));
            end
            FRpattern = nanmean(FRpattern,1);
            hold(h1,'on');
            plot(h1,FRpattern','color',cmap(i,:),'linewidth',2);
            FRpattern = FRpattern./FRpattern(min(find(~isnan(FRpattern))));
            hold(h2,'on');
            plot(h2,FRpattern,'color',cmap(i,:),'linewidth',2);
        end
    end
end
xlabel(h1,'length');ylabel('Hz');set(h1,'fontweight','bold');
xlabel(h2,'length');ylabel(h2,'normalized FR');set(h2,'fontweight','bold');      
title(h1,'grouped by position and case');
title(h2,'grouped by position and case');
%% is there a relationship between stop vs nostop and IFR? 
nostp = mmtable{:,{'position','length'}};
nostp = nostp(:,1)<nostp(:,2);
mmtable.NoStop = nostp;

%test whether to add random effect of position on intercept. Yes
formula = 'FR ~ NoStop'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ NoStop + (1|unitid:seqid:position)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect of seqid on intercept. Yes
formula = 'FR ~ NoStop + (1|unitid:seqid:position)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ NoStop + (1|unitid:seqid:position) + (1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect of unitid on intercept. No
formula = 'FR ~ NoStop + (1|unitid:seqid:position) + (1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ NoStop + (1|unitid:seqid:position) + (1|unitid:seqid) + (1|unitid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);


%test whether to add random effect of position on slope. Yes
formula = 'FR ~ NoStop + (1|unitid:seqid:position) + (1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ NoStop + (1|unitid:seqid:position) + (1|unitid:seqid) + (NoStop-1|unitid:seqid:position)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect of seqid on slope. Yes
formula = 'FR ~ NoStop + (1|unitid:seqid:position) + (1|unitid:seqid) + (NoStop-1|unitid:seqid:position)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ NoStop + (1|unitid:seqid:position) + (1|unitid:seqid) + (NoStop-1|unitid:seqid:position) + (NoStop-1|unitid:seqid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test whether to add random effect of unitid on slope. No
formula = 'FR ~ NoStop + (1|unitid:seqid:position) + (1|unitid:seqid) + (NoStop-1|unitid:seqid:position) + (NoStop-1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
formula = 'FR ~ NoStop + (1|unitid:seqid:position) + (1|unitid:seqid) + (NoStop-1|unitid:seqid:position) + (NoStop-1|unitid:seqid) + (NoStop-1|unitid)';
mdl2 = fitlme(mmtable,formula);
compare(mdl1,mdl2,'CheckNesting',true);

%Therefore, Not Stopping is not related to FR when grouped by position and
%seqid
formula = 'FR ~ NoStop + (1|unitid:seqid:position) + (1|unitid:seqid) + (NoStop-1|unitid:seqid:position) + (NoStop-1|unitid:seqid)'
mdl1 = fitlme(mmtable,formula);
%plot fixed estimates + random effects on position for mdl1
[~,~,stats] = randomEffects(mdl1);
beta = fixedEffects(mdl1);beta=beta(2);
ind = find(strcmp(stats.Name,'NoStop_1') & strcmp(stats.Group,'unitid:seqid'));
figure;subplot(1,2,1);hold on;
plot([stats(ind,:).Estimate]+beta,1:length(ind),'k.','markersize',8);hold on;
plot([stats(ind,:).Lower stats(ind,:).Upper]'+beta,repmat((1:length(ind)),2,1),'k');hold on;
plot([0 0],[1 length(ind)],'r','linewidth',2);
xlabel('NoStop beta');ylabel('unitid:seqid');
ylim([1 length(ind)]);set(gca,'fontweight','bold');
ind = find(strcmp(stats.Name,'NoStop_1') & strcmp(stats.Group,'unitid:seqid:position'));
subplot(1,2,2);hold on;
plot([stats(ind,:).Estimate]+beta,1:length(ind),'k.','markersize',8);hold on;
plot([stats(ind,:).Lower stats(ind,:).Upper]'+beta,repmat((1:length(ind)),2,1),'k');hold on;
plot([0 0],[1 length(ind)],'r','linewidth',2);
xlabel('NoStop beta');ylabel('unitid:seqid:position');
ylim([1 length(ind)]);set(gca,'fontweight','bold');


%plot FR vs NoStop grouped by position and seqid 
[cases ix] = unique(mmtable(:,{'unitid','seqid'}));
[~,ixd] = unique(mmtable(:,{'unitid','seqid'}),'last');
cmap = jet(size(cases,1));
figure;h1 = gca;
for i = 1:length(ix)
    nstop = mmtable(ix(i):ixd(i),:).NoStop;
    pos = mmtable(ix(i):ixd(i),:).position;
    fr = mmtable(ix(i):ixd(i),:).FR;
    rendition = mmtable(ix(i):ixd(i),:).rendition;
    FRpattern_nostop= [];FRpattern_stop = [];
    for npos = 1:max(pos)
        ind = find(pos==npos & nstop==0);
        FRpattern_nostop = [FRpattern_nostop; fr(ind)];
        ind = find(pos==npos & nstop==1);
        FRpattern_stop = [FRpattern_stop; fr(ind)];
    end
    hold(h1,'on');
    plot(h1,[1 2],[nanmean(FRpattern_stop) nanmean(FRpattern_nostop)]./...
        nanmean(FRpattern_stop),'-o','color',cmap(i,:),'linewidth',2);
end
set(h1,'xtick',[1 2],'xticklabels',{'stop','nostop'});xlim([0.5 2.5])
ylabel('normalized FR');set(h1,'fontweight','bold');
title('grouped by position and seqid');

%% regress FR at beginning or end with repeat length 
%FR at position 1 ~ length
%FR at last position ~ length
%neither show significantly relationship of length and FR

ind1 = mmtable{:,{'position'}}==1;

%test adding random effect of sequence ID on intercept. Yes
formula = 'FR ~ length';
mdl1 = fitlme(mmtable(ind1,{'unitid','seqid','length','FR','position'}),formula);
formula = 'FR ~ length + (1|unitid:seqid)';
mdl2 = fitlme(mmtable(ind1,{'unitid','seqid','length','FR','position'}),formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test adding random effect of sequence ID on slope. No. NO difference in
%log likelihood
formula = 'FR ~ length + (1|unitid:seqid)';
mdl1 = fitlme(mmtable(ind1,{'unitid','seqid','length','FR','position'}),formula);
formula = 'FR ~ length + (1|unitid:seqid) + (length-1|unitid:seqid)';
mdl2 = fitlme(mmtable(ind1,{'unitid','seqid','length','FR','position'}),formula);

%Therefore, firing at beginning of repeat is not related to length
formula = 'FR ~ length + (1|unitid:seqid)';
mdl1 = fitlme(mmtable(ind1,{'unitid','seqid','length','FR','position'}),formula);


ind2 = mmtable{:,{'position'}}==mmtable{:,{'length'}};

%test adding random effect of sequence ID on intercept. Yes
formula = 'FR ~ length';
mdl1 = fitlme(mmtable(ind2,{'unitid','seqid','length','FR','position'}),formula);
formula = 'FR ~ length + (1|unitid:seqid)';
mdl2 = fitlme(mmtable(ind2,{'unitid','seqid','length','FR','position'}),formula);
compare(mdl1,mdl2,'CheckNesting',true);

%test adding random effect of sequence ID on slope. Yes
formula = 'FR ~ length + (1|unitid:seqid)';
mdl1 = fitlme(mmtable(ind2,{'unitid','seqid','length','FR','position'}),formula);
formula = 'FR ~ length + (1|unitid:seqid) + (length-1|unitid:seqid)';
mdl2 = fitlme(mmtable(ind2,{'unitid','seqid','length','FR','position'}),formula);
compare(mdl1,mdl2,'CheckNesting',true);

%Therefore, firing at end of repeat is not related to length
formula = 'FR ~ length + (1|unitid:seqid) + (length-1|unitid:seqid)';
mdl2 = fitlme(mmtable(ind2,{'unitid','seqid','length','FR','position'}),formula);


