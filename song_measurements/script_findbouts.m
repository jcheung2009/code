function script_findbouts(batch,ind)
%script to run jc_findbouts for batch of folders
tic
config;
pathname = fileparts([pwd,'/analysis/data_structures/']);
ff = load_batchf(batch);
if isempty(ind)
    ind = [1 length(ff)];
end
for i = ind(1):ind(2)
    if isempty(ff(i).name)
        continue
    end
    for ii = 1:length(params.findbout)
        try
            load(['analysis/data_structures/motif_',params.findbout(ii).motif,'_',ff(i).name]);
        catch
            continue
        end
        cd(ff(i).name)
        disp(ff(i).name);
        cmd = [params.findbout(ii).boutstruct,ff(i).name,'=','jc_findbouts(params.batchfile,motif_',params.findbout(ii).motif,'_',ff(i).name,',params.findbout(',num2str(ii),'),params.filetype)'];
        eval(cmd);

        varname = [params.findbout(ii).boutstruct,ff(i).name];
        matfile = fullfile(pathname,varname);
        savecmd = ['save(matfile,varname,''-v7.3'')'];
        eval(savecmd);
        cd ../
    end
end
toc