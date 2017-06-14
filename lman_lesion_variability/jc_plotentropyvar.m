function jc_plotentropyvar(fv,syllable,marker,tbshift,fignum,removeoutliers)
%plots raw spectral information from fvstruct in script_findwnote2/jc_findwnote5
if isempty(fignum)
    fignum = input('figure number for raw data:');
end

if isempty(removeoutliers)
    removeoutliers = input('remove outliers?:','s');
end

entropyvar = [[fv(:).datenm]',[fv(:).entropyvar]'];

if ~isempty(tbshift)
    entropyvar(:,1) = jc_tb(entropyvar(:,1),7,0)+(tbshift*24*3600);
end

if removeoutliers == 'y'
    nstd = 4;
    entropyvar = jc_removeoutliers(entropyvar,nstd,1);
end

figure(fignum);hold on;
if isstr(marker)
    h = plot(entropyvar(:,1),entropyvar(:,2),marker);hold on
else
    marker = marker/max(marker);
    h = plot(entropyvar(:,1),entropyvar(:,2),'.','color',marker);hold on
end
if ~isempty(tbshift)
    xscale_hours_to_days(gca);
    xlabel('','fontweight','bold');
else
   xlabel('Time','fontweight','bold') 
end
ylabel('Entropy Variance','fontweight','bold')
title(syllable);
