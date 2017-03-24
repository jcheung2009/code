function [pre_pitchends post_pitchends] = jc_pitch(pre,post,nsamp,plotit);
%plots subset of points at beginning or end of day for data set

pre_first = [];
pre_last = [];
pre_mean = [];
for i = 1:length(pre)
    first_mn = mean(pre{i}(1:nsamp,2));
    [first_hCI first_lCI] = mBootstrapCI(pre{i}(1:nsamp,2),'');
    last_mn = mean(pre{i}(end-nsamp+1:end,2));
    [last_hCI last_lCI] = mBootstrapCI(pre{i}(end-nsamp+1:end,2),'');
    day_mn = mean(pre{i}(:,2));
    [daymn_hCI daymn_lCI] = mBootstrapCI(pre{i}(:,2),'');
    
    pre_first = cat(1,pre_first,[first_mn first_hCI first_lCI]);
    pre_last = cat(1,pre_last,[last_mn last_hCI last_lCI]);
    pre_mean = cat(1,pre_mean,[day_mn daymn_hCI daymn_lCI]);
    
end

post_first = [];
post_last = [];
post_mean = [];
for i = 1:length(post)
    first_mn = mean(post{i}(1:nsamp,2));
    [first_hCI first_lCI] = mBootstrapCI(post{i}(1:nsamp,2),'');
    last_mn = mean(post{i}(end-nsamp+1:end,2));
    [last_hCI last_lCI] = mBootstrapCI(post{i}(end-nsamp+1:end,2),'');
    day_mn = mean(post{i}(:,2));
    [daymn_hCI daymn_lCI] = mBootstrapCI(post{i}(:,2),'');
    
    post_first = cat(1,post_first,[first_mn first_hCI first_lCI]);
    post_last = cat(1,post_last,[last_mn last_hCI last_lCI]);
    post_mean = cat(1,post_mean,[day_mn daymn_hCI daymn_lCI]);
end



if plotit ~= 0

    %plotting first renditions
     for i = 1:length(pre_first)
        figure(plotit);hold on;subplot(1,3,1);hold on;
        plot([1 1],pre_first(i,2:3),'k');hold on;
        plot(1,pre_first(i,1),'ok');hold on;
     end
     
     for i = 1:length(post_first)
         figure(plotit);hold on;subplot(1,3,1);hold on;
        plot([2 2],post_first(i,2:3),'r');hold on;
        plot(2,post_first(i,1),'or');hold on;
     end
     
     %plotting last renditions
     for i = 1:length(pre_last)
         figure(plotit);hold on;subplot(1,3,2);hold on;
         plot([1 1],pre_last(i,2:3),'k');hold on;
         plot(1,pre_last(i,1),'ok');hold on;
     end
     
     for i = 1:length(post_last)
         figure(plotit);hold on;subplot(1,3,2);hold on;
         plot([2 2],post_last(i,2:3),'r');hold on;
         plot(2,post_last(i,1),'or');hold on;
     end
     
     %plotting whole day mean 
     for i = 1:length(pre_mean)
         figure(plotit);hold on;subplot(1,3,3);hold on;
         plot([1 1],pre_mean(i,2:3),'k');hold on;
         plot(1,pre_mean(i,1),'ok');hold on;
     end
     
     for i = 1:length(post_mean)
         figure(plotit);hold on;subplot(1,3,3);hold on;
         plot([2 2],post_mean(i,2:3),'r');hold on;
         plot(2,post_mean(i,1),'or');hold on;
     end
     
     figure(plotit);hold on;subplot(1,3,1);xlim([0.5 2.5]);
     figure(plotit);hold on;subplot(1,3,2);xlim([0.5 2.5]);
     figure(plotit);hold on;subplot(1,3,3);xlim([0.5 2.5]);
     
     %morning to evening difference
     for i = 1:length(pre)
         pre_first_n = pre{i}(1:nsamp,2) - mean(pre{i}(1:nsamp,2)); %mean subtract by mean of morning renditions
         pre_last_n = pre{i}(end-nsamp+1:end,2) - mean(pre{i}(1:nsamp,2));
         [pre_first_n_hi pre_first_n_lo] = mBootstrapCI(pre_first_n,'');
         [pre_last_n_hi pre_last_n_lo] = mBootstrapCI(pre_last_n,'');
         
         figure(plotit+1);hold on;subplot(1,2,1);hold on;
         plot([1 1],[pre_first_n_hi pre_first_n_lo],'k');hold on;
         plot(1,mean(pre_first_n),'ok');hold on;
         plot([2 2],[pre_last_n_hi pre_last_n_lo],'k');hold on;
         plot(2,mean(pre_last_n),'ok');hold on;
         plot([1 2],[mean(pre_first_n) mean(pre_last_n)],'k');hold on;
     end
     
     for i = 1:length(post)
         post_first_n = post{i}(1:nsamp,2) - mean(post{i}(1:nsamp,2)); %mean subtract 
         post_last_n = post{i}(end-nsamp+1:end,2) - mean(post{i}(1:nsamp,2));
         [post_first_n_hi post_first_n_lo] = mBootstrapCI(post_first_n,'');
         [post_last_n_hi post_last_n_lo] = mBootstrapCI(post_last_n,'');
         
         figure(plotit+1);hold on;subplot(1,2,1);hold on;
         plot([1 1],[post_first_n_hi post_first_n_lo],'r');hold on;
         plot(1,mean(post_first_n),'or');hold on;
         plot([2 2],[post_last_n_hi post_last_n_lo],'r');hold on;
         plot(2,mean(post_last_n),'or');hold on;
         plot([1 2],[mean(post_first_n) mean(post_last_n)],'r');hold on;
     end
     
     %evening to morning difference
     for i = 1:length(pre)-1
         pre_last_n = pre{i}(end-nsamp+1:end,2) - mean(pre{i}(end-nsamp+1:end,2)); %mean subtract by mean of evening renditions
         pre_first_n = pre{i+1}(1:nsamp,2) - mean(pre{i}(end-nsamp+1:end,2));
         [pre_last_n_hi pre_last_n_lo] = mBootstrapCI(pre_last_n,'');
         [pre_first_n_hi pre_first_n_lo] = mBootstrapCI(pre_first_n,'');
         
         figure(plotit+1);hold on;subplot(1,2,2);hold on;
         plot([1 1],[pre_last_n_hi pre_last_n_lo],'k');hold on;
         plot(1,mean(pre_last_n),'ok');hold on;
         plot([2 2],[pre_first_n_hi pre_first_n_lo],'k');hold on;
         plot(2,mean(pre_first_n),'ok');hold on;
         plot([1 2],[mean(pre_last_n) mean(pre_first_n)],'k');hold on;
     end
     
     for i = 1:length(post)-1
         post_last_n = post{i}(end-nsamp+1:end,2) - mean(post{i}(end-nsamp+1:end,2)); %mean subtract by mean of evening renditions
         post_first_n = post{i+1}(1:nsamp,2) - mean(post{i}(end-nsamp+1:end,2));
         [post_last_n_hi post_last_n_lo] = mBootstrapCI(post_last_n,'');
         [post_first_n_hi post_first_n_lo] = mBootstrapCI(post_first_n,'');
         
         figure(plotit+1);hold on;subplot(1,2,2);hold on;
         plot([1 1],[post_last_n_hi post_last_n_lo],'r');hold on;
         plot(1,mean(post_last_n),'or');hold on;
         plot([2 2],[post_first_n_hi post_first_n_lo],'r');hold on;
         plot(2,mean(post_first_n),'or');hold on;
         plot([1 2],[mean(post_last_n) mean(post_first_n)],'r');hold on;
     end

     figure(plotit+1);hold on;subplot(1,2,1);xlim([0.5 2.5]);
     figure(plotit+1);hold on;subplot(1,2,2);xlim([0.5 2.5]);
end



pre_pitchends.morn = pre_first;
pre_pitchends.even = pre_last;
pre_pitchends.day = pre_mean;

post_pitchends.morn = post_first;
post_pitchends.even = post_last;
post_pitchends.mean = post_mean;

