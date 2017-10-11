config;

%% premotor nspikes before gapdur, correlation 
ff = load_batchf('batchfile');
birdid = arrayfun(@(x) x.birdname,params,'unif',0);
spk_gapdur_corr = [];
spk_gapdur = {};
cnt = 0;
for i = 1:length(ff)
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms
    ind = find(cellfun(@(x) strcmp(x,birdname),birdid));
    gapids = params(ind).gapid;
    gapdurs_all = onsets(2:end)-offsets(1:end-1);
    for n = 1:length(gapids)
        idx = strfind(labels,gapids(n));
        if isempty(idx)
            continue
        end
        sylloff = offsets(idx);
        if length(sylloff) < 20
            continue
        end
        nspks = NaN(length(sylloff),1);mean_pos_corr
        for m = 1:length(sylloff)
            nspks(m) = length(find(spiketimes>=(sylloff(m)-40) & ...
                spiketimes<=(sylloff(m)+10)));
        end
        if mean(nspks)/0.05 < 50
            continue
        else
            cnt=cnt+1;
            gapdur_id = jc_removeoutliers(gapdurs_all(idx),3);
            spk_gapdur = [spk_gapdur; {nspks gapdur_id}];
            [r p] = corrcoef(nspks,gapdur_id,'rows','complete');
            spk_gapdur_corr = [spk_gapdur_corr; r(2) p(2)];
            if mod(cnt,16) == 1
                figure;hold on;
            end
            if mod(cnt,16) == 0
                subplot(4,4,16);hold on;
            else
                subplot(4,4,mod(cnt,16));hold on;
            end
            plot(nspks,gapdur_id,'k.');
        end
    end
end
            
total_cases_gaps = length(spk_gapdur_corr);
ind_gap = find(spk_gapdur_corr(:,2)<=0.05);
prop_significant_cases_gaps = length(ind_gap)/total_cases_gaps;
figure;[n b] = hist(spk_gapdur_corr(ind_gap,1),[-1:0.1:1]);stairs(b,n/sum(n),'k')
significant_spk_gapdur_corr = spk_gapdur_corr(ind_gap,:);
id_gapneg = find(significant_spk_gapdur_corr(:,1) < 0);
mean_neg_corr = mean(significant_spk_gapdur_corr(id_gapneg,1));
id_gappos = find(significant_spk_gapdur_corr(:,1) > 0);
mean_pos_corr = mean(significant_spk_gapdur_corr(id_gappos,1));
%% shuffled data

ntrials = 1000;
prop_significant_cases_random = NaN(ntrials,1);
for rep = 1:ntrials
    spk_gapdur_corr_random = [];
    for i = 1:length(ff)
        load(ff(i).name);
        spiketimes = spiketimes*1000;%ms
        ind = find(cellfun(@(x) strcmp(x,birdname),birdid));
        gapids = params(ind).gapid;
        gapdurs_all = onsets(2:end)-offsets(1:end-1);
        for n = 1:length(gapids)
            idx = strfind(labels,gapids(n));
            if isempty(idx)
                continue
            end
            sylloff = offsets(idx);
            if length(sylloff) < 20
                continue
            end
            nspks = NaN(length(sylloff),1);
            for m = 1:length(sylloff)
                nspks(m) = length(find(spiketimes>=(sylloff(m)-40) & ...
                    spiketimes<=(sylloff(m)+10)));
            end
            if mean(nspks)/0.05 < 50
                continue
            else
                gapdur_id = jc_removeoutliers(gapdurs_all(idx),3);
                nspks_rand = nspks(randperm(length(nspks),length(nspks)));
                [r p] = corrcoef(nspks_rand,gapdur_id,'rows','complete');
                spk_gapdur_corr_random = [spk_gapdur_corr_random; r(2) p(2)];
            end
        end
    end
    total_randcases = length(spk_gapdur_corr_random);
    ind = find(spk_gapdur_corr_random(:,2)<=0.05);
    prop_significant_randcases = length(ind)/total_randcases;
    prop_significant_cases_random(rep) = prop_significant_randcases;
    disp(['trial ',num2str(rep));
end

prop_significant_cases_random = sort(prop_significant_cases_random);
hi = prop_significant_cases_random(950)
lo = prop_significant_cases_random(50)

%% premotor nspikes before sylldur, correlation 

ff = load_batchf('batchfile');
birdid = arrayfun(@(x) x.birdname,params,'unif',0);
spk_dur_corr = [];
spk_dur = {};
cnt = 0;
for i = 1:length(ff)
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms
    ind = find(cellfun(@(x) strcmp(x,birdname),birdid));
    gapids = params(ind).gapid;
    durs_all = offsets-onsets;
    for n = 1:length(gapids)
        idx = strfind(labels,gapids(n));
        if isempty(idx)
            continue
        end
        syllon = onsets(idx+1);
        if length(syllon) < 20
            continue
        end
        nspks = NaN(length(syllon),1);
        for m = 1:length(syllon)
            nspks(m) = length(find(spiketimes>=(syllon(m)-40) & ...
                spiketimes<=(syllon(m)+10)));
        end
        if mean(nspks)/0.05 < 50
            continue
        else
            cnt=cnt+1;
            dur_id = jc_removeoutliers(durs_all(idx+1),3);
            spk_dur = [spk_dur; {nspks dur_id}];
            [r p] = corrcoef(nspks,dur_id,'rows','complete');
            spk_dur_corr = [spk_dur_corr; r(2) p(2)];
            if mod(cnt,16) == 1
                figure;hold on;
            end
            if mod(cnt,16) == 0
                subplot(4,4,16);hold on;
            else
                subplot(4,4,mod(cnt,16));hold on;
            end
            plot(nspks,dur_id,'k.');
        end
    end
end
            
total_cases_durs = length(spk_dur_corr);
ind_dur = find(spk_dur_corr(:,2)<=0.05);
prop_significant_cases_durs = length(ind_dur)/total_cases_durs;
figure;figure;[n b] = hist(spk_dur_corr(ind_dur,1),[-1:0.1:1]);stairs(b,n/sum(n),'k')
significant_spk_dur_corr = spk_dur_corr(ind_dur,:);
id_durneg = find(significant_spk_dur_corr(:,1) < 0);
mean_neg_corr = mean(significant_spk_dur_corr(id_durneg,1));
id_durpos = find(significant_spk_dur_corr(:,1) > 0);
mean_pos_corr = mean(significant_spk_dur_corr(id_durpos,1));

%% test proportion of significant cases for gaps vs sylls

%observed data
n1 = length(ind_gap); N1 = total_cases_gaps;
n2 = length(ind_dur); N2 = total_cases_durs;
p0 = (n1+n2)/(N1+N2);
n10 = N1*p0;
n20 = N2*p0;
observed = [n1 N1-n1 n2 N2-n2];
expected = [n10 N1-n10 n20 N2-n20];
chi2stat = sum((observed-expected).^2./expected);
disp(['prop of significant cases for gaps:',num2str(n1/N1)])
disp(['prop of significant cases for durs:',num2str(n2/N2)])
p = 1-chi2cdf(chi2stat,1)

%% test proportion of significant cases that are negative vs positive for gaps
n1 = length(id_gapneg); N1 = length(significant_spk_gapdur_corr);%neg
n2 = length(id_gappos); N2 = length(significant_spk_gapdur_corr);%pos
p0 = (n1+n2)/(N1+N2);
n10 = N1*p0;
n20 = N2*p0;
observed = [n1 N1-n1 n2 N2-n2];
expected = [n10 N1-n10 n20 N2-n20];
chi2stat = sum((observed-expected).^2./expected);
disp(['prop of significant neg corr cases for gaps:',num2str(n1/N1)])
disp(['prop of significant pos corr cases for gaps:',num2str(n2/N2)])
p = 1-chi2cdf(chi2stat,1)

%% test proportion of significant cases that are negative vs positive for durs
n1 = length(id_durneg); N1 = length(significant_spk_dur_corr);%neg
n2 = length(id_durpos); N2 = length(significant_spk_dur_corr);%pos
p0 = (n1+n2)/(N1+N2);
n10 = N1*p0;
n20 = N2*p0;
observed = [n1 N1-n1 n2 N2-n2];
expected = [n10 N1-n10 n20 N2-n20];
chi2stat = sum((observed-expected).^2./expected);
disp(['prop of significant neg corr cases for durs:',num2str(n1/N1)])
disp(['prop of significant pos corr cases for durs:',num2str(n2/N2)])
p = 1-chi2cdf(chi2stat,1)

%% 
%1) determine if activity is just drifting in time with gapdur or really
%trial by trial
%2) use sliding premotor window to determine which time window is most
%correlated
%3) determine if neuron is correlated to gapdur in one context, what is the
%sign and correlation with other gaps/syllables/syllable-pitch
%4) how much is it driven by repeats? can you predict repeat length? 
%5) can you predict "meta-bout" length? activity run-down
%6) bout pattern in pitch

