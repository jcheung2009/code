%using summary data from Sam and Mel's RA recordings 

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
        nspks = NaN(length(sylloff),1);
        for m = 1:length(sylloff)
            nspks(m) = length(find(spiketimes>=(sylloff(m)-40) & ...
                spiketimes<=(sylloff(m)+10)));
        end
        if mean(nspks)/0.05 < 50
            continue
        else
            cnt=cnt+1;
            gapdur_id = jc_removeoutliers(gapdurs_all(idx),3);
            gapdur_id = jc_removeoutliers(gapdur_id,3);
            spk_gapdur = [spk_gapdur; [nspks gapdur_id]];
            [r p] = corrcoef(nspks,gapdur_id,'rows','complete');
            spk_gapdur_corr = [spk_gapdur_corr; r(2) p(2)];
            if mod(cnt,36) == 1
                figure;hold on;
            end
            if mod(cnt,36) == 0
                subplot(6,6,36);hold on;
            else
                subplot(6,6,mod(cnt,36));hold on;
            end
            plot(nspks,gapdur_id,'k.');
            xlim([-1 max(nspks)+1]);
            if p(2)<=0.05
                box on;ax = gca; ax.LineWidth=4;ax.XColor='r';ax.YColor='r';ax.ZColor='r';
            end
        end
    end
end
            
total_cases_gaps = length(spk_gapdur_corr);
ind_gap = find(spk_gapdur_corr(:,2)<=0.05);
prop_significant_cases_gaps = length(ind_gap)/total_cases_gaps;
significant_spk_gapdur_corr = spk_gapdur_corr(ind_gap,:);
id_gapneg = find(significant_spk_gapdur_corr(:,1) < 0);
mean_neg_corr = mean(significant_spk_gapdur_corr(id_gapneg,1));
id_gappos = find(significant_spk_gapdur_corr(:,1) > 0);
mean_pos_corr = mean(significant_spk_gapdur_corr(id_gappos,1));
figure;[n b] = hist(spk_gapdur_corr(ind_gap,1),[-1:0.1:1]);
stairs(b,n/sum(n),'k','linewidth',2);hold on;y = get(gca,'ylim');
plot(mean_neg_corr,y(1),'b^','markersize',8);hold on;plot(mean_pos_corr,y(1),'r^','markersize',8);
title('r values for significant RA activity vs gap duration correlations');
xlabel('correlation coefficient');ylabel('probability');set(gca,'fontweight','bold');
text(0,1,{['total active units:',num2str(total_cases_gaps)];...
    ['proportion significant:',num2str(prop_significant_cases_gaps)];...
    ['proportion negative:',num2str(length(id_gapneg)/length(ind_gap))];...
    ['proportion positive:',num2str(length(id_gappos)/length(ind_gap))]},'units','normalized',...
    'verticalalignment','top');

% disp(['total gap cases with premotor activity: ',num2str(total_cases_gaps)]);
% disp(['proportion of significant gap correlations: ',num2str(prop_significant_cases_gaps)]);
% disp(['proportion of negative gap correlations: ',num2str(length(id_gapneg)/length(ind_gap))]);
% disp(['proportion of positive gap correlations: ',num2str(length(id_gappos)/length(ind_gap))]);
% disp(['average r value for negative correlations: ',num2str(mean_neg_corr)]);
% disp(['average r value for positive correlations: ',num2str(mean_pos_corr)]);

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
    disp(['trial ',num2str(rep)]);
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
            dur_id = jc_removeoutliers(dur_id,3);
            spk_dur = [spk_dur; [nspks dur_id]];
            [r p] = corrcoef(nspks,dur_id,'rows','complete');
            spk_dur_corr = [spk_dur_corr; r(2) p(2)];
            if mod(cnt,36) == 1
                figure;hold on;
            end
            if mod(cnt,36) == 0
                subplot(6,6,36);hold on;
            else
                subplot(6,6,mod(cnt,36));hold on;
            end
            plot(nspks,dur_id,'k.');
            xlim([-1 max(nspks)+1]);
            if p(2)<=0.05
                box on;ax = gca; ax.LineWidth=4;ax.XColor='r';ax.YColor='r';ax.ZColor='r';
            end
        end
    end
end
            
total_cases_durs = length(spk_dur_corr);
ind_dur = find(spk_dur_corr(:,2)<=0.05);
prop_significant_cases_durs = length(ind_dur)/total_cases_durs;
significant_spk_dur_corr = spk_dur_corr(ind_dur,:);
id_durneg = find(significant_spk_dur_corr(:,1) < 0);
mean_neg_corr = mean(significant_spk_dur_corr(id_durneg,1));
id_durpos = find(significant_spk_dur_corr(:,1) > 0);
mean_pos_corr = mean(significant_spk_dur_corr(id_durpos,1));
figure;[n b] = hist(spk_dur_corr(ind_dur,1),[-1:0.1:1]);
stairs(b,n/sum(n),'k','linewidth',2);hold on;y = get(gca,'ylim');
plot(mean_neg_corr,y(1),'b^','markersize',8);hold on;plot(mean_pos_corr,y(1),'r^','markersize',8);
title('r values for significant RA activity vs duration correlations');
xlabel('correlation coefficient');ylabel('probability');set(gca,'fontweight','bold');
text(0,1,{['total active units:',num2str(total_cases_durs)];...
    ['proportion significant:',num2str(prop_significant_cases_durs)];...
    ['proportion negative:',num2str(length(id_durneg)/length(ind_dur))];...
    ['proportion positive:',num2str(length(id_durpos)/length(ind_dur))]},'units','normalized',...
    'verticalalignment','top');

disp(['total dur cases with premotor activity: ',num2str(total_cases_durs)]);
disp(['proportion of significant gap correlations: ',num2str(prop_significant_cases_durs)]);
disp(['proportion of negative gap correlations: ',num2str(length(id_durneg)/length(ind_dur))]);
disp(['proportion of positive gap correlations: ',num2str(length(id_durpos)/length(ind_dur))]);
disp(['average r value for negative correlations: ',num2str(mean_neg_corr)]);
disp(['average r value for positive correlations: ',num2str(mean_pos_corr)]);

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

%% determine if activity is just drifting in time with gapdur

%significant negatively correlated cases
spk_gapdur_significant = spk_gapdur(ind_gap);
acov_spk_gapdur_neg = {};
for i = 1:length(id_gapneg)
    dat = spk_gapdur_significant{id_gapneg(i)};
    idx = find(isnan(dat(:,2)));
    dat(idx,:) = [];
    [c lag] = xcov(dat(:,1),dat(:,2),'coeff');
    acov_spk_gapdur_neg{i} = c(ceil(length(c)/2):end);
end
maxlength = max(cellfun(@length,acov_spk_gapdur_neg));
acov_spk_gapdur_neg = cellfun(@(x) [x;NaN(maxlength-length(x),1)],acov_spk_gapdur_neg,'unif',0);
acov_spk_gapdur_neg = cell2mat(acov_spk_gapdur_neg);
figure;plot(nanmean(acov_spk_gapdur_neg,2),'b','linewidth',2);hold on;
plot(nanmean(acov_spk_gapdur_neg,2)+nanstderr(acov_spk_gapdur_neg,2),'b');hold on;
plot(nanmean(acov_spk_gapdur_neg,2)-nanstderr(acov_spk_gapdur_neg,2),'b');hold on;
xlabel('lag (trial)');ylabel('correlation');title('activity vs gap duration (negative)');

nrep = 1000;
averagerand_acov_spk_gapdur = {};
for n = 1:nrep
    acov_spk_gapdur_negrand = {};
    for i = 1:length(id_gapneg)
        dat = spk_gapdur_significant{id_gapneg(i)};
        idx = find(isnan(dat(:,2)));
        dat(idx,:) = [];
        randdat = [dat(randperm(length(dat),length(dat)),1),dat(:,2)];
        [c lag] = xcov(randdat(:,1),randdat(:,2),'coeff');
        acov_spk_gapdur_negrand{i} = c(ceil(length(c)/2):end);
    end
    maxlength = max(cellfun(@length,acov_spk_gapdur_negrand));
    acov_spk_gapdur_negrand = cellfun(@(x) [x;NaN(maxlength-length(x),1)],acov_spk_gapdur_negrand,'unif',0);
    acov_spk_gapdur_negrand = cell2mat(acov_spk_gapdur_negrand);
    averagerand_acov_spk_gapdur{n} = nanmean(acov_spk_gapdur_negrand,2);
end
averagerand_acov_spk_gapdur = cell2mat(averagerand_acov_spk_gapdur);
averagerand_acov_spk_gapdur = sort(averagerand_acov_spk_gapdur,2);
plot(averagerand_acov_spk_gapdur(:,50),'r','linewidth',2);hold on;
plot(averagerand_acov_spk_gapdur(:,950),'r','linewidth',2);hold on;
xlim([0 100]);
set(gca,'fontweight','bold');

%significant positively correlated cases
spk_gapdur_significant = spk_gapdur(ind_gap);
acov_spk_gapdur_pos = {};
for i = 1:length(id_gappos)
    dat = spk_gapdur_significant{id_gappos(i)};
    idx = find(isnan(dat(:,2)));
    dat(idx,:) = [];
    [c lag] = xcov(dat(:,1),dat(:,2),'coeff');
    acov_spk_gapdur_pos{i} = c(ceil(length(c)/2):end);
end
maxlength = max(cellfun(@length,acov_spk_gapdur_pos));
acov_spk_gapdur_pos = cellfun(@(x) [x;NaN(maxlength-length(x),1)],acov_spk_gapdur_pos,'unif',0);
acov_spk_gapdur_pos = cell2mat(acov_spk_gapdur_pos);
figure;plot(nanmean(acov_spk_gapdur_pos,2),'b','linewidth',2);hold on;
plot(nanmean(acov_spk_gapdur_pos,2)+nanstderr(acov_spk_gapdur_pos,2),'b');hold on;
plot(nanmean(acov_spk_gapdur_pos,2)-nanstderr(acov_spk_gapdur_pos,2),'b');hold on;
xlabel('lag (trial)');ylabel('correlation');title('activity vs gap duration (positive)');

nrep = 1000;
averagerand_acov_spk_gapdur = {};
for n = 1:nrep
    acov_spk_gapdur_posrand = {};
    for i = 1:length(id_gappos)
        dat = spk_gapdur_significant{id_gappos(i)};
        idx = find(isnan(dat(:,2)));
        dat(idx,:) = [];
        randdat = [dat(randperm(length(dat),length(dat)),1),dat(:,2)];
        [c lag] = xcov(randdat(:,1),randdat(:,2),'coeff');
        acov_spk_gapdur_posrand{i} = c(ceil(length(c)/2):end);
    end
    maxlength = max(cellfun(@length,acov_spk_gapdur_posrand));
    acov_spk_gapdur_posrand = cellfun(@(x) [x;NaN(maxlength-length(x),1)],acov_spk_gapdur_posrand,'unif',0);
    acov_spk_gapdur_posrand = cell2mat(acov_spk_gapdur_posrand);
    averagerand_acov_spk_gapdur{n} = nanmean(acov_spk_gapdur_posrand,2);
end
averagerand_acov_spk_gapdur = cell2mat(averagerand_acov_spk_gapdur);
averagerand_acov_spk_gapdur = sort(averagerand_acov_spk_gapdur,2);
plot(averagerand_acov_spk_gapdur(:,50),'r','linewidth',2);hold on;
plot(averagerand_acov_spk_gapdur(:,950),'r','linewidth',2);hold on;
xlim([0 100]);
set(gca,'fontweight','bold');
   
%% determine if activity is just drifting in time with dur

%significant negatively correlated cases
spk_dur_significant = spk_dur(ind_dur);
acov_spk_dur_neg = {};
for i = 1:length(id_durneg)
    dat = spk_dur_significant{id_durneg(i)};
    idx = find(isnan(dat(:,2)));
    dat(idx,:) = [];
    [c lag] = xcov(dat(:,1),dat(:,2),'coeff');
    acov_spk_dur_neg{i} = c(ceil(length(c)/2):end);
end
maxlength = max(cellfun(@length,acov_spk_dur_neg));
acov_spk_dur_neg = cellfun(@(x) [x;NaN(maxlength-length(x),1)],acov_spk_dur_neg,'unif',0);
acov_spk_dur_neg = cell2mat(acov_spk_dur_neg);
figure;plot(nanmean(acov_spk_dur_neg,2),'b','linewidth',2);hold on;
plot(nanmean(acov_spk_dur_neg,2)+nanstderr(acov_spk_dur_neg,2),'b');hold on;
plot(nanmean(acov_spk_dur_neg,2)-nanstderr(acov_spk_dur_neg,2),'b');hold on;
xlabel('lag (trial)');ylabel('correlation');title('activity vs duration (negative)');

nrep = 1000;
averagerand_acov_spk_dur = {};
for n = 1:nrep
    acov_spk_dur_negrand = {};
    for i = 1:length(id_durneg)
        dat = spk_dur_significant{id_durneg(i)};
        idx = find(isnan(dat(:,2)));
        dat(idx,:) = [];
        randdat = [dat(randperm(length(dat),length(dat)),1),dat(:,2)];
        [c lag] = xcov(randdat(:,1),randdat(:,2),'coeff');
        acov_spk_dur_negrand{i} = c(ceil(length(c)/2):end);
    end
    maxlength = max(cellfun(@length,acov_spk_dur_negrand));
    acov_spk_dur_negrand = cellfun(@(x) [x;NaN(maxlength-length(x),1)],acov_spk_dur_negrand,'unif',0);
    acov_spk_dur_negrand = cell2mat(acov_spk_dur_negrand);
    averagerand_acov_spk_dur{n} = nanmean(acov_spk_dur_negrand,2);
end
averagerand_acov_spk_dur = cell2mat(averagerand_acov_spk_dur);
averagerand_acov_spk_dur = sort(averagerand_acov_spk_dur,2);
plot(averagerand_acov_spk_dur(:,50),'r','linewidth',2);hold on;
plot(averagerand_acov_spk_dur(:,950),'r','linewidth',2);hold on;
xlim([0 100]);
set(gca,'fontweight','bold');

%significant positively correlated cases
spk_dur_significant = spk_dur(ind_dur);
acov_spk_dur_pos = {};
for i = 1:length(id_durpos)
    dat = spk_dur_significant{id_durpos(i)};
    idx = find(isnan(dat(:,2)));
    dat(idx,:) = [];
    [c lag] = xcov(dat(:,1),dat(:,2),'coeff');
    acov_spk_dur_pos{i} = c(ceil(length(c)/2):end);
end
maxlength = max(cellfun(@length,acov_spk_dur_pos));
acov_spk_dur_pos = cellfun(@(x) [x;NaN(maxlength-length(x),1)],acov_spk_dur_pos,'unif',0);
acov_spk_dur_pos = cell2mat(acov_spk_dur_pos);
figure;plot(nanmean(acov_spk_dur_pos,2),'b','linewidth',2);hold on;
plot(nanmean(acov_spk_dur_pos,2)+nanstderr(acov_spk_dur_pos,2),'b');hold on;
plot(nanmean(acov_spk_dur_pos,2)-nanstderr(acov_spk_dur_pos,2),'b');hold on;
xlabel('lag (trial)');ylabel('correlation');title('activity vs duration (positive)');

nrep = 1000;
averagerand_acov_spk_dur = {};
for n = 1:nrep
    acov_spk_dur_posrand = {};
    for i = 1:length(id_durpos)
        dat = spk_dur_significant{id_durpos(i)};
        idx = find(isnan(dat(:,2)));
        dat(idx,:) = [];
        randdat = [dat(randperm(length(dat),length(dat)),1),dat(:,2)];
        [c lag] = xcov(randdat(:,1),randdat(:,2),'coeff');
        acov_spk_dur_posrand{i} = c(ceil(length(c)/2):end);
    end
    maxlength = max(cellfun(@length,acov_spk_dur_posrand));
    acov_spk_dur_posrand = cellfun(@(x) [x;NaN(maxlength-length(x),1)],acov_spk_dur_posrand,'unif',0);
    acov_spk_dur_posrand = cell2mat(acov_spk_dur_posrand);
    averagerand_acov_spk_dur{n} = nanmean(acov_spk_dur_posrand,2);
end
averagerand_acov_spk_dur = cell2mat(averagerand_acov_spk_dur);
averagerand_acov_spk_dur = sort(averagerand_acov_spk_dur,2);
plot(averagerand_acov_spk_dur(:,50),'r','linewidth',2);hold on;
plot(averagerand_acov_spk_dur(:,950),'r','linewidth',2);hold on;
xlim([0 100]);
set(gca,'fontweight','bold');
   
%% determine optimal premotor window that predicts gap duration

ff = load_batchf('batchfile');
birdid = arrayfun(@(x) x.birdname,params,'unif',0);

windowsize = 40;%ms
shift = 10;%ms
min_time_before = -250;
max_time_after = 250;
trials = [min_time_before:shift:max_time_after];
prop_significant_cases_lag_gaps = {};
for rep = 1:length(trials)
    case_outcome = [];
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
                nspks(m) = length(find(spiketimes>=(sylloff(m)+trials(rep)) & ...
                    spiketimes<=(sylloff(m)+trials(rep)+windowsize)));
            end
            if mean(nspks)/0.05 < 50
                continue
            else
                gapdur_id = jc_removeoutliers(gapdurs_all(idx),3);
                gapdur_id = jc_removeoutliers(gapdur_id,3);
                [r p] = corrcoef(nspks,gapdur_id,'rows','complete');
                case_outcome = [case_outcome;r(2) p(2)];
            end
        end
    end
    prop_significant_cases_lag_gaps{rep} = case_outcome;
end
[hi lo mn] = cellfun(@(x) mBootstrapCI(abs(x(:,1))),prop_significant_cases_lag_gaps);
mean_corr_lag_gaps = [mn' hi' lo'];
[hi lo mn] = cellfun(@(x) mBootstrapCI(abs(x(:,2))),prop_significant_cases_lag_gaps);
mean_pval_lag_gaps = [mn' hi' lo'];

% figure;hold on;subplot(2,1,1);hold on;
% for i = 1:length(trials)
%     plot(trials(i),abs(prop_significant_cases_lag_gaps{i}(:,1)),'k.');hold on;
% end
% plot(trials,mean_corr_lag_gaps(:,1),'color',[0.5 0.5 0.5],'linewidth',2,'marker','o','markersize',8);
% xlabel('time from syllable offset (ms)');ylabel('r value');
% title('correlation of activity vs gap');
% 
% 
% subplot(2,1,2);hold on;
% for i = 1:length(trials)
%     plot(trials(i),abs(prop_significant_cases_lag_gaps{i}(:,2)),'k.');hold on;
% end
% plot(trials,mean_pval_lag_gaps(:,1),'color',[0.5 0.5 0.5],'linewidth',2,'marker','o','markersize',8);
% xlabel('time from syllable onset (ms)');ylabel('p value');


%% determine optimal premotor window that predicts duration

ff = load_batchf('batchfile');
birdid = arrayfun(@(x) x.birdname,params,'unif',0);

windowsize = 40;%ms
shift = 10;%ms
min_time_before = -250;
max_time_after = 250;
trials = [min_time_before:shift:max_time_after];
prop_significant_cases_lag_durs = {};
for rep = 1:length(trials)
    case_outcome = [];
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
                nspks(m) = length(find(spiketimes>=(syllon(m)+trials(rep)) & ...
                    spiketimes<=(syllon(m)+trials(rep)+windowsize)));
            end
            if mean(nspks)/0.05 < 50
                continue
            else
                dur_id = jc_removeoutliers(durs_all(idx+1),3);
                dur_id = jc_removeoutliers(dur_id,3);
                [r p] = corrcoef(nspks,dur_id,'rows','complete');
                case_outcome = [case_outcome;r(2) p(2)];
            end
        end
    end
    prop_significant_cases_lag_durs{rep} = case_outcome;
end
[hi lo mn] = cellfun(@(x) mBootstrapCI(abs(x(:,1))),prop_significant_cases_lag_durs);
mean_corr_lag_durs = [mn' hi' lo'];
[hi lo mn] = cellfun(@(x) mBootstrapCI(abs(x(:,2))),prop_significant_cases_lag_durs);
mean_pval_lag_durs = [mn' hi' lo'];

% figure;hold on;subplot(2,1,1);hold on;
% for i = 1:length(trials)
%     plot(trials(i),abs(prop_significant_cases_lag_durs{i}(:,1)),'k.');hold on;
% end
% plot(trials,mean_corr_lag_durs(:,1),'color',[0.5 0.5 0.5],'linewidth',2,'marker','o','markersize',8);
% xlabel('time from syllable onset (ms)');ylabel('r value');
% title('correlation of activity vs duration');
% 
% subplot(2,1,2);hold on;
% for i = 1:length(trials)
%     plot(trials(i),abs(prop_significant_cases_lag_durs{i}(:,2)),'k.');hold on;
% end
% plot(trials,mean_pval_lag_durs(:,1),'color',[0.5 0.5 0.5],'linewidth',2,'marker','o','markersize',8);
% xlabel('time from syllable onset (ms)');ylabel('p value');


%% compare sliding premotor window between gaps and durs

figure;hold on;subplot(2,1,1);hold on;
plot(trials,mean_corr_lag_durs(:,1),'color',[0.5 0.5 0.5],'linewidth',2,'marker','o','markersize',8);hold on;
plot(trials,mean_corr_lag_durs(:,2),'color',[0.5 0.5 0.5],'linewidth',2);hold on;
plot(trials,mean_corr_lag_durs(:,3),'color',[0.5 0.5 0.5],'linewidth',2);hold on;
plot(trials,mean_corr_lag_gaps(:,1),'color',[0.7 0.3 0.3],'linewidth',2,'marker','o','markersize',8);hold on;
plot(trials,mean_corr_lag_gaps(:,2),'color',[0.7 0.3 0.3],'linewidth',2);hold on;
plot(trials,mean_corr_lag_gaps(:,3),'color',[0.7 0.3 0.3],'linewidth',2);hold on;
xlabel('time from syllable on/offset (ms)');ylabel('r value');
title('correlation of activity vs gap/dur');
set(gca,'fontweight','bold');
subplot(2,1,2);hold on;
plot(trials,mean_pval_lag_durs(:,1),'color',[0.5 0.5 0.5],'linewidth',2,'marker','o','markersize',8);hold on;
plot(trials,mean_pval_lag_durs(:,2),'color',[0.5 0.5 0.5],'linewidth',2);hold on;
plot(trials,mean_pval_lag_durs(:,3),'color',[0.5 0.5 0.5],'linewidth',2);hold on;
plot(trials,mean_pval_lag_gaps(:,1),'color',[0.7 0.3 0.3],'linewidth',2,'marker','o','markersize',8);hold on;
plot(trials,mean_pval_lag_gaps(:,2),'color',[0.7 0.3 0.3],'linewidth',2);hold on;
plot(trials,mean_pval_lag_gaps(:,3),'color',[0.7 0.3 0.3],'linewidth',2);hold on;
xlabel('time from syllable on/offset (ms)');ylabel('p value');
set(gca,'fontweight','bold');

%need to go back and control for one more syllable preceding gap and
%syllable 
%shuffled control?
%plot number of active units at each time bin 

%% determine sign of the relationship with other gaps/durations/pitch for each neuron
%NaN =  RA unit was not active
%0 = RA unit was not significantly correlated

ff = load_batchf('batchfile');
birdid = arrayfun(@(x) x.birdname,params,'unif',0);
behavior_correlation = struct();
for i = 1:length(ff)
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms
    ind = find(cellfun(@(x) strcmp(x,birdname),birdid));
    gapids = params(ind).gapid;
    gapdurs_all = onsets(2:end)-offsets(1:end-1);
    durs_all = offsets-onsets;
    gapcorr = [];durcorr = [];pitchcorr = [];
    for n = 1:length(gapids)
        idx = strfind(labels,gapids(n));
        if isempty(idx)
            continue
        end
        sylloff = offsets(idx);
        if length(sylloff) > 20
            nspks = NaN(length(sylloff),1);
            for m = 1:length(sylloff)
                nspks(m) = length(find(spiketimes>=(sylloff(m)-40) & ...
                    spiketimes<=(sylloff(m)+10)));
            end
            if mean(nspks)/0.05 > 50
                gapdur_id = jc_removeoutliers(gapdurs_all(idx),3);
                gapdur_id = jc_removeoutliers(gapdur_id,3);
                [r p] = corrcoef(nspks,gapdur_id,'rows','complete');
                if p(2) <= 0.05
                    gapcorr = [gapcorr r(2)];
                else
                    gapcorr = [gapcorr 0];
                end
            else
                gapcorr = [gapcorr NaN];
            end
        end
        syllon = onsets(idx+1);
        if length(syllon) > 20
            nspks = NaN(length(syllon),1);
            for m = 1:length(syllon)
                nspks(m) = length(find(spiketimes>=(syllon(m)-40) & ...
                    spiketimes<=(syllon(m)+10)));
            end
            if mean(nspks)/0.05 > 50
                dur_id = jc_removeoutliers(durs_all(idx+1),3);
                dur_id = jc_removeoutliers(dur_id,3);
                [r p] = corrcoef(nspks,dur_id,'rows','complete');
                if p(2) <= 0.05
                    durcorr = [durcorr r(2)];
                else
                    durcorr = [durcorr 0];
                end
                [r p] = corrcoef(nspks,peak_pinterp_labelvec(idx+1),'rows','complete');
                if p(2) <= 0.05
                    pitchcorr = [pitchcorr r(2)];
                else
                    pitchcorr = [pitchcorr 0];
                end
            else
                pitchcorr = [pitchcorr NaN];
                durcorr = [durcorr NaN];
            end
        end
    end
    behavior_correlation(i).birdname = birdname;
    behavior_correlation(i).gapcorr = gapcorr;
    behavior_correlation(i).durcorr = durcorr;
    behavior_correlation(i).pitchcorr = pitchcorr;
end

figure;hold on;subplot(1,3,1);hold on;
for i = 1:length(ff)
    numcases = length(behavior_correlation(i).gapcorr);
    plot(1:numcases,i,'ok','markersize',2);hold on;
    id = find(behavior_correlation(i).gapcorr > 0);
    if ~isempty(id)
        plot(id,i,'r.','markersize',10);hold on;
    end
    id = find(behavior_correlation(i).gapcorr < 0);
    if ~isempty(id)
        plot(id,i,'b.','markersize',10);hold on;
    end  
end
xlabel('gap ID');ylabel('unit');ylim([1 length(ff)]);set(gca,'fontweight','bold');

subplot(1,3,2);hold on;
for i = 1:length(ff)
    numcases = length(behavior_correlation(i).durcorr);
    plot(1:numcases,i,'ok','markersize',2);hold on;
    id = find(behavior_correlation(i).durcorr > 0);
    if ~isempty(id)
        plot(id,i,'r.','markersize',10);hold on;
    end
    id = find(behavior_correlation(i).durcorr < 0);
    if ~isempty(id)
        plot(id,i,'b.','markersize',10);hold on;
    end  
end
xlabel('dur ID');ylabel('unit');ylim([1 length(ff)]);set(gca,'fontweight','bold');

subplot(1,3,3);hold on;
for i = 1:length(ff)
    numcases = length(behavior_correlation(i).pitchcorr);
    plot(1:numcases,i,'ok','markersize',2);hold on;
    id = find(behavior_correlation(i).pitchcorr > 0);
    if ~isempty(id)
        plot(id,i,'r.','markersize',10);hold on;
    end
    id = find(behavior_correlation(i).pitchcorr < 0);
    if ~isempty(id)
        plot(id,i,'b.','markersize',10);hold on;
    end  
end
xlabel('dur ID');ylabel('unit');ylim([1 length(ff)]);set(gca,'fontweight','bold');
  
%quantify proportion neg/pos for each behavioral feature
%prop pitch correlated
%add volume

%% plot rasters for individual gaps with high significant correlation 
alignby = 'syllon2';%syllon1,sylloff1,syllon2
premotorwin = 'sylloff1';%sylloff1,syllon2
win = gausswin(20);%for smoothing spike trains
win = win./sum(win);
seqlen = 6;%4 = 2 syllables before and after target gap
rval_thr = 0.4;%threshold for correlation

ff = load_batchf('batchfile');
birdid = arrayfun(@(x) x.birdname,params,'unif',0);
for i = 1:length(ff)
    load(ff(i).name);
    spiketimes = spiketimes*1000;%ms

    %unique gap id
    N = length(labels);
    [a, ~, nn] = unique(labels(bsxfun(@plus,1:seqlen,(0:N-seqlen)')),'rows');
    cnts = sum(bsxfun(@(x,y)x==y,1:size(a,1),nn))';
    removeind = [];
    for ii = 1:size(a,1)
        if length(unique(a(ii,:)))==1 | sum(~isletter(a(ii,:))) > 0 %remove repeats and sequences with non-
            removeind = [removeind;ii];
        end
    end
    cnts(removeind) = [];a(removeind,:) = [];
    ind = find(cnts >= 25);%only sequences that occur more than 25 times 
    a = a(ind,:);cnts = cnts(ind);
    gapids = mat2cell(a,repmat(1,size(a,1),1))';
    gapdurs_all = onsets(2:end)-offsets(1:end-1);
    for n = 1:length(gapids)
        idx = strfind(labels,gapids(n));
        seqons = onsets(bsxfun(@plus, idx',(0:seqlen-1)));
        seqoffs = offsets(bsxfun(@plus,idx',(0:seqlen-1)));
        if strcmp(alignby,'sylloff1')
            seqst = floor(mean(seqoffs(:,seqlen/2)-seqons(:,1)));
            seqend = ceil(mean(seqoffs(:,end)-seqoffs(:,seqlen/2)));
        elseif strcmp(alignby,'syllon1')
            seqst = floor(mean(seqons(:,seqlen/2)-seqons(:,1)));
            seqend = ceil(mean(seqoffs(:,end)-seqons(:,seqlen/2)));
        elseif strcmp(alignby,'syllon2')
            seqst = floor(mean(seqons(:,seqlen/2+1)-seqons(:,1)));
            seqend = ceil(mean(seqoffs(:,end)-seqons(:,seqlen/2+1)));
        end
        
        nspks = NaN(size(seqons,1),1);%count spikes in premotor window before sylloff1
        for m = 1:size(seqons,1)
            if strcmp(premotorwin,'sylloff1')
                nspks(m) = length(find(spiketimes>=(seqoffs(m,seqlen/2)-40) & ...
                    spiketimes<=(seqoffs(m,seqlen/2)+10)));
            elseif strcmp(premotorwin,'syllon2')
                nspks(m) = length(find(spiketimes>=(seqons(m,seqlen/2+1)-40) & ...
                    spiketimes<=(seqons(m,seqlen/2+1)+10)));
            end 
        end
        if mean(nspks)/0.05 < 50
            continue
        else
            gapdur_id = jc_removeoutliers(gapdurs_all(idx+seqlen/2-1),3);
            gapdur_id = jc_removeoutliers(gapdur_id,3);
            [r p] = corrcoef(nspks,gapdur_id,'rows','complete');
            if p(2)<=0.05 & abs(r(2)) > 0.4
                 id = find(isnan(gapdur_id));
                 gapdur_id(id) = [];
                 seqons(id,:) = [];seqoffs(id,:) = [];
                 spktms = cell(size(seqons,1),1);
                 for m = 1:size(seqons,1)
                     if strcmp(alignby,'sylloff1')
                        x = spiketimes(find(spiketimes>=(seqoffs(m,seqlen/2)-seqst) & ...
                            spiketimes<=(seqoffs(m,seqlen/2)+seqend)));
                        spktms{m} = x - seqoffs(m,seqlen/2); 
                     elseif strcmp(alignby,'syllon1')
                        x = spiketimes(find(spiketimes>=(seqons(m,seqlen/2)-seqst) & ...
                            spiketimes<=(seqons(m,seqlen/2)+seqend)));
                        spktms{m} = x - seqons(m,seqlen/2); 
                     elseif strcmp(alignby,'syllon2')
                         x = spiketimes(find(spiketimes>=(seqons(m,seqlen/2+1)-seqst) & ...
                            spiketimes<=(seqons(m,seqlen/2+1)+seqend)));
                        spktms{m} = x - seqons(m,seqlen/2+1); 
                     end
                 end
                [~,ix] = sort(gapdur_id,'descend');%order trials by gapdur
                gapdur_id = gapdur_id(ix);
                spktms = spktms(ix);
                seqons = seqons(ix,:);
                seqoffs = seqoffs(ix,:);
                thr1 = quantile(gapdur_id,0.25);
                smallgaps_id = find(gapdur_id <= thr1);
                thr2 = quantile(gapdur_id,0.75);
                largegaps_id = find(gapdur_id >= thr2);
                
                figure;subplot(2,1,1);hold on;cnt=0;
                smooth_spiketrains = zeros(length(gapdur_id),seqst+seqend+1);
                for m = 1:length(gapdur_id)
                    plot(repmat(spktms{m},2,1),[cnt cnt+1],'k');hold on;
                    if strcmp(alignby,'sylloff1')
                        for syll=1:seqlen
                            patch([seqons(m,syll) seqoffs(m,syll) seqoffs(m,syll) seqons(m,syll)]-seqoffs(m,seqlen/2),...
                                 [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
                        end
                    elseif strcmp(alignby,'syllon1')
                        for syll=1:seqlen
                            patch([seqons(m,syll) seqoffs(m,syll) seqoffs(m,syll) seqons(m,syll)]-seqons(m,seqlen/2),...
                                 [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
                        end
                    elseif strcmp(alignby,'syllon2')
                        for syll=1:seqlen
                            patch([seqons(m,syll) seqoffs(m,syll) seqoffs(m,syll) seqons(m,syll)]-seqons(m,seqlen/2+1),...
                                 [cnt cnt cnt+1 cnt+1],[0.7 0.3 0.3],'edgecolor','none','facealpha',0.3);hold on;
                        end
                    end
                    cnt=cnt+1;
                    
                    temp = zeros(1,seqst+seqend+1);
                    spktimes = round(spktms{m})+seqst+1;
                    temp(spktimes) = 1;
                    smooth_spiketrains(m,:) = conv(temp,win,'same');
                end  
                
                [~,stid] = regexp(ff(i).name,'data_');
                enid = regexp(ff(i).name,'_TH');
                unitid = ff(i).name(stid+1:enid-1);
                xlim([-seqst seqend]);ylim([0 cnt]);xlabel('time (ms)');ylabel('trial');
                title([unitid,' ',gapids{n},' r=',num2str(r(2))],'interpreter','none');
                plot(-seqst,min(smallgaps_id),'r>','markersize',4,'linewidth',2);hold on;
                plot(-seqst,max(largegaps_id),'b>','markersize',4,'linewidth',2);hold on;
                set(gca,'fontweight','bold');
                
                subplot(2,1,2);hold on;
                patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(smallgaps_id,:),1)-...
                    stderr(smooth_spiketrains(smallgaps_id,:),1)...
                    fliplr(mean(smooth_spiketrains(smallgaps_id,:),1)+...
                    stderr(smooth_spiketrains(smallgaps_id,:),1))])*1000,[0.7 0.3 0.3],'edgecolor','none','facealpha',0.7);
               patch([-seqst:seqend fliplr(-seqst:seqend)],([mean(smooth_spiketrains(largegaps_id,:),1)-...
                    stderr(smooth_spiketrains(largegaps_id,:),1)...
                    fliplr(mean(smooth_spiketrains(largegaps_id,:),1)+...
                    stderr(smooth_spiketrains(largegaps_id,:),1))])*1000,[0.3 0.3 0.7],'edgecolor','none','facealpha',0.7);
                xlim([-seqst seqend]);xlabel('time (ms)');ylabel('Hz');set(gca,'fontweight','bold');
            end
        end
    end
end

            
                




%4) how much is it driven by repeats? can you predict repeat length? 
%5) can you predict bout length? activity run-down
%6) bout pattern in pitch?

