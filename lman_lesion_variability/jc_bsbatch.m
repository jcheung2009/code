function [pre_pitch post_pitch] = jc_bsbatch(pre,post,nsamp,st_o_en,pltit)
%compute mean + CI of each day in data set

    
pre_pitch = [];
for i = 1:length(pre)
 
    if length(pre{i}) < nsamp
        nsamp = length(pre{i});
    end
    if strcmp(st_o_en,'en')  
        mean_fv = mean(pre{i}(end-nsamp:end,2));
        [hi lo] = mBootstrapCI(pre{i}(end-nsamp:end,2),'');
    elseif strcmp(st_o_en,'st')
        mean_fv = mean(pre{i}(1:nsamp,2));
        [hi lo] = mBootstrapCI(pre{i}(1:nsamp,2),'');
    elseif isempty(st_o_en)
        mean_fv = mean(pre{i}(:,2));
        [hi lo] = mBootstrapCI(pre{i}(:,2),'');
    end
    pre_pitch(i,:) = [mean_fv hi lo];
    
end

post_pitch = [];
for i = 1:length(post)
    

    
    if length(post{i}) < nsamp
        nsamp = length(post{i});
    end
    if strcmp(st_o_en,'en')  
        mean_fv = mean(post{i}(end-nsamp:end,2));
        [hi lo] = mBootstrapCI(post{i}(end-nsamp:end,2),'');
    elseif strcmp(st_o_en,'st')
        mean_fv = mean(pre{i}(1:nsamp,2));
        [hi lo] = mBootstrapCI(post{i}(1:nsamp,2),'');
    elseif isempty(st_o_en)
        mean_fv = mean(post{i}(:,2));
        [hi lo] = mBootstrapCI(post{i}(:,2),'');
    end
    post_pitch(i,:) = [mean_fv hi lo];
    
end

    
    
    
    if pltit == 1
        for i = 1:length(pre_pitch)
            figure(22);hold on;
            plot([1 1],pre_pitch(i,2:3),'k');hold on;
            plot(1,pre_pitch(i,1),'ok');hold on;
        end
        
        for i = 1:length(post_pitch)
            figure(22);hold on;
            plot([2 2],post_pitch(i,2:3),'r');hold on;
            plot(2,post_pitch(i,1),'or');hold on;
        end
        
%         
%         if strcmp(st_o_en,'en')
%             tm = mean(invect.(fields{i},'_BS')(end-nsamp:end,1));
%         elseif strcmp(st_o_en,'st')
%             tm = mean(invect.(fields{i})(1:nsamp,1));
%         elseif isempty(st_o_en)
%             tm = mean(invect.(fields{i})(:,1));
%         end
%         figure(3);hold on;
%         plot(tm,mean_fv,'ob');hold on;
%         plot([tm tm],[hi lo],'b');
    end
    
        figure(22);hold on;xlim([0.5 2.5]);
     figure(22);hold on;xlim([0.5 2.5]);
