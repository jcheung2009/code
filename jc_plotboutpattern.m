function jc_plotboutpattern(boutinfo,marker,linecolor,motif,fignum1,fignum2,fignum3)
%this function plots the pitch, volume, and/or motif tempo over
%each rendition in the bout. Data is presented with normalization to first
%rendition and also in raw form. 

if length(motif) == 1 %only spectral
    spec = 'y';
    temp = 'n';
elseif length(motif) > 1 & isempty(boutinfo(1).boutpitch) %only tempo
    temp = 'y';
    spec = 'n';
elseif length(motif) > 1 & ~isempty(boutinfo(1).boutpitch) %spec and tempo
    spec = 'y';
    temp = 'y';
end

%% extract bout pitch,volume, and tempo patterns normalized to first rendition 
maxnummotifs = max(arrayfun(@(x) x.nummotifs,boutinfo));
numsylls = size(boutinfo(1).boutpitch,2);
pitchpattern = cell(1,numsylls);
volumepattern = cell(1,numsylls);
tempopattern = [];
for i = 1:length(boutinfo)
    if spec == 'y'
        for ii = 1:numsylls
            pitchpattern{ii} = [pitchpattern{ii} [boutinfo(i).boutpitch(:,ii)/boutinfo(i).boutpitch(1,ii);...
                NaN(maxnummotifs-boutinfo(i).nummotifs,1)]];%normalize by syllable in first motif, concatenates data for all syllables into one set
            volumepattern{ii} = [volumepattern{ii} [log(boutinfo(i).boutvolume(:,ii))/log(boutinfo(i).boutvolume(1,ii));...
                NaN(maxnummotifs-boutinfo(i).nummotifs,1)]];%normalize by syllable in first motif
        end
    end
    if temp == 'y'
        tempopattern = [tempopattern [boutinfo(i).boutacorr/boutinfo(i).boutacorr(1);NaN(maxnummotifs-boutinfo(i).nummotifs,1)]];
    end
end

%% extract mean pitch, volume, and tempo across bouts by ordinal position
tempobyposition = cell(1,maxnummotifs);
pitchbyposition = cell(1,maxnummotifs);
volumebyposition = cell(1,maxnummotifs);
for i = 1:maxnummotifs
    for ii = 1:length(boutinfo)
        if spec == 'y'
            if size(boutinfo(ii).boutpitch,1) >= i
                pitchbyposition{i} = [pitchbyposition{i};boutinfo(ii).boutpitch(i,:)];
                volumebyposition{i} = [volumebyposition{i};boutinfo(ii).boutvolume(i,:)];
            end
        end
        if temp == 'y'
            if size(boutinfo(ii).boutacorr,1) >= i
                tempobyposition{i} = [tempobyposition{i};boutinfo(ii).boutacorr(i,:)];
            end
        end
    end
end

%% plot pitch, volume, and tempo bout patterns
if spec == 'y'
    figure(fignum1);hold on;
    subtightplot(3,1,1,[0.08 0.08],[0.08 0.08],0.15);hold on;
    for ii = 1:numsylls
        mns = NaN(maxnummotifs,2);
        for i = 1:maxnummotifs
            jitter = (-1+2*rand)/10;
            normpitch = pitchpattern{ii}(i,:);
            normpitch = normpitch(~isnan(normpitch));
            if length(normpitch) >= 15
                [hi lo mn] = mBootstrapCI(normpitch);
                plot(jitter+i,mn,marker,'markersize',8);hold on;
                plot(jitter+[i i],[hi lo],linecolor,'linewidth',2);hold on;
                mns(i,:) = [jitter+i mn];
            end
        end
        plot(mns(:,1),mns(:,2),linecolor);hold on;
    end
    ylabel({'Normalized Frequency'});
    set(gca,'fontweight','bold');
    title([motif]);
    xlabel('position in bout');
    
    subtightplot(3,1,2,[0.08 0.08],[0.08 0.08],0.15);hold on;
    for i = 1:numsylls
        mns = NaN(maxnummotifs,2);
        for ii = 1:maxnummotifs
            jitter = (-1+2*rand)/10;
            if length(pitchbyposition{ii})>=15
                [hi lo mn] = mBootstrapCI(pitchbyposition{ii}(:,i));
                plot(jitter+ii,mn,marker,'markersize',8);hold on;
                plot(jitter+[ii ii],[hi lo],linecolor,'linewidth',2);hold on;
                mns(ii,:) = [jitter+ii,mn];
            end
        end
        plot(mns(:,1),mns(:,2),'k');
    end
    ylabel({'Frequency'});
    set(gca,'fontweight','bold');
    title(['bout ',motif]);
    xlabel('position in bout');
    
    subtightplot(3,1,3,[0.08 0.08],[0.08 0.08],0.15);hold on;
    for i = 1:numsylls
        mns = NaN(maxnummotifs,2);
        for ii = 1:maxnummotifs
            jitter = (-1+2*rand)/10;
            if length(pitchbyposition{ii})>=15
                [mn hi lo] = mBootstrapCI_CV(pitchbyposition{ii}(:,i));
                plot(jitter+ii,mn,marker,'markersize',8);hold on;
                plot(jitter+[ii ii],[hi lo],linecolor,'linewidth',2);hold on;
                mns(ii,:) = [jitter+ii,mn];
            end
        end
        plot(mns(:,1),mns(:,2),'k');
    end
    ylabel({'pitch CV'});
    set(gca,'fontweight','bold');
    title(['bout ',motif]);
    xlabel('position in bout');
    
    figure(fignum2);hold on;
    subtightplot(2,1,1,[0.08 0.08],[0.08 0.08],0.15);hold on;
    for ii = 1:numsylls
        mns = NaN(maxnummotifs,2);
        for i = 1:maxnummotifs
            jitter = (-1+2*rand)/10;
            normvolume = volumepattern{ii}(i,:);
            normvolume = normvolume(~isnan(normvolume));
            if length(normvolume) >= 15
                [hi lo mn] = mBootstrapCI(normvolume);
                plot(jitter+i,mn,marker,'markersize',8);hold on;
                plot(jitter+[i i],[hi lo],linecolor,'linewidth',2);hold on;
                mns(i,:) = [jitter+i mn];
            end
        end
        plot(mns(:,1),mns(:,2),linecolor);hold on;
    end
    ylabel({'Normalized Amplitude'});
    title([motif]);
    set(gca,'fontweight','bold');
    xlabel('position in bout');
    
    subtightplot(2,1,2,[0.08 0.08],[0.08 0.08],0.15);hold on;
    for i = 1:numsylls
        mns = NaN(maxnummotifs,2);
        for ii = 1:maxnummotifs
            jitter = (-1+2*rand)/10;
            if length(volumebyposition{ii})>=15
                [hi lo mn] = mBootstrapCI(log(volumebyposition{ii}(:,i)));
                plot(jitter+ii,mn,marker,'markersize',8);hold on;
                plot(jitter+[ii ii],[hi lo],linecolor,'linewidth',2);hold on;
                mns(ii,:) = [jitter+ii,mn];
            end
        end
        plot(mns(:,1),mns(:,2),'k');
    end
    ylabel({'Amplitude'});
    set(gca,'fontweight','bold');
    xlabel('position in bout');
end

if temp == 'y'
    figure(fignum3);hold on;
    subtightplot(3,1,1,[0.08 0.08],[0.08 0.08],0.15);hold on;
    mns = NaN(maxnummotifs,2);
    for i = 1:maxnummotifs
        jitter = (-1+2*rand)/10;
        normtempo = tempopattern(i,:);
        normtempo = normtempo(~isnan(normtempo));
        if length(normtempo) >= 15
            [hi lo mn] = mBootstrapCI(normtempo);
            plot(jitter+i,mn,marker,'markersize',8);hold on;
            plot(jitter+[i i],[hi lo],linecolor,'linewidth',2);hold on;
            mns(i,:) = [jitter+i mn];
        end
    end
    plot(mns(:,1),mns(:,2),linecolor);hold on;
    xlabel('position in bout');
    ylabel({'Normalized motif tempo'});
    title([motif]);
    set(gca,'fontweight','bold');
    
    subtightplot(3,1,2,[0.08 0.08],[0.08 0.08],0.15);hold on;
    mns = NaN(maxnummotifs,2);
    for ii = 1:maxnummotifs
        jitter = (-1+2*rand)/10;
        tempobyposition{ii} = tempobyposition{ii}(~isnan(tempobyposition{ii}));
        if length(tempobyposition{ii})>=15
            [hi lo mn] = mBootstrapCI(tempobyposition{ii});
            plot(jitter+ii,mn,marker,'markersize',8);hold on;
            plot(jitter+[ii ii],[hi lo],linecolor,'linewidth',2);hold on;
            mns(ii,:) = [jitter+ii,mn];
        end
    end
    plot(mns(:,1),mns(:,2),'k');
    ylabel({'interval duration'});
    set(gca,'fontweight','bold');
    xlabel('position in bout');
    
    subtightplot(3,1,3,[0.08 0.08],[0.08 0.08],0.15);hold on;
    mns = NaN(maxnummotifs,2);
    for ii = 1:maxnummotifs
        jitter = (-1+2*rand)/10;
        tempobyposition{ii} = tempobyposition{ii}(~isnan(tempobyposition{ii}));
        if length(tempobyposition{ii})>=15
            [mn hi lo] = mBootstrapCI_CV(tempobyposition{ii});
            plot(jitter+ii,mn,marker,'markersize',8);hold on;
            plot(jitter+[ii ii],[hi lo],linecolor,'linewidth',2);hold on;
            mns(ii,:) = [jitter+ii,mn];
        end
    end
    plot(mns(:,1),mns(:,2),'k');
    ylabel({'interval duration CV'});
    set(gca,'fontweight','bold');
    xlabel('position in bout');
end


