function jc_plotoptomotifsummary(motifinfo,motifparams,fignum,params,cnt);
%plot raw motif tempo values in motifstruct for script_plotdata
%for optogenetics experiments
motif = motifparams.motif;
removeoutliers = params.removeoutliers;

if isempty(fignum)
    fignum = input('figure number for plotting motif vals:');
end

trig = [motifinfo(:).TRIG];
catchtrig = [motifinfo(:).CATCH];
trigind = find(trig==1 & catchtrig==0);
catchind = find(catchtrig==1 | catchtrig==-1);
% trigind = find(trig==1 & (catchtrig==-1 | catchtrig==0));
% catchind = setdiff([1:length(motifinfo)],trigind);

if ~isempty(trigind)
    trigmotifdur = [[motifinfo(trigind).datenm]',[motifinfo(trigind).motifdur]'];
    trigsylldur = [[motifinfo(trigind).datenm]',arrayfun(@(x) mean(x.durations),motifinfo(trigind))'];
    triggapdur = [[motifinfo(trigind).datenm]',arrayfun(@(x) mean(x.gaps),motifinfo(trigind))'];
    trigfirstpeakdistance = [[motifinfo(trigind).datenm]' [motifinfo(trigind).firstpeakdistance]'];
end
if ~isempty(catchind)
    catchmotifdur = [[motifinfo(catchind).datenm]',[motifinfo(catchind).motifdur]'];
    catchsylldur = [[motifinfo(catchind).datenm]',arrayfun(@(x) mean(x.durations),motifinfo(catchind))'];
    catchgapdur = [[motifinfo(catchind).datenm]',arrayfun(@(x) mean(x.gaps),motifinfo(catchind))'];
    catchfirstpeakdistance = [[motifinfo(catchind).datenm]' [motifinfo(catchind).firstpeakdistance]'];
end

if removeoutliers == 'y'
    nstd = 4;
    if ~isempty(trigind)
        trigmotifdur = jc_removeoutliers(trigmotifdur,nstd,1);
        trigsylldur = jc_removeoutliers(trigsylldur,nstd,1);
        triggapdur = jc_removeoutliers(triggapdur,nstd,1);
        trigfirstpeakdistance = jc_removeoutliers(trigfirstpeakdistance,nstd,1);
    end
    if ~isempty(catchind)
        catchmotifdur = jc_removeoutliers(catchmotifdur,nstd,1);
        catchsylldur = jc_removeoutliers(catchsylldur,nstd,1);
        catchgapdur = jc_removeoutliers(catchgapdur,nstd,1);
        catchfirstpeakdistance = jc_removeoutliers(catchfirstpeakdistance,nstd,1);
    end
end

%% motif duration
figure(fignum);hold on;
subtightplot(3,1,1,0.07,0.08,0.15);hold on;
if ~isempty(trigind)
    [hi1 lo1 mn1] = mBootstrapCI(trigmotifdur(:,2));
else
    mn1=NaN;hi1=NaN;lo1=NaN;
end
if ~isempty(catchind)
    [hi2 lo2 mn2] = mBootstrapCI(catchmotifdur(:,2));
else
    mn2=NaN;hi2=NaN;lo2=NaN;
end
b = bar([cnt cnt+1],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor='r';
b(2).FaceColor = 'none';b(2).EdgeColor=[0.5 0.5 0.5];
offset = 0.1429;
errorbar(cnt-offset,mn1,hi1-mn1,'r');
errorbar(cnt+offset,mn2,hi2-mn2,'color',[0.5 0.5 0.5]);
ylabel('Duration (seconds)','fontweight','bold');
title([motif,': duration']);

%% syll duration
subtightplot(3,1,2,0.07,0.08,0.15);hold on;
if ~isempty(trigind)
    [hi1 lo1 mn1] = mBootstrapCI(trigsylldur(:,2));
else
    mn1=NaN;hi1=NaN;lo1=NaN;    
end
if ~isempty(catchind)
    [hi2 lo2 mn2] = mBootstrapCI(catchsylldur(:,2));
else
    mn2=NaN;hi2=NaN;lo2=NaN;   
end
b = bar([cnt cnt+1],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor='r';
b(2).FaceColor = 'none';b(2).EdgeColor=[0.5 0.5 0.5];
offset = 0.1429;
errorbar(cnt-offset,mn1,hi1-mn1,'r');
errorbar(cnt+offset,mn2,hi2-mn2,'color',[0.5 0.5 0.5]);
ylabel('Duration (seconds)');
title('Syllable duration');

%% gap duration
subtightplot(3,1,3,0.07,0.08,0.15);hold on;
if ~isempty(trigind)
    [hi1 lo1 mn1] = mBootstrapCI(triggapdur(:,2));
else
    mn1=NaN;hi1=NaN;lo1=NaN;      
end
if ~isempty(catchind)
    [hi2 lo2 mn2] = mBootstrapCI(catchgapdur(:,2));
else
    mn2=NaN;hi2=NaN;lo2=NaN;     
end
b = bar([cnt cnt+1],[mn1 mn2;NaN NaN]);
b(1).FaceColor = 'none';b(1).EdgeColor='r';
b(2).FaceColor = 'none';b(2).EdgeColor=[0.5 0.5 0.5];
offset = 0.1429;
errorbar(cnt-offset,mn1,hi1-mn1,'r');
errorbar(cnt+offset,mn2,hi2-mn2,'color',[0.5 0.5 0.5]);
ylabel('Duration (seconds)');
title('Gap duration');

