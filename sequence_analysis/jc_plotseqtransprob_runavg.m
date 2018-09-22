function jc_plotseqtransprob_runavg
%plots running average of sequence transition probability of all trials in
%config

config;

for k = 1:length(params.findseq)
    motifs = params.findseq(k).transitions;
    mcolor = hsv(length(motifs));
    structname = params.findseq(k).seqstruct;
    [~,modified_motifs] = db_con_or_div(motifs);
    for i = 1:length(params.trial)
        try
            eval(['load(''analysis/data_structures/',structname,params.trial(i).name,''')']);
            eval(['load(''analysis/data_structures/',structname,params.trial(i).baseline,''')']);
        catch
            continue
        end
       
        cmd1 = ['tb_sal =',structname,params.trial(i).baseline,'.time_per_song;'];
        eval(cmd1);
        cmd1 = ['tb_sal = jc_tb(cell2mat(tb_sal)'',7,0);'];
        eval(cmd1);
        
        cmd2 = ['tb_cond =',structname,params.trial(i).name,'.time_per_song;'];
        eval(cmd2);
        cmd2 = ['tb_cond = jc_tb(cell2mat(tb_cond)'',7,0);'];
        eval(cmd2);
            
        
        cmd1 = ['trans_sal =',structname,params.trial(i).baseline,'.trans_per_song;'];
        eval(cmd1);
        trans_sal = cell2mat(trans_sal);
        
        cmd2 = ['trans_cond =',structname,params.trial(i).name,'.trans_per_song;'];
        eval(cmd2);
        trans_cond = cell2mat(trans_cond);

        numseconds = tb_sal(end)-tb_sal(1);
        timewindow = 3600; % hr in seconds
        jogsize = 900;%15 minutes
        numtimewindows = ceil(numseconds/jogsize)-(timewindow/jogsize)/2;
        if numtimewindows < 0
            numtimewindows = 1;
        end
        
        timept1 = tb_sal(1);
        transavg1 = cell(1,length(modified_motifs));
        for p = 1:numtimewindows
            timept2 = timept1+timewindow;
            ind = find(tb_sal >= timept1 & tb_sal < timept2);
            syllpool = trans_sal(ind);
            if length(syllpool) >= 10
                for m = 1:length(modified_motifs)
                    transavg1{m} = [transavg1{m};timept1 length(strfind(syllpool,modified_motifs{m}))/length(syllpool)];
                end
            end
            timept1 = timept1+jogsize;
        end
        
        
        numseconds = tb_cond(end)-tb_cond(1);
        timewindow = 3600; % hr in seconds
        jogsize = 900;%15 minutes
        numtimewindows = ceil(numseconds/jogsize)-(timewindow/jogsize)/2;
        if numtimewindows < 0
            numtimewindows = 1;
        end
        
        timept1 = tb_cond(1);
        transavg2 = cell(1,length(modified_motifs));
        for p = 1:numtimewindows
            timept2 = timept1+timewindow;
            ind = find(tb_cond >= timept1 & tb_cond < timept2);
            syllpool = trans_cond(ind);
            if length(syllpool) >= 10
                for m = 1:length(modified_motifs)
                    transavg2{m} = [transavg2{m};timept1 length(strfind(syllpool,modified_motifs{m}))/length(syllpool)];
                end
            end
            timept1 = timept1+jogsize;
        end

        boot = db_transition_probability_calculation2(trans_sal,motifs);
        figure;hold on;
        for m = 1:length(motifs);
            hi = prctile(boot.([motifs{m}]),95);
            lo = prctile(boot.([motifs{m}]),5);
            patch([0 14 14 0],[lo lo hi hi],mcolor(m,:),'FaceAlpha',0.2,'edgecolor','none');hold on;

            plot(transavg1{m}(:,1)/3600,transavg1{m}(:,2),'color',mcolor(m,:),'marker','o','linestyle',':','linewidth',2);hold on;
            plot(transavg2{m}(:,1)/3600,transavg2{m}(:,2),'color',mcolor(m,:),'marker','o','linewidth',2);hold on;
            
            title(params.trial(i).name,'interpreter','none')

            xlim([0 14]);
            ylim('auto');
            ylabel('transition probability');
            xlabel('Hours since 7 AM');
            
            if ~isempty(params.trial(i).treattime)
                treattime = etime(datevec(params.trial(1).treattime,'HH:MM'),datevec('07:00','HH:MM'));
                plot(treattime,hi,'*','markersize',12,'linewidth',2,'color',[0 0 0]+0.5);hold on;
            end
        end
        h = [];
        for n = 1:length(motifs)
            ob = findobj(gca,'color',mcolor(n,:),'type','line');
            h = [h;ob(1)];
        end
        legend(h,motifs)
        set(gca,'fontweight','bold','ylim',[0 1]);
    end
end


   