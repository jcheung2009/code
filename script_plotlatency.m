%plots figure for each treatment day of running average of mean pitch,
%indicates when it exceeds 1 std of pitch during saline morning of same day
%generates data structure storing time of treatment and latency until drug
%effect for each trial 


ff = load_batchf('batchdcs');
if exist('dcstreatmenttime')
    ff2 = load_batchf('dcstreatmenttime');
else
    ff2 = '';
end
naspmpitchlatency = struct();
syllables = {'A1','A2','B1','B2'};
for i = 1:2:length(ff)

    figure;hold on;
    ax = gca;
    mcolor = hsv(length(syllables));
    naspmpitchlatency.(['tr_',ff(i+1).name]).latency = [];
    for ii = 1:length(syllables)
        cmd1 = ['load(''analysis/data_structures/fv_syll',syllables{ii},'_',ff(i).name,''');'];
        cmd2 = ['load(''analysis/data_structures/fv_syll',syllables{ii},'_',ff(i+1).name,''');'];
        eval(cmd1);
        eval(cmd2);
        cmd = ['fv_sal = fv_syll',syllables{ii},'_',ff(i).name,';'];
        cmd2 = ['fv_cond = fv_syll',syllables{ii},'_',ff(i+1).name,';'];
        eval(cmd);
        eval(cmd2);
        
        pitch_sal = [fv_sal(:).mxvals];
        pitch_cond = [fv_cond(:).mxvals];
%         pitch_sal = log([fv_sal(:).maxvol]);
%         pitch_cond = log([fv_cond(:).maxvol]);
        %pitch_cond = (pitch_cond - nanmean(pitch_sal))./nanstd(pitch_sal);

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
            indsal = 1:length(tb_sal);
            %indsal = find(tb_sal >= timept1 & tb_sal < timept2);
            pitch_condn = (pitch_cond(ind)-nanmean(pitch_sal(indsal)))./nanstd(pitch_sal(indsal));
            fv_cond_avg = [fv_cond_avg;timept1 nanmean(pitch_condn)];
            timept1 = timept1+jogsize;
        end
        
        fv_cond_avg(:,1) = fv_cond_avg(:,1)/3600;
        hold(ax,'on');
        plot(ax,[0 12],[1 1],'k','linewidth',2);hold on;
        plot(ax,[0 12],[-1 -1],'k','linewidth',2);hold on;
        plot(ax,fv_cond_avg(:,1),fv_cond_avg(:,2),'color',mcolor(ii,:),'marker','o');hold on;
        
        set(ax,'fontweight','bold');
        title(ff(i+1).name,'interpreter','none');
        xlim([0 12]);
        ylim('auto');
        ylabel('z-score');
        xlabel('Hours since 7 AM');
        
        ind_1std = find(abs(fv_cond_avg(:,2)) >= 1);
        if isempty(ind_1std) | length(ind_1std) < 2
            naspmpitchlatency.(['tr_',ff(i+1).name]).(['syll',syllables{ii}]) = NaN;
        else
            naspmpitchlatency.(['tr_',ff(i+1).name]).(['syll',syllables{ii}]) = fv_cond_avg(ind_1std(1),1);
        end
        
        if ~isempty(ff2)
            [a b] = regexp(ff2(i+1).name,'[0-9]+:[0-9]+');
            st_time = ff2(i+1).name(a:b);
            st_time = datevec(st_time,'HH:MM');
            day_st = datevec('07:00','HH:MM');
            st_time = etime(st_time,day_st);
        else
            st_time = tb_cond(1);
        end
        naspmpitchlatency.(['tr_',ff(i+1).name]).treattime = st_time/3600;   
        if isempty(ind_1std) | length(ind_1std) < 2
            naspmpitchlatency.(['tr_',ff(i+1).name]).latency = [naspmpitchlatency.(['tr_',...
                ff(i+1).name]).latency; NaN];
        else
            naspmpitchlatency.(['tr_',ff(i+1).name]).latency = [naspmpitchlatency.(['tr_',...
                ff(i+1).name]).latency; fv_cond_avg(ind_1std(1),1)-st_time/3600];%time between treatment start and drug effect in hours
        end 
    end
    h = [];
    for n = 1:length(syllables)
        h = [h;findobj(ax,'color',mcolor(n,:))];
    end
    legend(h,syllables);
    plot(ax,naspmpitchlatency.(['tr_',ff(i+1).name]).treattime,1,'r*','markersize',12);
    hold(ax,'off');
    
    clearvars -except ff ff2 syllables naspmpitchlatency
end
        
        
        