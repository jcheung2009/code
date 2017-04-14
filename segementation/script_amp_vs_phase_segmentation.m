%this script is to run amp_vs_phase_segmentation on a batch file in
%animal's directory

config
batch = uigetfile;
ff = load_batchf(batch);
dtwtemplate = [];
for i = 1:length(ff)
    if isempty(ff(i).name)
        continue
    else
        cd(ff(i).name);
    end
    
    for ii = 1:length(params.findmotif)
        if isempty(dtwtemplate)
            dtwtemplate = make_dtw_temp('batch.keep',params.findmotif,params.filetype);
        end
        cmd = ['motifsegment_',params.findmotif(ii).motif,'_',ff(i).name,'=','amp_vs_dtw_segmentation(''batch.keep'',params.findmotif(',num2str(ii),'),dtwtemplate,params.filetype)'];
        eval(cmd);
        cd ../analysis/data_structures
        varname = ['''motifsegment_',params.findmotif(ii).motif,'_',ff(i).name,''''];
        savecmd = ['save(',varname,',',varname,',','''-v7.3'')'];
        eval(savecmd);
        clearvars -except ff params dtwtemplate
        cd ../../
    end
end

