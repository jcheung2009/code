%script for summary of vocal changes  and covariation of syllable features
%for lman lesion analysis

config;

%% load data
for i = 1:length(params.trial)
    if isfield(params,'findnote')  
        for n = 1:length(params.findnote)
            if ~exist([params.findnote(n).fvstruct,params.trial(i).name])
                load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).name]);
            end
        end
    end
    if isfield(params,'findmotif')  
        for n = 1:length(params.findmotif)
            if ~exist([params.findmotif(n).motifstruct,params.trial(i).name])
                load(['analysis/data_structures/',params.findmotif(n).motifstruct,params.trial(i).name]);
            end
        end
    end
end
    
%% pitch
summary=struct();
for i = 1:length(params.trial)
    if isfield(params,'findnote')  
        for n = 1:length(params.findnote)
            syllable = params.findnote(n).syllable;
            if ~isempty(params.trial(i).prevday)
                fv_prev = eval([params.findnote(n).fvstruct,params.trial(i).prevday]);
                tb_prev = jc_tb([fv_prev(:).datenm]',7,0);
                if strcmp(params.trial(i).condition,params.timeshift{1})
                    tb_prev=tb_prev-params.timeshift{2};
                end
                intv = find(tb_prev >=9);
                prev_night = mean([fv_prev(intv).mxvals]);
                prev_whole = mean([fv_prev(:).mxvals]);
            else
                night_to_morn = NaN;
                day_to_day = NaN;
            end
            fv = eval([params.findnote(n).fvstruct,params.trial(i).name]);
            tb = jc_tb([fv(:).datenm]',7,0)/3600;
            if strcmp(params.trial(i).condition,'pre')
                tb = tb-2;
            end
            st = floor(tb(1)); en = ceil(tb(end));hrs = [st:en];
            wholeday = mean([fv(:).mxvals]);
            
            %hourly 
            hour = NaN(length(hrs),1);
            for ind = 1:length(hrs)-1
                intv = find(tb>=hrs(ind) & tb<hrs(ind+1));   
                if length(intv) >= 15
                    samp = [fv(intv).mxvals]';
                    hour(ind) = mean(samp);
                else
                    continue
                end
            end
            hour = 100*[diff(hour)./hour(1:end-1)]; 
            
            %morning 
            intv = find(tb>=0 & tb<= 4);
            if length(intv) >= 15
                mornpitch = mean([fv(intv).mxvals]);
            else
                mornpitch = NaN;
            end
            
            %evening
            intv = find(tb>=9);
            if length(intv) >= 15
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
            if ~isempty(params.trial(i).prevday)
                fv_prev = eval([params.findnote(n).fvstruct,params.trial(i).prevday]);
                tb_prev = jc_tb([fv_prev(:).datenm]',7,0);
                if strcmp(params.trial(i).condition,params.timeshift{1})
                    tb_prev=tb_prev-params.timeshift{2};
                end
                intv = find(tb_prev >=9);
                prev_night = mean([fv_prev(intv).spent]);
                prev_whole = mean([fv_prev(:).spent]);
            else
                night_to_morn = NaN;
                day_to_day = NaN;
            end
            fv = eval([params.findnote(n).fvstruct,params.trial(i).name]);
            tb = jc_tb([fv(:).datenm]',7,0)/3600;
            if strcmp(params.trial(i).condition,'pre')
                tb = tb-2;
            end
            st = floor(tb(1)); en = ceil(tb(end));hrs = [st:en];
            wholeday = mean([fv(:).spent]);
            
            %hourly 
            hour = NaN(length(hrs),1);
            for ind = 1:length(hrs)-1
                intv = find(tb>=hrs(ind) & tb<hrs(ind+1));   
                if length(intv) >= 15
                    samp = [fv(intv).spent]';
                    hour(ind) = mean(samp);
                else
                    continue
                end
            end
            hour = 100*[diff(hour)./hour(1:end-1)]; 
            
            %morning 
            intv = find(tb>=0 & tb<= 4);
            if length(intv) >= 15
                mornpitch = mean([fv(intv).spent]);
            else
                mornpitch = NaN;
            end
            
            %evening
            intv = find(tb>=9);
            if length(intv) >= 15
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
            if ~isempty(params.trial(i).prevday)
                motif_prev = eval([params.findmotif(n).motifstruct,params.trial(i).prevday]);
                tb_prev = jc_tb([motif_prev(:).datenm]',7,0);
                if strcmp(params.trial(i).condition,params.timeshift{1})
                    tb_prev=tb_prev-params.timeshift{2};
                end
                intv = find(tb_prev >=9);
                prev_night = mean([motif_prev(intv).motifdur]);
                prev_whole = mean([motif_prev(:).motifdur]);
            else
                night_to_morn = NaN;
                day_to_day = NaN;
            end
            mt = eval([params.findmotif(n).motifstruct,params.trial(i).name]);
            tb = jc_tb([mt(:).datenm]',7,0)/3600;
            if strcmp(params.trial(i).condition,'pre')
                tb = tb-2;
            end
            st = floor(tb(1)); en = ceil(tb(end));hrs = [st:en];
            wholeday = mean([mt(:).motifdur]);
            
            %hourly 
            hour = NaN(length(hrs),1);
            for ind = 1:length(hrs)-1
                intv = find(tb>=hrs(ind) & tb<hrs(ind+1));   
                if length(intv) >= 15
                    samp = [mt(intv).motifdur]';
                    hour(ind) = mean(samp);
                else
                    continue
                end
            end
            hour = 100*[diff(hour)./hour(1:end-1)]; 
            
            %morning 
            intv = find(tb>=0 & tb<= 4);
            if length(intv) >= 15
                mornpitch = mean([mt(intv).motifdur]);
            else
                mornpitch = NaN;
            end
            
            %evening
            intv = find(tb>=9);
            if length(intv) >= 15
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

%% entropy variance

for i = 1:length(params.trial)
    if isfield(params,'findnote')  
        for n = 1:length(params.findnote)
            syllable = params.findnote(n).syllable;
            if ~isempty(params.trial(i).prevday)
                fv_prev = eval([params.findnote(n).fvstruct,params.trial(i).prevday]);
                tb_prev = jc_tb([fv_prev(:).datenm]',7,0);
                if strcmp(params.trial(i).condition,params.timeshift{1})
                    tb_prev=tb_prev-params.timeshift{2};
                end
                intv = find(tb_prev >=9);
                try
                    prev_night = mean([fv_prev(intv).entropyvar]);
                    prev_whole = mean([fv_prev(:).entropyvar]);
                catch
                    prev_night = mean([fv_prev(intv).entvar]);
                    prev_whole = mean([fv_prev(:).entvar]);
                end
            else
                night_to_morn = NaN;
                day_to_day = NaN;
            end
            fv = eval([params.findnote(n).fvstruct,params.trial(i).name]);
            tb = jc_tb([fv(:).datenm]',7,0)/3600;
            if strcmp(params.trial(i).condition,'pre')
                tb = tb-2;
            end
            st = floor(tb(1)); en = ceil(tb(end));hrs = [st:en];
            try
                wholeday = mean([fv(:).entropyvar]);
            catch
                wholeday = mean([fv(:).entvar]);
            end
                    
            
            %hourly 
            hour = NaN(length(hrs),1);
            for ind = 1:length(hrs)-1
                intv = find(tb>=hrs(ind) & tb<hrs(ind+1));   
                if length(intv) >= 20
                    try
                        samp = [fv(intv).entropyvar]';
                    catch
                        samp = [fv(intv).entvar]';
                    end
                    hour(ind) = mean(samp);
                else
                    continue
                end
            end
            hour = 100*[diff(hour)./hour(1:end-1)]; 
            
            %morning 
            intv = find(tb>=hrs(1) & tb<= 3);
            if length(intv) >= 20
                try
                    mornpitch = mean([fv(intv).entropyvar]);
                catch
                    mornpitch = mean([fv(intv).entvar]);
                end
            else
                mornpitch = NaN;
            end
            
            %evening
            intv = find(tb>=9);
            if length(intv) >= 20
                try
                    nightpitch = mean([fv(intv).entropyvar]);
                catch
                    nightpitch = mean([fv(intv).entvar]);
                end
            else
                nightpitch = NaN;
            end
            
            morn_to_night = 100*(nightpitch-mornpitch)/mornpitch;
            
            if ~isempty(params.trial(i).prevday)
                night_to_morn = 100*(mornpitch-prev_night)/prev_night;
                day_to_day = 100*(wholeday-prev_whole)/prev_whole;
            end
           
            summary.entropyvar.([syllable]).hourly.([params.trial(i).condition]).([params.trial(i).name]) = hour;
            summary.entropyvar.([syllable]).morn_to_night.([params.trial(i).condition]).([params.trial(i).name]) = morn_to_night;
            summary.entropyvar.([syllable]).night_to_morn.([params.trial(i).condition]).([params.trial(i).name]) = night_to_morn;
            summary.entropyvar.([syllable]).day_to_day.([params.trial(i).condition]).([params.trial(i).name]) = day_to_day;
            
        end
    end
end


figure;hold on;
sylls = fieldnames(summary.entropyvar);
numsylls = length(fieldnames(summary.entropyvar));
for i = 1:numsylls
    h = subtightplot(numsylls,1,i,[0.07 0.05],0.08,0.12);
    hour_pre = cell2mat(struct2cell(summary.entropyvar.([sylls{i}]).hourly.pre));
    hour_post = cell2mat(struct2cell(summary.entropyvar.([sylls{i}]).hourly.post));
    morn_to_night_pre = cell2mat(struct2cell(summary.entropyvar.([sylls{i}]).morn_to_night.pre));
    morn_to_night_post = cell2mat(struct2cell(summary.entropyvar.([sylls{i}]).morn_to_night.post));
    night_to_morn_pre = cell2mat(struct2cell(summary.entropyvar.([sylls{i}]).night_to_morn.pre));
    night_to_morn_post = cell2mat(struct2cell(summary.entropyvar.([sylls{i}]).night_to_morn.post));
    day_to_day_pre = cell2mat(struct2cell(summary.entropyvar.([sylls{i}]).day_to_day.pre));
    day_to_day_post = cell2mat(struct2cell(summary.entropyvar.([sylls{i}]).day_to_day.post));
    
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
    title([sylls{i},' entropy variance']);
end

%% covariation in pitch and spectral temporal entropy
nstd = 3;
if isfield(params,'findmotif')  
    for n = 1:length(params.findmotif)
        numsylls = length(params.findmotif(n).syllables);
        if numsylls < 2
                continue
        end
        motif = params.findmotif(n).motif;
        pre_pitch = []; post_pitch = [];
        pre_spent = []; post_spent = [];
        pre_entvar = []; post_entvar = [];
        pre_dur = []; post_dur = [];
        for i = 1:length(params.trial)
            mt = eval([params.findmotif(n).motifstruct,params.trial(i).name]);
            syllpitch = cell2mat(arrayfun(@(x) x.syllpitch',mt,'unif',0)');
            syllspent = cell2mat(arrayfun(@(x) x.syllent',mt,'unif',0)');
            syllentvar = cell2mat(arrayfun(@(x) x.syllentvar',mt,'unif',0)');
            sylldur = cell2mat(arrayfun(@(x) x.durations',mt,'unif',0)');
            
            syllpitch = jc_removeoutliers(syllpitch,nstd);
            syllspent = jc_removeoutliers(syllspent,nstd);
            syllentvar = jc_removeoutliers(syllentvar,nstd);
            sylldur = jc_removeoutliers(sylldur,nstd);
            
            syllpitch = (syllpitch-nanmean(syllpitch))./nanstd(syllpitch);
            syllspent = (syllspent-nanmean(syllspent))./nanstd(syllspent);
            syllentvar = (syllentvar-nanmean(syllentvar))./nanstd(syllentvar);
            sylldur = (sylldur-nanmean(sylldur))./nanstd(sylldur);
            
            if strcmp(params.trial(i).condition,'pre')
                pre_pitch = [pre_pitch; syllpitch];
                pre_spent = [pre_spent; syllspent];
                pre_entvar = [pre_entvar; syllentvar];
                pre_dur = [pre_dur; sylldur];
            elseif strcmp(params.trial(i).condition,'post')
                post_pitch = [post_pitch; syllpitch];
                post_spent = [post_spent; syllspent];
                post_entvar = [post_entvar; syllentvar];
                post_dur = [post_dur; sylldur];
            end
        end
    end

    syllables = params.findmotif(n).syllables;
    numpairs = nchoosek(numsylls,2);
    cmb = nchoosek([1:numsylls],2);
    
    figure;hold on;
    for m = 1:numpairs
        h1 = subtightplot(numpairs,2,m*2-1,[0.07 0.05],0.08,0.12);
        plot(h1,pre_pitch(:,cmb(m,1)),pre_pitch(:,cmb(m,2)),'k.');hold on;
        [r p] = corrcoef(pre_pitch(:,cmb(m,1)),pre_pitch(:,cmb(m,2)),'rows','complete');
        x = get(h1,'xlim');y = get(h1,'ylim');
        text(x(1),y(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        set(h1,'xlim',x,'ylim',y,'fontweight','bold');
        title([syllables{cmb(m,:)},' pre pitch']);
        xlabel('zsc');ylabel('zsc');
        summary.covar.pitch.([syllables{cmb(m,:)}]).pre = [r(2) p(2)];
        
        h2 = subtightplot(numpairs,2,m*2,[0.07 0.05],0.08,0.12);
        plot(h2,post_pitch(:,cmb(m,1)),post_pitch(:,cmb(m,2)),'r.');hold on;
        [r p] = corrcoef(post_pitch(:,cmb(m,1)),post_pitch(:,cmb(m,2)),'rows','complete');
        x = get(h2,'xlim');y = get(h2,'ylim');
        text(x(1),y(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        set(h2,'xlim',x,'ylim',y,'fontweight','bold');
        title([syllables{cmb(m,:)},' post pitch']);
        xlabel('zsc');ylabel('zsc');
        summary.covar.pitch.([syllables{cmb(m,:)}]).post = [r(2) p(2)];
    end
    
    figure;hold on;
    for m = 1:numpairs
        h1 = subtightplot(numpairs,2,m*2-1,[0.07 0.05],0.08,0.12);
        plot(h1,pre_spent(:,cmb(m,1)),pre_spent(:,cmb(m,2)),'k.');hold on;
        [r p] = corrcoef(pre_spent(:,cmb(m,1)),pre_spent(:,cmb(m,2)),'rows','complete');
        x = get(h1,'xlim');y = get(h1,'ylim');
        text(x(1),y(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        set(h1,'xlim',x,'ylim',y,'fontweight','bold');
        title([syllables{cmb(m,:)},' pre entropy']);
        xlabel('zsc');ylabel('zsc');
        summary.covar.spent.([syllables{cmb(m,:)}]).pre = [r(2) p(2)];
        
        h2 = subtightplot(numpairs,2,m*2,[0.07 0.05],0.08,0.12);
        plot(h2,post_spent(:,cmb(m,1)),post_spent(:,cmb(m,2)),'r.');hold on;
        [r p] = corrcoef(post_spent(:,cmb(m,1)),post_spent(:,cmb(m,2)),'rows','complete');
        x = get(h2,'xlim');y = get(h2,'ylim');
        text(x(1),y(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        set(h2,'xlim',x,'ylim',y,'fontweight','bold');
        title([syllables{cmb(m,:)},' post entropy']);
        xlabel('zsc');ylabel('zsc');
        summary.covar.spent.([syllables{cmb(m,:)}]).post = [r(2) p(2)];
    end
            
    figure;hold on;
    for m = 1:numpairs
        h1 = subtightplot(numpairs,2,m*2-1,[0.07 0.05],0.08,0.12);
        plot(h1,pre_entvar(:,cmb(m,1)),pre_entvar(:,cmb(m,2)),'k.');hold on;
        [r p] = corrcoef(pre_entvar(:,cmb(m,1)),pre_entvar(:,cmb(m,2)),'rows','complete');
        x = get(h1,'xlim');y = get(h1,'ylim');
        text(x(1),y(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        set(h1,'xlim',x,'ylim',y,'fontweight','bold');
        title([syllables{cmb(m,:)},' pre entropy variance']);
        xlabel('zsc');ylabel('zsc');
        summary.covar.entvar.([syllables{cmb(m,:)}]).pre = [r(2) p(2)];
        
        h2 = subtightplot(numpairs,2,m*2,[0.07 0.05],0.08,0.12);
        plot(h2,post_entvar(:,cmb(m,1)),post_entvar(:,cmb(m,2)),'r.');hold on;
        [r p] = corrcoef(post_entvar(:,cmb(m,1)),post_entvar(:,cmb(m,2)),'rows','complete');
        x = get(h2,'xlim');y = get(h2,'ylim');
        text(x(1),y(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        set(h2,'xlim',x,'ylim',y,'fontweight','bold');
        title([syllables{cmb(m,:)},' post entropy variance']);
        xlabel('zsc');ylabel('zsc');
        summary.covar.entvar.([syllables{cmb(m,:)}]).post = [r(2) p(2)];
    end      
end

%% autocorrelation in pitch
nstd = 3;
aph = 0.05;
lagcutoff = 50;
shufftrials = 1000;
if isfield(params,'findnote')  
    for n = 1:length(params.findnote)
        syllable = params.findnote(n).syllable;
        autocorr_integral_pre = [];autocorr_integral_post = [];
        autocorr_tc_pre = []; autocorr_tc_post = [];
        for i = 1:length(params.trial)
            
            fv = eval([params.findnote(n).fvstruct,params.trial(i).name]);
            pitch = [fv(:).mxvals]';
            pitch = jc_removeoutliers(pitch,nstd);
            pitch = (pitch-nanmean(pitch))./nanstd(pitch);
            [c lag] = xcorr(pitch(isfinite(pitch)),'coeff');
            shuffcorrs = NaN(shufftrials,length(lag));
            for rep = 1:shufftrials
                shuffpitch = pitch(randperm(length(pitch),length(pitch)));
                [shuffc lag] = xcorr(shuffpitch(isfinite(shuffpitch)),'coeff');
                shuffcorrs(rep,:) = shuffc;
            end
            shuffcorrs = sort(shuffcorrs,1);
            lo = shuffcorrs(floor(shufftrials*aph/2),:);
            hi = shuffcorrs(shufftrials-floor(shufftrials*aph/2),:);
            ix = find(lag >= 0 & lag <= lagcutoff);
            normc = c-hi';
            normc(normc < 0) = 0;
            
            if strcmp(params.trial(i).condition,'pre')
                autocorr_integral_pre = [autocorr_integral_pre; trapz(normc(ix))];
            elseif strcmp(params.trial(i).condition,'post')
                autocorr_integral_post = [autocorr_integral_post; trapz(normc(ix))];
            end
            
            %identify when correlation falls to random from lag 0
            lag_gt_0 = find(lag >= 0);
            c = c(lag_gt_0);
            c_n = conv(c,ones(10,1)./10,'same');
            hi_gt_0 = hi(lag_gt_0);
            c_gt_hi = find(bsxfun(@lt,c_n(2:end),hi_gt_0(2:end)'));
            c_gt_hi = c_gt_hi(1);
            c = c(1:c_gt_hi);
            
            %fit double exponential to autocorr
            try
                f = fit([1:length(c)]',c,'exp2');
                betas = coeffvalues(f);
                tc = betas([2,4]);
    %             betaconf = confint(f);
    %             if 0 >= betaconf(1,1) & 0 <= betaconf(2,1)
    %                 tc = betas(4);
    %             elseif 0 >= betaconf(1,3) & 0 <= betaconf(2,3)
    %                 tc = betas(2);
    %             elseif betas(3) < betas(1)
    %                 tc = betas(4);
    %             elseif betas(1) < betas(3)
    %                 tc = betas(2);
    %             end
                figure;hold on;
                plot(c(1:c_gt_hi),'k');hold on;
                plot(f,1:c_gt_hi,c(1:c_gt_hi));hold on;
                title([syllable,' ',params.trial(i).name],'interpreter','none')
            catch
                tc = NaN(1,2);
            end
            
            if strcmp(params.trial(i).condition,'pre')
                autocorr_tc_pre = [autocorr_tc_pre; tc];
            elseif strcmp(params.trial(i).condition,'post')
                autocorr_tc_post = [autocorr_tc_post; tc];
            end
%              figure;hold on;plot(lag,c,'k');hold on;
%              patch('XData',[lag fliplr(lag)],'YData',[hi fliplr(lo)],'facecolor',[0.85 0.85 0.85],'facealpha',0.75,'edgecolor','none');
%              title([syllable,' ',params.trial(i).name],'interpreter','none')
        end
        summary.pitch_autocorr.([syllable]).pre = autocorr_integral_pre;
        summary.pitch_autocorr.([syllable]).post = autocorr_integral_post;
        summary.pitch_autocorr.([syllable]).pre_tc = autocorr_tc_pre;
        summary.pitch_autocorr.([syllable]).post_tc = autocorr_tc_post;
    end
    
end

%% pitch cv before and after
nstd = 3;
if isfield(params,'findnote')  
    for n = 1:length(params.findnote)
        syllable = params.findnote(n).syllable;
        pitchcv_pre = [];pitchcv_post = [];
        for i = 1:length(params.trial)
            
            fv = eval([params.findnote(n).fvstruct,params.trial(i).name]);
            tb = jc_tb([fv(:).datenm]',7,0);
            pitch = [fv(:).mxvals]';
            pitch = jc_removeoutliers(pitch,nstd);
            
            %detrend  
            pitch = jc_detrendpitch(pitch,tb);
            
            if strcmp(params.trial(i).condition,'pre')
                pitchcv_pre = [pitchcv_pre; cv(pitch)];
            elseif strcmp(params.trial(i).condition,'post')
                pitchcv_post = [pitchcv_post; cv(pitch)];
            end
            
             figure;hold on;plot(tb,pitch,'k.');hold on;
             title([syllable,' ',params.trial(i).name],'interpreter','none');
        end
        summary.pitch_cv.([syllable]).pre = pitchcv_pre;
        summary.pitch_cv.([syllable]).post = pitchcv_post;
    end
    
end
