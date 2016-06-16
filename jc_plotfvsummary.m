function [fv v et pcv] = jc_plotfvsummary(fv_syll_sal, fv_syll_cond,marker,...
    linecolor,xpt,excludewashin,startpt,matchtm, checkoutliers,rawplot,fignum);
%fv_syll from jc_findwnote5
%generate summary changes in pitch, entropy, volume, and pitch cv
%(normalized and raw)
%for experiment design saline morning vs drug afternoon


pitch = [fv_syll_sal(:).mxvals];
vol = log([fv_syll_sal(:).maxvol]);
ent = [fv_syll_sal(:).spent];

tb_sal = jc_tb([fv_syll_sal(:).datenm]',7,0);
tb_cond = jc_tb([fv_syll_cond(:).datenm]',7,0);

if excludewashin == 1 & ~isempty(startpt)
    ind = find(tb_cond < startpt);
    tb_cond(ind) = [];
elseif excludewashin == 1
    ind = find(tb_cond<tb_sal(end)+1800); %exclude first half hour of wash in 
    tb_cond(ind) = [];
end

if ~isempty(matchtm)
    indsal = find(tb_sal>=tb_cond(1) & tb_sal <= tb_cond(end)); 
    tb_sal = tb_sal(indsal);
    pitch = pitch(indsal);
    vol = vol(indsal);
    ent = ent(indsal);
end 

pitch2 = [fv_syll_cond(:).mxvals];
vol2 = log([fv_syll_cond(:).maxvol]);
ent2 = [fv_syll_cond(:).spent];
if excludewashin == 1
    pitch2(ind) = [];
    vol2(ind) = [];
    ent2(ind) = [];
end

if checkoutliers == 'y'
    fignum = input('figure number for checking outliers:');
    figure(fignum);
    plot(tb_sal,pitch,'k.');
    removeoutliers = input('remove outliers (y/n):','s');
    while removeoutliers == 'y'
        cla;
        nstd = input('nstd:');
        removeind = jc_findoutliers(pitch',nstd);
        pitch(removeind) = [];
        vol(removeind) = [];
        ent(removeind) = [];
        tb_sal(removeind) = [];
        plot(tb_sal,pitch,'k.');
        removeoutliers = input('remove outliers (y/n):','s');
    end
    cla

    plot(tb_sal,vol,'k.');
    removeoutliers = input('remove outliers:','s');
    while removeoutliers == 'y'
        cla;jc_plotfvsummary
        nstd = input('nstd:');
        removeind = jc_findoutliers(vol',nstd);
        pitch(removeind) = [];
        vol(removeind) = [];
        ent(removeind) = [];
        tb_sal(removeind) = [];
        plot(tb_sal,vol,'k.');
        removeoutliers = input('remove outliers (y/n):','s');
    end
    cla

    plot(tb_sal,ent,'k.');
    removeoutliers = input('remove outliers:','s');
    while removeoutliers == 'y'
        cla;
        nstd = input('nstd:');
        removeind = jc_findoutliers(ent',nstd);
        pitch(removeind) = [];
        vol(removeind) = [];
        ent(removeind) = [];
        tb_sal(removeind) = [];
        plot(tb_sal,ent,'k.');
        removeoutliers = input('remove outliers (y/n):','s');
    end
    cla

    plot(tb_cond,pitch2,'k.');
    removeoutliers = input('remove outliers:','s');
    while removeoutliers == 'y'
        cla;
        nstd = input('nstd:');
        removeind = jc_findoutliers(pitch2',nstd);
        pitch2(removeind) = [];
        vol2(removeind) = [];
        ent2(removeind) = [];
        tb_cond(removeind) = [];
        plot(tb_cond,pitch2,'k.');
        removeoutliers = input('remove outliers (y/n):','s');
    end
    cla

    plot(tb_cond,vol2,'k.');
    removeoutliers = input('remove outliers:','s');
    while removeoutliers == 'y'
        cla;
        nstd = input('nstd:');
        removeind = jc_findoutliers(vol2',nstd);
        pitch2(removeind) = [];
        vol2(removeind) = [];
        ent2(removeind) = [];
        tb_cond(removeind) = [];
        plot(tb_cond,vol2,'k.');
        removeoutliers = input('remove outliers (y/n):','s');
    end
    cla

    plot(tb_cond,ent2,'k.');
    removeoutliers = input('remove outliers:','s');
    while removeoutliers == 'y'
        cla;
        nstd = input('nstd:');
        removeind = jc_findoutliers(ent2',nstd);
        pitch2(removeind) = [];
        vol2(removeind) = [];
        ent2(removeind) = [];
        tb_cond(removeind) = [];
        plot(tb_cond,ent2,'k.');
        removeoutliers = input('remove outliers (y/n):','s');
    end
    hold off;
end

if ~isempty(find(isnan(pitch2)))
    removeind = find(isnan(pitch2));
    pitch2(removeind) = [];
    vol2(removeind) = [];
    ent2(removeind) = [];
    tb_cond(removeind) = [];
elseif ~isempty(find(isnan(vol2)))
    removeind = find(isnan(vol2));
    pitch2(removeind) = [];
    vol2(removeind) = [];
    ent2(removeind) = [];
    tb_cond(removeind) = [];
elseif ~isempty(find(isnan(ent2)))
    removeind = find(isnan(ent2));
    pitch2(removeind) = [];
    vol2(removeind) = [];
    ent2(removeind) = [];
    tb_cond(removeind) = [];
end

if ~isempty(find(isnan(pitch)))
    removeind = find(isnan(pitch));
    pitch(removeind) = [];
    vol(removeind) = [];
    ent(removeind) = [];
    tb_sal(removeind) = [];
elseif ~isempty(find(isnan(vol)))
    removeind = find(isnan(vol));
    pitch(removeind) = [];
    vol(removeind) = [];
    ent(removeind) = [];
    tb_sal(removeind) = [];
elseif ~isempty(find(isnan(ent)))
    removeind = find(isnan(ent));
    pitch(removeind) = [];
    vol(removeind) = [];
    ent(removeind) = [];
    tb_sal(removeind) = [];
end

%rawplot = input('plot raw summary?:(y/n)','s');
if rawplot == 'y'
    
    figure(fignum);hold on;
    subtightplot(2,4,1,0.07,0.04,0.1);hold on;
    [hi lo mn1] = mBootstrapCI(pitch);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [hi lo mn2] = mBootstrapCI(pitch2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    h = plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    legend(h,'data');
    ylabel('Frequency Hz');
    title('Raw pitch changes');


    subtightplot(2,4,2,0.07,0.04,0.1);hold on;
    [hi lo mn1] = mBootstrapCI(log(vol));
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [hi lo mn2] = mBootstrapCI(log(vol2));
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel('Amplitude (log)');
    title('Raw volume changes');

    subtightplot(2,4,3,0.07,0.04,0.1);hold on;
    [hi lo mn1] = mBootstrapCI(ent);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [hi lo mn2] = mBootstrapCI(ent2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linefvnaspmcolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel('Entropy');
    title('Raw entropy changes');
    
    subtightplot(2,4,4,0.07,0.04,0.1);hold on;
    [mn1 hi lo] = mBootstrapCI_CV(pitch);
    plot(0.5,mn1,marker,[0.5 0.5],[hi,lo],linecolor,'linewidth',1,'markersize',12);
    [mn2 hi lo] = mBootstrapCI_CV(pitch2);
    plot(1.5,mn2,marker,[1.5 1.5],[hi lo],linecolor,'linewidth',1,'markersize',12);
    plot([0.5 1.5],[mn1 mn2],linecolor,'linewidth',1);
    set(gca,'xlim',[0 2],'xtick',[0.5,1.5],'xticklabel',{'saline','drug'});
    ylabel('CV');
    title('Raw Pitch CV changes');

else
    figure(fignum);hold on;
    
    %z-score
    pitchn = (pitch2-mean(pitch))./std(pitch);
    voln = (vol2-mean(vol))./std(vol);
    entn = (ent2-mean(ent))./std(ent);
    
    subtightplot(4,1,1,0.07,0.07,0.15);hold on;
    jitter = (-1+2*rand)/4;
    xpt = xpt+jitter;
    [hi lo mn2] = mBootstrapCI(pitchn);
    plot(xpt,mn2,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
    set(gca,'xlim',[0 5],'xtick',[0.5,1.5 2.5 3.5 4.5],'xticklabel',...
        {'saline','naspm','apv','musc','naspm+musc'},'fontweight','bold');
    ylabel('z-score');;
    title('Change in pitch relative to saline');
    fv.zsc = mn2;
    
    subtightplot(4,1,2,0.07,0.07,0.15);hold on;
    [hi lo mn2] = mBootstrapCI(voln);
    plot(xpt,mn2,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
    set(gca,'xlim',[0 5],'xtick',[0.5,1.5 2.5 3.5 4.5],'xticklabel',...
        {'saline','naspm','apv','musc','naspm+musc'},'fontweight','bold');
    ylabel('z-score');
    title('Change in volume relative to saline');
    v.zsc = mn2;
    
    subtightplot(4,1,3,0.07,0.07,0.15);hold on;
    [hi lo mn2] = mBootstrapCI(entn);
    plot(xpt,mn2,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
    set(gca,'xlim',[0 5],'xtick',[0.5,1.5 2.5 3.5 4.5],'xticklabel',...
        {'saline','naspm','apv','musc','naspm+musc'},'fontweight','bold');
    ylabel('z-score');
    title('Change in entropy relative to saline');
    et.zsc = mn2;
    
    subtightplot(4,1,4,0.07,0.07,0.15);hold on;
    mn1 = mBootstrapCI_CV(pitch);
    [mn2 hi lo] = mBootstrapCI_CV(pitch2);
    mn3 = mn2/mn1;
    hi = mn3+((hi-mn2)/mn1);
    lo = mn3-((mn2-lo)/mn1);
    plot(xpt,mn3,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
    set(gca,'xlim',[0 5],'xtick',[0.5,1.5 2.5 3.5 4.5],'xticklabel',...
        {'saline','naspm','apv','musc','naspm+musc'},'fontweight','bold');
    ylabel('Pitch CV change');
    title('Change in pitch CV relative to saline');
    pcv = mn3;
    
    %absolute change
    fv.abs = mean(pitch2)-mean(pitch);
    v.abs = mean(vol2)-mean(vol);
    et.abs = mean(ent2)-mean(ent);
    
    %relative change
    
    
    fv.rel = (mean(pitch2)-mean(pitch))/mean(pitch);
    v.rel = (mean(vol2)-mean(vol))/abs(mean(vol));
    et.rel = (mean(ent2)-mean(ent))/mean(ent);

end
    
hold off 

