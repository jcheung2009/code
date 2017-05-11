%script to run jc_findwnote5 in batch with config settings

%start in directory with all data folders
config;
noteparams = params.findnote;
pathname = fileparts([pwd,'/analysis/data_structures/']);
ff = load_batchf('batch');
ind = input('batch index [st, end]:');
tic
for i = ind(1):ind(2)%1:length(ff)
    cd(ff(i).name);
    disp(ff(i).name);
    numsylls = length(noteparams.syllables);
    for n = 1:numsylls
        cmd = ['fv_syll',upper(noteparams.syllables{n}),'_',ff(i).name,'=',...
            'jc_findwnote5(''batch.keep'',noteparams.syllables{n},noteparams.prenotes{n},',...
            'noteparams.postnotes{n},noteparams.timeshifts{n},noteparams.fvalbnd{n},noteparams.nfft,',...
            'noteparams.usefit,noteparams.chanspec,noteparams.evtaf,noteparams.addx,noteparams.chckpc);'];
        eval(cmd);
    
        varname = ['fv_syll',upper(noteparams.syllables{n}),'_',ff(i).name];
        matfile = fullfile(pathname,varname);
        savecmd = ['save(matfile,varname,''-v7.3'')'];
        eval(savecmd);
    end
    cd ..
end
toc