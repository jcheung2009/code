function script_findbout_df(batch,ind)
%save bout structures for every song file that is made. 

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
    
    cd(ff(i).name);
    ff2 = load_batchf('batch.keep');
    ff_songs = [];
    cnt = 0;
    for m = 1:length(ff2)
        load([ff2(m).name,'.not.mat']);
        if ~isempty(regexp(labels,'[a-z]'))
            cnt = cnt+1;
            ff_songs(cnt).name = ff2(m).name;
        end
    end
    cmd2 = ['bout_',ff(i).name,'=struct(''filename'',arrayfun(@(x) x.name,ff_songs,''unif'',0),''datenm'',arrayfun(@(x) wavefn2datenum(x.name),ff2,''unif'',0));'];
    eval(cmd2);

    cd ../analysis/data_structures
    varname2 = ['''bout_',ff(i).name,''''];
    savecmd2 = ['save(',varname2,',',varname2,',','''-v7.3'')'];
    eval(savecmd2);
    
    clearvars -except  ff
    cd ../../
end
