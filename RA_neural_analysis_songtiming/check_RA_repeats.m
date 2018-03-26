function check_RA_repeats()
ifr = 1;
win = gausswin(20);%for smoothing spike trains, 20 ms
win = win./sum(win);

ff = load_batchf('batchfile');
for i = 16:23
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms
    labels = lower(labels);
    
    %identify variable repeats
    syllables = unique(labels);
    repsylls = {};onind = {};offind = {};replength = {};
    for nsyll = 1:length(syllables)
        p = ismember(labels,syllables(nsyll));
        kk = [find(diff([-1 p -1])~=0)];
        runlength = diff(kk);
        runlength = runlength(1+(p(1)==0):2:end);
        if cv(runlength') >= 0.2 & length(runlength) >= 25 & max(runlength) > 2
            repsylls = [repsylls,syllables(nsyll)];
            pp = find(diff([0 p])==1);
            onind = [onind pp];%start index for each repeat run
            offind = [offind pp+runlength-1];%end index for each repeat run
            replength = [replength runlength];
        end
    end
    
    %remove non-letter labels and intronotes and 'x's
    introind = [find(cellfun(@(x) ~isempty(strfind(x,'i')),repsylls))...
        find(cellfun(@(x) ~isempty(strfind(x,'x')),repsylls))];
    repsylls(introind) = [];onind(introind) = [];offind(introind) = [];
    replength(introind) = [];
    keepid = find(cellfun(@(x) isletter(x),repsylls));
    repsylls = repsylls(keepid); onind = onind(keepid);offind = offind(keepid);
    replength = replength(keepid);
    
    if isempty(repsylls)
        continue
    end
    
    %for a repeat, separate if preceded by multiple different syllables 
    repsylls2 = {};onind2 = {};offind2 = {};replength2 = {};
    for nrep = 1:length(repsylls)
        if onind{nrep}(1) == 1
            onind{nrep}(1) = [];replength{nrep}(1) = [];offind{nrep}(1) = [];
        end
        presylls = arrayfun(@(x) labels(x-1),onind{nrep});
        prf = unique(presylls);
        for px = 1:length(prf)
            id = strfind(presylls,prf(px));
            if length(id) >= 25
                repsylls2 = [repsylls2 [prf(px),repsylls{nrep}]];
                onind2 = [onind2 onind{nrep}(id)];
                offind2 = [offind2 offind{nrep}(id)];
                replength2 = [replength2 replength{nrep}(id)];
            end
        end
    end
    repsylls = repsylls2; onind = onind2; offind = offind2; replength = replength2;       
    
    %test again variability of repeats after controlling for presyllable
    removeid = unique([find(cellfun(@(x) cv(x'),replength)< 0.2)...
        find(cellfun(@length,replength) < 25)...
        find(cellfun(@(x) length(find(x>1)),replength) < 10)...
        find(cellfun(@(x) max(x),replength)<=2)]);
    repsylls(removeid) = [];onind(removeid) = []; offind(removeid) = []; replength(removeid) = [];
    if isempty(repsylls)
        continue
    end

    for nrep = 1:length(repsylls) 
        if length(replength{nrep}) < 25
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
        
        repid = 2;
        ix = find(replength{nrep}+1>=repid);
        replength_corr = replength{nrep}(ix);
        seqons = seqons_all(ix);seqoffs = seqoffs_all(ix);

        %align by onset
        mngap = 0;
        rependbuff = mngap;%ms 
        anchor = cellfun(@(x) x(repid),seqons)';
        seqst = cellfun(@(x,y) x(repid)-y(1),seqons,seqons);
        seqend = cellfun(@(x,y) x(end)+rependbuff-y(repid),seqoffs,seqons);
        [PSTH_mn tb smooth_spiketrains spktms] = smoothtrain(spiketimes,seqst,seqend,anchor,win,ifr);

        figure;subplot(2,1,1);hold on;
        plotraster(replength_corr,spktms,[],[],...
            seqons,seqoffs,max(seqst),max(seqend),anchor,...
            ff(i).name,pct_error,repsylls{nrep},repid);

        subplot(2,1,2);hold on;
        plotPSTH(ceil(max(seqst)),ceil(max(seqend)),...
            smooth_spiketrains,replength_corr,[],[]);
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
    
function plotraster(replen,spktms,tm1,tm2,seqons,seqoffs,...
    seqst,seqend,anchor,name,pct_error,seqid,position)
    short = 10;long = length(replen)-9;
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
                plot(repmat(spktms_inburst{m},2,1),[cnt cnt+1],'g');hold on;
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
    title([unitid,' ',seqid,num2str(position),' unit=',num2str(singleunit)],'interpreter','none');
    xlabel('time (ms)');ylabel('trial');set(gca,'fontweight','bold');
    xlim([-seqst seqend]);ylim([0 cnt]);
    plot(-seqst,long,'r>','markersize',4,'linewidth',2);hold on;
    plot(-seqst,short,'b>','markersize',4,'linewidth',2);hold on;
        
function plotPSTH(seqst,seqend,smooth_spiketrains,replen,tm1,tm2)
    short = 10;long = length(replen)-9;
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(long:end,:),1)-...
        stderr(smooth_spiketrains(long:end,:),1)...
        fliplr(mean(smooth_spiketrains(long:end,:),1)+...
        stderr(smooth_spiketrains(long:end,:),1))])*1000,[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
    patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(1:short,:),1)-...
        stderr(smooth_spiketrains(1:short,:),1)...
        fliplr(mean(smooth_spiketrains(1:short,:),1)+...
        stderr(smooth_spiketrains(1:short,:),1))])*1000,[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
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

    
        
        