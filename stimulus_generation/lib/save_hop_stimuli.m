 function stimset = save_hop_stimuli(stimset,d, stimsetname)
% stimset = MakeStimsetFolder(stimsetname,d)
% transform a stimulus set into a folder of binary files
% save the stimulus set, minus the signals, to stimsetname/stimsetname.mat
% for use with multiHop
% d = directory stimset is stored in

mkdir(d,stimsetname)

for i=1:stimset.numstims
    stimset.stims(i).signal = set_rms_for_hop(stimset.stims(i).signal, 75);
    fid = fopen([d,stimsetname,'/',stimset.stims(i).name,'.sng'],...
        'w','l');
    
    n = fwrite(fid,stimset.stims(i).signal,'double');
    fclose(fid);
    fprintf('File no. %d, %s, %d samples written\n',i,...
            stimset.stims(i).name,n);
end
stimset.name = stimsetname;
% save version for outside dir
save(fullfile(d,stimsetname),'stimset');
% remove signals and save version for inside dir
stimset.stims = rmfield(stimset.stims,'signal');
save(fullfile(d,stimsetname,stimsetname),'stimset');
