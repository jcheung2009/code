function jc_plotoptofvsummary(fv,noteparams,fignum,params,cnt)
%plots spectral summary information from fvstruct in script_findwnote2/jc_findwnote5
%for optogenetics experiments
syllable = [noteparams.prenotes,upper(noteparams.syllable),noteparams.postnotes];
removeoutliers = params.removeoutliers;

if isempty(fignum)
    fignum = input('figure number for raw data:');
end

trig = [fv(:).TRIG]';
catchtrig = [fv(:).CATCH]';
trigind = find(trig==1 & catchtrig==0);
catchind = find(catchtrig==1 | catchtrig==-1);
%trigind = find(trig==1 & (catchtrig==-1 | catchtrig==0));
%catchind = setdiff([1:length(fv)],trigind);

if ~isempty(trigind)
    trigpitch = [[fv(trigind).datenm]',[fv(trigind).mxvals]'];
    trigvol = [[fv(trigind).datenm]',log([fv(trigind).maxvol]')];
    trigent = [[fv(trigind).datenm]',[fv(trigind).spent]'];
end
if ~isempty(catchind)
    catchpitch = [[fv(catchind).datenm]',[fv(catchind).mxvals]'];
    catchvol = [[fv(catchind).datenm]',log([fv(catchind).maxvol]')];
    catchent = [[fv(catchind).datenm]',[fv(catchind).spent]'];
end

if removeoutliers == 'y'
    nstd = 4;
    if ~isempty(trigind)
        trigpitch = jc_removeoutliers(trigpitch,nstd,1);
        trigvol = jc_removeoutliers(trigvol,nstd,1);
        trigent = jc_removeoutliers(trigent,nstd,1);
    end
    if ~isempty(catchind)
        catchpitch = jc_removeoutliers(catchpitch,nstd,1);
        catchvol = jc_removeoutliers(catchvol,nstd,1);
        catchent = jc_removeoutliers(catchent,nstd,1);
    end
end

%% pitch
figure(fignum);hold on;
subtightplot(2,1,1,0.07,0.08,0.15);hold on;
if ~isempty(trigind)
    [hi1 lo1 mn1] = mBootstrapCI(trigpitch(:,2));
else
    mn1=NaN;hi1=NaN;lo1=NaN;
end
if ~isempty(catchind)
    [hi2 lo2 mn2] = mBootstrapCI(catchpitch(:,2));
else
    mn2=NaN;hi2=NaN;lo2=NaN;
end
b = bar([cnt cnt+1],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor='r';
b(2).FaceColor = 'none';b(2).EdgeColor=[0.5 0.5 0.5];
offset = 0.1429;
errorbar(cnt-offset,mn1,hi1-mn1,'r');
errorbar(cnt+offset,mn2,hi2-mn2,'color',[0.5 0.5 0.5]);
ylabel('Frequency (Hz)','fontweight','bold')
title(syllable);

%% volume
subtightplot(2,1,2,0.07,0.08,0.15);hold on;
if ~isempty(trigind)
    [hi1 lo1 mn1] = mBootstrapCI(trigvol(:,2));
else
    mn1=NaN;hi1=NaN;lo1=NaN;
end
if ~isempty(catchind)
    [hi2 lo2 mn2] = mBootstrapCI(catchvol(:,2));
else
    mn2=NaN;hi2=NaN;lo2=NaN;
end
b = bar([cnt cnt+1],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor='r';
b(2).FaceColor = 'none';b(2).EdgeColor=[0.5 0.5 0.5];
offset = 0.1429;
errorbar(cnt-offset,mn1,hi1-mn1,'r');
errorbar(cnt+offset,mn2,hi2-mn2,'color',[0.5 0.5 0.5]);
ylabel('Log Amplitude','fontweight','bold')
