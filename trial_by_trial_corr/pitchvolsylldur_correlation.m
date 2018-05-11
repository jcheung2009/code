%plot trial by trial pairwise correlation of pitch, volume, sylldur for
%each trial (saline vs naspm) 
%normalize data by saline for each trial and combine across trials 
%save data for each syllable in pitchvolsylldur_tbl
%save correlation results for each pairwise comparison for each syllable in
%pitchvolsylldur_corr along with shuffle tests

config;
shufftrials = 1000;
drug = 'saline';%naspm
baselinecondition = 'saline1';%saline in naspm, saline1 in saline
treatmentcondition = 'saline2';%naspm in naspm, saline2 in saline

data = cell(length(params.findnote),2,3);
trials = params.trial(arrayfun(@(x) strcmp(x.condition,drug),params.trial));
for syll = 1:length(params.findnote)   
    figure;
    for i = 1:length(trials)
        load(['analysis/data_structures/',params.findnote(syll).fvstruct,trials(i).name]);
        load(['analysis/data_structures/',params.findnote(syll).fvstruct,trials(i).baseline]);
        basedata = eval([params.findnote(syll).fvstruct,trials(i).baseline]);
        testdata = eval([params.findnote(syll).fvstruct,trials(i).name]);
        
        %cut off washin time
        tb_cond = jc_tb([testdata(:).datenm]',7,0);
        tb_base = jc_tb([basedata(:).datenm]',7,0);
        if ~strcmp(drug,'saline') & ~strcmp(params.baseepoch,'morn')
            if ~isempty(trials(i).treattime)
                start_time = time2datenum(trials(i).treattime) + 5400;%1.5 hr buffer
            else
                start_time = tb_cond(1) + 5400; 
            end
            ind = find(tb_cond >= start_time);
            testdata = testdata(ind);
        else
            ind = find(tb_cond >= 5*3600);
            testdata = testdata(ind);
            ind = find(tb_base < 5*3600);
            basedata = basedata(ind);
        end

        %extract variables from data structures
        pitchbase = [basedata(:).mxvals]';
        volbase = log10([basedata(:).maxvol]');
        sylldurbase = arrayfun(@(x) x.offs-x.ons,basedata)';
        pitch = [testdata(:).mxvals]';
        vol = log10([testdata(:).maxvol]');
        sylldur = arrayfun(@(x) x.offs-x.ons,testdata)';
        
        %remove outliers
        pitchbase = jc_removeoutliers(pitchbase,3);
        volbase = jc_removeoutliers(volbase,3);
        sylldurbase = jc_removeoutliers(sylldurbase,3);
        pitch = jc_removeoutliers(pitch,3);
        vol = jc_removeoutliers(vol,3);
        sylldur = jc_removeoutliers(sylldur,3);
        
        %normalize variables
        pitch = (pitch-nanmean(pitchbase))./nanstd(pitchbase);
        vol = (vol-nanmean(volbase))./nanstd(volbase);
        sylldur = (sylldur-nanmean(sylldurbase))./nanstd(sylldurbase);
        pitchbase = (pitchbase-nanmean(pitchbase))./nanstd(pitchbase);
        volbase = (volbase-nanmean(volbase))./nanstd(volbase);
        sylldurbase = (sylldurbase-nanmean(sylldurbase))./nanstd(sylldurbase);
        
        %save variables in data cell for combining across trials
        data{syll,1,1} = [data{syll,1,1};pitchbase];
        data{syll,2,1} = [data{syll,2,1};pitch];
        data{syll,1,2} = [data{syll,1,2};volbase];
        data{syll,2,2} = [data{syll,2,2};vol];
        data{syll,1,3} = [data{syll,1,3};sylldurbase];
        data{syll,2,3} = [data{syll,2,3};sylldur];
        
        %plot pairwise correlations for each trial
        subplot(3,length(trials),i);
        plot(pitchbase,volbase,'k.');hold on;
        plot(pitch,vol,'r.');
        title(strjoin({params.findnote(syll).syllable,trials(i).name}),'interpreter','none')
        xlabel('pitch');ylabel('amp');
        
        subplot(3,length(trials),i+length(trials));
        plot(pitchbase,sylldurbase,'k.');hold on;
        plot(pitch,sylldur,'r.');
        title(strjoin({params.findnote(syll).syllable,trials(i).name}),'interpreter','none')
        xlabel('pitch');ylabel('syll dur');
        
        subplot(3,length(trials),i+2*length(trials));
        plot(volbase,sylldurbase,'k.');hold on;
        plot(vol,sylldur,'r.');
        title(strjoin({params.findnote(syll).syllable,trials(i).name}),'interpreter','none')
        xlabel('amp');ylabel('syll dur');
        
    end
end

%% plot pairwise correlation for data combined across trials and place data
%into table
if ~exist(['analysis/data_structures/pitchvolsylldur_correlation_',params.birdname,'.mat'])
    pitchvolsylldur_tbl = table([],[],[],[],[],[],'VariableNames',{'birdname','syllID',...
        'condition','pitch','volume','sylldur'});
    pitchvolsylldur_corr = table([],[],[],[],[],[],[],[],[],'VariableNames',...
        {'birdname','syllID','condition','pitchvol','pitchsylldur',...
    'volsylldur','pitchvol_shuff','pitchsylldur_shuff','volsylldur_shuff'});
else
    load(['analysis/data_structures/pitchvolsylldur_correlation_',params.birdname]);
end
birdnm = params.birdname;
for i = 1:length(params.findnote)
    figure;
    subplot(1,3,1);hold on;
    plot(data{i,1,1},data{i,1,2},'k.');hold on;
    plot(data{i,2,1},data{i,2,2},'r.');hold on;
    title(params.findnote(i).syllable);
    xlabel('pitch');ylabel('amp');
    
    subplot(1,3,2);hold on;
    plot(data{i,1,1},data{i,1,3},'k.');hold on;
    plot(data{i,2,1},data{i,2,3},'r.');hold on;
    title(params.findnote(i).syllable);
    xlabel('pitch');ylabel('syll dur');
    
    subplot(1,3,3);hold on;
    plot(data{i,1,2},data{i,1,3},'k.');hold on;
    plot(data{i,2,2},data{i,2,3},'r.');hold on;
    title(params.findnote(i).syllable);
    xlabel('amp');ylabel('syll dur');
    
    syllid = params.findnote(i).fvstruct(1:end-1);
    numtrials = length(data{i,1,1});
    pitchvolsylldur_tbl = [pitchvolsylldur_tbl; table(repmat({birdnm},numtrials,1),...
        repmat({syllid},numtrials,1),repmat({baselinecondition},numtrials,1),...
        data{i,1,1},data{i,1,2},data{i,1,3},'VariableNames',...
        {'birdname','syllID','condition','pitch','volume','sylldur'})];
    numtrials = length(data{i,2,1});
    pitchvolsylldur_tbl = [pitchvolsylldur_tbl; table(repmat({birdnm},numtrials,1),...
        repmat({syllid},numtrials,1),repmat({treatmentcondition},numtrials,1),...
        data{i,2,1},data{i,2,2},data{i,2,3},'VariableNames',...
        {'birdname','syllID','condition','pitch','volume','sylldur'})];
    
    %correlation and significance values for pairwise comparison
    [r p] = corrcoef(data{i,1,1},data{i,1,2},'rows','complete');
    [r2 p2] = corrcoef(data{i,2,1},data{i,2,2},'rows','complete');
    pitchvolbasecorr = r(2);pitchvolbasecorrpval = p(2);
    pitchvolcorr = r2(2);pitchvolcorrpval = p2(2);
    
    [r p] = corrcoef(data{i,1,1},data{i,1,3},'rows','complete');
    [r2 p2] = corrcoef(data{i,2,1},data{i,2,3},'rows','complete');
    pitchsylldurbasecorr = r(2);pitchsylldurbasecorrpval = p(2);
    pitchsylldurcorr = r2(2);pitchsylldurcorrpval = p2(2);
    
    [r p] = corrcoef(data{i,1,2},data{i,1,3},'rows','complete');
    [r2 p2] = corrcoef(data{i,2,2},data{i,2,3},'rows','complete');
    volsylldurbasecorr = r(2);volsylldurbasecorrpval = p(2);
    volsylldurcorr = r2(2);volsylldurcorrpval = p2(2);
    
    %shuffle tests
    [pitchvolbaseshuff pitchvolbaseshuffpval] = shuffle(data{i,1,1},data{i,1,2},shufftrials);
    [pitchvolshuff pitchvolshuffpval] = shuffle(data{i,2,1},data{i,2,2},shufftrials);
    [pitchsylldurbaseshuff pitchsylldurbaseshuffpval] = shuffle(data{i,1,1},data{i,1,3},shufftrials);
    [pitchsylldurshuff pitchsylldurshuffpval] = shuffle(data{i,2,1},data{i,2,3},shufftrials);
    [volsylldurbaseshuff volsylldurbaseshuffpval] = shuffle(data{i,1,2},data{i,1,3},shufftrials);
    [volsylldurshuff volsylldurshuffpval] = shuffle(data{i,2,2},data{i,2,3},shufftrials);
    
    pitchvolsylldur_corr = [pitchvolsylldur_corr; table({birdnm},{syllid},{baselinecondition},...
        [pitchvolbasecorr pitchvolbasecorrpval],...
        [pitchsylldurbasecorr pitchsylldurbasecorrpval],...
        [volsylldurbasecorr volsylldurbasecorrpval],...
        {pitchvolbaseshuff pitchvolbaseshuffpval},...
        {pitchsylldurbaseshuff pitchsylldurbaseshuffpval},...
        {volsylldurbaseshuff volsylldurbaseshuffpval},'VariableNames',...
        {'birdname','syllID','condition','pitchvol','pitchsylldur',...
        'volsylldur','pitchvol_shuff','pitchsylldur_shuff','volsylldur_shuff'})];
    pitchvolsylldur_corr = [pitchvolsylldur_corr; table({birdnm},{syllid},{treatmentcondition},...
        [pitchvolcorr pitchvolcorrpval],...
        [pitchsylldurcorr pitchsylldurcorrpval],...
        [volsylldurcorr volsylldurcorrpval],...
        {pitchvolshuff pitchvolshuffpval},...
        {pitchsylldurshuff pitchsylldurshuffpval},...
        {volsylldurshuff volsylldurshuffpval},'VariableNames',...
        {'birdname','syllID','condition','pitchvol','pitchsylldur',...
        'volsylldur','pitchvol_shuff','pitchsylldur_shuff','volsylldur_shuff'})];
end

%%
function [r p] = shuffle(x,y,shufftrials);
    xshuff = repmat(x',shufftrials,1);
    xshuff = permute_rowel(xshuff);
    [r p] = corrcoef([xshuff',y],'rows','pairwise');
    r = r(1:end-1,end);
    p = p(1:end-1,end);  
end

function shuffmat = permute_rowel(mat);
    %shuffle elements within rows in matrix
    [~,permmat] = sort(rand(size(mat,1),size(mat,2)),2);
    permmat = (permmat-1)*size(mat,1)+ndgrid(1:size(mat,1),1:size(mat,2));
    shuffmat = mat(permmat);
end