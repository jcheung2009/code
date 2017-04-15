%this script tests the robustness of amp segmentation vs alternative segmentation
%for changes in volume

config;
batch = uigetfile;
ff = load_batchf(batch);
tbshft2 = repmat([0:length(ff)/params.plotdata.tbshft-1],params.plotdata.tbshft,1);
tbshft2 = tbshft2(:);

%% plot durations for motif, syllable, and gaps for both segmentation methods

for ii = 1:length(params.findmotif)
    motifsegment.([params.findmotif(ii).motif]).base = [];
    motifsegment.([params.findmotif(ii).motif]).drug = [];
    h = figure;%motif
    h2=figure;%syll
    h3=figure;%gap
    for i = 1:length(ff)
        if isempty(ff(i).name)
            continue
        end
        load(['analysis/data_structures/motifsegment_',params.findmotif(ii).motif,'_',ff(i).name]);
        
        if ~isempty(strfind(ff(i).name,'naspm')) | ~isempty(strfind(ff(i).name,'IEM'))
            mrk = 'r.';
            mcolor = 'r';
            motifsegment.([params.findmotif(ii).motif]).drug = [motifsegment.([params.findmotif(ii).motif]).drug ...
                eval(['motifsegment_',params.findmotif(ii).motif,'_',ff(i).name])];
        else
            mrk = 'k.';
            mcolor = 'k';
            motifsegment.([params.findmotif(ii).motif]).base = [motifsegment.([params.findmotif(ii).motif]).base ...
                eval(['motifsegment_',params.findmotif(ii).motif,'_',ff(i).name])];
        end
        

        jc_plotmotifval_amp_vs_phase_segmentation(eval(['motifsegment_',...
            params.findmotif(ii).motif,'_',ff(i).name]),mrk,tbshft2(i),params.findmotif(ii).motif,'y',h,h2,h3);

    end
end

%% correlate tempo (acorr) with motif volume
nstd = 4;
figure;hold on;
for ii = 1:length(params.findmotif)
    motif = params.findmotif(ii).motif;
    if ~isempty(motifsegment.([motif]).base)
        tempo_vol_base = [arrayfun(@(x) x.firstpeakdistance,motifsegment.([motif]).base)',...
            arrayfun(@(x) log(mean(x.sm)),motifsegment.([motif]).base)'];
        tempo_vol_base = jc_removeoutliers(tempo_vol_base,nstd);
        
        subtightplot(1,3,1,0.08,0.1,0.07);hold on;
        scatter(tempo_vol_base(:,1),tempo_vol_base(:,2),'k.');hold on;
        [r p] = corrcoef(tempo_vol_base,'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('interval duration (sec)');
        title('baseline');set(gca,'fontweight','bold');
    end
    if ~isempty(motifsegment.([motif]).drug)
        tempo_vol_drug = [arrayfun(@(x) x.firstpeakdistance,motifsegment.([motif]).drug)',...
            arrayfun(@(x) log(mean(x.sm)),motifsegment.([motif]).drug)'];
        tempo_vol_drug = jc_removeoutliers(tempo_vol_drug,nstd);
        
        subtightplot(1,3,2,0.08,0.1,0.07);hold on;
        scatter(tempo_vol_drug(:,1),tempo_vol_drug(:,2),'r.');hold on;
        [r p] = corrcoef(tempo_vol_drug,'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('interval duration (sec)');
        title('drug');set(gca,'fontweight','bold');
    end
    if ~isempty(motifsegment.([motif]).base) & ~isempty(motifsegment.([motif]).drug)
        subtightplot(1,3,3,0.08,0.1,0.07);hold on;
        combo = [tempo_vol_base;tempo_vol_drug];
        group = [zeros(size(tempo_vol_base));ones(size(tempo_vol_drug))];
        gscatter(combo(:,1),combo(:,2),group,'kr','.',6,'off');
        combo = jc_removenan(combo);
        m = polyfit(combo(:,1),combo(:,2),1);
        refline(m(1),m(2));
        [r p] = corrcoef(combo,'rows','complete');
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('interval duration (sec)');set(gca,'fontweight','bold');
    end
end
%% correlate tempo (acorr) and syll dur and gaps 
nstd = 4;
for ii = 1:length(params.findmotif)
    motif = params.findmotif(ii).motif;
    h = figure;h2 = figure;
    if ~isempty(motifsegment.([motif]).base)
        tempo_syll_base = [arrayfun(@(x) x.firstpeakdistance,motifsegment.([motif]).base)',...
            arrayfun(@(x) mean(x.amp_durs),motifsegment.([motif]).base)',arrayfun(@(x) ...
            mean(x.ph_durs),motifsegment.([motif]).base)'];
        tempo_gap_base = [arrayfun(@(x) x.firstpeakdistance,motifsegment.([motif]).base)',...
            arrayfun(@(x) mean(x.amp_gaps),motifsegment.([motif]).base)',arrayfun(@(x) ...
            mean(x.ph_gaps),motifsegment.([motif]).base)'];
        
        tempo_syll_base = jc_removeoutliers(tempo_syll_base,nstd);
        tempo_gap_base = jc_removeoutliers(tempo_gap_base,nstd);
        
        figure(h);hold on;
        subtightplot(2,3,1,0.08,0.1,0.07);hold on;
        scatter(tempo_syll_base(:,1),tempo_syll_base(:,2),'k.');hold on;
        [r p] = corrcoef(tempo_syll_base(:,[1,2]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('mean syll durations (sec)');
        xlabel('mean tempo (sec)');
        title('baseline (amp)');
        
        subtightplot(2,3,4,0.08,0.1,0.07);hold on;
        scatter(tempo_gap_base(:,1),tempo_gap_base(:,2),'k.');hold on;
        [r p] = corrcoef(tempo_gap_base(:,[1,2]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('mean gap durations (sec)');
        xlabel('mean tempo (sec)');
        title('baseline (amp)');
        
        figure(h2);hold on;
        subtightplot(2,3,1,0.08,0.1,0.07);hold on;
        scatter(tempo_syll_base(:,1),tempo_syll_base(:,3),'k.');hold on;
        [r p] = corrcoef(tempo_syll_base(:,[1,3]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('mean syll durations (sec)');
        xlabel('mean tempo (sec)');
        title('baseline (phase)');
        
        subtightplot(2,3,4,0.08,0.1,0.07);hold on;
        scatter(tempo_gap_base(:,1),tempo_gap_base(:,3),'k.');hold on;
        [r p] = corrcoef(tempo_gap_base(:,[1,3]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('mean gap durations (sec)');
        xlabel('mean tempo (sec)');
        title('baseline (phase)');
    end
    
    if ~isempty(motifsegment.([motif]).drug)
        tempo_syll_drug = [arrayfun(@(x) x.firstpeakdistance,motifsegment.([motif]).drug)',...
            arrayfun(@(x) mean(x.amp_durs),motifsegment.([motif]).drug)',arrayfun(@(x) ...
            mean(x.ph_durs),motifsegment.([motif]).drug)'];
        tempo_gap_drug = [arrayfun(@(x) x.firstpeakdistance,motifsegment.([motif]).drug)',...
            arrayfun(@(x) mean(x.amp_gaps),motifsegment.([motif]).drug)',arrayfun(@(x) ...
            mean(x.ph_gaps),motifsegment.([motif]).drug)'];
        
        tempo_syll_drug = jc_removeoutliers(tempo_syll_drug,nstd);
        tempo_gap_drug = jc_removeoutliers(tempo_gap_drug,nstd);   
        
        figure(h);hold on;
        subtightplot(2,3,2,0.08,0.1,0.07);hold on;
        scatter(tempo_syll_drug(:,1),tempo_syll_drug(:,2),'r.');hold on;
        [r p] = corrcoef(tempo_syll_drug(:,[1,2]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('mean syll durations (sec)');
        xlabel('mean tempo (sec)');
        title('drug (amp)');
        
        subtightplot(2,3,5,0.08,0.1,0.07);hold on;
        scatter(tempo_gap_drug(:,1),tempo_gap_drug(:,2),'r.');hold on;
        [r p] = corrcoef(tempo_gap_drug(:,[1,2]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('mean gap durations (sec)');
        xlabel('mean tempo (sec)');
        title('drug (amp)');
        
        figure(h2);hold on;
        subtightplot(2,3,2,0.08,0.1,0.07);hold on;
        scatter(tempo_syll_drug(:,1),tempo_syll_drug(:,3),'r.');hold on;
        [r p] = corrcoef(tempo_syll_drug(:,[1,3]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('mean syll durations (sec)');
        xlabel('mean tempo (sec)');
        title('drug (phase)');
        
        subtightplot(2,3,5,0.08,0.1,0.07);hold on;
        scatter(tempo_gap_drug(:,1),tempo_gap_drug(:,3),'r.');hold on;
        [r p] = corrcoef(tempo_gap_drug(:,[1,3]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('mean gap durations (sec)');
        xlabel('mean tempo (sec)');
        title('drug (phase)');
    end
    
    if ~isempty(motifsegment.([motif]).base) & ~isempty(motifsegment.([motif]).drug)
        figure(h);hold on;
        subtightplot(2,3,3,0.08,0.1,0.07);hold on;
        combo = [tempo_syll_base(:,[1,2]);tempo_syll_drug(:,[1,2])];
        group = [zeros(length(tempo_syll_base),1);ones(length(tempo_syll_drug),1)];
        gscatter(combo(:,1),combo(:,2),group,'kr','.',6,'off');
        combo = jc_removenan(combo);
        m = polyfit(combo(:,1),combo(:,2),1);
        refline(m(1),m(2));
        [r p] = corrcoef(combo,'rows','complete');
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('mean syll durations (sec)');
        xlabel('mean tempo (sec)');
        title('amp');

        subtightplot(2,3,6,0.08,0.1,0.07);hold on;
        combo = [tempo_gap_base(:,[1,2]);tempo_gap_drug(:,[1,2])];
        group = [zeros(length(tempo_gap_base),1);ones(length(tempo_gap_drug),1)];
        gscatter(combo(:,1),combo(:,2),group,'kr','.',6,'off');
        combo = jc_removenan(combo);
        m = polyfit(combo(:,1),combo(:,2),1);
        refline(m(1),m(2));
        [r p] = corrcoef(combo,'rows','complete');
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('mean gap durations (sec)');
        xlabel('mean tempo (sec)');
        title('amp');
        
        figure(h2);hold on;
        subtightplot(2,3,3,0.08,0.1,0.07);hold on;
        combo = [tempo_syll_base(:,[1,3]);tempo_syll_drug(:,[1,3])];
        group = [zeros(length(tempo_syll_base),1);ones(length(tempo_syll_drug),1)];
        gscatter(combo(:,1),combo(:,2),group,'kr','.',6,'off');
        combo = jc_removenan(combo);
        m = polyfit(combo(:,1),combo(:,2),1);
        refline(m(1),m(2));
        [r p] = corrcoef(combo,'rows','complete');
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('mean syll durations (sec)');
        xlabel('mean tempo (sec)');
        title('phase');

        subtightplot(2,3,6,0.08,0.1,0.07);hold on;
        combo = [tempo_gap_base(:,[1,3]);tempo_gap_drug(:,[1,3])];
        group = [zeros(length(tempo_gap_base),1);ones(length(tempo_gap_drug),1)];
        gscatter(combo(:,1),combo(:,2),group,'kr','.',6,'off');
        combo = jc_removenan(combo);
        m = polyfit(combo(:,1),combo(:,2),1);
        refline(m(1),m(2));
        [r p] = corrcoef(combo,'rows','complete');
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('mean gap durations (sec)');
        xlabel('mean tempo (sec)');
        title('phase');
    end
end
%% correlate syll and gap duration with mean motif volume
nstd = 4;
for ii = 1:length(params.findmotif)
    motif = params.findmotif(ii).motif;
    h = figure;h2 = figure;
    if ~isempty(motifsegment.([motif]).base)
        sylldur_vol_base = [arrayfun(@(x) mean(x.amp_durs),motifsegment.([motif]).base)',arrayfun(@(x) ...
            mean(x.ph_durs),motifsegment.([motif]).base)',arrayfun(@(x) log(mean(x.sm)),motifsegment.([motif]).base)'];
        gapdur_vol_base = [arrayfun(@(x) mean(x.amp_gaps),motifsegment.([motif]).base)',arrayfun(@(x) ...
            mean(x.ph_gaps),motifsegment.([motif]).base)',arrayfun(@(x) log(mean(x.sm)),motifsegment.([motif]).base)'];
 
        sylldur_vol_base = jc_removeoutliers(sylldur_vol_base,nstd);
        gapdur_vol_base = jc_removeoutliers(gapdur_vol_base,nstd);

        figure(h);hold on;
        subtightplot(2,3,1,0.08,0.1,0.07);hold on;
        scatter(sylldur_vol_base(:,1),sylldur_vol_base(:,3),'k.');hold on;
        [r p] = corrcoef(sylldur_vol_base(:,[1,3]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('mean syll durations (sec)');
        title('baseline (amp)');
        
        subtightplot(2,3,4,0.08,0.1,0.07);hold on;
        scatter(gapdur_vol_base(:,1),gapdur_vol_base(:,3),'k.');hold on;
        [r p] = corrcoef(gapdur_vol_base(:,[1,3]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('mean gap durations (sec)');
        title('baseline (amp)');
        
        figure(h2);hold on;
        subtightplot(2,3,1,0.08,0.1,0.07);hold on;
        scatter(sylldur_vol_base(:,2),sylldur_vol_base(:,3),'k.');hold on;
        [r p] = corrcoef(sylldur_vol_base(:,[2,3]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('mean syll durations (sec)');
        title('baseline (phase)');
        
        subtightplot(2,3,4,0.08,0.1,0.07);hold on;
        scatter(gapdur_vol_base(:,2),gapdur_vol_base(:,3),'k.');hold on;
        [r p] = corrcoef(gapdur_vol_base(:,[2,3]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('mean gap durations (sec)');
        title('baseline (phase)');      
    end
    
    if ~isempty(motifsegment.([motif]).drug)
        sylldur_vol_drug = [arrayfun(@(x) mean(x.amp_durs),motifsegment.([motif]).drug)',arrayfun(@(x) ...
            mean(x.ph_durs),motifsegment.([motif]).drug)',arrayfun(@(x) log(mean(x.sm)),motifsegment.([motif]).drug)'];
        gapdur_vol_drug = [arrayfun(@(x) mean(x.amp_gaps),motifsegment.([motif]).drug)',arrayfun(@(x) ...
            mean(x.ph_gaps),motifsegment.([motif]).drug)',arrayfun(@(x) log(mean(x.sm)),motifsegment.([motif]).drug)'];

        sylldur_vol_drug = jc_removeoutliers(sylldur_vol_drug,nstd);
        gapdur_vol_drug = jc_removeoutliers(gapdur_vol_drug,nstd);
        
        figure(h);hold on;
        subtightplot(2,3,2,0.08,0.1,0.07);hold on;
        scatter(sylldur_vol_drug(:,1),sylldur_vol_drug(:,3),'r.');hold on;
        [r p] = corrcoef(sylldur_vol_drug(:,[1,3]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('mean syll durations (sec)');
        title('drug (amp)');
        
        subtightplot(2,3,5,0.08,0.1,0.07);hold on;
        scatter(gapdur_vol_drug(:,1),gapdur_vol_drug(:,3),'r.');hold on;
        [r p] = corrcoef(gapdur_vol_drug(:,[1,3]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('mean gap durations (sec)');
        title('drug (amp)');
        
        figure(h2);hold on;
        subtightplot(2,3,2,0.08,0.1,0.07);hold on;
        scatter(sylldur_vol_drug(:,2),sylldur_vol_drug(:,3),'r.');hold on;
        [r p] = corrcoef(sylldur_vol_drug(:,[2,3]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('mean syll durations (sec)');
        title('drug (phase)');
        
        subtightplot(2,3,5,0.08,0.1,0.07);hold on;
        scatter(gapdur_vol_drug(:,2),gapdur_vol_drug(:,3),'r.');hold on;
        [r p] = corrcoef(gapdur_vol_drug(:,[2,3]),'rows','complete');
        lsline;
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('mean gap durations (sec)');
        title('drug (phase)'); 
    end

    if ~isempty(motifsegment.([motif]).base) & ~isempty(motifsegment.([motif]).drug)
        figure(h);hold on;
        subtightplot(2,3,3,0.08,0.1,0.07);hold on;
        combo = [sylldur_vol_base(:,[1,3]);sylldur_vol_drug(:,[1,3])];
        group = [zeros(length(sylldur_vol_base),1);ones(length(sylldur_vol_drug),1)];
        gscatter(combo(:,1),combo(:,2),group,'kr','.',6,'off');
        combo = jc_removenan(combo);
        m = polyfit(combo(:,1),combo(:,2),1);
        refline(m(1),m(2));
        [r p] = corrcoef(combo,'rows','complete');
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('mean syll durations (sec)');
        title('amp');

        subtightplot(2,3,6,0.08,0.1,0.07);hold on;
        combo = [gapdur_vol_base(:,[1,3]);gapdur_vol_drug(:,[1,3])];
        group = [zeros(length(gapdur_vol_base),1);ones(length(gapdur_vol_drug),1)];
        gscatter(combo(:,1),combo(:,2),group,'kr','.',6,'off');
        combo = jc_removenan(combo);
        m = polyfit(combo(:,1),combo(:,2),1);
        refline(m(1),m(2));
        [r p] = corrcoef(combo,'rows','complete');
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('mean gap durations (sec)');
        title('amp');
        
        figure(h2);hold on;
        subtightplot(2,3,3,0.08,0.1,0.07);hold on;
        combo = [sylldur_vol_base(:,[2,3]);sylldur_vol_drug(:,[2,3])];
        group = [zeros(length(sylldur_vol_base),1);ones(length(sylldur_vol_drug),1)];
        gscatter(combo(:,1),combo(:,2),group,'kr','.',6,'off');
        combo = jc_removenan(combo);
        m = polyfit(combo(:,1),combo(:,2),1);
        refline(m(1),m(2));
        [r p] = corrcoef(combo,'rows','complete');
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('mean syll durations (sec)');
        title('phase');

        subtightplot(2,3,6,0.08,0.1,0.07);hold on;
        combo = [gapdur_vol_base(:,[2,3]);gapdur_vol_drug(:,[2,3])];
        group = [zeros(length(gapdur_vol_base),1);ones(length(gapdur_vol_drug),1)];
        gscatter(combo(:,1),combo(:,2),group,'kr','.',6,'off');
        combo = jc_removenan(combo);
        m = polyfit(combo(:,1),combo(:,2),1);
        refline(m(1),m(2));
        [r p] = corrcoef(combo,'rows','complete');
        ylim = get(gca,'ylim');set(gca,'ylim',ylim);
        xlim = get(gca,'xlim');set(gca,'xlim',xlim);
        text(xlim(1),ylim(2),{['r=',num2str(r(2))];['p=',num2str(p(2))]});
        ylabel('motif volume (log)');
        xlabel('mean gap durations (sec)');
        title('phase');
    end
end
%% look at spectrograms and segmentation of select motifs
motif = params.findmotif(ii).motif;
range=[0.115 0.1152];
 ind1 = find(arrayfun(@(x) x.firstpeakdistance>=range(1) & x.firstpeakdistance<=range(2),motifsegment.([motif]).base));
 ind2 = find(arrayfun(@(x) x.firstpeakdistance>=range(1) & x.firstpeakdistance<=range(2),motifsegment.([motif]).drug));
% ind2 = find(arrayfun(@(x) mean(x.ph_durs)>= 0.059,motifsegment.([motif]).drug));
% ind1 = find(arrayfun(@(x) mean(x.ph_durs)<=0.052,motifsegment.([motif]).base));
fs=44100;
NFFT = 512;
overlap = NFFT-2;
t=-NFFT/2+1:NFFT/2;
sigma=(1/1000)*fs;
w=exp(-(t/sigma).^2);

h1=figure;h2=figure;
for i = 1:8
    smtemp=motifsegment.([motif]).base(ind1(i)).smtemp;
    sm = log(motifsegment.([motif]).base(ind1(i)).sm);
    ons=motifsegment.([motif]).base(ind1(i)).ph_ons;
    offs=motifsegment.([motif]).base(ind1(i)).ph_offs;
    filtsong = bandpass(smtemp,44100,1000,10000,'hanningffir');
    [sp f tm] = spectrogram(filtsong,w,overlap,NFFT,fs);
    indf = find(f>1000 & f<10000);
    sp=sp(indf,:);
    
    figure(h1);hold on;
    subtightplot(2,4,i,0.08,0.1,0.07);hold on;
    imagesc(tm,f(indf),log(abs(sp)));set(gca,'YDir','normal');hold on;
    if ~isempty(ons)
        plot([ons ons],[1000 10000],'r');hold on;
        plot([offs offs],[1000 10000],'r');hold on;
    end
    set(gca,'ylim',[1000 10000]);
    title('base phase');
    
    figure(h2);hold on;
    subtightplot(2,4,i,0.08,0.1,0.07);hold on;
    plot([1:length(sm)]/fs,sm);hold on;
    if ~isempty(ons)
        plot([ons ons],[min(sm) max(sm)],'r');hold on;
        plot([offs offs],[min(sm) max(sm)],'r');hold on;
    end
    title('base phase');
end
    
h1=figure;h2=figure;
for i = 1:8
    smtemp=motifsegment.([motif]).drug(ind2(i)).smtemp;
    sm = log(motifsegment.([motif]).drug(ind2(i)).sm);
    ons=motifsegment.([motif]).drug(ind2(i)).ph_ons;
    offs=motifsegment.([motif]).drug(ind2(i)).ph_offs;
    filtsong = bandpass(smtemp,44100,1000,10000,'hanningffir');
    [sp f tm] = spectrogram(filtsong,w,overlap,NFFT,fs);
    indf = find(f>1000 & f<10000);
    sp=sp(indf,:);
    
    figure(h1);hold on;
    subtightplot(2,4,i,0.08,0.1,0.07);hold on;
    imagesc(tm,f(indf),log(abs(sp)));set(gca,'YDir','normal');hold on;
    if ~isempty(ons)
        plot([ons ons],[1000 10000],'r');hold on;
        plot([offs offs],[1000 10000],'r');hold on;
    end
    set(gca,'ylim',[1000 10000]);
    title('drug phase');
    
    figure(h2);hold on;
    subtightplot(2,4,i,0.08,0.1,0.07);hold on;
    plot([1:length(sm)]/fs,sm);hold on;
    if ~isempty(ons)
        plot([ons ons],[min(sm) max(sm)],'r');hold on;
        plot([offs offs],[min(sm) max(sm)],'r');hold on;
    end
    title('drug phase');
end

h1=figure;h2=figure;
for i = 1:8
    smtemp=motifsegment.([motif]).base(ind1(i)).smtemp;
    sm = log(motifsegment.([motif]).base(ind1(i)).sm);
    ons=motifsegment.([motif]).base(ind1(i)).amp_ons;
    offs=motifsegment.([motif]).base(ind1(i)).amp_offs;
    filtsong = bandpass(smtemp,44100,1000,10000,'hanningffir');
    [sp f tm] = spectrogram(filtsong,w,overlap,NFFT,fs);
    indf = find(f>1000 & f<10000);
    sp=sp(indf,:);
    
    figure(h1);hold on;
    subtightplot(2,4,i,0.08,0.1,0.07);hold on;
    imagesc(tm,f(indf),log(abs(sp)));set(gca,'YDir','normal');hold on;
    if ~isempty(ons)
        plot([ons ons],[1000 10000],'r');hold on;
        plot([offs offs],[1000 10000],'r');hold on;
    end
    set(gca,'ylim',[1000 10000]);
    title('base amp');
    
    figure(h2);hold on;
    subtightplot(2,4,i,0.08,0.1,0.07);hold on;
    plot([1:length(sm)]/fs,sm);hold on;
    if ~isempty(ons)
        plot([ons ons],[min(sm) max(sm)],'r');hold on;
        plot([offs offs],[min(sm) max(sm)],'r');hold on;
    end
    title('base amp');
end
    
h1=figure;h2=figure;
for i = 1:8
    smtemp=motifsegment.([motif]).drug(ind2(i)).smtemp;
    sm = log(motifsegment.([motif]).drug(ind2(i)).sm);
    ons=motifsegment.([motif]).drug(ind2(i)).amp_ons;
    offs=motifsegment.([motif]).drug(ind2(i)).amp_offs;
    filtsong = bandpass(smtemp,44100,1000,10000,'hanningffir');
    [sp f tm] = spectrogram(filtsong,w,overlap,NFFT,fs);
    indf = find(f>1000 & f<10000);
    sp=sp(indf,:);
    
    figure(h1);hold on;
    subtightplot(2,4,i,0.08,0.1,0.07);hold on;
    imagesc(tm,f(indf),log(abs(sp)));set(gca,'YDir','normal');hold on;
    if ~isempty(ons)
        plot([ons ons],[1000 10000],'r');hold on;
        plot([offs offs],[1000 10000],'r');hold on;
    end
    set(gca,'ylim',[1000 10000]);
    title('drug amp');
    
    figure(h2);hold on;
    subtightplot(2,4,i,0.08,0.1,0.07);hold on;
    plot([1:length(sm)]/fs,sm);hold on;
    if ~isempty(ons)
        plot([ons ons],[min(sm) max(sm)],'r');hold on;
        plot([offs offs],[min(sm) max(sm)],'r');hold on;
    end
    title('drug amp');
end


