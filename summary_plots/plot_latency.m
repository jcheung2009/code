function latency = plot_latency(condition,feature);

%plots figure for each treatment day of running average of mean pitch,
%indicates when it exceeds 1 std of pitch during saline morning of same day
%generates data structure storing time of treatment and latency until drug
%effect for each trial 

%parameters
config
trialind = find(arrayfun(@(x) strcmp(x.condition,condition),params.trial));
latency = struct();
for i = 1:length(trialind)

    figure;hold on;
    ax = gca;
    mcolor = hsv(length(params.findnote));
    for ii = 1:length(params.findnote)
        cmd1 = ['load(''analysis/data_structures/',params.findnote(ii).fvstruct,...
            params.trial(trialind(i)).name,''');'];
        cmd2 = ['load(''analysis/data_structures/',params.findnote(ii).fvstruct,...
            params.trial(trialind(i)).baseline,''');'];
        eval(cmd1);
        eval(cmd2);
        cmd = ['fv_sal =',params.findnote(ii).fvstruct,params.trial(trialind(i)).baseline,';'];
        cmd2 = ['fv_cond =',params.findnote(ii).fvstruct,params.trial(trialind(i)).name,';'];
        eval(cmd);
        eval(cmd2);
        
        if strcmp(feature,'pitch')
            sal_vals = [fv_sal(:).mxvals];
            cond_vals = [fv_cond(:).mxvals];
        elseif strcmp(feature,'volume')
            sal_vals = log([fv_sal(:).maxvol]);
            cond_vals = log([fv_cond(:).maxvol]);
        elseif strcmp(feature,'cv')
            cond_vals = ([fv_cond(:).mxvals]-nanmean([fv_sal(:).mxvals]))./nanstd([fv_sal(:).mxvals]);
        end

        tb_cond = jc_tb([fv_cond(:).datenm]',7,0);
        tb_sal = jc_tb([fv_sal(:).datenm]',7,0);
        numseconds = tb_cond(end)-tb_cond(1);
        timewindow = 3600; % hr in seconds
        jogsize = 900;%15 minutes
        numtimewindows = floor(numseconds/jogsize)-(timewindow/jogsize)/2;%2*floor(numseconds/timewindow)-1;
        if numtimewindows <= 0
            numtimewindows = 1;
        end

        timept1 = tb_cond(1);
        fv_cond_avg = [];
        for p = 1:numtimewindows
            timept2 = timept1+timewindow;
            ind = find(tb_cond >= timept1 & tb_cond < timept2);
            if strcmp(params.baseepoch,'morn')
                indsal = 1:length(tb_sal);
            else
                indsal = find(tb_sal >= timept1 & tb_sal < timept2);
            end
            cond_valsn = (cond_vals(ind)-nanmean(sal_vals(indsal)))./nanstd(sal_vals(indsal));
            fv_cond_avg = [fv_cond_avg;timept1 nanmean(cond_valsn)];
            timept1 = timept1+jogsize;
        end
        
        fv_cond_avg(:,1) = fv_cond_avg(:,1)/3600;
        hold(ax,'on');
        plot(ax,[0 12],[1 1],'k','linewidth',2);hold on;
        plot(ax,[0 12],[-1 -1],'k','linewidth',2);hold on;
        plot(ax,fv_cond_avg(:,1),fv_cond_avg(:,2),'color',mcolor(ii,:),'marker','o');hold on;
        
        set(ax,'fontweight','bold');
        title(params.trial(trialind(i)).name,'interpreter','none');
        xlim([0 12]);
        ylim('auto');
        ylabel('z-score');
        xlabel('Hours since 7 AM');
        
        ind_1std = find(abs(fv_cond_avg(:,2)) >= 1);
        if isempty(ind_1std) | length(ind_1std) < 2
            latency.(['tr_',params.findnote(ii).fvstruct,params.trial(...
                trialind(i)).name]) = NaN;
        else
            latency.(['tr_',params.findnote(ii).fvstruct,params.trial(...
                trialind(i)).name]) = fv_cond_avg(ind_1std(1),1);
        end
        
        if params.trial(trialind(i)).treattime
            treat_time = params.trial(trialind(i)).treattime;
            treat_time = datevec(treat_time,'HH:MM');
            day_st = datevec('07:00','HH:MM');
            treat_time = etime(treat_time,day_st);
        else
            treat_time = tb_cond(1);
        end 
        
        treat_time = treat_time/3600;   
        if isempty(ind_1std) | length(ind_1std) < 2
            latency.(['tr_',params.findnote(ii).fvstruct,params.trial(...
                trialind(i)).name]) = NaN;
        else
            latency.(['tr_',params.findnote(ii).fvstruct,params.trial(...
                trialind(i)).name]) = fv_cond_avg(ind_1std(1),1)-treat_time;
        end 
    end
    h = [];
    for n = 1:length(params.findnote)
        h = [h;findobj(ax,'color',mcolor(n,:))];
    end
    legend(h,{params.findnote(:).syllable});
    plot(ax,treat_time,1,'r*','markersize',12);
    hold(ax,'off');
    
    clearvars -except params latency i ii trialind feature condition
end
        
        
        