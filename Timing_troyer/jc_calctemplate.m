function [template] = jc_calctemplate(batch)
%batch = list of spec.mat in specs_for_note_ folder
%make sure you are in that folder directory
% find template by averaging aligned exemplars
%Initial alignment is just based on centering all the exemplars 
%Second alignment which is more intensive is based on a cross correlation
%measurement to the crude template from the initial alignment


ff = load_batchf(batch);
samp = randsample(length(ff),floor(0.1*length(ff))); %randomly choose 10% of songs
ff = ff(samp);
load('specparams.mat');

avgspec.iterations = 1; % number of iterations of aligning and averaging
avgspec.normalize = 0; % normalize by the sum of all entries
avgspec.mtchparams = jc_defaultmtchparams; 
avgspec.freqinds = 1:length(specparams.f);

%% first find size of examplars and initialize output data
exempnum = 0;% number of exemplars
exempsize = [];% number of time bins for each exemplar
for i = 1:length(ff)
    fn = ff(i).name;
    if ~exist(fn)
            continue
    else
        load(fn);
        exempnum = exempnum + length(notespecs);
        if specparams.tds == 1
            spec_exempsize = arrayfun(@(x) size(x.spectds,2),notespecs)';%number of time bins for each exemplar in the current notespecs
        else
            spec_exempsize = arrayfun(@(x) size(x.spec,2),notespecs)';
        end
        spec_exempsize = spec_exempsize(spec_exempsize*specparams.dt < 100);%skip spectrograms that are more than 100 ms, mislabelled
        exempsize = [exempsize;spec_exempsize];
    end
end
mxtime = max(exempsize); % max number of time bins over all exemplars
template = zeros(length(specparams.f),mxtime);  % initializing matrix for final template, size is = max time bin of longest exemplar
tempcenter = ceil(mxtime/2);

%% find initial average
% disp('Finding initial average');
wb1 = waitbar(0,'initial matching');
for i = 1:length(ff)
    fn = ff(i).name;
    if ~exist(fn)
        continue
    else
        load(fn);
        if specparams.tds == 1
            spec_exempsize = arrayfun(@(x) size(x.spectds,2),notespecs)';
        else
            spec_exempsize = arrayfun(@(x) size(x.spec,2),notespecs)';
        end
        exempcenters = ceil(spec_exempsize/2);
        for ii = 1:length(spec_exempsize)
            if spec_exempsize(ii)*specparams.dt > 100
                continue
            else
                tmpinds = (tempcenter-exempcenters(ii))+(1:spec_exempsize(ii));
                if specparams.tds == 1
                    template(:,tmpinds) = template(:,tmpinds) + notespecs(ii).spectds;
                else
                    template(:,tmpinds) = template(:,tmpinds) + notespecs(ii).spec;
                end
            end
        end
    end
    wb1 = waitbar(i/length(ff),wb1);
end
close(wb1);
template = template/exempnum;
%temphist{1} = template;

%% cycle through alignment and averaging
for n = 1:avgspec.iterations
    %% find padding for template
    templatetime = size(template,2);
    exempoffsets = ceil(avgspec.mtchparams.offsetfrac*max(exempsize,templatetime));
    pad = max(exempoffsets); % template is as big as or bigger than biggest exemplar
    % make padtemplate - current template with zero padding on each side
    template = [zeros(length(specparams.f),pad) template zeros(length(specparams.f),pad)];
    if avgspec.normalize
        template = template/sum(sum(template));
    end
    tempcenter = ceil(size(template,2)/2);
    datarange = tempcenter*[1 1]; % will keep track of where data has been placed so that the edges can be clipped
    newtemplate = zeros(size(template));
    wb = waitbar(0,'Matching exemplars');
    for i=1:length(ff)
        tic
        % find start indices for each exemplar based on different sizes of template and exemplars
%         startinds = (pad+1-exempoffsets(i)):(pad+1+exempoffsets(i)+templatetime-exempsize(i));
%         center = floor((templatetime-exempsize(i))/2);
        fn = ff(i).name;
        if ~exist(fn)
            continue
        else
            load(fn);
            if specparams.tds ==1
                spec_exempsize = arrayfun(@(x) size(x.spectds,2),notespecs)';
            else
                spec_exempsize = arrayfun(@(x) size(x.spec,2),notespecs)';
            end
            exempcenters = ceil(spec_exempsize/2);
            spec_exempoffsets = ceil(avgspec.mtchparams.offsetfrac*max(spec_exempsize,templatetime));
            for ii = 1:length(spec_exempoffsets);
                %calculate match at each offset
                if spec_exempsize(ii)*specparams.dt > 100
                    continue
                end
                tmpoffsets = -spec_exempoffsets(ii):spec_exempoffsets(ii);
                tmpmatch = zeros(length(tmpoffsets),1);
                for j = 1:length(tmpoffsets)
                    if specparams.tds == 1
                        tmpexemp = notespecs(ii).spectds(avgspec.freqinds,:);
                    else
                        tmpexemp = notespecs(ii).spec(avgspec.freqinds,:);
                    end
                    if avgspec.normalize
                        tmpexemp = tmpexemp/sum(sum(tmpexemp));
                    end
                    tmpinds = tmpoffsets(j)+tempcenter-exempcenters(ii)+(1:spec_exempsize(ii));
                    tmpindscomp = setdiff(1:size(template,2),tmpinds);
                    tmpmatch(j) = feval(avgspec.mtchparams.metric,tmpexemp,...
                        template(avgspec.freqinds,tmpinds)) + ...
                    feval(avgspec.mtchparams.metric,zeros(length(avgspec.freqinds),length(tmpindscomp)),...
                        template(avgspec.freqinds,tmpindscomp));
                end
                % find minimum of match and add to template at appropriate offset
                [val ind] = min(tmpmatch);
                tmpinds = tmpoffsets(ind)+tempcenter-exempcenters(ii)+(1:spec_exempsize(ii));
                if specparams.tds == 1
                    newtemplate(:,tmpinds) = newtemplate(:,tmpinds) + notespecs(ii).spectds;
                else
                    newtemplate(:,tmpinds) = newtemplate(:,tmpinds) + notespecs(ii).spec;
                end
                datarange(1) = min(datarange(1),tmpinds(1));
                datarange(2) = max(datarange(2),tmpinds(end));
            end
        end
        wb = waitbar(i/length(ff),wb);
        toc
    end
    template = newtemplate(:,datarange(1):datarange(2))/exempnum;
    close(wb)
%     newcenter = datarange(1)-1+ceil(diff(datarange)/2);
    
%     if tempcenter~= newcenter
%         offsets = offsets-(newcenter-tempcenter);
%     end

%     if n<avgspec.iterations
%         temphist{n+1} = template;
%     end
end
          
save('template.mat','template');

    