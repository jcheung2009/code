function jc_plotseqtransprob_runavg(batch)
%plots running average of sequence transition probability 

config;

ff = load_batchf(batch);
for k = 1:length(params.sequences)
    motifs = params.sequences{k};
    [~,modified_motifs] = db_con_or_div(motifs);
    mcolor = hsv(length(motifs));
    structname = ['seq_',strjoin(motifs,'_'),'_'];
    for i = 1:params.numconditions:length(ff)
        figure;hold on;ax = gca;
        eval(['load(''analysis/data_structures/',structname,ff(i).name,''')']);
        cmd1 = ['tb_sal =',structname,ff(i).name,'.time_per_song;'];
        eval(cmd1);
        cmd1 = ['tb_sal = jc_tb(cell2mat(tb_sal)'',7,0);'];
        eval(cmd1);
        if ~isempty(ff(i+1).name)
            eval(['load(''analysis/data_structures/',structname,ff(i+1).name,''')']);
            cmd2 = ['tb_cond1 =',structname,ff(i+1).name,'.time_per_song;'];
            eval(cmd2);
            cmd2 = ['tb_cond1 = jc_tb(cell2mat(tb_cond1)'',7,0);'];
            eval(cmd2);
        end
        
        cmd1 = ['trans_sal =',structname,ff(i).name,'.trans_per_song;'];
        eval(cmd1);
        trans_sal = cell2mat(trans_sal);
        if ~isempty(ff(i+1).name)
            cmd2 = ['trans_cond1 =',structname,ff(i+1).name,'.trans_per_song;'];
            eval(cmd2);
            trans_cond1 = cell2mat(trans_cond1);
        end
        
        numseconds = tb_cond1(end)-tb_cond1(1);
        timewindow = 3600; % hr in seconds
        jogsize = 900;%15 minutes
        numtimewindows = ceil(numseconds/jogsize)-(timewindow/jogsize)/2;
        if numtimewindows < 0
            numtimewindows = 1;
        end
        
        timept1 = tb_cond1(1);
        transavg = cell(1,length(modified_motifs));
        for p = 1:numtimewindows
            timept2 = timept1+timewindow;
            ind = find(tb_cond1 >= timept1 & tb_cond1 < timept2);
            syllpool = trans_cond1(ind);
            if length(syllpool) >= 20
                for m = 1:length(modified_motifs)
                    transavg{m} = [transavg{m};timept1 length(strfind(syllpool,modified_motifs{m}))/length(syllpool)];
                end
            end
            timept1 = timept1+jogsize;
        end

        boot = db_transition_probability_calculation2(trans_sal,motifs);
        for m = 1:length(motifs);
            hi = prctile(boot.([motifs{m}]),95);
            lo = prctile(boot.([motifs{m}]),5);
            patch([0 14 14 0],[lo lo hi hi],mcolor(m,:),'FaceAlpha',0.2,'edgecolor','none');

            plot(transavg{m}(:,1)/3600,transavg{m}(:,2),'color',mcolor(m,:),'marker','o','linewidth',2);hold on;
            
            title(ff(i+1).name,'interpreter','none');

            xlim([0 14]);
            ylim('auto');
            ylabel('transition probability');
            xlabel('Hours since 7 AM');
            
            if isempty(strfind(batch,'sal'))
                drugtime = params.treatmenttime.(['tr_',ff(i+1).name]);
                drugtime = etime(datevec(drugtime,'HH:MM'),datevec('07:00','HH:MM'))/3600;
            else
                drugtime = params.treatmenttime.saline;
                drugtime = etime(datevec(drugtime,'HH:MM'),datevec('07:00','HH:MM'))/3600;
            end
            plot(drugtime,hi,'*','markersize',12,'linewidth',2,'color',[0 0 0]+0.5);hold on;
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


   