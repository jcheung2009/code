function averagemotif2 = jc_plotmotifvals(motifinfo,marker,linecolor,averagerefmotif)
%motifinfo from jc_findmotif for linear motifs
%marker = 'k.';
%linecolor = 'k';
fs = 32000;
   
varseq = input('motif is variable (y/n):','s');
if varseq == 'y'
    firstpeakdistance = [];sylldurations = [];gaps = [];
    for i = 1:length(motifinfo)
        if ~isempty(motifinfo(i).firstpeakdistance)
            firstpeakdistance = [firstpeakdistance; [motifinfo(i).datenm motifinfo(i).firstpeakdistance]];
        end
        sylldurations = [sylldurations; [motifinfo(i).datenm mean(motifinfo(i).durations)]];
        gaps = [gaps;[motifinfo(i).datenm mean(motifinfo(i).gaps)]];
    end
    
    fignum = input('figure for tempo measurement over time:');
    figure(fignum);hold on;
    %plot tempo estimate over time
    tb_firstpeakdistance = jc_tb(firstpeakdistance(:,1),7,0);
    subtightplot(3,1,1,0.07,0.04,0.15);hold on;
    h = plot(tb_firstpeakdistance,firstpeakdistance(:,2),marker);
    removeoutliers = input('remove outliers? (y/n):','s');
    while removeoutliers == 'y'
        delete(h)
        ind = jc_findoutliers(firstpeakdistance(:,2),3.5);
        firstpeakdistance(ind,:) = [];
        tb_firstpeakdistance(ind) = [];
        h = plot(tb_firstpeakdistance,firstpeakdistance(:,2),marker);
        removeoutliers = input('remove outliers? (y/n):','s');
    end
%     runningaverage = jc_RunningAverage(firstpeakdistance(:,2),50);
%     fill([tb_firstpeakdistance' fliplr(tb_firstpeakdistance')],[runningaverage(:,1)'-runningaverage(:,2)',...
%     fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,...
%     'EdgeColor','none','FaceAlpha',0.5);
    title('Average duration between adjacent syllables');
    ylabel('Duration (seconds)');
    xlabel('Time (seconds since lights on)');  

    %plot average syll duration over time
      tb_syllduration = jc_tb(sylldurations(:,1),7,0);
    subtightplot(3,1,2,0.07,0.04,0.15);hold on;
    h = plot(tb_syllduration,sylldurations(:,2),marker);
    removeoutliers = input('remove outliers? (y/n):','s');
    while removeoutliers == 'y'
        delete(h)
        ind = jc_findoutliers(sylldurations(:,2),3.5);
        sylldurations(ind,:) = [];
        tb_syllduration(ind) = [];
        h = plot(tb_syllduration,sylldurations(:,2),marker);
        removeoutliers = input('remove outliers? (y/n):','s');
    end
%     runningaverage = jc_RunningAverage(sylldurations(:,2),50);
%     fill([tb_syllduration' fliplr(tb_syllduration')],[runningaverage(:,1)'-runningaverage(:,2)',...
%     fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,...
%     'EdgeColor','none','FaceAlpha',0.5);
    title('Average syllable duration');
    ylabel('Duration (seconds)');
    xlabel('Time (seconds since lights on)');      
    
    %plot average gap duration over time
      tb_gap = jc_tb(gaps(:,1),7,0);
    subtightplot(3,1,3,0.07,0.04,0.15);hold on;
    h = plot(tb_gap,gaps(:,2),marker);
    removeoutliers = input('remove outliers? (y/n):','s');
    while removeoutliers == 'y'
        delete(h)
        ind = jc_findoutliers(gaps(:,2),3.5);
        tb_gap(ind) = [];
        gaps(ind,:) = [];
        h = plot(tb_gap,gaps(:,2),marker);
        removeoutliers = input('remove outliers? (y/n):','s');
    end
%     runningaverage = jc_RunningAverage(gaps(:,2),50);
%     fill([tb_gap' fliplr(tb_gap')],[runningaverage(:,1)'-runningaverage(:,2)',...
%     fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,...
%     'EdgeColor','none','FaceAlpha',0.5);
    title('Average gap duration');
    ylabel('Duration (seconds)');
    xlabel('Time (seconds since lights on)');      
    
    %plot tempo vs spec correlation
    figure;hold on;
    syllduration_vs_pitch = arrayfun(@(x) [mean(x.durations) x.syllpitch],motifinfo,'UniformOutput',false);
    syllduration_vs_pitch = cell2mat(syllduration_vs_pitch');
    syllduration_vs_amp = arrayfun(@(x) [mean(x.durations) x.syllvol],motifinfo,'UniformOutput',false);
    syllduration_vs_amp = cell2mat(syllduration_vs_amp');
    syllduration_vs_ent = arrayfun(@(x) [mean(x.durations) x.syllent],motifinfo,'UniformOutput',false);
    syllduration_vs_ent = cell2mat(syllduration_vs_ent');
    ncol = size(syllduration_vs_pitch,2)-1;
    for i= 1:ncol
        subtightplot(3,ncol,i,0.07);hold on;
        h = plot(syllduration_vs_pitch(:,1),syllduration_vs_pitch(:,i+1),marker);
        removeoutliers = input('remove outliers (y/n):','s');
        while removeoutliers=='y'
                delete(h)
                ind = jc_findoutliers(syllduration_vs_pitch(:,1),3.5);
                syllduration_vs_pitch(ind,:) = [];
                h = plot(syllduration_vs_pitch(:,1),syllduration_vs_pitch(:,i+1),marker);
                removeoutliers = input('remove outliers? (y/n):','s');
        end
        p = polyfit(syllduration_vs_pitch(:,1),syllduration_vs_pitch(:,i+1),1);
        [c1 pval] = corrcoef(syllduration_vs_pitch(:,1),syllduration_vs_pitch(:,i+1));
        h = plot([syllduration_vs_pitch(:,1)],polyval(p,[syllduration_vs_pitch(:,1)]),'r','DisplayName',...
            sprintf(['R=',num2str(c1(2)),'\np=',num2str(pval(2))]));hold on;
        xlabel('Average syllable duration (seconds)');
        ylabel('Frequency (Hz)');
        title('Pitch vs mean syllable duration');
        legend(h);
        
        subtightplot(3,ncol,i+ncol,0.07);hold on;
        h = plot(syllduration_vs_amp(:,1),log(syllduration_vs_amp(:,i+1)),marker);
         removeoutliers = input('remove outliers (y/n):','s');
        while removeoutliers=='y'
                delete(h)
                ind = jc_findoutliers(syllduration_vs_amp(:,1),3.5);
                syllduration_vs_amp(ind,:) = [];
                h = plot(syllduration_vs_amp(:,1),log(syllduration_vs_amp(:,i+1)),marker);
                removeoutliers = input('remove outliers? (y/n):','s');
        end
         p = polyfit(syllduration_vs_amp(:,1),log(syllduration_vs_amp(:,i+1)),1);
        [c1 pval] = corrcoef(syllduration_vs_amp(:,1),log(syllduration_vs_amp(:,i+1)));
        h = plot([syllduration_vs_amp(:,1)],polyval(p,[syllduration_vs_amp(:,1)]),'r','DisplayName',...
            sprintf(['R=',num2str(c1(2)),'\np=',num2str(pval(2))]));hold on;
        xlabel('Average syllable duration (seconds)');
        ylabel('Volume (log)');
        title('Volume vs mean syllable duration')
        legend(h);
        
        subtightplot(3,ncol,i+2*ncol,0.07);hold on;
        h = plot(syllduration_vs_ent(:,1),syllduration_vs_ent(:,i+1),marker);
         removeoutliers = input('remove outliers (y/n):','s');
        while removeoutliers=='y'
                delete(h)
                ind = jc_findoutliers(syllduration_vs_ent(:,1),3.5);
                syllduration_vs_ent(ind,:) = [];
                h = plot(syllduration_vs_ent(:,1),syllduration_vs_ent(:,i+1),marker);
                removeoutliers = input('remove outliers? (y/n):','s');
        end
         p = polyfit(syllduration_vs_ent(:,1),syllduration_vs_ent(:,i+1),1);
        [c1 pval] = corrcoef(syllduration_vs_ent(:,1),syllduration_vs_ent(:,i+1));
        h = plot([syllduration_vs_ent(:,1)],polyval(p,[syllduration_vs_ent(:,1)]),'r','DisplayName',...
            sprintf(['R=',num2str(c1(2)),'\np=',num2str(pval(2))]));hold on;
        xlabel('Average syllable duration (seconds)');
        ylabel('Entropy');
        title('Entropy vs mean syllable duration');
        legend(h);
    end
else
    autocorr = input('use autocorrelation measurement?:','s');
    %get tempo measurements
    for i = 1:length(motifinfo)
        if autocorr == 'y'
            motifvals.firstpeakdistance(i,:) = [motifinfo(i).datenm motifinfo(i).firstpeakdistance];
        end
        motifvals.syllduration(i,:) = [motifinfo(i).datenm motifinfo(i).durations'];
        motifvals.gaps(i,:) = [motifinfo(i).datenm motifinfo(i).gaps'];
        motifvals.motifdur(i,:) = [motifinfo(i).datenm motifinfo(i).motifdur];
    end

    %% plot time course of tempo measurements
    % autocorrelation 
    
    plot_tempo_timecourse = input('plot tempo timecourse? (y/n):','s');
    if plot_tempo_timecourse == 'y'
        fignum = input('figure for tempo measurements over time:');
        figure(fignum);hold on;
        
        if autocorr == 'y'
            tb_firstpeakdistance = jc_tb(motifvals.firstpeakdistance(:,1),7,0);    
            subtightplot(4,1,1,0.07,0.04,0.15);hold on;
            h = plot(tb_firstpeakdistance,motifvals.firstpeakdistance(:,2),marker);
            removeoutliers = input('remove outliers? (y or n):','s');
            while removeoutliers == 'y'
                nstd = input('use this nstd threshold:');
                delete(h);
                ind = jc_findoutliers(motifvals.firstpeakdistance(:,2),nstd);
                motifvals.firstpeakdistance(ind,:) = [];
                tb_firstpeakdistance(ind) = [];
                h = plot(tb_firstpeakdistance,motifvals.firstpeakdistance(:,2),marker);
                removeoutliers = input('remove outliers? (y or no):','s');
            end
            title('Average duration between adjacent syllables');
            ylabel('Duration (seconds)');
            xlabel('Time (seconds since lights on)');  
            
%             if length(motifvals.firstpeakdistance(:,2)) > 50
%                 runningaverage = jc_RunningAverage(motifvals.firstpeakdistance(:,2),50);
%                 fill([tb_firstpeakdistance',fliplr(tb_firstpeakdistance')],...
%                     [runningaverage(:,1)'-runningaverage(:,2)',...
%                     fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,...
%                     'EdgeColor','none','FaceAlpha',0.5);
%             end
        end

        %motif duration
        
        tb_motifdur = jc_tb(motifvals.motifdur(:,1),7,0);
        if autocorr == 'y'
            subtightplot(4,1,2,0.07,0.04,0.15);hold on;
        else
            subtightplot(3,1,1,0.07,0.04,0.15);hold on;
        end
        h2 = plot(tb_motifdur,motifvals.motifdur(:,2),marker);
        removeoutliers = input('remove outliers? (y or n):','s');
        while removeoutliers == 'y'
            nstd = input('use this nstd threshold:');
            delete(h2);
            ind = jc_findoutliers(motifvals.motifdur(:,2),nstd);
            motifvals.motifdur(ind,:) = [];
            tb_motifdur(ind) = [];
            h2 = plot(tb_motifdur,motifvals.motifdur(:,2),marker);
            removeoutliers = input('remove outliers? (y or no):','s');
        end
        ylabel('Duration (seconds)');
        xlabel('Time (seconds since lights on)');  
        title('Motif duration');
        
%         if length(motifvals.motifdur(:,2)) >50
%             runningaverage = jc_RunningAverage(motifvals.motifdur(:,2),50);
%             fill([tb_motifdur',fliplr(tb_motifdur')],...
%                 [runningaverage(:,1)'-runningaverage(:,2)',...
%                 fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,...
%                 'EdgeColor','none','FaceAlpha',0.5);
%         end

        %average syllable duration
        tb_sylldur = jc_tb(motifvals.syllduration(:,1),7,0);
        avgsyllduration = [motifvals.syllduration(:,1) mean(motifvals.syllduration(:,2:end),2)];
        if autocorr == 'y'
            subtightplot(4,1,3,0.07,0.04,0.15);hold on;
        else
            subtightplot(3,1,2,0.07,0.04,0.15);hold on;
        end
        h3 = plot(tb_sylldur,avgsyllduration(:,2),marker);
        removeoutliers = input('remove outliers? (y or n):','s');
        while removeoutliers == 'y'
             nstd = input('use this nstd threshold:');
            delete(h3);
            ind = jc_findoutliers(avgsyllduration(:,2),nstd);
            avgsyllduration(ind,:) = [];
            tb_sylldur(ind) = [];
            h3 = plot(tb_sylldur,avgsyllduration(:,2),marker);
            removeoutliers = input('remove outliers? (y or no):','s');
        end
        ylabel('Duration (seconds)');
        xlabel('Time (seconds since lights on)');  
        title('Average syllable duration');
        
%         if length(avgsyllduration(:,2)) > 50
%             runningaverage = jc_RunningAverage(avgsyllduration(:,2),50);
%             fill([tb_sylldur',fliplr(tb_sylldur')],...
%                 [runningaverage(:,1)'-runningaverage(:,2)',...
%                 fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,...
%                 'EdgeColor','none','FaceAlpha',0.5);
%         end
        
        %average gap duration
        tb_gap = jc_tb(motifvals.gaps(:,1),7,0);
        avggapduration = [motifvals.gaps(:,1) mean(motifvals.gaps(:,2:end),2)];
        if autocorr == 'y'
             subtightplot(4,1,4,0.07,0.04,0.15);hold on;
        else
             subtightplot(3,1,3,0.07,0.04,0.15);hold on;
        end
             
        h4 = plot(tb_gap,avggapduration(:,2),marker);
        removeoutliers = input('remove outliers? (y or n):','s');
        while removeoutliers == 'y'
             nstd = input('use this nstd threshold:');
            delete(h4);
            ind = jc_findoutliers(avggapduration(:,2),nstd);
            avggapduration(ind,:) = [];
            tb_gap(ind) = [];
            h4 = plot(tb_gap,avggapduration(:,2),marker);
            removeoutliers = input('remove outliers? (y or no):','s');
        end
        ylabel('Duration (seconds)');
        xlabel('Time (seconds since lights on)');  
        title('Average gap duration');
            
%         if length(avggapduration(:,2)) > 50
%             runningaverage = jc_RunningAverage(avggapduration(:,2),50);
%             fill([tb_gap',fliplr(tb_gap')],...
%                 [runningaverage(:,1)'-runningaverage(:,2)',...
%                 fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,...
%                 'EdgeColor','none','FaceAlpha',0.5);
%         end
        
    %syllable and gap duration for each syllable
    % tb_sylldur = jc_tb(motifvals.syllduration(:,1),7,0);
    % subtightplot(4,2,5,0.04);hold on;
    % cmap = summer(size(motifvals.syllduration,2)-1);
    % for i = 1:size(motifvals.syllduration,2)-1
    %     runningaverage = jc_RunningAverage(motifvals.syllduration(:,i+1),50);
    %     subtightplot(4,2,5,0.04);hold on;
    %     fill([tb_sylldur' fliplr(tb_sylldur')],[runningaverage(:,1)'-runningaverage(:,2)',...
    %         fliplr(runningaverage(:,1)'+runningaverage(:,2)')],cmap(i,:),'EdgeColor','none',...
    %         'FaceAlpha',0.5);
    % end
    % ylabel('Duration (seconds)');
    % xlabel('Time (seconds since lights on)');  
    % title('Syllable duration running average with SEM'); 
    % 
    % tb_gap = jc_tb(motifvals.gaps(:,1),7,0);
    % subtightplot(4,2,6,0.04);hold on;
    % cmap = summer(size(motifvals.gaps,2)-1);
    % for i = 1:size(motifvals.gaps,2)-1
    %     runningaverage = jc_RunningAverage(motifvals.gaps(:,i+1),50);
    %     subtightplot(4,2,6,0.04);hold on;
    %     fill([tb_gap' fliplr(tb_gap')],[runningaverage(:,1)'-runningaverage(:,2)',...
    %         fliplr(runningaverage(:,1)'+runningaverage(:,2)')],cmap(i,:),'EdgeColor','none',...
    %         'FaceAlpha',0.5);
    % end
    % title('Gap duration running average with SEM');
    % ylabel('Duration (seconds)');
    % xlabel('Time (seconds since lights on)');  
end

%% average log(sm) 
plotsm = input('plot smoothed amp env? (y/n):','s');
if plotsm == 'y'
    averagemotif = [];
    maxsmlength = max(arrayfun(@(x) length(x.logsm),motifinfo));
    averagemotif = arrayfun(@(x) [x.logsm; zeros(maxsmlength-length(x.logsm),1)],...
        motifinfo,'UniformOutput',false);
    averagemotif = cell2mat(averagemotif);
    for i = 1:size(averagemotif,2)
        if i == 1
            refmotif = averagemotif(:,i);
        else
            [crl lag] = xcorr(refmotif,averagemotif(:,i));
            [c ind] = max(crl);
            shft = lag(ind);
            if shft > 0 %shift second signal to right
                averagemotif(:,i) = [NaN(shft,1);averagemotif(1:end-shft,i)];
            elseif shft < 0 %shift second signal to left
                averagemotif(:,i) = [averagemotif(abs(shft)+1:end,i);NaN(abs(shft),1)];
            elseif shft == 0
                averagemotif(:,i) = averagemotif(:,i);
            end
        end
    end
    averagemotif2 = [nanmean(averagemotif,2) nanstderr(averagemotif,2)];
    if ~isempty(averagerefmotif)
        [crl lag] = xcorr(averagerefmotif(:,1),averagemotif2(:,1));
        [c ind] = max(crl);
        shft = lag(ind);
        if shft > 0
                averagemotif2 = [NaN(shft,2);averagemotif2(1:end-shft,:)];
        elseif shft < 0
            averagemotif2 = [averagemotif2(abs(shft)+1:end,:);NaN(abs(shft),2)];
        elseif shft==0
            averagemotif2 = averagemotif2;
        end
    end

    fignum = input('figure number for average sm:');
    tb_sm = [1:maxsmlength]/fs;
    figure(fignum);hold on;
    fill([tb_sm fliplr(tb_sm)],[averagemotif2(:,1)'-averagemotif2(:,2)',...
        fliplr(averagemotif2(:,1)'+averagemotif2(:,2)')],linecolor,'EdgeColor',linecolor,...
        'FaceAlpha',0.5);
    xlabel('Time (seconds)');
    ylabel('Normalized Amplitude (log)')
end

%% correlate tempo with spectral features
%pitch vs motif duration
plot_correlation = input('plot correlation between motif duration and spec? (y/n):','s');
if plot_correlation == 'y'
    motifdur_and_pitch = arrayfun(@(x) [x.motifdur x.syllpitch],motifinfo,'UniformOutput',false);
    motifdur_and_volume = arrayfun(@(x) [x.motifdur x.syllvol],motifinfo,'UniformOutput',false);
    motifdur_and_entropy = arrayfun(@(x) [x.motifdur x.syllent],motifinfo,'UniformOutput',false);
    motifdur_and_volume = cell2mat(motifdur_and_volume');
    motifdur_and_pitch = cell2mat(motifdur_and_pitch');
    motifdur_and_entropy = cell2mat(motifdur_and_entropy');
    ncol = size(motifdur_and_pitch,2)-1;
    figure;
    for i= 1:ncol
        ind = find(isnan(motifdur_and_pitch(:,i+1)));
        motifdur_and_pitch(ind,:) = [];
        subtightplot(3,ncol,i,0.07,0.1,0.1);hold on;
        plot(motifdur_and_pitch(:,1),motifdur_and_pitch(:,i+1),marker);
        removeoutliers = input('remove outliers in motifdur? (y/n)','s');
        while removeoutliers == 'y'
             nstd = input('use this nstd threshold:');
            cla
            ind = jc_findoutliers(motifdur_and_pitch(:,1),nstd);
            motifdur_and_pitch(ind,:) = [];
            plot(motifdur_and_pitch(:,1),motifdur_and_pitch(:,i+1),marker);
            removeoutliers = input('remove outliers in motifdur? (y/n)','s');
        end
        removeoutliers = input('remove outliers in pitch? (y/n)','s');
        while removeoutliers == 'y'
             nstd = input('use this nstd threshold:');
            cla
            ind = jc_findoutliers(motifdur_and_pitch(:,i+1),nstd);
            motifdur_and_pitch(ind,:) = [];
            plot(motifdur_and_pitch(:,1),motifdur_and_pitch(:,i+1),marker);
            removeoutliers = input('remove outliers in pitch? (y/n)','s');
        end
        p = polyfit(motifdur_and_pitch(:,1),motifdur_and_pitch(:,i+1),1);
        [c1 pval] = corrcoef(motifdur_and_pitch(:,1),motifdur_and_pitch(:,i+1));
        h = plot(motifdur_and_pitch(:,1),polyval(p,motifdur_and_pitch(:,1)),'r','DisplayName',...
            sprintf(['R=',num2str(c1(2)),'\np=',num2str(pval(2))]));hold on;
        xlabel('Motif Duration (seconds)');
        ylabel('Frequency (Hz)');
        title('Pitch vs motif duration');
        legend(h);
        
        ind = find(isnan(motifdur_and_volume(:,i+1)));
        motifdur_and_volume(ind,:) = [];
        subtightplot(3,ncol,i+ncol,0.07,0.1,0.1);hold on;
        plot(motifdur_and_volume(:,1),log(motifdur_and_volume(:,i+1)),marker);
        removeoutliers = input('remove outliers in motifdur? (y/n)','s');
        while removeoutliers == 'y'
            nstd = input('use this nstd threshold:');
            cla
            ind = jc_findoutliers(motifdur_and_volume(:,1),nstd);
            motifdur_and_volume(ind,:) = [];
            plot(motifdur_and_volume(:,1),log(motifdur_and_volume(:,i+1)),marker);
            removeoutliers = input('remove outliers in motifdur? (y/n)','s');
        end
        removeoutliers = input('remove outliers in volume? (y/n)','s');
        while removeoutliers == 'y'
            nstd = input('use this nstd threshold:');
            cla
            ind = jc_findoutliers(log(motifdur_and_volume(:,i+1)),nstd);
            motifdur_and_volume(ind,:) = [];
            plot(motifdur_and_volume(:,1),log(motifdur_and_volume(:,i+1)),marker);
            removeoutliers = input('remove outliers in volume? (y/n)','s');
        end
        p = polyfit(motifdur_and_volume(:,1),log(motifdur_and_volume(:,i+1)),1);
            [c1 pval] = corrcoef(motifdur_and_volume(:,1),log(motifdur_and_volume(:,i+1)));
            h = plot([motifdur_and_volume(:,1)],polyval(p,[motifdur_and_volume(:,1)]),'r','DisplayName',...
                sprintf(['R=',num2str(c1(2)),'\np=',num2str(pval(2))]));hold on;
        xlabel('Motif Duration (seconds)');
        ylabel('Log Volume');
        title('Volume vs motif duration');
        legend(h);

        ind = find(isnan(motifdur_and_entropy(:,i+1)));
        motifdur_and_entropy(ind,:) = [];
        subtightplot(3,ncol,i+2*ncol,0.07,0.1,0.1);hold on;
        plot(motifdur_and_entropy(:,1),motifdur_and_entropy(:,i+1),marker);
         removeoutliers = input('remove outliers in motifdur? (y/n)','s');
        while removeoutliers == 'y'
            nstd = input('use this nstd threshold:');
            cla
            ind = jc_findoutliers(motifdur_and_entropy(:,1),nstd);
            motifdur_and_entropy(ind,:) = [];
            plot(motifdur_and_entropy(:,1),motifdur_and_entropy(:,i+1),marker);
            removeoutliers = input('remove outliers in motifdur? (y/n)','s');
        end
         removeoutliers = input('remove outliers in entropy? (y/n)','s');
        while removeoutliers == 'y'
            nstd = input('use this nstd threshold:');
            cla
            ind = jc_findoutliers(motifdur_and_entropy(:,i+1),nstd);
            motifdur_and_entropy(ind,:) = [];
            plot(motifdur_and_entropy(:,1),motifdur_and_entropy(:,i+1),marker);
            removeoutliers = input('remove outliers in entropy? (y/n)','s');
        end
        
        p = polyfit(motifdur_and_entropy(:,1),motifdur_and_entropy(:,i+1),1);
            [c1 pval] = corrcoef(motifdur_and_entropy(:,1),motifdur_and_entropy(:,i+1));
            h = plot([motifdur_and_entropy(:,1)],polyval(p,[motifdur_and_entropy(:,1)]),'r','DisplayName',...
                sprintf(['R=',num2str(c1(2)),'\np=',num2str(pval(2))]));hold on;
        xlabel('Motif Duration (seconds)');
        ylabel('Entropy');
        title('Entropy vs motif duration');
        legend(h);
    end
end

%% pairwise cross correlation of log(sm) 
plot_crosscorrsm = input('plot pairwise cross correlation of sm? (y/n):','s');
if plot_crosscorrsm == 'y'
    averagemotif(find(isnan(averagemotif))) = 0;
    A=corr(averagemotif);
    pairwise_correlation_adj_syll = diag(A,1);
    tb_paircorr = [motifinfo(:).datenm];
    tb_paircorr = tb_paircorr(1:end-1);
    tb_paircorr = jc_tb(tb_paircorr',7,0);
    runningaverage = jc_RunningAverage(pairwise_correlation_adj_syll,50);
    fignum = input('figure number for pairwise correlation:');
    figure(fignum);hold on;
    plot(tb_paircorr,pairwise_correlation_adj_syll,marker);hold on;
    fill([tb_paircorr' fliplr(tb_paircorr')],[runningaverage(:,1)'-runningaverage(:,2)',...
        fliplr(runningaverage(:,1)'+runningaverage(:,2)')],linecolor,'EdgeColor','none','FaceAlpha',0.5);
    title('Pairwise cross correlation of adjacent motif amplitude envelop');
    xlabel('Time (seconds since lights on)');
    ylabel('Correlation Coefficient');
end

end


