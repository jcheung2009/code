function [filter_pre addwn_post] = jc_lmandata(pre,post,fc,Ast,pltit)
%fc = frequency cutoff in hz
% specs used for analysis: N = 2, Ast = 5, fc = 0.1 hz 

%% filter pre lesion data

fc = fc*2; %converts to pi radians
%[b a] = butter(2,fc,'low');

 d = fdesign.lowpass('N,Fst,Ast',2,fc,Ast);%filter order 2, attenuate by Ast decibels
 Hd = design(d);

%filter_pre = cellfun(@(x) [x(:,1) filter(b,a,x(:,2))],pre,'UniformOutput',false);
filter_pre = cellfun(@(x) [x(:,1) filter(Hd,x(:,2))],pre,'UniformOutput',false);
filter_pre = cellfun(@(x) x(20:end,:),filter_pre,'UniformOutput',false);%removes first 19 points, artifact from filtering


%% add white noise to post lesion data, match mean std of pre

%matching whole day STD
[c i ] = max(cellfun(@(x) std(x(:,2)),pre));
pre_pool = pre{i}(:,2);

% pre_pool = [];
% for i = 1:length(pre)
%     pre_pool = [pre_pool; pre{i}(:,2)];
% end

for i = 1:length(post)
    [h p] = vartest2(pre_pool, post{i}(:,2));
    if h == 1
        addwn_post{i} = post{i};
        while h == 1
            addwn_post{i}(:,2) = addwn_post{i}(:,2) + randn(length(addwn_post{i}(:,2)),1);
            [h p] = vartest2(pre_pool, addwn_post{i}(:,2),'Alpha',0.10);
        end
    elseif h == 0
        addwn_post{i} = post{i};
    end
end

% match_std = mean(cellfun(@(x) std(x(:,2)),pre));
% post_std = mean(cellfun(@(x) std(x(:,2)),post));
% addwn_post = cellfun(@(x) [x(:,1) x(:,2)+randn(length(x(:,2)),1)],post,'UniformOutput',false);
% while abs(match_std - post_std) > 
%     addwn_post = cellfun(@(x) [x(:,1) x(:,2)+randn(length(x(:,2)),1)],addwn_post,'UniformOutput',false);
%     post_std = mean(cellfun(@(x) std(x(:,2)),addwn_post));
% end

%% match STD by segment
% segstd = [];
% nseg = 50;
% for i = 1:length(pre)
%     [y z] = buffer(pre{i}(:,2),nseg);
%     segstd = cat(2,segstd,std(y,0,1));
% end
% match_std = mean(segstd);
% 
% for i = 1:length(post)
%     [y z] = buffer(post{i}(:,2),nseg);
%     wn_post = [];
%     for ii = 1:size(y,2)
%         addwn_postseg = y(:,ii) + randn(length(y(:,ii)),1);
%         post_segstd = std(addwn_postseg);
%         while match_std - post_segstd > -30
%             addwn_postseg = addwn_postseg + randn(length(addwn_postseg),1);
%             post_segstd = std(addwn_postseg);
%         end
%         wn_post = cat(1,wn_post,addwn_postseg);
%     end
%         
%     if length(z) < 20
%         wn_post = cat(1,wn_post,z);
%     else 
%         addwn_postseg = z + randn(length(z),1);
%         post_segstd = std(addwn_postseg);
%         while match_std - post_segstd > -30
%            addwn_postseg = addwn_postseg + randn(length(addwn_postseg),1);
%            post_segstd = std(addwn_postseg);
%         end
%         wn_post = cat(1,wn_post,addwn_postseg);
%     end
%     
%      addwn_post{i} = [post{i}(:,1) wn_post];
% end

%     

%%
if pltit ~=0
    %plot pre and filtered pre data
    figure(pltit);hold on;
    for i = 1:length(pre)
        subtightplot(1,length(pre),i,[0.01 0.01],[0.035 0.035],[0.035 0.035]);plot(pre{i}(:,2),'k.');hold on;
        plot(filter_pre{i}(:,2),'r.');
    end
    
    %plot post and post+wn
    figure(pltit+1);hold on;
    for i = 1:length(post)
        subtightplot(1,length(post),i,[0.01 0.01],[0.035 0.035],[0.035 0.035]);plot(addwn_post{i}(:,2),'r.');hold on;
        plot(post{i}(:,2),'k.');
    end
    
end




        
    


