function jc_plottransprob(batch)
%plots figure for transition probability and transition entropy for each
%treatment day in batch between baseline and condition
%performs permutation test to calculate p-value for difference in
%transition probability or transition entropy between conditions for each
%trial

config;

ff = load_batchf(batch);
spc = 0.15;
for k = 1:length(params.sequences)
    motifs = params.sequences{k};
    [~,modified_motifs] = db_con_or_div(motifs);
    mcolor = hsv(length(motifs));
    structname = ['seq_',strjoin(motifs,'_'),'_'];
    figure;
    h = subtightplot(2,1,1,0.07,0.08,0.15);hold on;
    h2 = subtightplot(2,1,2,0.07,0.08,0.15);hold on;
    daycnt = 1;
    for i = 1:params.numconditions:length(ff)
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

        if isempty(strfind(batch,'sal'))
            drugtime = params.treatmenttime.(['tr_',ff(i+1).name]);
            drugtime = etime(datevec(drugtime,'HH:MM'),datevec('07:00','HH:MM'))/3600;
            startpt = (drugtime+params.latency)*3600;
        else
            startpt = params.treatmenttime.saline;
            startpt = etime(datevec(startpt,'HH:MM'),datevec('07:00','HH:MM'));
        end

        if strcmp(params.baselinetype,'cross day')     
            ind2 = find(tb_cond1 >= startpt);
            tb_cond1 = tb_cond1(ind2);
            ind1 = find(tb_sal >= tb_cond1(1) & tb_sal <= tb_cond1(end));
            tb_sal = tb_sal(ind1);
        elseif strcmp(params.baselinetype,'same day')
            if isempty(strfind(batch,'sal'))
                ind2 = find(tb_cond1 >= startpt);
                tb_cond1 = tb_cond1(ind2);
                ind1 = 1:length(tb_sal);
            else
                ind2 = find(tb_sal>=startpt);
                tb_cond1 = tb_sal(ind2);
                ind1 = find(tb_sal < startpt);
                tb_sal = tb_sal(ind1);
            end
        end

        if ~isempty(strfind(ff(i+1).name,'naspm'))&~isempty(strfind(ff(i+1).name,'apv'))
            mrk2 = 'og';
            mcolor2 = 'g';
        elseif ~isempty(strfind(ff(i+1).name,'apv'))
            mrk2 = 'ob';
            mcolor2 = 'b';
        elseif ~isempty(strfind(ff(i+1).name,'naspm'))
            mrk2 = 'or';
            mcolor2 = 'r';
        else
            mrk2 = 'ok';
            mcolor2 = 'k';
        end

        
        cmd1 = ['trans_sal =',structname,ff(i).name,'.trans_per_song;'];
        eval(cmd1);
        trans_sal = cell2mat(trans_sal);
        trans_sal = trans_sal(ind1);
        if ~isempty(ff(i+1).name)
            cmd2 = ['trans_cond1 =',structname,ff(i+1).name,'.trans_per_song;'];
            eval(cmd2);
            trans_cond1 = cell2mat(trans_cond1);
            trans_cond1 = trans_cond1(ind2);
        else
            trans_cond1 = trans_sal(ind2);
        end
          
        %plot bootstrapped confidence intervals 
        [boot_results entropy_results] = db_transition_probability_calculation2(trans_sal, motifs);
        [boot_results1 entropy_results1] = db_transition_probability_calculation2(trans_cond1,motifs);

        for n = 1:length(motifs)
            hi = prctile(boot_results.([motifs{n}]),95);
            lo = prctile(boot_results.([motifs{n}]),5);
            mn = median(boot_results.([motifs{n}]));
            hi1 = prctile(boot_results1.([motifs{n}]),95);
            lo1 = prctile(boot_results1.([motifs{n}]),5);
            mn1 = median(boot_results1.([motifs{n}]));

            plot(h,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
            plot(h,daycnt,mn,'ok','MarkerSize',8,'linewidth',2);hold on;
            plot(h,[daycnt daycnt]+spc,[hi1 lo1],'color',mcolor(n,:),'linewidth',2);hold on;
            plot(h,daycnt+spc,mn1,'o','MarkerSize',8,'color',mcolor(n,:),'linewidth',2);hold on;
            plot(h,[daycnt daycnt+spc],[mn mn1],'color',[0 0 0]+0.85,'linewidth',2);hold on;

        end
        ob = [];
        for n = 1:length(motifs)
            o = findobj(h,'color',mcolor(n,:));
            ob = [ob;o(1)];
        end
        legend(ob,motifs);

        hi2 = prctile(entropy_results,95);
        lo2 = prctile(entropy_results,5);
        mn2 = mean(entropy_results);
        hi3 = prctile(entropy_results1,95);
        lo3 = prctile(entropy_results1,5);
        mn3 = mean(entropy_results1);

        plot(h2,[daycnt daycnt],[hi2 lo2],'k','linewidth',2);hold on;
        plot(h2,daycnt,mn2,'ok','MarkerSize',8,'linewidth',2);hold on;

        plot(h2,[daycnt daycnt]+spc,[hi3 lo3],'color',mcolor2,'linewidth',2);hold on;
        plot(h2,daycnt+spc,mn3,mrk2,'MarkerSize',8,'linewidth',2);hold on;
        plot(h2,[daycnt daycnt+spc],[mn2 mn3],'color',[0 0 0]+0.85,'linewidth',2);hold on;
        
        %p value: permutation test for transition probability and entropy
        %between baseline and condition, shuffle by bout
        cmd1 = ['tb_sal =',structname,ff(i).name,'.time_per_song;'];
        cmd2 = ['tb_cond1 =',structname,ff(i+1).name,'.time_per_song;'];
        eval(cmd1);
        eval(cmd2);
        tb_sal = jc_tb(cellfun(@(x) x(1),tb_sal)',7,0);
        tb_cond1 = jc_tb(cellfun(@(x) x(1),tb_cond1)',7,0);
        if strcmp(params.baselinetype,'cross day')     
            ind2 = find(tb_cond1 >= startpt);
            tb_cond1 = tb_cond1(ind2);
            ind1 = find(tb_sal >= tb_cond1(1) & tb_sal <= tb_cond1(end));
            tb_sal = tb_sal(ind1);
        elseif strcmp(params.baselinetype,'same day')
            ind2 = find(tb_cond1 >= startpt);
            tb_cond1 = tb_cond1(ind2);
            ind1 = 1:length(tb_sal);
        end
        cmd1 = ['trans_sal =',structname,ff(i).name,'.trans_per_song;'];
        cmd2 = ['trans_cond1 =',structname,ff(i+1).name,'.trans_per_song;'];
        eval(cmd1);
        eval(cmd2);
        trans_sal = trans_sal(ind1);
        trans_cond1 = trans_cond1(ind2);
        
        numpool1 = length(trans_sal);
        numpool2 = length(trans_cond1);
        numreps = 1000;
        trans_pool = [trans_sal trans_cond1];
        for iter = 1:numreps
            shuff = trans_pool(randperm(length(trans_pool)));
            trans_sal_shuff = cell2mat(shuff(1:numpool1));
            trans_cond1_shuff = cell2mat(shuff(numpool1+1:end));
            shuffprobs_sal = [];
            shuffprobs_cond1 = [];
            for n = 1:length(motifs)
                mn_sal = length(strfind(trans_sal_shuff,modified_motifs{n}))/length(trans_sal_shuff);
                mn_cond = length(strfind(trans_cond1_shuff,modified_motifs{n}))/length(trans_cond1_shuff);
                transdiff_distribution.([motifs{n}])(iter) = mn_cond-mn_sal;
                shuffprobs_sal = [shuffprobs_sal; mn_sal];
                shuffprobs_cond1 = [shuffprobs_cond1; mn_cond];
            end
            shuffent_sal = shuffprobs_sal.*log2(shuffprobs_sal);
            shuffent_sal = sum(shuffent_sal)*-1;
            shuffent_cond1 = shuffprobs_cond1.*log2(shuffprobs_cond1);
            shuffent_cond1 = sum(shuffent_cond1)*-1;
            entropydiff_distribution(iter) = shuffent_cond1-shuffent_sal;
        end
        
        for nnn = 1:length(motifs)
            transdiff_pval.([motifs{nnn}]) = sum(abs(transdiff_distribution.([motifs{nnn}])) > abs(mn1-mn))/numreps;
        end
        entdiff_pval = sum(abs(entropydiff_distribution) > abs(mn3-mn2))/numreps;
        
        if length(motifs) > 2
            str = [];
            for nnn = 1:length(motifs)
                str = [str;'p=',num2str(transdiff_pval.([motifs{nnn}]))];
            end
            text(h,daycnt,1,str,'fontsize',7);
        else
            text(h,daycnt,1,['p=',num2str(transdiff_pval.([motifs{1}]))],'fontsize',7);
        end
        
        str = ['p=',num2str(entdiff_pval)];
        text(h2,daycnt,1,str,'fontsize',7);
        
        daycnt = daycnt+1;
        clear ind*
    end
    title(h,['transition probability with 90% CI']);
    ylabel(h,'probability');
    set(h,'fontweight','bold','xlim',[0.5 daycnt-0.5],'xtick',[1:daycnt-1],...
        'ylim',[0 1]);            

    title(h2,['transition entropy with 90% CI']);
    ylabel(h2,'probability');
    set(h2,'fontweight','bold','xlim',[0.5 daycnt-0.5],'xtick',[1:daycnt-1],...
        'ylim',[0.5 1]);  

    
end

% batchname = 'batchsal';
% ff = load_batchf(batchname);
% figure;
% h = subtightplot(2,1,1,0.07,0.08,0.15);hold on;
% h2 = subtightplot(2,1,2,0.07,0.08,0.15);hold on;
% daycnt = 1;
% mcolor = hsv(length(motifs));
% for i = 1:2:length(ff);
%     eval(['load(''analysis/data_structures/seq_rn_or_in_',ff(i).name,''')']);
%     eval(['load(''analysis/data_structures/seq_rn_or_in_',ff(i+1).name,''')']);
%     cmd1 = ['tb_sal1 = seq_rn_or_in_',ff(i).name,'.time_per_song;'];
%     cmd2 = ['tb_sal2 = seq_rn_or_in_',ff(i+1).name,'.time_per_song;'];
%     eval(cmd1);
%     eval(cmd2);
%     cmd1 = ['tb_sal1 = jc_tb(cell2mat(tb_sal1)'',7,0);'];
%     cmd2 = ['tb_sal2 = jc_tb(cell2mat(tb_sal2)'',7,0);'];
%     eval(cmd1);
%     eval(cmd2);
%     
%     startpt = 4*3600;
%     ind2 = find(tb_sal2 >= startpt);
%     tb_sal2 = tb_sal2(ind2);
%     ind1 = find(tb_sal >= tb_sal2(1) & tb_sal <= tb_sal2(end));
%     tb_sal1 = tb_sal1(ind1);
%     
%     mrk2 = 'ok';
%     mcolor2 = 'k';
%     
%     cmd1 = ['trans_sal1 = seq_rn_or_in_',ff(i).name,'.trans_per_song;'];
%     cmd2 = ['trans_sal2 = seq_rn_or_in_',ff(i+1).name,'.trans_per_song;'];
%     eval(cmd1);
%     eval(cmd2);
%     trans_sal1 = cell2mat(trans_sal1);
%     trans_sal2 = cell2mat(trans_sal2);
%     trans_sal2 = trans_sal2(ind2);
%     trans_sal1 = trans_sal1(ind1);
% 
%     [boot_results entropy_results] = db_transition_probability_calculation2(trans_sal1, motifs);
%     [boot_results1 entropy_results1] = db_transition_probability_calculation2(trans_sal2,motifs);
% 
%     for n = 1:length(motifs)
% 
%         hi = prctile(boot_results.([motifs{n}]),95);
%         lo = prctile(boot_results.([motifs{n}]),5);
%         mn = median(boot_results.([motifs{n}]));
%         hi1 = prctile(boot_results1.([motifs{n}]),95);
%         lo1 = prctile(boot_results1.([motifs{n}]),5);
%         mn1 = median(boot_results1.([motifs{n}]));
% 
%         plot(h,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
%         plot(h,daycnt,mn,'ok','MarkerSize',8,'linewidth',2);hold on;
%         plot(h,[daycnt daycnt]+spc,[hi1 lo1],'color',mcolor(n,:),'linewidth',2);hold on;
%         plot(h,daycnt+spc,mn1,'o','MarkerSize',8,'color',mcolor(n,:),'linewidth',2);hold on;
%         plot(h,[daycnt daycnt+spc],[mn mn1],'color',[0 0 0]+0.85,'linewidth',2);hold on;
%    
%     end
%     ob = [];
%     for n = 1:length(motifs)
%         o = findobj(h,'color',mcolor(n,:));
%         ob = [ob;o(1)];
%     end
%     legend(ob,motifs);
%     
%     hi = prctile(entropy_results,95);
%     lo = prctile(entropy_results,5);
%     mn = mean(entropy_results);
%     hi1 = prctile(entropy_results1,95);
%     lo1 = prctile(entropy_results1,5);
%     mn1 = mean(entropy_results1);
% 
%     plot(h2,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
%     plot(h2,daycnt,mn,'ok','MarkerSize',8,'linewidth',2);hold on;
% 
%     plot(h2,[daycnt daycnt]+spc,[hi1 lo1],'color',mcolor2,'linewidth',2);hold on;
%     plot(h2,daycnt+spc,mn1,mrk2,'MarkerSize',8,'linewidth',2);hold on;
%    
%     daycnt = daycnt+1;
%     clear ind1 ind2
% end
% title(h,['transition probability with 90% CI']);
% ylabel(h,'probability');
% set(h,'fontweight','bold','xlim',[0.5 daycnt-0.5],'xtick',[1:daycnt-1]);            
% 
% title(h2,['transition entropy with 90% CI']);
% ylabel(h2,'probability');
% set(h2,'fontweight','bold','xlim',[0.5 daycnt-0.5],'xtick',[1:daycnt-1]);  