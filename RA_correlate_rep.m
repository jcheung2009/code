function [spk_rep_corr case_name dattable] = RA_correlate_rep(batchfile,...
    minsampsize,activitythresh,plotcasecondition,shuff,ifr)
%correlate premotor spikes with repeat length 
%minsampsize = minimum number of trials 
%activitythresh = for peak detection (zscore relative to shuffled activity)
%plotcasecondition = 'n' (don't plot), 'ysu'
%(plot significant single unit cases),'y' (plot everything significant) 
%shuff = 'n' or 'y' (shuffled analysis, for cases with peak activity
%greater than thresh and multi unit), or 'ysu' (for activity greater than thresh and single units)
%ifr = 1 use mean instantaneous FR or 0 use spike count


% add characteristics of repeat: variability, min and max length, cv

%parameters
config
win = gausswin(20);%for smoothing spike trains, 20 ms
win = win./sum(win);
if strcmp(plotcasecondition,'n')
    plotcasecondition = '1==0';
elseif strcmp(plotcasecondition,'y')
    plotcasecondition = ['pkactivity >=',num2str(activitythresh)];
elseif strcmp(plotcasecondition,'ysu')
    plotcasecondition = ['mean(pct_error)<=0.01 & pkactivity >=',num2str(activitythresh)]; 
end

spk_rep_corr = [];case_name = {};
dattable = table([],[],[],[],[],[],[],[],[],'VariableNames',{'length','spikes',...
    'position','unittype','activity','birdid','unitid','seqid','corrpval'});
ff = load_batchf(batchfile);
for i = 1:length(ff)
    
    id = find(arrayfun(@(x) ~isempty(strfind(ff(i).name,x.birdname)),params));
    if isempty(params(id).repeat)
        continue
    else
        load(ff(i).name);
        spiketimes = spiketimes*1000;%ms
        repsylls = params(id).repeat;
    end
    
    %find indices for variable repeats and repeat length on each trial
    onind = {};offind = {};replength = {};
    for nsyll = 1:length(repsylls)
        p = ismember(labels,repsylls{nsyll}(2));
        kk = [find(diff([-1 p -1])~=0)];
        runlength = diff(kk);
        runlength = runlength(1+(p(1)==0):2:end);
        pp = find(diff([0 p])==1);
        id = strfind(labels(pp-1),repsylls{nsyll}(1));%select repeats with correct presyll 
        pp = pp(id);runlength = runlength(id);
        onind = [onind pp];%start index for each repeat run
        offind = [offind pp+runlength-1];%end index for each repeat run
        replength = [replength runlength];
    end

    %for each repeat
    for nrep = 1:length(repsylls) 
        
        if length(replength{nrep}) < minsampsize
            continue
        end
        seqons_all = arrayfun(@(x,y,z) onsets(x+[-1:y-1])',onind{nrep},replength{nrep},'un',0);%includes pre-syllable
        seqoffs_all = arrayfun(@(x,y,z) offsets(x+[-1:y-1])',onind{nrep},replength{nrep},'un',0);
        
        %remove outliers where repeat is greater than 2 s
        if ~isempty(find(cellfun(@(x,y) y(end)-x(1),seqons_all,seqoffs_all) >= 2000))
            id = find(cellfun(@(x,y) y(end)-x(1),seqons_all,seqoffs_all) >= 2000);
            seqons_all(id) = [];seqoffs_all(id) = [];replength{nrep}(id) = [];
            onind{nrep}(id) = [];offind{nrep}(id) = [];
        end
        
        %order by repeat length
        [~,ix] = sort(replength{nrep});
        seqons_all = seqons_all(ix);seqoffs_all = seqoffs_all(ix); replength{nrep} = replength{nrep}(ix);
        onind{nrep} = onind{nrep}(ix); offind{nrep} = offind{nrep}(ix);
        
        durs_all = cellfun(@(x,y) y-x,seqons_all,seqoffs_all,'un',0);
        gaps_all = cellfun(@(x,y) x(2:end)-y(1:end-1),seqons_all,seqoffs_all,'un',0);
        durs_all = max(cell2mat(cellfun(@(x) [x NaN(1,max(replength{nrep})+1-length(x))],durs_all,'un',0)'));
        gaps_all = min(cell2mat(cellfun(@(x) [x NaN(1,max(replength{nrep})-length(x))],gaps_all,'un',0)'));
        
        %compute PSTH aligned to each syllable 
        for repid = 1:max(replength{nrep})+1
            %omit trials with length less than repid 
            ix = find(replength{nrep}+1>=repid);
            replength_corr = replength{nrep}(ix);
            seqons = seqons_all(ix);seqoffs = seqoffs_all(ix);
            
            if length(replength_corr)<minsampsize
                continue
            end
            
            %offsets for finding peaks
            mndur = durs_all(repid);
            if repid ~= 1
                mngap = gaps_all(repid-1);
            else
                mngap = 0;
            end

            %align by onset
            rependbuff = gaps_all(repid);%ms 
            anchor = cellfun(@(x) x(repid),seqons)';
            seqst = cellfun(@(x,y) x(repid)-y(1),seqons,seqons);
            seqend = cellfun(@(x,y) x(end)+rependbuff-y(repid),seqoffs,seqons);
            [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,seqst,seqend,anchor,win,ifr);
            
            %align by offset
            anchor2 = cellfun(@(x) x(repid),seqoffs)';
            seqst2 = cellfun(@(x,y) x(repid)-y(1),seqoffs,seqons);
            seqend2 = cellfun(@(x,y) x(end)+rependbuff-y(repid),seqoffs,seqoffs);
            [PSTH_mn2 tb2 smooth_spiketrains2 spktms2] = smoothtrain(spiketimes,seqst2,seqend2,anchor2,win,ifr);
            
            %find peaks in PSTHs 
            [pks, locs,w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',5,...
                'MinPeakWidth',10,'MinPeakDistance',20,'Annotate','extents','WidthReference','halfheight');
            pkid = find(tb(locs)>=-mngap & tb(locs)<=0);%in the gap preceding
            wc = round(wc);
            [pks2, locs2,w2,~,wc2] = findpeaks2(PSTH_mn2,'MinPeakProminence',5,...
                'MinPeakWidth',10,'MinPeakDistance',20,'Annotate','extents','WidthReference','halfheight');
            pkid2 = find(tb2(locs2)>=-mndur & tb2(locs2)<=0);%in the syllable
            wc2 = round(wc2);

            if isempty(pkid) & isempty(pkid2)
                continue
            end
            
            %shuffled spike train to detect peaks that are significantly
            %above shuffled activity
            smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
            PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;
            
            if ~isempty(pkid) %burst in the gap
            	for ixx = 1:length(pkid)
                    [burstst burstend] = peakborder(wc,pkid(ixx),locs,tb);
                    pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand); 
                    if ifr == 1
                        npks_burst = mean(smooth_spiketrains(:,burstst:burstend),2).*1000;
                    else
                        npks_burst = countspks(spktms,tb(burstst),tb(burstend),ifr);
                    end
                    wth = w(pkid(ixx));
                    
                    removenan = find(isnan(npks_burst));
                    npks_burst(removenan) = 0;%0 Hz for trials with no spikes in window
                    
                    if ~isempty(strfind(shuff,'y'))
                        shufftrials = 1000;
                        if isempty(strfind(shuff,'su')) %for multi unit shuff
                            if mean(pct_error)<=0.01 | pkactivity < activitythresh
                                continue
                            end
                        else
                            if mean(pct_error) > 0.01 | pkactivity < activitythresh
                                continue
                            end
                        end
                        [r p] = shuffle(npks_burst,replength_corr',shufftrials);
                        if sum(replength_corr==repid-1)>=10 %at least 10 end events 
                            classes = double(replength_corr>repid-1);%1 = continues, 0 = end
                            p2 = mnshuffle(npks_burst,classes',shufftrials);
                        else
                            p2 = NaN(shufftrials,1);
                        end
                        spk_rep_corr = [spk_rep_corr r p p2];
                    else
                        [r p] = corrcoef(npks_burst,replength_corr);%linear regression
                        if sum(replength_corr==repid-1)>=10 %at least 10 end events
                            nostp = find(replength_corr > repid-1);
                            stp = find(replength_corr <= repid-1);
                            classes = double(replength_corr>repid-1);%1 = continues, 0 = end
                            [h p2] = ttest2(npks_burst(nostp),npks_burst(stp));
                            numends = length(stp);%number of trials where repeat ended at repid
                        else
                            p2 = NaN;numends = NaN;
                        end
                           
                        %save measurements
                        spk_rep_corr = [spk_rep_corr; r(2) p(2) p2 numends repid pkactivity ...
                            wth mean(pct_error) length(npks_burst) cv(replength_corr') mean(replength_corr)];
                        T = maketable(ff(i).name,repsylls(nrep),replength_corr,...
                            npks_burst,pct_error,pkactivity,p(2),repid);
                        dattable=[dattable;T];
                        case_name = [case_name,{T.unitid{1},T.seqid(1)}];

                        if eval(plotcasecondition) 
                            if p(2) <= 0.05 | p2 <= 0.05
                                figure;
                                subplot(3,1,3);hold on;
                                if p(2) <= 0.05
                                    plotCORR(npks_burst,replength_corr,ifr);
                                    corrval = r(2);
                                else
                                    plotBAR(npks_burst,classes,ifr);
                                    corrval = NaN;
                                end
                                
                                subplot(3,1,1);hold on;
                                plotraster(replength_corr,spktms,tb(burstst),tb(burstend),...
                                    seqons,seqoffs,max(seqst),max(seqend),anchor,...
                                    ff(i).name,pct_error,repsylls{nrep},repid,corrval);

                                subplot(3,1,2);hold on;
                                plotPSTH(ceil(max(seqst)),ceil(max(seqend)),...
                                    smooth_spiketrains,replength_corr,tb(burstst),tb(burstend));
                            end 
                        end
                    end
                end
            end
                    
            if ~isempty(pkid2)%burst in the syllable
            	for ixx = 1:length(pkid2)
                    [burstst2 burstend2] = peakborder(wc2,pkid2(ixx),locs2,tb2);
                    pkactivity = (pks2(pkid2(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand);
                    if ifr == 1
                        npks_burst = mean(smooth_spiketrains2(:,burstst2:burstend2),2).*1000;
                    else
                        npks_burst = countspks(spktms2,tb2(burstst2),tb2(burstend2),ifr);
                    end
                    wth = w2(pkid2(ixx));
                    
                    removenan = find(isnan(npks_burst));
                    npks_burst(removenan) = 0;%0 Hz for trials with no spikes in window
                    
                    if ~isempty(strfind(shuff,'y'))
                        shufftrials = 1000;
                        if isempty(strfind(shuff,'su')) %for multi unit shuff
                            if mean(pct_error)<=0.01 | pkactivity < activitythresh
                                continue
                            end
                        else
                            if mean(pct_error) > 0.01 | pkactivity < activitythresh
                                continue
                            end
                        end
                        [r p] = shuffle(npks_burst,replength_corr',shufftrials);
                       if sum(replength_corr==repid-1)>=10 %at least 10 end events 
                            classes = double(replength_corr>repid-1);%1 = continues, 0 = end
                            p2 = mnshuffle(npks_burst,classes',shufftrials);
                        else
                            p2 = NaN(shufftrials,1);
                        end
                        spk_rep_corr = [spk_rep_corr r p p2];
                    else
                        [r p] = corrcoef(npks_burst,replength_corr);
                        if sum(replength_corr==repid-1)>=10 %at least 10 end events
                            nostp = find(replength_corr > repid-1);
                            stp = find(replength_corr <= repid-1);
                            classes = double(replength_corr>repid-1);%1 = continues, 0 = end
                            [h p2] = ttest2(npks_burst(nostp),npks_burst(stp));
                            numends = length(stp);%number of trials where repeat ended at repid
                        else
                            p2 = NaN;numends = NaN;
                        end
                        
                        %save measurements
                        spk_rep_corr = [spk_rep_corr; r(2) p(2) p2 numends repid pkactivity ...
                            wth mean(pct_error) length(npks_burst) cv(replength_corr') mean(replength_corr)];
                        T = maketable(ff(i).name,repsylls(nrep),replength_corr,...
                            npks_burst,pct_error,pkactivity,p(2),repid);
                        dattable=[dattable;T];
                        case_name = [case_name,{T.unitid{1},T.seqid(1)}];

                        if eval(plotcasecondition)
                            if p(2)<=0.05 | p2 <= 0.05
                                figure;
                                subplot(3,1,3);hold on;
                                if p(2) <= 0.05
                                    plotCORR(npks_burst,replength_corr,ifr);
                                    corrval = r(2);
                                else
                                    plotBAR(npks_burst,classes,ifr);
                                    corrval = NaN;
                                end
                                
                                subplot(3,1,1);hold on;
                                plotraster(replength_corr,spktms2,tb2(burstst2),tb2(burstend2),...
                                    seqons,seqoffs,max(seqst2),max(seqend2),anchor2,...
                                    ff(i).name,pct_error,repsylls{nrep},repid,corrval);

                                subplot(3,1,2);hold on;
                                plotPSTH(ceil(max(seqst2)),ceil(max(seqend2)),...
                                    smooth_spiketrains2,replength_corr,tb2(burstst2),tb2(burstend2));
                            end        
                        end
                    end
                end
            end        
        end 
    end
end

function [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,seqst,seqend,anchor,win,ifr);
    spktms = cell(size(anchor,1),1);%spike times for each trial relative to target gap 
    smooth_spiketrains = zeros(size(anchor,1),ceil(max(seqst))+ceil(max(seqend))+1);
    for m = 1:size(anchor,1)
        temp = zeros(1,size(smooth_spiketrains,2));
        x = spiketimes(find(spiketimes>=(anchor(m)-seqst(m)) & spiketimes<=(anchor(m)+seqend(m))));
        spktms{m} = x - anchor(m); 
        spktimes = round(spktms{m})+ceil(max(seqst))+1;
        if ifr == 1
            temp(spktimes(1:end-1)) = 1./diff(x);
        else
            temp(spktimes) = 1;
        end
        smooth_spiketrains(m,:) = conv(temp,win,'same');
    end
    tb = [-ceil(max(seqst)):ceil(max(seqend))];
    PSTH_mn = mean(smooth_spiketrains,1).*1000;%spikes/second
    
function [burstst burstend] = peakborder(wc,id,locs,tb);
    burstend = wc(id,2)+(wc(id,2)-locs(id));
    burstst = wc(id,1)-(locs(id)-(wc(id,1)));
    if id<size(wc,1)
        if burstend > wc(id+1,1)
            burstend = ceil((wc(id,2)+wc(id+1,1))/2);
        end
    end
    if id ~= 1
        if burstst < wc(id-1,2)
            burstst = floor((wc(id,1)+wc(id-1,2))/2);
        end
    end
    if burstst <= 0
        burstst = 1;
    end
    if burstend > length(tb)
        burstend = length(tb);
    end
    
function npks = countspks(spktms,tm1,tm2,ifr);
if length(tm1) == 1
    if ifr == 0
        npks = cellfun(@(x) length(find(x>=tm1 & x<tm2)),spktms);%extract nspks in each trial
    elseif ifr == 1
        id = cellfun(@(x) find(x(1:end-1)>=tm1&x(1:end-1)<tm2),spktms,'un',0);
        spktms_diff = cellfun(@(x) diff(x),spktms,'un',0);
        npks = cellfun(@(x,y) median(x(y)),spktms_diff,id);%average ifr in each trial
        npks = 1000*(1./npks);
    end
else
    if ifr == 0
        npks = cellfun(@(x,y,z) length(find(x>=y & x<z)),spktms,tm1,tm2);%extract nspks in each trial
    elseif ifr == 1
        id = cellfun(@(x,y,z) find(x(1:end-1)>=y & x(1:end-1)< z),spktms,tm1,tm2,'un',0);
        spktms_diff = cellfun(@(x) diff(x),spktms,'un',0);
        npks = cellfun(@(x,y) median(x(y)),spktms_diff,id);
        npks = 1000*(1./npks);
    end
end
    
function [r p] = shuffle(npks_burst,dur_id_corr,shufftrials);
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff);
    [r p] = corrcoef([npks_burst_shuff',dur_id_corr]);
    r = r(1:end-1,end);
    p = p(1:end-1,end);
    
function p = mnshuffle(npks_burst,classes,shufftrials);
    stp = find(classes==0);
    nostp = find(classes==1);
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff); %shuffles elements within each row
    p = NaN(1000,1);
    parfor rep = 1:shufftrials
        pval = ranksum(npks_burst_shuff(rep,stp),npks_burst_shuff(rep,nostp));
        p(rep) = pval;
    end
    
function [r p] = logistic_shuffle(npks_burst,replength_corr,shufftrials);
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff);
    r = NaN(1000,1);p = NaN(1000,1);
    parfor rep = 1:shufftrials
        mdl = fitglm(npks_burst_shuff(rep,:),classes,'Distribution','binomial');
        r(rep) = mdl.Coefficients.Estimate(2);
        p(rep) = mdl.Coefficients.pValue(2);
    end
    
function plotraster(replen,spktms,tm1,tm2,seqons,seqoffs,...
    seqst,seqend,anchor,name,pct_error,seqid,position,corrval)
    i = 0;
    while length(find(replen >= max(replen)-i)) < 10
        i = i + 1;
    end
    longid = min(find(replen >= max(replen)-i));
    i = 0;
    while length(find(replen <= min(replen)+i)) < 10
        i = i + 1;
    end
    shortid = max(find(replen <= min(replen)+i));
    if ~isempty(tm1)
        if length(tm1) == 1
            spktms_inburst = cellfun(@(x) x(find(x>=tm1&x<tm2)),spktms,'un',0);
        else
            spktms_inburst = cellfun(@(x,y,z) x(find(x>=y&x<z)),spktms,tm1,tm2,'un',0);
        end
    end
    cnt=0;
    for m = 1:length(replen)
        if ~isempty(spktms{m})
            plot(repmat(spktms{m},2,1),[cnt cnt+1],'k');hold on;
        end
        if ~isempty(tm1)
            if ~isempty(spktms_inburst{m})
                plot(repmat(spktms_inburst{m},2,1),[cnt cnt+1],'b');hold on;
            end
        end
        for syll=1:size(seqons{m},2)
            patch([seqons{m}(syll) seqoffs{m}(syll) seqoffs{m}(syll) seqons{m}(syll)]-anchor(m),...
                 [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
        end
        cnt=cnt+1;
    end
    [~,stid] = regexp(name,'data_');
    enid = regexp(name,'_TH');
    unitid = name(stid+1:enid-1);
    singleunit = mean(pct_error)<=0.01;
    title([unitid,' ',seqid,num2str(position-1),' r=',num2str(corrval),...
        ' unit=',num2str(singleunit)],'interpreter','none');
    xlabel('time (ms)');ylabel('trial');set(gca,'fontweight','bold');
    xlim([-seqst seqend]);ylim([0 cnt]);
    plot(-seqst,longid,'r>','markersize',4,'linewidth',2);hold on;
    plot(-seqst,shortid,'b>','markersize',4,'linewidth',2);hold on;
        
function plotPSTH(seqst,seqend,smooth_spiketrains,replen,tm1,tm2);
    i = 0;
    while length(find(replen >= max(replen)-i)) < 10
        i = i + 1;
    end
    longid = find(replen >= max(replen)-i);
    i = 0;
    while length(find(replen <= min(replen)+i)) < 10
        i = i + 1;
    end
    shortid = find(replen <= min(replen)+i);
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(longid,:),1)-...
        stderr(smooth_spiketrains(longid,:),1)...
        fliplr(mean(smooth_spiketrains(longid,:),1)+...
        stderr(smooth_spiketrains(longid,:),1))])*1000,[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(shortid,:),1)-...
        stderr(smooth_spiketrains(shortid,:),1)...
        fliplr(mean(smooth_spiketrains(shortid,:),1)+...
        stderr(smooth_spiketrains(shortid,:),1))])*1000,[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains,1)-...
        stderr(smooth_spiketrains,1)...
        fliplr(mean(smooth_spiketrains,1)+...
        stderr(smooth_spiketrains,1))])*1000,[0.8 0.8 0.8],'edgecolor','none','facealpha',0.7);
    yl = get(gca,'ylim');
    if ~isempty(tm1)
        plot(repmat([tm1 tm2],2,1),yl,'g','linewidth',2);hold on;
    end
    xlim([-seqst seqend]);                        
    xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');        
        
function plotCORR(npks_burst,replen,ifr,varargin);
    if nargin<4%linear
        scatter(npks_burst,replen,'k.');hold on;
        xlim([min(npks_burst)-1 max(npks_burst)+1]);lsline
    else%logistic
        scatter(npks_burst,replen,'k.');hold on;
        xhat = [0:10:max(npks_burst)];
        ypred = predict(varargin{1},xhat');
        plot(xhat,ypred,'k');
    end
    if ifr == 0
        xlabel('number of spikes');
    else
        xlabel('IFR');
    end
    ylabel('length');
    set(gca,'fontweight','bold');
    
function plotBAR(npks_burst,classes,ifr);
    stp = find(classes==0);
    nostp = find(classes==1);
    err1 = stderr(npks_burst(stp));
    err2 = stderr(npks_burst(nostp));
    bar([1,2],[mean(npks_burst(stp)),mean(npks_burst(nostp))],'facecolor','none','linewidth',2);hold on;
    errorbar(1,mean(npks_burst(stp)),err1,'k');hold on;
    errorbar(2,mean(npks_burst(nostp)),err2,'k');hold on;
    xticks([1 2]);xticklabels({'stop','continue'})
    if ifr == 0
        ylabel('number of spikes');
    else
        ylabel('IFR');
    end
    
function T = maketable(name,seqid,replen,npks_burst,pct_error,pkactivity,corrpval,position);
    [~,stid] = regexp(name,'data_');
    enid = regexp(name,'_TH');
    unitid = name(stid+1:enid-1);
    birdid = repmat({unitid(1:regexp(unitid,'_')-1)},length(replen),1);
    unitid = repmat({unitid},length(replen),1);
    seqid = repmat(seqid,length(replen),1);
    replenn = (replen-nanmean(replen))/nanstd(replen);
    npks_burstn = (npks_burst-mean(npks_burst))/std(npks_burst);
    unittype = repmat(mean(pct_error),length(replen),1);
    activitylevel = repmat(pkactivity,length(replen),1);
    corrpval = repmat(corrpval,length(replen),1);
    position = repmat(position,length(replenn),1);
    T = table(replenn',npks_burstn,position,unittype,activitylevel,birdid,unitid,seqid,corrpval,'VariableNames',...
        {'length','spikes','position','unittype','activity','birdid','unitid','seqid','corrpval'});
        
    %for each repeat syllable, correlate activity with probability of
    %following syllable
    
    %correlate activity before repeat start with repeat length
    
    %bursts at end of syllable and end of repeat, logistic regression for
    %ending or continuing
    