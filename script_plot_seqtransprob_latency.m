%plots running average of sequence transition probability 

batchname = 'batchdcs';
ff = load_batchf(batchname);
load('analysis/data_structures/apvpitchcvlatency.mat');
load('analysis/data_structures/apvnaspmlatency.mat')
load('analysis/data_structures/naspmpitchcvlatency.mat');
load('analysis/data_structures/naspmapvlatency.mat');
load('analysis/data_structures/dcslatency.mat');
motifs = {'ab','gb'};
[~,modified_motifs] = db_con_or_div(motifs);
if isempty(strfind(batchname,'sal'))
    for i =  1:3:length(ff)

        figure;hold on;
        ax = gca;
        mcolor = hsv(length(motifs));
        eval(['load(''analysis/data_structures/seq_ab_or_gb_',ff(i).name,''')']);
        eval(['load(''analysis/data_structures/seq_ab_or_gb_',ff(i+1).name,''')']);
         if ~isempty(ff(i+2).name)
                cmd3 = ['load(''analysis/data_structures/seq_ab_or_gb_',ff(i+2).name,''')'];
                eval(cmd3);
                cmd3 = ['tb_cond2 = seq_ab_or_gb_',ff(i+2).name,'.time_per_song;'];
                eval(cmd3);
                cmd3 = ['tb_cond2 = jc_tb(cell2mat(tb_cond2)'',7,0);'];
                eval(cmd3);
         end
        cmd1 = ['tb_sal = seq_ab_or_gb_',ff(i).name,'.time_per_song;'];
        cmd2 = ['tb_cond1 = seq_ab_or_gb_',ff(i+1).name,'.time_per_song;'];
        eval(cmd1);
        eval(cmd2);
        cmd1 = ['tb_sal = jc_tb(cell2mat(tb_sal)'',7,0);'];
        cmd2 = ['tb_cond1 = jc_tb(cell2mat(tb_cond1)'',7,0);'];
        eval(cmd1);
        eval(cmd2);

        cmd1 = ['trans_sal = seq_ab_or_gb_',ff(i).name,'.trans_per_song;'];
        cmd2 = ['trans_cond1 = seq_ab_or_gb_',ff(i+1).name,'.trans_per_song;'];
        eval(cmd1);
        eval(cmd2);
        trans_sal = cell2mat(trans_sal);
        trans_cond1 = cell2mat(trans_cond1);
        if ~isempty(ff(i+2).name)
                cmd3 = ['trans_cond2 = seq_ab_or_gb_',ff(i+2).name,'.trans_per_song;'];
                eval(cmd3);
                trans_cond2 = cell2mat(trans_cond2);
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
            for m = 1:length(modified_motifs)
                transavg{m} = [transavg{m};timept1 length(strfind(syllpool,modified_motifs{m}))/length(syllpool)];
            end
            timept1 = timept1+jogsize;
        end

         if ~isempty(ff(i+2).name)
                numseconds = tb_cond2(end)-tb_cond2(1);
                timewindow = 3600; % hr in seconds
                jogsize = 900;%15 minutes
                numtimewindows = ceil(numseconds/jogsize)-(timewindow/jogsize)/2;%2*ceil(numseconds/timewindow)-1;
                if numtimewindows <= 0
                    numtimewindows = 1;
                end

                timept1 = tb_cond2(1);
                transavg2 = cell(1,length(modified_motifs));
                for p = 1:numtimewindows
                    timept2 = timept1+timewindow;
                    ind = find(tb_cond2 >= timept1 & tb_cond2 < timept2);
                    syllpool = trans_cond2(ind);
                    for m = 1:length(modified_motifs)
                        transavg2{m} = [transavg2{m};timept1 length(strfind(syllpool,modified_motifs{m}))/length(syllpool)];
                    end
                    timept1 = timept1+jogsize;
                end
         end

         boot = db_transition_probability_calculation2(trans_sal,motifs);
         for m = 1:length(motifs);
            hi = prctile(boot.([motifs{m}]),95);
            lo = prctile(boot.([motifs{m}]),5);
            patch([0 14 14 0],[lo lo hi hi],'k','FaceAlpha',0.2,'edgecolor','none');
            
            plot(transavg{m}(:,1)/3600,transavg{m}(:,2),'color',mcolor(m,:),'marker','o','linewidth',2);hold on;
            if ~isempty(ff(i+2).name)
                plot(transavg2{m}(:,1)/3600,transavg2{m}(:,2),'color',mcolor(m,:),'marker','o','linewidth',2);hold on;
            end
            set(gca,'fontweight','bold');
            if ~isempty(ff(i+2).name)
                title(ff(i+2).name,'interpreter','none');
            else
                title(ff(i+1).name,'interpreter','none');
            end
            xlim([0 14]);
            ylim('auto');
            ylabel('transition probability');
            xlabel('Hours since 7 AM');

            if ~isempty(strfind(ff(i+1).name,'apvnaspm')) 
                drugtime = apvnaspmlatency.(['tr_',ff(i+1).name]).treattime;
            elseif ~isempty(strfind(ff(i+1).name,'naspm'))
                drugtime = naspmpitchcvlatency.(['tr_',ff(i+1).name]).treattime;
            elseif ~isempty(strfind(ff(i+1).name,'apv'))
                drugtime = apvpitchcvlatency.(['tr_',ff(i+1).name]).treattime;
            elseif ~isempty(strfind(ff(i+1).name,'dcs'))
                drugtime = dcslatency.(['tr_',ff(i+1).name]).treattime;
            end

            plot(drugtime,hi,'*','markersize',12,'linewidth',2,'color',[0 0 0]+0.5);hold on;

            if ~isempty(ff(i+2).name)
                if ~isempty(strfind(ff(i+2).name,'naspmapv'))
                    drugtime2 = naspmapvlatency.(['tr_',ff(i+2).name]).treattime;
                elseif ~isempty(strfind(ff(i+2).name,'apvnaspm'))
                    drugtime2 = apvnaspmlatency.(['tr_',ff(i+2).name]).treattime;
                end
                plot(drugtime2,hi,'*','markersize',12,'linewidth',2,'color',[0 0 0]+0.5);hold on; 
            end

         end
    end
else
    for i =  1:length(ff)
        figure;hold on;
        ax = gca;
        mcolor = hsv(length(motifs));
        eval(['load(''analysis/data_structures/seq_ab_or_gb_',ff(i).name,''')']);
        cmd1 = ['tb_sal = seq_ab_or_gb_',ff(i).name,'.time_per_song;'];
        eval(cmd1);
        cmd1 = ['tb_sal = jc_tb(cell2mat(tb_sal)'',7,0);'];
        eval(cmd1);

        cmd1 = ['trans_sal = seq_ab_or_gb_',ff(i).name,'.trans_per_song;'];
        eval(cmd1);
        trans_sal = cell2mat(trans_sal);
        numseconds = tb_sal(end)-tb_sal(1);
        timewindow = 3600; % hr in seconds
        jogsize = 900;%15 minutes
        numtimewindows = ceil(numseconds/jogsize)-(timewindow/jogsize)/2;
        if numtimewindows < 0
            numtimewindows = 1;
        end

        timept1 = tb_sal(1);
        transavg = cell(1,length(modified_motifs));
        for p = 1:numtimewindows
            timept2 = timept1+timewindow;
            ind = find(tb_sal >= timept1 & tb_sal < timept2);
            syllpool = trans_sal(ind);
            for m = 1:length(modified_motifs)
                transavg{m} = [transavg{m};timept1 length(strfind(syllpool,modified_motifs{m}))/length(syllpool)];
            end
            timept1 = timept1+jogsize;
        end

         boot = db_transition_probability_calculation2(trans_sal,motifs);
         for m = 1:length(motifs);
            hi = prctile(boot.([motifs{m}]),95);
            lo = prctile(boot.([motifs{m}]),5);
            plot(transavg{m}(:,1)/3600,transavg{m}(:,2),'color',mcolor(m,:),'marker','o','linewidth',2);hold on;
            set(gca,'fontweight','bold');
            title(ff(i).name,'interpreter','none');
            xlim([0 14]);
            ylim('auto');
            ylabel('transition probability');
            xlabel('Hours since 7 AM');

            plot([0 14],[hi hi],'k','linewidth',2);hold on;
            plot([0 14],[lo lo],'k','linewidth',2);hold on;
         end
    end
end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        