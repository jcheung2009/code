function [bursttable mmtable coxtable] = RA_correlate_rep(batchfile,...
    activitythresh,minsampsize,plotfig,ifr)
%correlate activity in repeat syllables with repeat length 
%activitythresh = for peak detection (zscore relative to shuffled activity)
%plotfig = 'n' or 'y', plots every repeat case aligned by first syllable (for debugging),
%will always plot every correlated burst 
%ifr = 1 use mean instantaneous FR or 0 use spike count
%only bursts that cross activitythresh (number of std above random) 

%bursttable = results of linear regression and rank sum tests on each burst
%mmtable = raw data to be used to test mixed model for FR ~ position + length 
%coxtable = results of cox regression on averageFR, starting FR, and burst
%FR for each repeat case
%% parameters
config
suthresh = 0.02;%2% percent error threshold for single unit id
win = gausswin(20);%for smoothing spike trains, 20 ms
win = win./sum(win);
shufftrials = 1000;

bursttable = table([],[],[],[],[],[],[],[],'VariableNames',{'unitid','birdid','seqid','position',...
    'length','IFR','linear','linear2'});
coxtable =  table([],[],[],[],[],'VariableNames',{'unitid','seqid',...
    'averageFR','startFR','burstFR'});
mmtable = table([],[],[],[],[],[],[],'VariableNames',...
        {'unitid','birdid','seqid','rendition','position','length','FR'});
    
%% extract FR for each burst in each repeat  
ff = load_batchf(batchfile);
for i = 1:length(ff)
    disp(ff(i).name);
    [~,stid] = regexp(ff(i).name,'data_');enid = regexp(ff(i).name,'_TH');
    unitid = ff(i).name(stid+1:enid-1);
    birdid = unitid(1:regexp(unitid,'_')-1);
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

    %for each repeat type, identify bursts at each syllable position 
    for nrep = 1:length(repsylls) 
       %col=syllable position,row=trial,cell cols=bursts at that position 
        IFRposition = cell(length(replength{nrep}),max(replength{nrep}));
        %onset/offset times for each syllable in every repeat rendition
        seqons_all = arrayfun(@(x,y,z) onsets(x+[0:y-1])',onind{nrep},replength{nrep},'un',0);
        seqoffs_all = arrayfun(@(x,y,z) offsets(x+[0:y-1])',onind{nrep},replength{nrep},'un',0);
        
        %remove outliers where repeat is greater than 2 s
        if ~isempty(find(cellfun(@(x,y) y(end)-x(1),seqons_all,seqoffs_all) >= 2000))
            id = find(cellfun(@(x,y) y(end)-x(1),seqons_all,seqoffs_all) >= 2000);
            seqons_all(id) = [];seqoffs_all(id) = [];replength{nrep}(id) = [];
            onind{nrep}(id) = [];offind{nrep}(id) = [];
        end
        
        %order by repeat length
        [~,ix] = sort(replength{nrep});
        seqons_all = seqons_all(ix);seqoffs_all = seqoffs_all(ix); 
        replength{nrep} = replength{nrep}(ix);
        onind{nrep} = onind{nrep}(ix); offind{nrep} = offind{nrep}(ix);
        
        %syllable and gap durations for every repeat rendition
        durs_all = cellfun(@(x,y) y-x,seqons_all,seqoffs_all,'un',0);
        gaps_all = cellfun(@(x,y) x(2:end)-y(1:end-1),seqons_all,seqoffs_all,'un',0);
        durs_all = max(cell2mat(cellfun(@(x) [x NaN(1,max(replength{nrep})-length(x))],durs_all,'un',0)'));
        gaps_all = max(cell2mat(cellfun(@(x) [x NaN(1,max(replength{nrep})-1-length(x))],gaps_all,'un',0)'));
        
        %compute PSTH aligned to each syllable 
        for repid = 1:max(replength{nrep})
            %omit trials with length less than repid 
            ix = find(replength{nrep}>=repid);
            replength_corr = replength{nrep}(ix);
            seqons = seqons_all(ix);seqoffs = seqoffs_all(ix);
            
            %offsets for finding peaks and extracting spike times
            mndur = durs_all(repid);
            if repid ~= max(replength{nrep})
                buff = gaps_all(repid);%edges of syllables for burst detection 
            else
                buff = 5;
            end
            
            %align by onset
            pt = [0 mndur];
            anchor = cellfun(@(x) x(repid),seqons)';
            seqst = cellfun(@(x,y) x(repid)-y(1)+buff,seqons,seqons);
            seqend = cellfun(@(x,y) x(end)+buff-y(repid),seqoffs,seqons);
            [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,...
                seqst,seqend,anchor,win,ifr);
            
            %average pairwise trial by trial correlation
            tbid = find(tb>=pt(1) & tb<=pt(2));
            r = xcorr(smooth_spiketrains(:,tbid)',0,'coeff');
            r = reshape(r,[size(smooth_spiketrains,1) size(smooth_spiketrains,1)]);
            r = r(find(triu(r,1)));
            varfr = nanmean(r);
            
            %align by offset
            pt2 = [-mndur 0];
            anchor2 = cellfun(@(x) x(repid),seqoffs)';
            seqst2 = cellfun(@(x,y) x(repid)-y(1)-buff,seqoffs,seqons);
            seqend2 = cellfun(@(x,y) x(end)+buff-y(repid),seqoffs,seqoffs);
            [PSTH_mn2 tb2 smooth_spiketrains2 spktms2] = smoothtrain(spiketimes,...
                seqst2,seqend2,anchor2,win,ifr);
            
            %average pairwise trial by trial correlation
            tb2id = find(tb2>=pt2(1) & tb2<=pt2(2));
            r = xcorr(smooth_spiketrains2(:,tb2id)',0,'coeff');
            r = reshape(r,[size(smooth_spiketrains2,1) size(smooth_spiketrains2,1)]);
            r = r(find(triu(r,1)));
            varfr2 = nanmean(r);
            
            %decide to align by onset of offset
            if varfr<varfr2
                PSTH_mn = PSTH_mn2;tb = tb2; smooth_spiketrains = smooth_spiketrains2;
                spktms = spktms2; tbid = tb2id; anchor = anchor2;
                seqst = seqst2; seqend = seqend2;pt = pt2;
            end
            
            %shuffled spike train to detect peaks that are significantly
            %above shuffled activity
            if repid == 1
                smooth_spiketrains_rand = permute_rowel(smooth_spiketrains);
                PSTH_mn_rand = mean(smooth_spiketrains_rand,1).*1000;
            end
            
            %find peaks in PSTHs within 5 ms of syllable borders
            [pks, locs,w,~,wc] = findpeaks2(PSTH_mn,'MinPeakProminence',5,...
                'MinPeakWidth',10,'MinPeakDistance',20,'Annotate','extents',...
                'WidthReference','halfheight');
            pkid = find(tb(locs)>=pt(1)-5 & tb(locs)<=pt(2)+5);
            wc = round(wc);
            if isempty(pkid)
                continue
            end

            %plot raster and PSTH aligned to first syllable position (for
            %debugging)
            if strcmp(plotfig,'y') & repid == 1
                figure;hold on;
                subplot(2,1,1);hold on;
                plotraster2(replength_corr,spktms,seqons,seqoffs,max(seqst),...
                    max(seqend),anchor,ff(i).name,pct_error,repsylls{nrep});

                subplot(2,1,2);hold on;
                plotPSTH2(ceil(max(seqst)),ceil(max(seqend)),...
                    smooth_spiketrains,replength_corr);
            end
            
            %IFR or spike count in detected bursts
            if ~isempty(pkid) 
                totalFR = [];
            	for ixx = 1:length(pkid)
                    [burstst burstend] = peakborder(wc,pkid(ixx),locs,tb);
                    pkactivity = (pks(pkid(ixx))-mean(PSTH_mn_rand))/std(PSTH_mn_rand); 
                    if pkactivity < activitythresh
                        continue
                    end

                    %exclude bursts that only happen when repeat ends
                    classes = double(replength_corr>repid);%1 = continues, 0 = end
                    nostp = find(classes == 1);stp = find(classes == 0);
                    PSTH_nostp = mean(mean(smooth_spiketrains(nostp,burstst:burstend)).*1000);
                    if PSTH_nostp < mean(PSTH_mn_rand)
                        continue
                    end
                    
                    if ifr == 1
                        npks_burst = mean(smooth_spiketrains(:,burstst:burstend),2).*1000;
                    else
                        npks_burst = countspks(spktms,tb(burstst),tb(burstend));
                    end
                    totalFR = [totalFR npks_burst];
                    
                    %linear regression and rank sum for burst at target position ~
                    %length
                    [lintest lintest2] = regressburst(npks_burst,replength_corr,repid,...
                        minsampsize,shufftrials);
                    bursttable = [bursttable; table({unitid},{birdid},{repsylls{nrep}},...
                        repid,{replength_corr},{npks_burst},lintest,lintest2,'VariableNames',...
                        {'unitid','birdid','seqid','position','length','IFR','linear','linear2'})];

                    %plot raster and PSTH aligned to target syllable
                    %position with target burst for correlated cases
                    if lintest{2}<=0.05 
                        figure;subplot(3,1,3);hold on;
                        plotCORR(npks_burst,replength_corr,ifr);
                        subplot(3,1,1);hold on;
                        plotraster(replength_corr,spktms,tb(burstst),tb(burstend),seqons,seqoffs,...
                            ceil(max(seqst)),ceil(max(seqend)),anchor,ff(i).name,...
                            pct_error,repsylls{nrep},repid,lintest{1})
                        subplot(3,1,2);hold on;
                        plotPSTH(ceil(max(seqst)),ceil(max(seqend)),smooth_spiketrains,...
                            replength_corr,tb(burstst),tb(burstend),repid);
                    elseif lintest2{2} <=0.05
                        classes = double(replength_corr>repid);%1 = continues, 0 = end
                        figure;subplot(3,1,3);hold on;
                        plotBAR(npks_burst,classes,ifr);
                        subplot(3,1,1);hold on;
                        plotraster(replength_corr,spktms,tb(burstst),tb(burstend),seqons,seqoffs,...
                            ceil(max(seqst)),ceil(max(seqend)),anchor,ff(i).name,pct_error,...
                            repsylls{nrep},repid,lintest2{1})
                        subplot(3,1,2);hold on;
                        plotPSTH(ceil(max(seqst)),ceil(max(seqend)),smooth_spiketrains,...
                            replength_corr,tb(burstst),tb(burstend),repid);
                    end
                end
                
                if isempty(totalFR)
                    continue
                end
                totalFR = mat2cell(totalFR,ones(size(totalFR,1),1),size(totalFR,2));
                IFRposition(ix,repid) = totalFR;
            end
        end
        
       %filter out cases with no activity at any syllable positions 
        if isempty(find(cellfun(@(x) ~isempty(x),IFRposition)))
            continue
        end
        
        %cox regression with average FR, starting FR, and each burst FR
        if nargout >= 3 
            [avgFR,stFR,burstFR] = coxregress(IFRposition,replength{nrep},shufftrials);
            coxtable = [coxtable; table({unitid},{repsylls{nrep}},avgFR,{stFR},burstFR,'VariableNames',...
                {'unitid','seqid','averageFR','startFR','burstFR'})];
        end

        %data for mixed model, organized by syllable position 
        if nargout >= 2
            position = cell2mat(arrayfun(@(x) [1:x]',replength{nrep},'un',0)');
            unitid2 = repmat({unitid},length(position),1);
            birdid2 = repmat({birdid},length(position),1);
            seqid2 = repmat({repsylls{nrep}},length(position),1);
            renditionID = [1:length(replength{nrep})]';
            renditionID = cell2mat(arrayfun(@(x,y) repmat(x,y,1),renditionID,replength{nrep}','un',0));
            fr = cellfun(@(x) mean(x),IFRposition);
            fr = cell2mat(arrayfun(@(x,y) fr(x,1:y)',[1:size(fr,1)]',replength{nrep}','un',0));
            len = cell2mat(arrayfun(@(x) repmat(x,x,1),replength{nrep}','un',0));
            mmtable = [mmtable; table(unitid2,birdid2,seqid2,renditionID,...
                position,len,fr,'VariableNames',{'unitid','birdid','seqid','rendition','position','length','FR'})];
        end
    end
end

function [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,seqst,seqend,anchor,win,ifr);
    %extracts spike times in target window for each trial
    %smooth spike train to get PSTH
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
    %finds the beginning and end of target peak from findpeak2
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
    
function npks = countspks(spktms,tm1,tm2);
%extract num spikes in each trial
if length(tm1) == 1
    npks = cellfun(@(x) length(find(x>=tm1 & x<tm2)),spktms);
else
    npks = cellfun(@(x,y,z) length(find(x>=y & x<z)),spktms,tm1,tm2);
end
    
function [r p] = shuffle(npks_burst,dur_id_corr,shufftrials);
%shuffle test, permutes order of npks_burst shufftrialsx and correlates
%with dur_id_corr
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff);
    [r p] = corrcoef([npks_burst_shuff',dur_id_corr]);
    r = r(1:end-1,end);
    p = p(1:end-1,end);
    
function p = mnshuffle(npks_burst,classes,shufftrials);
%shuffle test, permutes order of npks_burst shufftrialsX and performs
%ranksum test
    stp = find(classes==0);
    nostp = find(classes==1);
    npks_burst_shuff = repmat(npks_burst',shufftrials,1);
    npks_burst_shuff = permute_rowel(npks_burst_shuff); %shuffles elements within each row
    p = NaN(1000,1);
    parfor rep = 1:shufftrials
        pval = ranksum(npks_burst_shuff(rep,stp),npks_burst_shuff(rep,nostp));
        p(rep) = pval;
    end
    
function [r p] = coxshuffle(averageFR,len,shufftrials);
%shuffle test, permutes order of averageFR shufftrialsX and performs cox
%regression
    averageFR_shuff = repmat(averageFR',shufftrials,1);
    averageFR_shuff = permute_rowel(averageFR_shuff);
    p = NaN(1000,1);r = NaN(1000,1);
    parfor rep = 1:shufftrials
        [b,~,~,stats] = coxphfit(averageFR_shuff(rep,:),len);
        p(rep) = stats.p;
        r(rep) = b;
    end
    
function plotraster(replen,spktms,tm1,tm2,seqons,seqoffs,...
    seqst,seqend,anchor,name,pct_error,seqid,position,corrval)
%plot spike times and syllable times for each rendition aligned to anchor
%highlights spikes in target burst designed by tm1 and tm2 
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
    title([unitid,' ',seqid,num2str(position),' r=',num2str(corrval),...
        ' unit=',num2str(singleunit)],'interpreter','none');
    xlabel('time (ms)');ylabel('trial');set(gca,'fontweight','bold');
    xlim([-seqst seqend]);ylim([0 cnt]);
    if length(replen) >= 20
        longid = length(replen)-9;
        shortid = replen(10);
    else
        longid = min(find(replen>position));
        shortid = max(find(replen<=position));
    end
    plot(-seqst,longid,'r>','markersize',4,'linewidth',2);hold on;
    plot(-seqst,shortid,'b>','markersize',4,'linewidth',2);hold on;

function plotraster2(replen,spktms,seqons,seqoffs,...
    seqst,seqend,anchor,name,pct_error,seqid)
%plots spike times and syllable times for each rendition aligned to anchor 
    cnt=0;
    for m = 1:length(replen)
        if ~isempty(spktms{m})
            plot(repmat(spktms{m},2,1),[cnt cnt+1],'k');hold on;
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
    title([unitid,' ',seqid,' unit=',num2str(singleunit)],'interpreter','none');
    xlabel('time (ms)');ylabel('trial');set(gca,'fontweight','bold');
    xlim([-seqst seqend]);ylim([0 cnt]);
        
function plotPSTH(seqst,seqend,smooth_spiketrains,replen,tm1,tm2,position);
%plots average PSTH as well as shortest and longest 10 renditions 
    if length(replen) >=20
        longid = length(replen)-9:length(replen);
        shortid = 1:10;
    else
        longid = (find(replen>position));
        shortid = (find(replen<=position));
    end
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
    
function plotPSTH2(seqst,seqend,smooth_spiketrains,replen);
%plots average PSTH
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains,1)-...
        stderr(smooth_spiketrains,1) fliplr(mean(smooth_spiketrains,1)+...
        stderr(smooth_spiketrains,1))])*1000,[0.8 0.8 0.8],'edgecolor','none','facealpha',0.7);
    yl = get(gca,'ylim');
    xlim([-seqst seqend]);                        
    xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');     
        
function plotCORR(npks_burst,replen,ifr);
%scatter plot and lsq line 
    scatter(npks_burst,replen,'k.');hold on;
    xlim([min(npks_burst)-1 max(npks_burst)+1]);lsline
    if ifr == 0
        xlabel('number of spikes');
    else
        xlabel('IFR');
    end
    ylabel('length');
    set(gca,'fontweight','bold');
    
function plotBAR(npks_burst,classes,ifr);
%bar plot 
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
    
function [lintest lintest2] = regressburst(npks_burst,replength_corr,repid,minsampsize,shufftrials);
    %regress with length
    if length(replength_corr) >= minsampsize
        [r1 p1] = corrcoef(npks_burst,replength_corr');
        [shuffr1 shuffp1] = shuffle(npks_burst,replength_corr',shufftrials);%shuffle test
        t = {r1(2) p1(2) shuffr1 shuffp1};
        lintest = {r1(2) p1(2) shuffr1 shuffp1};
    else
        lintest = {[],[],[],[]};
    end
    %regress with stop vs continue
    if sum(replength_corr==repid)>=2
        classes = double(replength_corr>repid);
        [r2 p2] = corrcoef(npks_burst,classes');
        [shuffr2 shuffp2] = shuffle(npks_burst,classes',shufftrials);%shuffle test
        lintest2 = {r2(2) p2(2) shuffr2 shuffp2};
    else
        lintest2 = {[],[],[],[]};
    end

function [avgFR,stFR,burstFR] = coxregress(IFRposition,len,shufftrials);
    %average FR of all bursts in repeat rendition
    averageFR = arrayfun(@(x) mean(cat(2,IFRposition{x,:})),1:size(IFRposition,1),'un',1)';
    if ~isempty(find(~isnan(averageFR)))
        [b,~,h,stats] = coxphfit(averageFR,len);
        [shuffb shuffp] = coxshuffle(averageFR,len,shufftrials);
        avgFR = {b h stats.p shuffb shuffp};
    else
        avgFR = {[],[],[],[],[]};
    end
    %starting FR at beginning of rendition 
    startFR = NaN(length(len),size(cat(1,IFRposition{:,1}),2));
    ind = find(~cellfun(@isempty,IFRposition(:,1)));
    startFR(ind,:) = cat(1,IFRposition{:,1});
    if ~isempty(startFR)
        numstartbursts = size(cat(1,IFRposition{:,1}),2);
        stFR = {};
        for n = 1:numstartbursts
            [b,~,h,stats] = coxphfit(startFR(:,n),len);
            [shuffb shuffp] = coxshuffle(startFR(:,n),len,shufftrials);
            stFR = [stFR; {b h stats.p shuffb shuffp}];
        end
    else
        stFR = {[],[],[],[],[]};
    end
    %burst FR at each position
    ttimes = [cell2mat(arrayfun(@(x) [0:x-1]',len,'un',0)') ...
        cell2mat(arrayfun(@(x) [1:x]',len,'un',0)')];
    fr = cellfun(@(x) mean(x),IFRposition);
    fr = cell2mat(arrayfun(@(x,y) fr(x,1:y)',[1:size(fr,1)]',len','un',0));
    [b,~,h,stats] = coxphfit(fr,ttimes);
    [shuffb shuffp] = coxshuffle(fr,ttimes,shufftrials);
    burstFR = {b h stats.p shuffb shuffp};