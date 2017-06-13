%script for summary of vocal changes (lman lesions)

config;

%% pitch
summary=struct();
for i = 1:length(params.trial)
    if isfield(params,'findnote')  
        for n = 1:length(params.findnote)
            syllable = params.findnote(n).syllable;
            load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).name]);
            if ~isempty(params.trial(i).prevday)
                load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).prevday]);
                fv_prev = eval([params.findnote(n).fvstruct,params.trial(i).prevday]);
                tb_prev = jc_tb([fv_prev(:).datenm]',7,0);
                intv = find(tb_prev >=9);
                prev_night = mean([fv_prev(intv).mxvals]);
                prev_whole = mean([fv_prev(:).mxvals]);
            else
                night_to_morn = NaN;
                day_to_day = NaN;
            end
            fv = eval([params.findnote(n).fvstruct,params.trial(i).name]);
            tb = jc_tb([fv(:).datenm]',7,0)/3600;
            st = floor(tb(1)); en = ceil(tb(end));hrs = [st:en];
            wholeday = mean([fv(:).mxvals]);
            
            %hourly 
            hour = NaN(length(hrs),1);
            for ind = 1:length(hrs)-1
                intv = find(tb>=hrs(ind) & tb<hrs(ind+1));   
                if length(intv) >= 20
                    samp = [fv(intv).mxvals]';
                    hour(ind) = mean(samp);
                else
                    continue
                end
            end
            hour = 100*[diff(hour)./hour(1:end-1)]; 
            
            %morning 
            intv = find(tb>=hrs(1) & tb<= 3);
            if length(intv) >= 20
                mornpitch = mean([fv(intv).mxvals]);
            else
                mornpitch = NaN;
            end
            
            %evening
            intv = find(tb>=11);
            if length(intv) >= 20
                nightpitch = mean([fv(intv).mxvals]);
            else
                nightpitch = NaN;
            end
            
            morn_to_night = 100*(nightpitch-mornpitch)/mornpitch;
            
            if ~isempty(params.trial(i).prevday)
                night_to_morn = 100*(mornpitch-prev_night)/prev_night;
                day_to_day = 100*(wholeday-prev_whole)/prev_whole;
            end
           
            summary.pitch.([syllable]).hourly.([params.trial(i).condition]).([params.trial(i).name]) = hour;
            summary.pitch.([syllable]).morn_to_night.([params.trial(i).condition]).([params.trial(i).name]) = morn_to_night;
            summary.pitch.([syllable]).night_to_morn.([params.trial(i).condition]).([params.trial(i).name]) = night_to_morn;
            summary.pitch.([syllable]).day_to_day.([params.trial(i).condition]).([params.trial(i).name]) = day_to_day;
            
        end
    end
end


figure;hold on;
sylls = fieldnames(summary.pitch);
numsylls = length(fieldnames(summary.pitch));
for i = 1:numsylls
    h = subtightplot(numsylls,1,i,[0.07 0.05],0.08,0.12);
    hour_pre = cell2mat(struct2cell(summary.pitch.([sylls{i}]).hourly.pre));
    hour_post = cell2mat(struct2cell(summary.pitch.([sylls{i}]).hourly.post));
    morn_to_night_pre = cell2mat(struct2cell(summary.pitch.([sylls{i}]).morn_to_night.pre));
    morn_to_night_post = cell2mat(struct2cell(summary.pitch.([sylls{i}]).morn_to_night.post));
    night_to_morn_pre = cell2mat(struct2cell(summary.pitch.([sylls{i}]).night_to_morn.pre));
    night_to_morn_post = cell2mat(struct2cell(summary.pitch.([sylls{i}]).night_to_morn.post));
    day_to_day_pre = cell2mat(struct2cell(summary.pitch.([sylls{i}]).day_to_day.pre));
    day_to_day_post = cell2mat(struct2cell(summary.pitch.([sylls{i}]).day_to_day.post));
    
    percentchange = [nanmean(hour_pre) nanmean(hour_post); ...
        nanmean(morn_to_night_pre) nanmean(morn_to_night_post); ...
        nanmean(night_to_morn_pre) nanmean(night_to_morn_post); ...
        nanmean(day_to_day_pre) nanmean(day_to_day_post)];
    b = bar(h,percentchange);
    b(1).FaceColor = 'none';b(1).LineWidth = 2;
    b(2).FaceColor = 'none'; b(2).EdgeColor = 'r';b(2).LineWidth = 2;
    axes(h);hold on;
    l(1)=plot(h,repmat(1+b(1).XOffset,2,1),nanmean(hour_pre)+[nanstderr(hour_pre) -nanstderr(hour_pre)]','k');hold on;
    l(2)=plot(h,repmat(2+b(1).XOffset,2,1),nanmean(morn_to_night_pre)+[nanstderr(morn_to_night_pre) -nanstderr(morn_to_night_pre)],'k');hold on;
    l(3)=plot(h,repmat(3+b(1).XOffset,2,1),nanmean(night_to_morn_pre)+[nanstderr(night_to_morn_pre) -nanstderr(night_to_morn_pre)],'k');hold on;
    l(4)=plot(h,repmat(4+b(1).XOffset,2,1),nanmean(day_to_day_pre)+[nanstderr(day_to_day_pre) -nanstderr(day_to_day_pre)],'k');hold on;
    l(5)=plot(h,repmat(1+b(2).XOffset,2,1),nanmean(hour_post)+[nanstderr(hour_post) -nanstderr(hour_post)],'r');hold on;
    l(6)=plot(h,repmat(2+b(2).XOffset,2,1),nanmean(morn_to_night_post)+[nanstderr(morn_to_night_post) -nanstderr(morn_to_night_post)],'r');hold on;
    l(7)=plot(h,repmat(3+b(2).XOffset,2,1),nanmean(night_to_morn_post)+[nanstderr(night_to_morn_post) -nanstderr(night_to_morn_post)],'r');hold on;
    l(8)=plot(h,repmat(4+b(2).XOffset,2,1),nanmean(day_to_day_post)+[nanstderr(day_to_day_post) -nanstderr(day_to_day_post)],'r');hold on;

    p = ranksum(hour_pre,hour_post);
    if p <= 0.05
        text(1+b(2).XOffset,1.25*b(2).YData(1),'*');
    end
    p = ranksum(morn_to_night_pre,morn_to_night_post);
    if p <= 0.05
        text(2+b(2).XOffset,1.25*b(2).YData(2),'*');
    end
    p = ranksum(night_to_morn_pre,night_to_morn_post);
    if p <= 0.05
        text(3+b(2).XOffset,1.25*b(2).YData(3),'*');
    end

    xlbls = {'hour','morning to night','night to morning','day to day'};
    set(h,'fontweight','bold','xticklabel',xlbls);set(l,'linewidth',2);
    ylabel('percent change');
    title([sylls{i},' pitch']);
end

%% spectral temporal entropy

for i = 1:length(params.trial)
    if isfield(params,'findnote')  
        for n = 1:length(params.findnote)
            syllable = params.findnote(n).syllable;
            load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).name]);
            if ~isempty(params.trial(i).prevday)
                load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).prevday]);
                fv_prev = eval([params.findnote(n).fvstruct,params.trial(i).prevday]);
                tb_prev = jc_tb([fv_prev(:).datenm]',7,0);
                intv = find(tb_prev >=9);
                prev_night = mean([fv_prev(intv).spent]);
                prev_whole = mean([fv_prev(:).spent]);
            else
                night_to_morn = NaN;
                day_to_day = NaN;
            end
            fv = eval([params.findnote(n).fvstruct,params.trial(i).name]);
            tb = jc_tb([fv(:).datenm]',7,0)/3600;
            st = floor(tb(1)); en = ceil(tb(end));hrs = [st:en];
            wholeday = mean([fv(:).spent]);
            
            %hourly 
            hour = NaN(length(hrs),1);
            for ind = 1:length(hrs)-1
                intv = find(tb>=hrs(ind) & tb<hrs(ind+1));   
                if length(intv) >= 20
                    samp = [fv(intv).spent]';
                    hour(ind) = mean(samp);
                else
                    continue
                end
            end
            hour = 100*[diff(hour)./hour(1:end-1)]; 
            
            %morning 
            intv = find(tb>=hrs(1) & tb<= 3);
            if length(intv) >= 20
                mornpitch = mean([fv(intv).spent]);
            else
                mornpitch = NaN;
            end
            
            %evening
            intv = find(tb>=11);
            if length(intv) >= 20
                nightpitch = mean([fv(intv).spent]);
            else
                nightpitch = NaN;
            end
            
            morn_to_night = 100*(nightpitch-mornpitch)/mornpitch;
            
            if ~isempty(params.trial(i).prevday)
                night_to_morn = 100*(mornpitch-prev_night)/prev_night;
                day_to_day = 100*(wholeday-prev_whole)/prev_whole;
            end
           
            summary.spent.([syllable]).hourly.([params.trial(i).condition]).([params.trial(i).name]) = hour;
            summary.spent.([syllable]).morn_to_night.([params.trial(i).condition]).([params.trial(i).name]) = morn_to_night;
            summary.spent.([syllable]).night_to_morn.([params.trial(i).condition]).([params.trial(i).name]) = night_to_morn;
            summary.spent.([syllable]).day_to_day.([params.trial(i).condition]).([params.trial(i).name]) = day_to_day;
            
        end
    end
end


figure;hold on;
sylls = fieldnames(summary.spent);
numsylls = length(fieldnames(summary.spent));
for i = 1:numsylls
    h = subtightplot(numsylls,1,i,[0.07 0.05],0.08,0.12);
    hour_pre = cell2mat(struct2cell(summary.spent.([sylls{i}]).hourly.pre));
    hour_post = cell2mat(struct2cell(summary.spent.([sylls{i}]).hourly.post));
    morn_to_night_pre = cell2mat(struct2cell(summary.spent.([sylls{i}]).morn_to_night.pre));
    morn_to_night_post = cell2mat(struct2cell(summary.spent.([sylls{i}]).morn_to_night.post));
    night_to_morn_pre = cell2mat(struct2cell(summary.spent.([sylls{i}]).night_to_morn.pre));
    night_to_morn_post = cell2mat(struct2cell(summary.spent.([sylls{i}]).night_to_morn.post));
    day_to_day_pre = cell2mat(struct2cell(summary.spent.([sylls{i}]).day_to_day.pre));
    day_to_day_post = cell2mat(struct2cell(summary.spent.([sylls{i}]).day_to_day.post));
    
    percentchange = [nanmean(hour_pre) nanmean(hour_post); ...
        nanmean(morn_to_night_pre) nanmean(morn_to_night_post); ...
        nanmean(night_to_morn_pre) nanmean(night_to_morn_post); ...
        nanmean(day_to_day_pre) nanmean(day_to_day_post)];
    b = bar(h,percentchange);
    b(1).FaceColor = 'none';b(1).LineWidth = 2;
    b(2).FaceColor = 'none'; b(2).EdgeColor = 'r';b(2).LineWidth = 2;
    axes(h);hold on;
    l(1)=plot(h,repmat(1+b(1).XOffset,2,1),nanmean(hour_pre)+[nanstderr(hour_pre) -nanstderr(hour_pre)]','k');hold on;
    l(2)=plot(h,repmat(2+b(1).XOffset,2,1),nanmean(morn_to_night_pre)+[nanstderr(morn_to_night_pre) -nanstderr(morn_to_night_pre)],'k');hold on;
    l(3)=plot(h,repmat(3+b(1).XOffset,2,1),nanmean(night_to_morn_pre)+[nanstderr(night_to_morn_pre) -nanstderr(night_to_morn_pre)],'k');hold on;
    l(4)=plot(h,repmat(4+b(1).XOffset,2,1),nanmean(day_to_day_pre)+[nanstderr(day_to_day_pre) -nanstderr(day_to_day_pre)],'k');hold on;
    l(5)=plot(h,repmat(1+b(2).XOffset,2,1),nanmean(hour_post)+[nanstderr(hour_post) -nanstderr(hour_post)],'r');hold on;
    l(6)=plot(h,repmat(2+b(2).XOffset,2,1),nanmean(morn_to_night_post)+[nanstderr(morn_to_night_post) -nanstderr(morn_to_night_post)],'r');hold on;
    l(7)=plot(h,repmat(3+b(2).XOffset,2,1),nanmean(night_to_morn_post)+[nanstderr(night_to_morn_post) -nanstderr(night_to_morn_post)],'r');hold on;
    l(8)=plot(h,repmat(4+b(2).XOffset,2,1),nanmean(day_to_day_post)+[nanstderr(day_to_day_post) -nanstderr(day_to_day_post)],'r');hold on;

    p = ranksum(hour_pre,hour_post);
    if p <= 0.05
        text(1+b(2).XOffset,1.25*b(2).YData(1),'*');
    end
    p = ranksum(morn_to_night_pre,morn_to_night_post);
    if p <= 0.05
        text(2+b(2).XOffset,1.25*b(2).YData(2),'*');
    end
    p = ranksum(night_to_morn_pre,night_to_morn_post);
    if p <= 0.05
        text(3+b(2).XOffset,1.25*b(2).YData(3),'*');
    end

    xlbls = {'hour','morning to night','night to morning','day to day'};
    set(h,'fontweight','bold','xticklabel',xlbls);set(l,'linewidth',2);
    ylabel('percent change');
    title([sylls{i},' spectral temporal entropy']);
end

%% motif duration
for i = 1:length(params.trial)
    if isfield(params,'findmotif')  
        for n = 1:length(params.findmotif)
            motif = params.findmotif(n).motif;
            load(['analysis/data_structures/',params.findmotif(n).motifstruct,params.trial(i).name]);
            if ~isempty(params.trial(i).prevday)
                load(['analysis/data_structures/',params.findmotif(n).motifstruct,params.trial(i).prevday]);
                motif_prev = eval([params.findmotif(n).motifstruct,params.trial(i).prevday]);
                tb_prev = jc_tb([motif_prev(:).datenm]',7,0);
                intv = find(tb_prev >=9);
                prev_night = mean([motif_prev(intv).motifdur]);
                prev_whole = mean([motif_prev(:).motifdur]);
            else
                night_to_morn = NaN;
                day_to_day = NaN;
            end
            mt = eval([params.findmotif(n).motifstruct,params.trial(i).name]);
            tb = jc_tb([mt(:).datenm]',7,0)/3600;
            st = floor(tb(1)); en = ceil(tb(end));hrs = [st:en];
            wholeday = mean([mt(:).motifdur]);
            
            %hourly 
            hour = NaN(length(hrs),1);
            for ind = 1:length(hrs)-1
                intv = find(tb>=hrs(ind) & tb<hrs(ind+1));   
                if length(intv) >= 20
                    samp = [mt(intv).motifdur]';
                    hour(ind) = mean(samp);
                else
                    continue
                end
            end
            hour = 100*[diff(hour)./hour(1:end-1)]; 
            
            %morning 
            intv = find(tb>=hrs(1) & tb<= 3);
            if length(intv) >= 20
                mornpitch = mean([mt(intv).motifdur]);
            else
                mornpitch = NaN;
            end
            
            %evening
            intv = find(tb>=11);
            if length(intv) >= 20
                nightpitch = mean([mt(intv).motifdur]);
            else
                nightpitch = NaN;
            end
            
            morn_to_night = 100*(nightpitch-mornpitch)/mornpitch;
            
            if ~isempty(params.trial(i).prevday)
                night_to_morn = 100*(mornpitch-prev_night)/prev_night;
                day_to_day = 100*(wholeday-prev_whole)/prev_whole;
            end
           
            summary.motif.([motif]).hourly.([params.trial(i).condition]).([params.trial(i).name]) = hour;
            summary.motif.([motif]).morn_to_night.([params.trial(i).condition]).([params.trial(i).name]) = morn_to_night;
            summary.motif.([motif]).night_to_morn.([params.trial(i).condition]).([params.trial(i).name]) = night_to_morn;
            summary.motif.([motif]).day_to_day.([params.trial(i).condition]).([params.trial(i).name]) = day_to_day;
            
        end
    end
end


figure;hold on;
motifs = fieldnames(summary.motif);
nummotifs = length(fieldnames(summary.motif));
for i = 1:nummotifs
    h = subtightplot(nummotifs,1,i,[0.07 0.05],0.08,0.12);
    hour_pre = cell2mat(struct2cell(summary.motif.([motifs{i}]).hourly.pre));
    hour_post = cell2mat(struct2cell(summary.motif.([motifs{i}]).hourly.post));
    morn_to_night_pre = cell2mat(struct2cell(summary.motif.([motifs{i}]).morn_to_night.pre));
    morn_to_night_post = cell2mat(struct2cell(summary.motif.([motifs{i}]).morn_to_night.post));
    night_to_morn_pre = cell2mat(struct2cell(summary.motif.([motifs{i}]).night_to_morn.pre));
    night_to_morn_post = cell2mat(struct2cell(summary.motif.([motifs{i}]).night_to_morn.post));
    day_to_day_pre = cell2mat(struct2cell(summary.motif.([motifs{i}]).day_to_day.pre));
    day_to_day_post = cell2mat(struct2cell(summary.motif.([motifs{i}]).day_to_day.post));
    
    percentchange = [nanmean(hour_pre) nanmean(hour_post); ...
        nanmean(morn_to_night_pre) nanmean(morn_to_night_post); ...
        nanmean(night_to_morn_pre) nanmean(night_to_morn_post); ...
        nanmean(day_to_day_pre) nanmean(day_to_day_post)];
    b = bar(h,percentchange);
    b(1).FaceColor = 'none';b(1).LineWidth = 2;
    b(2).FaceColor = 'none'; b(2).EdgeColor = 'r';b(2).LineWidth = 2;
    axes(h);hold on;
    l(1)=plot(h,repmat(1+b(1).XOffset,2,1),nanmean(hour_pre)+[nanstderr(hour_pre) -nanstderr(hour_pre)]','k');hold on;
    l(2)=plot(h,repmat(2+b(1).XOffset,2,1),nanmean(morn_to_night_pre)+[nanstderr(morn_to_night_pre) -nanstderr(morn_to_night_pre)],'k');hold on;
    l(3)=plot(h,repmat(3+b(1).XOffset,2,1),nanmean(night_to_morn_pre)+[nanstderr(night_to_morn_pre) -nanstderr(night_to_morn_pre)],'k');hold on;
    l(4)=plot(h,repmat(4+b(1).XOffset,2,1),nanmean(day_to_day_pre)+[nanstderr(day_to_day_pre) -nanstderr(day_to_day_pre)],'k');hold on;
    l(5)=plot(h,repmat(1+b(2).XOffset,2,1),nanmean(hour_post)+[nanstderr(hour_post) -nanstderr(hour_post)],'r');hold on;
    l(6)=plot(h,repmat(2+b(2).XOffset,2,1),nanmean(morn_to_night_post)+[nanstderr(morn_to_night_post) -nanstderr(morn_to_night_post)],'r');hold on;
    l(7)=plot(h,repmat(3+b(2).XOffset,2,1),nanmean(night_to_morn_post)+[nanstderr(night_to_morn_post) -nanstderr(night_to_morn_post)],'r');hold on;
    l(8)=plot(h,repmat(4+b(2).XOffset,2,1),nanmean(day_to_day_post)+[nanstderr(day_to_day_post) -nanstderr(day_to_day_post)],'r');hold on;

    p = ranksum(hour_pre,hour_post);
    if p <= 0.05
        text(1+b(2).XOffset,1.25*b(2).YData(1),'*');
    end
    p = ranksum(morn_to_night_pre,morn_to_night_post);
    if p <= 0.05
        text(2+b(2).XOffset,1.25*b(2).YData(2),'*');
    end
    p = ranksum(night_to_morn_pre,night_to_morn_post);
    if p <= 0.05
        text(3+b(2).XOffset,1.25*b(2).YData(3),'*');
    end

    xlbls = {'hour','morning to night','night to morning','day to day'};
    set(h,'fontweight','bold','xticklabel',xlbls);set(l,'linewidth',2);
    ylabel('percent change');
    title([motifs{i},' motif duration']);
end