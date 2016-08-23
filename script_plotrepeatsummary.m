ff = load_batchf('batchsal');
load('analysis/data_structures/iemapvlatency');
repsal = struct();
repeats = {'Q'};
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
            mcolor = 'r';
            mrk = 'ro';
        elseif ~isempty(strfind(ff(i+1).name,'APV'))
             mcolor = 'g';
             mrk = 'go';
        else
            mcolor = 'k';
            mrk = 'ko';
        end

        rep1 = ['fv_rep',repeats{ii},'_',ff(i).name];
        rep2 = ['fv_rep',repeats{ii},'_',ff(i+1).name];

        if ~isempty(strfind(ff(i+1).name,'sal'))
            startpt = '';
        else
            drugtime = iemapvlatency.(['tr_',ff(i+1).name]).treattime;
            startpt = (drugtime+0.6)*3600;
        end

        [repsal(trialcnt).([repeats{ii}]).rep repsal(trialcnt).([repeats{ii}]).sdur ...
            repsal(trialcnt).([repeats{ii}]).gdur repsal(trialcnt).([repeats{ii}]).acorr] ...
            = jc_plotrepeatsummary(eval(rep1),eval(rep2),mrk,mcolor,0.5,0,startpt,0,'y',32);

    end
end
