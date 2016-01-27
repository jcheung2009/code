ff = load_batchf('batch_sal');
load('analysis/data_structures/naspmvolumelatency');
repsal = struct();
repeats = {'A','B','D'};
trialcnt = 0;
for i = 1:2:length(ff)
    trialcnt = trialcnt+1;
    for ii = 1:length(repeats)
        load(['analysis/data_structures/fv_rep',repeats{ii},'_',ff(i).name]);
        load(['analysis/data_structures/fv_rep',repeats{ii},'_',ff(i+1).name]);

        if ~isempty(strfind(ff(i+1).name,'naspm'))
                mcolor = 'r';
                mrk = 'ro';
        elseif ~isempty(strfind(ff(i+1).name,'IEM'))
            mcolor = 'm';
            mrk = 'mo';
        elseif ~isempty(strfind(ff(i+1).name,'APV'))
             mcolor = 'b';
             mrk = 'bo';
        else
            mcolor = 'k';
            mrk = 'ko';
        end

        rep1 = ['fv_rep',repeats{ii},'_',ff(i).name];
        rep2 = ['fv_rep',repeats{ii},'_',ff(i+1).name];

        if ~isempty(strfind(ff(i+1).name,'sal'))
            startpt = '';
        else
            drugtime = naspmvolumelatency.(['tr_',ff(i+1).name]).treattime;
            startpt = (drugtime+1.13)*3600;
        end

        [repsal(trialcnt).([repeats{ii}]).rep repsal(trialcnt).([repeats{ii}]).sdur ...
            repsal(trialcnt).([repeats{ii}]).gdur repsal(trialcnt).([repeats{ii}]).acorr] ...
            = jc_plotrepeatsummary(eval(rep1),eval(rep2),mrk,mcolor,1.5,0,startpt,'','n',12);

    end
end
