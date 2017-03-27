%plots figure for transition probability and transition entropy for each
%treatment day 
%%use batchnaspm2, batchapv2

ff = load_batchf('batchnaspm2');
load('analysis/data_structures/apvpitchcvlatency.mat');
load('analysis/data_structures/apvnaspmlatency.mat')
load('analysis/data_structures/naspmpitchcvlatency.mat');
load('analysis/data_structures/naspmapvlatency.mat');
load('analysis/data_structures/dcslatency.mat');
motifs = {'ab','gb'};
spc = 0.15;
figure;
h = subtightplot(2,1,1,0.07,0.08,0.15);hold on;
h2 = subtightplot(2,1,2,0.07,0.08,0.15);hold on;
daycnt = 1;
mcolor = hsv(length(motifs));
for i = 1:3:length(ff);
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

         if ~isempty(strfind(ff(i+1).name,'apvnaspm')) 
            drugtime = apvnaspmlatency.(['tr_',ff(i+1).name]).treattime;
        elseif ~isempty(strfind(ff(i+1).name,'naspm'))
            drugtime = naspmpitchcvlatency.(['tr_',ff(i+1).name]).treattime;
        elseif ~isempty(strfind(ff(i+1).name,'apv'))
            drugtime = apvpitchcvlatency.(['tr_',ff(i+1).name]).treattime;
         elseif ~isempty(strfind(ff(i+1).name,'dcs'))
            drugtime = dcslatency.(['tr_',ff(i+1).name]).treattime;
        end
        startpt = (drugtime+0.61)*3600;%change latency time!
        ind = find(tb_cond1 >= startpt);
    
        if ~isempty(ff(i+2).name)
            if ~isempty(strfind(ff(i+2).name,'naspmapv'))
                drugtime2 = naspmapvlatency.(['tr_',ff(i+2).name]).treattime;
            elseif ~isempty(strfind(ff(i+2).name,'apvnaspm'))
                drugtime2 = apvnaspmlatency.(['tr_',ff(i+2).name]).treattime;
            end
            startpt2 = (drugtime2+0.61)*3600;
            ind2 = find(tb_cond2 >= startpt2);
            tb_cond2 = tb_cond2(ind2);
        else %single drug condiiton
            startpt2 = (drugtime+4)*3600;
            ind2 = find(tb_cond1 > startpt2);
            tb_cond2 = tb_cond1(ind2);
        end    
        tb_cond1 = tb_cond1(ind);
        
        cmd1 = ['trans_sal = seq_ab_or_gb_',ff(i).name,'.trans_per_song;'];
        cmd2 = ['trans_cond1 = seq_ab_or_gb_',ff(i+1).name,'.trans_per_song;'];
        eval(cmd1);
        eval(cmd2);
        trans_sal = cell2mat(trans_sal);
        trans_cond1 = cell2mat(trans_cond1);
        trans_cond1 = trans_cond1(ind);
        if ~isempty(ff(i+2).name)
            cmd3 = ['trans_cond2 = seq_ab_or_gb_',ff(i+2).name,'.trans_per_song;'];
            eval(cmd3);
        else 
            cmd3 = ['trans_cond2 = seq_ab_or_gb_',ff(i+1).name,'.trans_per_song;'];
            eval(cmd3);
        end
        trans_cond2 = cell2mat(trans_cond2);
        trans_cond2 = trans_cond2(ind2);
            
        [boot_results entropy_results] = db_transition_probability_calculation2(trans_sal, motifs);
        [boot_results1 entropy_results1] = db_transition_probability_calculation2(trans_cond1,motifs);
        [boot_results2 entropy_results2] = db_transition_probability_calculation2(trans_cond2,motifs);
        
        for n = 1:length(motifs)
            cmap = zeros(3,3);
            cmap(:,1) = linspace(mcolor(n,1)*0.7,mcolor(n,1),3)';
            cmap(:,2) = linspace(mcolor(n,2)*0.7,mcolor(n,2),3)';
            cmap(:,3) = linspace(mcolor(n,3)*0.7,mcolor(n,3),3)';

            hi = prctile(boot_results.([motifs{n}]),95);
            lo = prctile(boot_results.([motifs{n}]),5);
            mn = median(boot_results.([motifs{n}]));
            hi1 = prctile(boot_results1.([motifs{n}]),95);
            lo1 = prctile(boot_results1.([motifs{n}]),5);
            mn1 = median(boot_results1.([motifs{n}]));
            hi2 = prctile(boot_results2.([motifs{n}]),95);
            lo2 = prctile(boot_results2.([motifs{n}]),5);
            mn2 = median(boot_results2.([motifs{n}]));
            
            plot(h,[daycnt daycnt],[hi lo],'color',cmap(1,:),'linewidth',2);hold on;
            plot(h,daycnt,mn,'o','MarkerSize',8,'color',cmap(1,:),'linewidth',2);hold on;
            plot(h,[daycnt daycnt]+spc,[hi1 lo1],'color',cmap(2,:),'linewidth',2);hold on;
            plot(h,daycnt+spc,mn1,'o','MarkerSize',8,'color',cmap(2,:),'linewidth',2);hold on;
            if ~isempty(ff(i+2).name)
                plot(h,[daycnt daycnt]+2*spc,[hi2 lo2],'color',cmap(3,:),'linewidth',2);hold on;
                plot(h,daycnt+2*spc,mn2,'o','MarkerSize',8,'color',cmap(3,:),'linewidth',2);hold on;
            else
                plot(h,[daycnt daycnt]+2*spc,[hi2 lo2],'color',cmap(2,:),'linewidth',2);hold on;
                plot(h,daycnt+2*spc,mn2,'o','MarkerSize',8,'color',cmap(2,:),'linewidth',2);hold on;
            end
        end
        hi = prctile(entropy_results,95);
        lo = prctile(entropy_results,5);
        mn = mean(entropy_results);
        hi1 = prctile(entropy_results1,95);
        lo1 = prctile(entropy_results1,5);
        mn1 = mean(entropy_results1);
        hi2 = prctile(entropy_results2,95);
        lo2 = prctile(entropy_results2,5);
        mn2 = mean(entropy_results2);

        plot(h2,[daycnt daycnt],[hi lo],'k','linewidth',2);hold on;
        plot(h2,daycnt,mn,'ok','MarkerSize',8,'linewidth',2);hold on;
        if ~isempty(strfind(ff(i+1).name,'apvnaspm'))
            mrk = 'og';
            mcolor2 = 'g';
        elseif ~isempty(strfind(ff(i+1).name,'naspm'))
            mrk = 'or';
            mcolor2 = 'r';
        elseif ~isempty(strfind(ff(i+1).name,'iem'))
            mrk = 'om';
            mcolor2 = 'm';
        elseif ~isempty(strfind(ff(i+1).name,'apv'))
            mrk = 'ob';
            mcolor2 = 'b';
        elseif ~isempty(strfind(ff(i+1).name,'dcs'))
            mrk = 'mo';
            mcolor2 = 'm';
        else
            mrk = 'ok';
            mcolor2 = 'k';
        end
        plot(h2,[daycnt daycnt]+spc,[hi1 lo1],'color',mcolor2,'linewidth',2);hold on;
        plot(h2,daycnt+spc,mn1,mrk,'MarkerSize',8,'linewidth',2);hold on;
        if ~isempty(ff(i+2).name)
            plot(h2,[daycnt daycnt]+2*spc,[hi2 lo2],'g','linewidth',2);hold on;
            plot(h2,daycnt+2*spc,mn2,'og','MarkerSize',8,'linewidth',2);hold on;
        else
            plot(h2,[daycnt daycnt]+2*spc,[hi2 lo2],'color',mcolor2,'linewidth',2);hold on;
            plot(h2,daycnt+2*spc,mn2,mrk,'MarkerSize',8,'linewidth',2);hold on;
        end
        daycnt = daycnt+1;
end
title(h,['transition probability with 90% CI']);
ylabel(h,'probability');
set(h,'fontweight','bold','xlim',[0.5 daycnt-0.5],'xtick',[1:daycnt-1]);            

title(h2,['transition entropy with 90% CI']);
ylabel(h2,'probability');
set(h2,'fontweight','bold','xlim',[0.5 daycnt-0.5],'xtick',[1:daycnt-1]);  
        