%LMAN lesion analysis: 9_7_2014


%plotting running average
cmap = hsv(length(pre));
winsize = 200;
for i = 1:length(pre)
    pre_n = pre{i}(:,2) - mean(pre{i}(:,2)); %mean subtract
    %runavg = mRunningAvg(pre_n,winsize);
    runavg = conv(pre_n,ones(winsize,1)/winsize,'same');
    figure(1);subplot(1,2,1);hold on;
    plot(pre_tb{i},runavg,'color',cmap(i,:));hold on;
end

cmap = hsv(length(post));
winsize = 200;
for i = 1:length(post)
    post_n = post{i}(:,2) - mean(post{i}(:,2));
    %runavg = mRunningAvg(post_n,winsize);
    runavg = conv(post_n,ones(winsize,1)/winsize,'same');
    figure(1);subplot(1,2,2);hold on;
    plot(post_tb{i},runavg,'color',cmap(i,:));hold on;
end

%z score normalize cells
mean_std = mean(cellfun(@(x) mean(x(:,2)),precell));
precell_n = cellfun(@(x) [x(:,1) (x(:,2)-mean(x(:,2)))/mean_std],precell,'UniformOutput',false);
postcell_n = cellfun(@(x) [x(:,1) (x(:,2)-mean(x(:,2)))/mean_std],postcell,'UniformOutput',false);


%fold change in CV of first 50, last 50, and whole day mean pitch
%(normalized to pre lesion) 
for i = 1:length(allbirds_pitchends)
    
    cv_pre = cv(allbirds_pitchends{i}.pre_pitchends.morn(:,1));
    cv_post = cv(allbirds_pitchends{i}.post_pitchends.morn(:,1));
    figure(4);hold on;plot(1,cv_post/cv_pre,'ok');hold on;
    cv_pre = cv(allbirds_pitchends{i}.pre_pitchends.even(:,1));
    cv_post = cv(allbirds_pitchends{i}.post_pitchends.even(:,1));
    plot(2,cv_post/cv_pre,'ok');hold on;
    cv_pre = cv(allbirds_pitchends{i}.pre_pitchends.day(:,1));
    cv_post = cv(allbirds_pitchends{i}.post_pitchends.mean(:,1));
    plot(3,cv_post/cv_pre,'ok');hold on;

end


%% plotting bout distributions
boutdistr_pre = boutdistr_pre_o50bk72;
boutdistr_post = boutdistr_post_o50bk72;
plt = 10;
minval = min([min(boutdistr_pre.st(:,1)) min(boutdistr_pre.end(:,1)) min(boutdistr_post.st(:,1)) min(boutdistr_post.end(:,1))]);
maxval = max([max(boutdistr_pre.st(:,1)) max(boutdistr_pre.end(:,1)) max(boutdistr_post.st(:,1)) max(boutdistr_post.end(:,1))]); 
figure(plt);hold on;subplot(2,3,1);
[n b] = hist(boutdistr_pre.st(:,1),[minval:5:maxval]);plot(b,n/sum(n),'k');hold on;
[n b] = hist(boutdistr_pre.end(:,1),[minval:5:maxval]);plot(b,n/sum(n),'r');hold on;
title({'pre o50bk72 median pitch'; 'bout start (k) and end (r)'});
figure(plt);hold on;subplot(2,3,4);
[n b] = hist(boutdistr_post.st(:,1),[minval:5:maxval]);plot(b,n/sum(n),'k--');hold on;
[n b] = hist(boutdistr_post.end(:,1),[minval:5:maxval]);plot(b,n/sum(n),'r--');hold on;
title({'post o50bk72 median pitch'; 'bout start (k) and end (r)'});
minval = min([min(boutdistr_pre.inboutchange(:,1)) min(boutdistr_pre.btwnboutchange(:,1)) min(boutdistr_post.inboutchange(:,1)) min(boutdistr_post.btwnboutchange(:,1))]);
maxval = max([max(boutdistr_pre.inboutchange(:,1)) max(boutdistr_pre.btwnboutchange(:,1)) max(boutdistr_post.inboutchange(:,1)) max(boutdistr_post.btwnboutchange(:,1))]); 
figure(plt);hold on;subplot(2,3,2);
[n b] = hist(boutdistr_pre.inboutchange(:,1),[minval:5:maxval]);plot(b,n/sum(n),'k');hold on;
[n b] = hist(boutdistr_pre.btwnboutchange(:,1),[minval:5:maxval]);plot(b,n/sum(n),'r');hold on;
title({'pre o50bk72 pitch change'; 'within (k) and between (r) bouts'});
figure(plt);hold on;subplot(2,3,5);
[n b] = hist(boutdistr_post.inboutchange(:,1),[minval:5:maxval]);plot(b,n/sum(n),'k--');hold on;
[n b] = hist(boutdistr_post.btwnboutchange(:,1),[minval:5:maxval]);plot(b,n/sum(n),'r--');hold on;
title({'post o50bk72 pitch change'; 'within (k) and between (r) bouts'});

[hi lo] = mBootstrapCImed(boutdistr_pre.st(:,1),'')
lerr = median(boutdistr_pre.st(:,1)) - lo;
herr = hi - median(boutdistr_pre.st(:,1));
figure(plt);hold on;subplot(2,3,3);errorbar_x(median(boutdistr_pre.st(:,1)),2,lerr, herr,'k.');
[hi lo] = mBootstrapCImed(boutdistr_pre.end(:,1),'')
lerr = median(boutdistr_pre.end(:,1)) - lo;
herr = hi - median(boutdistr_pre.end(:,1));
figure(plt);hold on;subplot(2,3,3);errorbar_x(median(boutdistr_pre.end(:,1)),2,lerr, herr,'r.');

[hi lo] = mBootstrapCImed(boutdistr_post.st(:,1),'')
lerr = median(boutdistr_post.st(:,1)) - lo;
herr = hi - median(boutdistr_post.st(:,1));
figure(plt);hold on;subplot(2,3,3);errorbar_x(median(boutdistr_post.st(:,1)),1,lerr, herr,'k.');
[hi lo] = mBootstrapCImed(boutdistr_post.end(:,1),'')
lerr = median(boutdistr_post.end(:,1)) - lo;
herr = hi - median(boutdistr_post.end(:,1));
figure(plt);hold on;subplot(2,3,3);errorbar_x(median(boutdistr_post.end(:,1)),1,lerr, herr,'r.');
title('95% CI median bout st (k) and end (r)');
set(gca,'YTick',[0.5:0.5:2.5],'YTickLabel',{'','post','','pre',''});

[hi lo] = mBootstrapCImed(boutdistr_pre.inboutchange(:,1),'')
lerr = median(boutdistr_pre.inboutchange(:,1)) - lo;
herr = hi - median(boutdistr_pre.inboutchange(:,1));
figure(plt);hold on;subplot(2,3,6);errorbar_x(median(boutdistr_pre.inboutchange(:,1)),2,lerr, herr,'k.');
[hi lo] = mBootstrapCImed(boutdistr_pre.btwnboutchange(:,1),'')
lerr = median(boutdistr_pre.btwnboutchange(:,1)) - lo;
herr = hi - median(boutdistr_pre.btwnboutchange(:,1));
figure(plt);hold on;subplot(2,3,6);errorbar_x(median(boutdistr_pre.btwnboutchange(:,1)),2,lerr, herr,'r.');

[hi lo] = mBootstrapCImed(boutdistr_post.inboutchange(:,1),'')
lerr = median(boutdistr_post.inboutchange(:,1)) - lo;
herr = hi - median(boutdistr_post.inboutchange(:,1));
figure(plt);hold on;subplot(2,3,6);errorbar_x(median(boutdistr_post.inboutchange(:,1)),1,lerr, herr,'k.');
[hi lo] = mBootstrapCImed(boutdistr_post.btwnboutchange(:,1),'')
lerr = median(boutdistr_post.btwnboutchange(:,1)) - lo;
herr = hi - median(boutdistr_post.btwnboutchange(:,1));
figure(plt);hold on;subplot(2,3,6);errorbar_x(median(boutdistr_post.btwnboutchange(:,1)),1,lerr, herr,'r.');
title({'95% CI median pitch change'; 'within (k) and between (r) bouts'});
set(gca,'YTick',[0.5:0.5:2.5],'YTickLabel',{'','post','','pre',''});

%% bout fit plots
%slope distributions
plt = 12;
boutfits_pre = boutfits_pre_o50bk72_time;
boutfits_post = boutfits_post_o50bk72_time;
minval = min([min(boutfits_pre.coeff(:,1)) min(boutfits_post.coeff(:,1))]);
maxval = max([max(boutfits_pre.coeff(:,1)) max(boutfits_post.coeff(:,1))]);
figure(plt);hold on;subplot(2,4,1);
[n b] = hist(boutfits_pre.coeff(:,1),[minval:2:maxval]);plot(b,n/sum(n),'k');hold on;
[n b] = hist(boutfits_post.coeff(:,1),[minval:2:maxval]);plot(b,n/sum(n),'r');hold on;
title('o50bk72 pre (k) and post (r) slope pdf');
%slope vs bout length
minval = min([min(boutfits_pre.length) min(boutfits_post.length)]);
maxval = max([max(boutfits_post.length) max(boutfits_post.length)]);
figure(plt);hold on;subplot(2,4,2);
[n b] = hist(boutfits_pre.length,[minval:2:maxval]);plot(b,n/sum(n),'k');hold on;
[n b] = hist(boutfits_post.length,[minval:2:maxval]);plot(b,n/sum(n),'r');hold on
title('bout length distribution in renditions');
%in bout changes
minval = min([min(boutfits_pre.inboutchange) min(boutfits_pre.btwnboutchange) min(boutfits_post.inboutchange) min(boutfits_post.btwnboutchange)]);
maxval = max([max(boutfits_pre.inboutchange) max(boutfits_pre.btwnboutchange) max(boutfits_post.inboutchange) max(boutfits_post.btwnboutchange)]);
figure(plt);hold on;subplot(2,4,3);
[n b] = hist(boutfits_pre.inboutchange,[minval:5:maxval]);plot(b,n/sum(n),'k');hold on;
[n b] = hist(boutfits_post.inboutchange,[minval:5:maxval]);plot(b,n/sum(n),'r');hold on;
title('within bout pitch change pdf');
%btwn bout changes
figure(plt);hold on;subplot(2,4,4);
[n b] = hist(boutfits_pre.btwnboutchange,[minval:2:maxval]);plot(b,n/sum(n),'k');hold on;
[n b] = hist(boutfits_post.btwnboutchange,[minval:2:maxval]);plot(b,n/sum(n),'r');hold on;
title('between bout pitch change pdf');
%bout st distr
minval = min([boutfits_pre.st; boutfits_post.st; boutfits_pre.end; boutfits_post.end]);
maxval = max([boutfits_pre.st; boutfits_post.st; boutfits_pre.end; boutfits_post.end]);
figure(plt);hold on;subplot(2,4,5);
[n b] = hist(boutfits_pre.st,[minval:5:maxval]);plot(b,n/sum(n),'k');hold on;
[n b] = hist(boutfits_post.st,[minval:5:maxval]);plot(b,n/sum(n),'r');hold on;
title('bout st pdf');
%bout end distr
figure(plt);hold on;subplot(2,4,6);
[n b] = hist(boutfits_pre.end,[minval:5:maxval]);plot(b,n/sum(n),'k');hold on;
[n b] = hist(boutfits_post.end,[minval:5:maxval]);plot(b,n/sum(n),'r');hold on;
title('bout end pdf');
%95% CI for in and btwn bout changes
[hi lo] = mBootstrapCI(boutfits_pre.inboutchange,'');
lerr = mean(boutfits_pre.inboutchange)-lo; herr = hi-mean(boutfits_pre.inboutchange);
figure(plt);hold on;subplot(2,4,7);errorbar_x(mean(boutfits_pre.inboutchange),2,lerr,herr,'k.');
[hi lo] = mBootstrapCI(boutfits_pre.btwnboutchange,'');
lerr = mean(boutfits_pre.btwnboutchange)-lo; herr = hi-mean(boutfits_pre.btwnboutchange);
figure(plt);hold on;subplot(2,4,7);errorbar_x(mean(boutfits_pre.btwnboutchange),2,lerr,herr,'r.');

[hi lo] = mBootstrapCI(boutfits_post.inboutchange,'');
lerr = mean(boutfits_post.inboutchange)-lo; herr = hi-mean(boutfits_post.inboutchange);
figure(plt);hold on;subplot(2,4,7);errorbar_x(mean(boutfits_post.inboutchange),1,lerr,herr,'k.');
[hi lo] = mBootstrapCI(boutfits_post.btwnboutchange,'');
lerr = mean(boutfits_post.btwnboutchange)-lo; herr = hi-mean(boutfits_post.btwnboutchange);
figure(plt);hold on;subplot(2,4,7);errorbar_x(mean(boutfits_post.btwnboutchange),1,lerr,herr,'r.');
title({'95% CI mean pitch change';'within (k) and between (r) bouts'});
set(gca,'YTick',[0.5:0.5:2.5],'YTickLabel',{'','post','','pre',''});
%95% CI for st and end bout pitch
[hi lo] = mBootstrapCI(boutfits_pre.st,'');
lerr = mean(boutfits_pre.st)-lo;herr = hi-mean(boutfits_pre.st);
figure(plt);hold on;subplot(2,4,8);errorbar_x(mean(boutfits_pre.st),2,lerr,herr,'k.');
[hi lo] = mBootstrapCI(boutfits_pre.end,'');
lerr = mean(boutfits_pre.end)-lo;herr = hi-mean(boutfits_pre.end);
figure(plt);hold on;subplot(2,4,8);errorbar_x(mean(boutfits_pre.end),2,lerr,herr,'r.');

[hi lo] = mBootstrapCI(boutfits_post.st,'');
lerr = mean(boutfits_post.st)-lo;herr = hi-mean(boutfits_post.st);
figure(plt);hold on;subplot(2,4,8);errorbar_x(mean(boutfits_post.st),1,lerr,herr,'k.');
[hi lo] = mBootstrapCI(boutfits_post.end,'');
lerr = mean(boutfits_post.end)-lo;herr = hi-mean(boutfits_post.end);
figure(plt);hold on;subplot(2,4,8);errorbar_x(mean(boutfits_post.end),1,lerr,herr,'r.');
title({'95% CI mean pitch';'bout start (k) and end (r)'});
set(gca,'YTick',[0.5:0.5:2.5],'YTickLabel',{'','post','','pre',''});

%% summary bout data across all birds
% zscore normalized 95% CI for medians
plt = 12;
boutfits_pre = boutfits_pre_o50bk72;
boutfits_post = boutfits_post_o50bk72;
%slope distr
pre = (boutfits_pre.coeff(:,1) - mean(boutfits_pre.coeff(:,1)))/std(boutfits_pre.coeff(:,1));
post = (boutfits_post.coeff(:,1) - mean(boutfits_post.coeff(:,1)))/std(boutfits_pre.coeff(:,1));
[hi lo] = mBootstrapCImed(pre,'');
lerr = median(boutfits_pre.coeff(:,1))-lo;herr=hi-median(boutfits_pre.coeff(:,1));
figure(plt);hold on;subplot(1,5,1);errorbar(1,median(boutfits_pre.coeff(:,1)),lerr,herr,'k.');
[hi lo] = mBootstrapCImed(post,'');
lerr = median(boutfits_post.coeff(:,1))-lo;herr=hi-median(boutfits_post.coeff(:,1));
figure(plt);hold on;subplot(1,5,1);errorbar(2,median(boutfits_post.coeff(:,1)),lerr,herr,'r.');hold on;
plot([1 2],[median(boutfits_pre.coeff(:,1)) median(boutfits_post.coeff(:,1))],'k');
%bout st from fits 
pre = (boutfits_pre.st - mean(boutfits_pre.st))/std(boutfits_pre.st);
post = (boutfits_post.st - mean(boutfits_post.st))/std(boutfits_pre.st);
[hi lo] = mBootstrapCImed(pre,'');
lerr = median(boutfits_pre.st)-lo;herr=hi-median(boutfits_pre.st);
figure(plt);hold on;subplot(1,5,2);errorbar(1,median(boutfits_pre.st),lerr,herr,'k.');
[hi lo] = mBootstrapCImed(post,'');
lerr = median(boutfits_post.st)-lo;herr=hi-median(boutfits_post.st);
figure(plt);hold on;subplot(1,5,2);errorbar(2,median(boutfits_post.st),lerr,herr,'r.');hold on;
plot([1 2],[median(boutfits_pre.st) median(boutfits_post.st)],'k');
%bout end from fits
pre = (boutfits_pre.end - mean(boutfits_pre.end))/std(boutfits_pre.end);
post = (boutfits_post.end - mean(boutfits_post.end))/std(boutfits_pre.end);
[hi lo] = mBootstrapCImed(pre,'');
lerr = median(boutfits_pre.end)-lo;herr=hi-median(boutfits_pre.end);
figure(plt);hold on;subplot(1,5,3);errorbar(1,median(boutfits_pre.end),lerr,herr,'k.');
[hi lo] = mBootstrapCImed(post,'');
lerr = median(boutfits_post.end)-lo;herr=hi-median(boutfits_post.end);
figure(plt);hold on;subplot(1,5,3);errorbar(2,median(boutfits_post.end),lerr,herr,'r.');hold on;
plot([1 2],[median(boutfits_pre.end) median(boutfits_post.end)],'k');
%withinbout change from fits
pre = (boutfits_pre.inboutchange - mean(boutfits_pre.inboutchange))/std(boutfits_pre.inboutchange);
post = (boutfits_post.inboutchange - mean(boutfits_post.inboutchange))/std(boutfits_pre.inboutchange);
[hi lo] = mBootstrapCImed(pre,'');
lerr = median(boutfits_pre.inboutchange)-lo;herr=hi-median(boutfits_pre.inboutchange);
figure(plt);hold on;subplot(1,5,4);errorbar(1,median(boutfits_pre.inboutchange),lerr,herr,'k.');
[hi lo] = mBootstrapCImed(post,'');
lerr = median(boutfits_post.inboutchange)-lo;herr=hi-median(boutfits_post.inboutchange);
figure(plt);hold on;subplot(1,5,4);errorbar(2,median(boutfits_post.inboutchange),lerr,herr,'r.');hold on;
plot([1 2],[median(boutfits_pre.inboutchange) median(boutfits_post.inboutchange)],'k');
%btwnboutchange from fits
pre = (boutfits_pre.btwnboutchange - mean(boutfits_pre.btwnboutchange))/std(boutfits_pre.btwnboutchange);
post = (boutfits_post.btwnboutchange - mean(boutfits_post.btwnboutchange))/std(boutfits_pre.btwnboutchange);
[hi lo] = mBootstrapCImed(pre,'');
lerr = median(boutfits_pre.btwnboutchange)-lo;herr=hi-median(boutfits_pre.btwnboutchange);
figure(plt);hold on;subplot(1,5,5);errorbar(1,median(boutfits_pre.btwnboutchange),lerr,herr,'k.');
[hi lo] = mBootstrapCImed(post,'');
lerr = median(boutfits_post.btwnboutchange)-lo;herr=hi-median(boutfits_post.btwnboutchange);
figure(plt);hold on;subplot(1,5,5);errorbar(2,median(boutfits_post.btwnboutchange),lerr,herr,'r.');hold on;
plot([1 2],[median(boutfits_pre.btwnboutchange) median(boutfits_post.btwnboutchange)],'k');

