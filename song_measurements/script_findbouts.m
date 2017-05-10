%script to run jc_findbouts for batch of folders
tic
config;
batch = uigetfile;
pathname = fileparts([pwd,'/analysis/data_structures/']);

ff = load_batchf(batch);
for i = 1:length(ff)
    for ii = 1:length(params.findbout)
        try
            load(['analysis/data_structures/motif_',params.findbout(ii).motif,'_',ff(i).name]);
        catch
            continue
        end
        cd(ff(i).name)
        disp(ff(i).name);
        cmd = ['bout_',params.findbout(ii).motif,'_',ff(i).name,'=','jc_findbouts(params.batchfile,motif_',params.findbout(ii).motif,'_',ff(i).name,',params.findbout(',num2str(ii),'),params.filetype)'];
        eval(cmd);

        varname = ['bout_',params.findbout(ii).motif,'_',ff(i).name];
        matfile = fullfile(pathname,varname);
        savecmd = ['save(matfile,varname,''-v7.3'')'];
        eval(savecmd);
        cd ../
    end
end
toc