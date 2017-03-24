function [pre_sim post_sim] = jc_lmansim(lofreqamp, per, hifreqstd, nfac, lofreqchange, pltit)
% generates "pre" and "post" simulated lman lesion signals 
% keep constant low frequency component if lofreqchange is empty
%specify how much to change slow drift amplitude with lofreqchange



if isempty(nfac)
    nfac = 0.7; % 30% reduction in STD for post compared to pre
end


%create signal
repnum = 6;
pre_sim = cell(1,6);
post_sim = cell(1,6);
if isempty(lofreqchange) 
   
    T = 2*pi/per;
    x = 1:1:1000; %1000 points
    y = lofreqamp*sin(T*x); %slow frequency component, constant for both pre and post condition
    for i = 1:repnum   
        hifreqstd_rand = ((1.08-.92)*rand(1,1)+0.92)*hifreqstd; % up to 8% variability in std of hi freq noise
        y_noise = y + hifreqstd_rand*randn(1,length(y)); %add hi freq noise, 'pre-lesion'
        hifreqstd_post = nfac*hifreqstd;
        hifreqstd_post_rand = ((1.08-.92)*rand(1,1)+0.92)*hifreqstd_post;
        y_noise_lo = y + hifreqstd_post_rand*randn(1,length(y)); %add less hi freq noise, 'post lesion' 
        pre_sim{i} = [NaN(length(y_noise),1) y_noise'];
        post_sim{i} = [NaN(length(y_noise_lo),1) y_noise_lo'];
    end

else 
    
    T = 2*pi/per;
    x = 1:1:1000;
    y = lofreqamp*sin(T*x); %slow frequency component for pre lesion
    y2 = (lofreqamp+lofreqchange)*sin(T*x); %slow frequency component for post lesion
    
    for i = 1:repnum
        
        hifreqstd_rand = ((1.08-.92)*rand(1,1)+0.92)*hifreqstd; % up to 8% variability in std of hi freq noise
        y_noise = y + hifreqstd_rand*randn(1,length(y)); %add hi freq noise, 'pre-lesion'
        hifreqstd_post = nfac*hifreqstd;
         hifreqstd_post_rand = ((1.08-.92)*rand(1,1)+0.92)*hifreqstd_post;
        y_noise_lo = y2 + hifreqstd_post_rand*randn(1,length(y)); %add less hi freq noise, 'post lesion' 
        pre_sim{i} = [NaN(length(y_noise),1) y_noise'];
        post_sim{i} = [NaN(length(y_noise_lo),1) y_noise_lo'];
    end
end


%%
if pltit ~= 0;
   
    for i = 1:length(pre_sim)
        figure(pltit);hold on;subtightplot(1,length(pre_sim),i,[0.01 0.01],[0.03 0.03],[0.03 0.03]);
        plot(pre_sim{i},'k.');hold on;
    end
    
    for i = 1:length(post_sim)
        figure(pltit);hold on;subtightplot(1,length(post_sim),i,[0.01 0.01],[0.03 0.03],[0.03 0.03]);
        plot(post_sim{i},'r.');hold on;
    end
end




