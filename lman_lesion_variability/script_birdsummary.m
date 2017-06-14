%script for summary of vocal changes  and covariation of syllable features
%for lman lesion analysis

config;

%% load data
for i = 1:length(params.trial)
    if isfield(params,'findnote')  
        for n = 1:length(params.findnote)
            load(['analysis/data_structures/',params.findnote(n).fvstruct,params.trial(i).name]);
        end
    end
    if isfield(params,'findmotif')  
        for n = 1:length(params.findmotif)
            load(['analysis/data_structures/',params.findmotif(n).motifstruct,params.trial(i).name]);
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
            if ~isempty(params.trial(i).prevday)
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
            if ~isempty(params.trial(i).prevday)
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

%% entropy variance

for i = 1:length(params.trial)
    if isfield(params,'findnote')  
        for n = 1:length(params.findnote)
            syllable = params.findnote(n).syllable;
            if ~isempty(params.trial(i).prevday)
                fv_prev = eval([params.findnote(n).fvstruct,params.trial(i).prevday]);
                tb_prev = jc_tb([fv_prev(:).datenm]',7,0);
                intv = find(tb_prev >=9);
                prev_night = mean([fv_prev(intv).entropyvar]);
                prev_whole = mean([fv_prev(:).entropyvar]);
            else
                night_to_morn = NaN;
                day_to_day = NaN;
            end
            fv = eval([params.findnote(n).fvstruct,params.trial(i).name]);
            tb = jc_tb([fv(:).datenm]',7,0)/3600;
            st = floor(tb(1)); en = ceil(tb(end));hrs = [st:en];
            wholeday = mean([fv(:).entropyvar]);
            
            %hourly 
            hour = NaN(length(hrs),1);
            for ind = 1:length(hrs)-1
                intv = find(tb>=hrs(ind) & tb<hrs(ind+1));   
                if length(intv) >= 20
                    samp = [fv(intv).entropyvar]';
                    hour(ind) = mean(samp);
                else
                    continue
                end
            end
            hour = 100*[diff(hour)./hour(1:end-1)]; 
            
            %morning 
            intv = find(tb>=hrs(1) & tb<= 3);
            if length(intv) >= 20
                mornpitch = mean([fv(intv).entropyvar]);
            else
                mornpitch = NaN;
            end
            
            %evening
            intv = find(tb>=11);
            if length(intv) >= 20
                nightpitch = mean([fv(intv).entropyvar]);
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
    nstd = 3;
    pre_pitch = jc_removeoutliers(pre_pitch,nstd);
    pre_spent = jc_removeoutliers(pre_spent,nstd);
    pre_entvar = jc_removeoutliers(pre_entvar,nstd);
    pre_dur = jc_removeoutliers(pre_dur,nstd);
    
    post_pitch = jc_removeoutliers(post_pitch,nstd);
    post_spent = jc_removeoutliers(post_spent,nstd);
    post_entvar = jc_removeoutliers(post_entvar,nstd);
    post_dur = jc_removeoutliers(post_dur,nstd);
    
    pre_pitch = (pre_pitch-nanmean(pre_pitch,1))./nanstd(pre_pitch,1);
    pre_spent = (pre_spent-nanmean(pre_spent,1))./nanstd(pre_spent,1);
    pre_entvar = (pre_entvar-nanmean(pre_entvar,1))./nanstd(pre_entvar,1);
    pre_dur = (pre_dur-nanmean(pre_dur,1))./nanstd(pre_dur,1);

    post_pitch = (post_pitch-nanmean(post_pitch,1))./nanstd(post_pitch,1);
    post_spent = (post_spent-nanmean(post_spent,1))./nanstd(post_spent,1);
    post_entvar = (post_entvar-nanmean(post_entvar,1))./nanstd(post_entvar,1);
    post_dur = (post_dur-nanmean(post_dur,1))./nanstd(post_dur,1);

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