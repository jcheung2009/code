function [syll varargout] = jc_getfirstsyll(indCell,incell,pltdistr,pltcorr)
%use znorm incells if plotting distribution of pitches and correlation of
%first syllable pitch with rest length

syll = cell(size(indCell));
for i = 1:length(indCell)
    [c ia] = unique(indCell{i},'first');%ia = index for first syllable in each bout
    [c ib] = unique(indCell{i},'last');%ib = index for last syllable 
    syll{i} = [ia ib];
end

%plot distribution of first syll pitch to all pitches
if ~isempty(pltdistr)
    allsyllables = cellfun(@(x) x(:,2),incell,'UniformOutput',false);
    allsyllables = vertcat(allsyllables{:});
    minbin = floor(min(allsyllables)*10^2)/10^2;
    maxbin = ceil(max(allsyllables)*10^2)/10^2;
    figure(pltdistr);hold on;
    [n b] = hist(allsyllables,[minbin:0.005:maxbin]);bar(b,n/sum(n),'k');
    jc_transphist;
    
    firstsyllables = cell(size(incell));
    lastsyllables = cell(size(incell));
    for i = 1:length(incell)
        firstsyllables{i} = incell{i}(syll{i}(:,1),2);
        lastsyllables{i} = incell{i}(syll{i}(:,2),2);
    end
    firstsyllables = vertcat(firstsyllables{:});
    lastsyllables = vertcat(lastsyllables{:});
    
    figure(pltdistr);hold on;
    [n b] = hist(firstsyllables,[minbin:0.005:maxbin]);bar(b,n/sum(n),'r');
    jc_transphist;

    figure(pltdistr);hold on;
    [n b] = hist(lastsyllables,[minbin:0.005:maxbin]);bar(b,n/sum(n),'b');
    jc_transphist;
end

%correlate first syllable pitch (z score) with rest interval before bout
if ~isempty(pltcorr)
    pitchrestcorr = cell(size(incell));
    for i = 1:length(syll)
        boutind = [syll{i}(2:end,1), syll{i}(1:end-1,2)];%index for [start of one bout, end of last bout]
        pitchrestcorr{i} = [];
        for ii = 1:length(boutind)
            restinterval = etime(datevec(incell{i}(boutind(ii,1),1)),datevec(incell{i}(boutind(ii,2),1)));
            pitchrestcorr{i} = [pitchrestcorr{i};[restinterval incell{i}(boutind(ii,1),2)]];
        end
    end
    pitchrestcorr = vertcat(pitchrestcorr{:});
    figure(pltcorr);hold on;
    plot(pitchrestcorr(:,1),pitchrestcorr(:,2),'ok');
    [r p] = corrcoef(pitchrestcorr(:,1),pitchrestcorr(:,2))
end
    



