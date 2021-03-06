%spectral correlation with gap duration analysis from all birds in
%directory 

%% extract infromation from each bird's gapdata 
batch = uigetfile;
ff = load_batchf(batch);

gapdata = [];
for i = 1:length(ff)
    if exist([ff(i).name,'/analysis/data_structures/gapdata_',ff(i).name,'.mat'])
        load([ff(i).name,'/analysis/data_structures/gapdata_',ff(i).name,'.mat']);
        gapdata = [gapdata;eval(['gapdata_',ff(i).name])];
    end
end

%% center and transform each predictor 
birdnm = unique(gapdata.BirdID);
newgapid = NaN(size(gapdata,1),1);
gapcnt = 0;
for i = 1:length(birdnm)
    ind = strcmp(gapdata.BirdID,birdnm{i});
    gapid = unique(gapdata.GapID(ind));
    for n = 1:length(gapid)
        id = strcmp(gapdata.BirdID,birdnm{i}) & gapdata.GapID==gapid(n) & gapdata.Treatment==0;
        id2 = strcmp(gapdata.BirdID,birdnm{i}) & gapdata.GapID==gapid(n) & gapdata.Treatment==1;

        %z-score from baseline vals 
        gapdur = gapdata.GapDur(id);
        gapdurt = gapdata.GapDur(id2);
        gapdurt = (gapdurt-nanmean(gapdur))./nanstd(gapdur);
        gapdur = (gapdur-nanmean(gapdur))./nanstd(gapdur);
        
        pitchN1 = gapdata.PitchN1(id);
        pitchN1t = gapdata.PitchN1(id2);
        volN1 = gapdata.VolN1(id);
        volN1t = gapdata.VolN1(id2);
        durN1 = gapdata.DurN1(id);
        durN1t = gapdata.DurN1(id2);
        
        pitchN1t = (pitchN1t-nanmean(pitchN1))./nanstd(pitchN1);
        volN1t = (volN1t-nanmean(volN1))./nanstd(volN1);
        durN1t = (durN1t-nanmean(durN1))./nanstd(durN1);
        
        pitchN1 = (pitchN1-nanmean(pitchN1))./nanstd(pitchN1);
        volN1 = (volN1-nanmean(volN1))./nanstd(volN1);
        durN1 = (durN1-nanmean(durN1))./nanstd(durN1);
        
        gapdata.GapDur(id) = gapdur;
        gapdata.GapDur(id2) = gapdurt;
        
        gapdata.PitchN1(id) = pitchN1;
        gapdata.PitchN1(id2) = pitchN1t;
        gapdata.VolN1(id) = volN1;
        gapdata.VolN1(id2) = volN1t;
        gapdata.DurN1(id) = durN1;
        gapdata.DurN1(id2) = durN1t;
        
        id = strcmp(gapdata.BirdID,birdnm{i}) & gapdata.GapID==gapid(n);
        gapcnt = gapcnt + 1;
        newgapid(id) = gapcnt;%rename each gap uniquely across birds
    end
end
gapdata.GapID = newgapid; 

boutid = NaN(size(gapdata,1),1);
gapid = unique(gapdata.GapID);
for i = 1:length(gapid)
    ind = gapdata.GapID == gapid(i);
    [~,~,ic] = unique(gapdata.BoutID(ind));
    boutid(ind) = ic;
end
gapdata.BoutID = boutid;

%% 
gapdata_post = gapdata(gapdata.Treatment==1,:);
gapdata_pre = gapdata(gapdata.Treatment==0,:);

formula = 'GapDur ~ PitchN1 + BoutID + (PitchN1+BoutID|BirdID) + (PitchN1+BoutID|BirdID:GapID)';
mdl1_post = fitlme(gapdata_post,formula);
mdl1_pre = fitlme(gapdata_pre,formula);

formula = 'GapDur ~ PitchN1 + RenditionID + (PitchN1+RenditionID|BirdID) + (PitchN1+RenditionID|BirdID:GapID)';
mdl2_post = fitlme(gapdata_post,formula);
mdl2_pre = fitlme(gapdata_pre,formula);_pre.

formula = 'GapDur ~ PitchN1 + BoutID + RenditionID + (PitchN1+BoutID+RenditionID|BirdID) + (PitchN1+BoutID+RenditionID|BirdID:GapID)';
mdl3_post = fitlme(gapdata_post,formula);
mdl3_pre = fitlme(gapdata_pre,formula);

formula = 'GapDur ~ PitchN1 + (PitchN1|BirdID:GapID:RenditionID) + (PitchN1|BirdID:GapID:BoutID) + (PitchN1|BirdID) + (PitchN1|BirdID:GapID)';
mdl4_post = fitlme(gapdata_post,formula);
mdl4_pre = fitlme(gapdata_pre,formula);


formula = 'GapDur ~ PitchN1*Treatment + BoutID + (PitchN1*Treatment+BoutID|BirdID) + (PitchN1*Treatment+BoutID|BirdID:GapID)';
mdl1 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1*Treatment + RenditionID + (PitchN1*Treatment+RenditionID|BirdID) + (PitchN1*Treatment+RenditionID|BirdID:GapID)';
mdl2 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1*Treatment + BoutID + RenditionID + (PitchN1*Treatment+BoutID+RenditionID|BirdID) + (PitchN1*Treatment+BoutID+RenditionID|BirdID:GapID)';
mdl3 = fitlme(gapdata,formula);

formula = 'GapDur ~ PitchN1*Treatment + (PitchN1*Treatment|BirdID:GapID:RenditionID) + (PitchN1*Treatment|BirdID:GapID:BoutID) + (PitchN1*Treatment|BirdID) + (PitchN1*Treatment|BirdID:GapID)';
mdl4 = fitlme(gapdata,formula);




