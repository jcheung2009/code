function [diffskew pitch1n pitch2n] = jc_plotskewsummary(fv_syll_sal, fv_syll_cond,marker,...
    linecolor,xpt,excludewashin,startpt,matchtm,checkoutliers,fignum2);
%plots distribution of pitch and tests differences in skew

pitch = [fv_syll_sal(:).mxvals]';

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
end 

pitch2 = [fv_syll_cond(:).mxvals]';
if excludewashin == 1
    pitch2(ind) = [];
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
    hold off;
end

if ~isempty(find(isnan(pitch2)))
    removeind = find(isnan(pitch2));
    pitch2(removeind) = [];
    tb_cond(removeind) = [];
end

if ~isempty(find(isnan(pitch)))
    removeind = find(isnan(pitch));
    pitch(removeind) = [];
    tb_sal(removeind) = [];
end

figure(fignum2);hold on;
pitch2n = (pitch2-mean(pitch))./std(pitch);
pitch1n = (pitch-mean(pitch))./std(pitch);
jitter = (-1+2*rand)/4;
xpt = xpt+jitter;
[diffskew hi lo] = jc_testSkew(pitch1n,pitch2n,'');
plot(xpt,diffskew,marker,[xpt xpt],[hi lo],linecolor,'linewidth',1,'markersize',12);
set(gca,'xlim',[0 4],'xtick',[0.5 1.5 2.5 3.5],'xticklabel',...
    {'saline','naspm','apv','muscimol'},'fontweight','bold');
ylabel('skew difference (drug-saline)');
title('Difference in skew relative to saline');


