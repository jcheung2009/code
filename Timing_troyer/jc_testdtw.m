function jc_testdtw(template,specparams,freqrange,note,prenote)
%compares dynamic time warp and amplitude segmentation on same sound clip
%(runs of repeats)
%with manipulations (signal divided by a factor)

%tempsize = ceil(size(template,2)*specparams.dt*32);%length to be matched by length of rawclip 

%% set defaults
caldtw.metric = @mnsqrdev2;
caldtw.mlim = .25;
caldtw.boundary = [];
caldtw.interpolate = 1;
caldtw.freqrange = [0 16];
freqinds = find(specparams.f>=caldtw.freqrange(1) & specparams.f<=caldtw.freqrange(2));

if caldtw.mlim>0 & caldtw.mlim<1
    caldtw.mlim = ceil(caldtw.mlim*size(template,2));
end
if isempty(caldtw.boundary)
    caldtw.boundary = zeros(caldtw.mlim,1);
    %caldtw.boundary = zeros(ceil(caldtw.mlim/10),1);
end

%% choose onset and offsets in template for dtw
query = 'n';figure;
while strcmp(query,'n')
    timeaxis = specparams.dt*(0.5:size(template,2));
    subplot(2,1,1);imagesc(timeaxis,specparams.f,template);syn();
    xlimits = get(gca,'xlim');
    xlabel('Template time (msec)','fontsize',12);
    ylabel('kHz','fontsize',12);
    tempamp = ftr_amp(template,specparams.f,'freqrange',freqrange);
    subplot(2,1,2);plot(timeaxis,tempamp./max(tempamp),'k');set(gca,'xlim',xlimits);
    tempedges = input('Template onset and offset (msec):');
    [c ind] = min(abs(timeaxis-tempedges(1)));
    tempedges(1) = timeaxis(ind);
    [c ind] = min(abs(timeaxis-tempedges(2)));
    tempedges(2) = timeaxis(ind);
    subplot(2,1,1);hold on;plot([tempedges(1) tempedges(1)],[0 16],'g','linewidth',2);
    subplot(2,1,1);hold on;plot([tempedges(2) tempedges(2)],[0 16],'g','linewidth',2);
    subplot(2,1,2);hold on;plot([tempedges(1) tempedges(1)],[0 1],'g','linewidth',2);
    subplot(2,1,2);hold on;plot([tempedges(2) tempedges(2)],[0 1],'g','linewidth',2);
    query = input('Are onsets and offsets good?(y/n):','s');
    clf
end
close;
templatetimeaxis = specparams.dt*(0.5:size(template,2));

%% choose file and get rawsong clip
fn = uigetfile;
load([fn,'.not.mat']);
p = ismember(labels,note);
kk = [find(diff([-1 p -1])~=0)];
runlength = diff(kk);
runlength = runlength(1+(p(1)==0):2:end);
pp = strfind(labels,[prenote note]);
onind = pp + 1; %start index for each repeat run
offind = pp + runlength; %end index for each repeat run
[rawsong fs] = evsoundin('',fn,'obs0');

if ~exist('dtwtest')
    mkdir('dtwtest')
end
cd('dtwtest');
if ~exist([fn,'_dtwtest'])
    mkdir([fn,'_dtwtest'])
end
cd([fn,'_dtwtest']);

segcomp = [];
dtwcomp = [];
h1 = figure;
h2 = figure;
h3 = figure;
for i = 1:length(onind)
    clip = rawsong(floor(onsets(onind(i))*1e-3*fs)-1600:ceil(offsets(offind(i))*1e-3*fs)+1600);
    sm = evsmooth(clip,fs);
    [spec f t] = jc_ftr_specgram(clip,specparams);
    %sm = sm./max(sm);
    f = f;
    t = t - (specparams.NFFT-specparams.Nadvance)/(fs/1000);
    %onsets and offsets based on evsonganaly amplitude segmentation
    cliponsets = onsets(onind(i):offind(i));
    clipoffsets = offsets(onind(i):offind(i));
    cliponsets = cliponsets - (((onsets(onind(i))*1e-3*fs)-1600)/(fs/1000));%in msec
    clipoffsets = clipoffsets - (((onsets(onind(i))*1e-3*fs)-1600)/(fs/1000));
    
    gapons = floor(clipoffsets(1:end-1)*(fs/1000));
    gapoffs = ceil(cliponsets(2:end)*(fs/1000));
    smgaps = [];
    for m = 1:length(gapons)
        smgaps = [smgaps;sm(gapons(m):gapoffs(m))];
    end
    
    nrms = mean(sm([floor(cliponsets*(fs/1000));ceil(clipoffsets*(fs/1000))]))/rms(smgaps);
    [ons offs] = SegmentNotes(sm,fs,5,30,nrms*rms(smgaps));
    ons = ons*1000;
    offs = offs*1000;
    segcomp(i).(['trial',num2str(0)]) = [ons offs];
        
    figure(h1);hold on;
    subplot(2,1,1);imagesc(t,f,log(abs(spec)));syn();h = get(gca,'xlim');
    title('amplitude segmentation','fontsize',12);
    subplot(2,1,2);plot((0:length(sm)-1)/(fs/1000),sm,'k');set(gca,'xlim',h);ylim = get(gca,'ylim');
    for ii = 1:length(ons)
        figure(h1);hold on;
        subplot(2,1,1);hold on;plot([ons(ii) ons(ii)],[0 16],'k','linewidth',2);
        subplot(2,1,1);hold on;plot([offs(ii) offs(ii)],[0 16],'k','linewidth',2);
        subplot(2,1,2);hold on;plot([ons(ii) ons(ii)],[0 ylim(2)],'k','linewidth',2);
        subplot(2,1,2);hold on;plot([offs(ii) offs(ii)],[0 ylim(2)],'k','linewidth',2);
    end
    
    dtwonsets = [];
    dtwoffsets = [];
    for p = 1:length(cliponsets)
%         exempsize = (size(floor(cliponsets(p)*(fs/1000)):ceil(clipoffsets(p)*(fs/1000)),2));
%         %exempsize = (size(floor(cliponsets(p)*(fs/1000)):ceil(clipoffsets(p)*(fs/1000)),2)+2*(specparams.NFFT-specparams.Nadvance));
%         if exempsize < tempsize
%             pad = ceil((tempsize-exempsize)/2);
%         else
%             pad = 0;
%         end
        syllclip = clip(floor(cliponsets(p)*(fs/1000))-128:ceil(clipoffsets(p)*(fs/1000))+128);
        %syllclip = clip(floor(cliponsets(p)*(fs/1000))-pad:ceil(clipoffsets(p)*(fs/1000))+pad);
        [syllspec] = jc_ftr_specgram(syllclip,specparams);
%         if size(syllspec,2) > size(template,2)
%             extrabins = size(syllspec,2) - size(template,2);
%             if mod(extrabins,2) == 1
%                 syllspec = syllspec(:,ceil(extrabins/2):end-ceil(extrabins/2));
%             else
%                 syllspec = syllspec(:,(extrabins/2)+1:end-(extrabins/2));
%             end
%         end
        pad = floor(((specparams.NFFT-specparams.Nadvance)/specparams.Nadvance)/2);
        if specparams.tds == 1
            syllspec = conv2(log(abs(syllspec)),specparams.gaussfilter,'same');
            syllspec = diff(syllspec,1,2);
            syllspec = syllspec(:,pad:end-pad);%to get rid of padding from jc_ftr_specgram
        else
            syllspec = log(abs(syllspec));
            syllspec = syllspec(:,pad:end-pad);
        end
                   
        [w, r, m] = dtw(template,syllspec,...
            'freqinds',freqinds,'metric',caldtw.metric,'mlim',caldtw.mlim,'boundary',caldtw.boundary);
        %time relative to the padded clip used for spectrogram
        exemptimeaxis = specparams.dt*(.5:size(syllspec,2));
        %exemptimeaxis = (specparams.dt*(0:size(syllspec,2)-1)) + (specparams.NFFT/2)/(specparams.fs/1000);
        exempedges = (tempedges/specparams.dt) + 0.5;
        exempedges(1) = w(exempedges(1));%index
        exempedges(2) = w(exempedges(2));
        exempedges(1) = interp1(1:length(exemptimeaxis),exemptimeaxis,exempedges(1));%in msec
        exempedges(2) = interp1(1:length(exemptimeaxis),exemptimeaxis,exempedges(2));
        %correct exemp times to be absolute time in original clip
        dtwonsets = [dtwonsets; (exempedges(1)+cliponsets(p))];
        dtwoffsets = [dtwoffsets; (exempedges(2)+cliponsets(p))];
%         dtwonsets = [dtwonsets; (exempedges(1) - (specparams.NFFT-specparams.Nadvance)/(specparams.fs/1000) + cliponsets(p) - (pad/(fs/1000)))];
%         dtwoffsets = [dtwoffsets; (exempedges(2)- (specparams.NFFT-specparams.Nadvance)/(specparams.fs/1000) + cliponsets(p)- (pad/(fs/1000)))];
    end
    dtwcomp(i).(['trial',num2str(0)]) = [dtwonsets dtwoffsets];
    
    figure(h2);hold on;
    subplot(2,1,1);imagesc(t,f,log(abs(spec)));syn();h = get(gca,'xlim');
    title('dynamic time warp segmentation','fontsize',12)
    subplot(2,1,2);plot((0:length(sm)-1)/(fs/1000),sm,'k');set(gca,'xlim',h);
    for q = 1:length(dtwonsets)
        figure(h2);hold on;
        subplot(2,1,1);hold on;plot([dtwonsets(q) dtwonsets(q)],[0 16],'k','linewidth',2);
        subplot(2,1,2);hold on;plot([dtwonsets(q) dtwonsets(q)],[0 ylim(2)],'k','linewidth',2);
        subplot(2,1,1);hold on;plot([dtwoffsets(q) dtwoffsets(q)],[0 16],'k','linewidth',2);
        subplot(2,1,2);hold on;plot([dtwoffsets(q) dtwoffsets(q)],[0 ylim(2)],'k','linewidth',2);
    end    
       
    cmap = hsv(11);
    for n = 1:11
        mag = 0.05 + 0.05*(n-1);
        clipn = (1-mag)*clip;
        smn = evsmooth(clipn,fs);

%         noiseamp = max(abs(clip))*mag;
%         clipn = clip + noiseamp*pinknoise(length(clip))';
%         smn = evsmooth(clipn,fs);
         %smn = smn./max(smn);
         figure(h1);
         subplot(2,1,2);hold on;plot((0:length(smn)-1)/(fs/1000),smn,'color',cmap(n,:));
         figure(h2);
         subplot(2,1,2);hold on;plot((0:length(smn)-1)/(fs/1000),smn,'color',cmap(n,:));
%         smngaps = [];
%         for l = length(gapons)
%             smngaps = [smngaps;smn(gapons(l):gapoffs(l))];
%         end
        [ons offs] = SegmentNotes(smn,fs,5,30,nrms*rms(smgaps));
        ons = ons*1000;
        offs = offs*1000;
        segcomp(i).(['amptrial',num2str(n)]) = [ons offs];
        
        for ii = 1:length(ons)
            figure(h1);hold on;
            subplot(2,1,1);hold on;plot([ons(ii) ons(ii)],[0 16],'color',cmap(n,:),'linewidth',2);
            subplot(2,1,1);hold on;plot([offs(ii) offs(ii)],[0 16],'color',cmap(n,:),'linewidth',2);
            subplot(2,1,2);hold on;plot([ons(ii) ons(ii)],[0 ylim(2)],'color',cmap(n,:),'linewidth',2);
            subplot(2,1,2);hold on;plot([offs(ii) offs(ii)],[0 ylim(2)],'color',cmap(n,:),'linewidth',2);
        end

        figure(h3);clf;hold on;
        dtwonsets = [];
        dtwoffsets = [];
        for s = 1:length(ons)
            %exempsize = (size(floor(ons(s)*(fs/1000)):ceil(offs(s)*(fs/1000)),2));
%             if exempsize < tempsize
%                 pad = ceil((tempsize-exempsize)/2);
%             else
%                 pad = 0;
%             end
            syllclip = clipn(floor(ons(s)*(fs/1000))-128:ceil(offs(s)*(fs/1000))+128);
            %syllclip = clipn(floor(ons(s)*(fs/1000))-pad:ceil(offs(s)*(fs/1000))+pad);
            [syllspec] = jc_ftr_specgram(syllclip,specparams);
            pad = floor(((specparams.NFFT-specparams.Nadvance)/specparams.Nadvance));
            if specparams.tds == 1
                syllspec = conv2(log(abs(syllspec)),specparams.gaussfilter,'same');
                syllspec = diff(syllspec,1,2); 
                syllspec = syllspec(:,pad:end-pad);
            else
                syllspec = log(abs(syllspec));
                syllspec = syllspec(:,pad:end-pad);
            end
            [w, r, mtrix] = dtw(template,syllspec,...
                'freqinds',freqinds,'metric',caldtw.metric,'mlim',caldtw.mlim,'boundary',caldtw.boundary);
            %time relative to the syll padded clip used for spectrogram 
            exemptimeaxis = specparams.dt*(.5:size(syllspec,2));
            %exemptimeaxis = (specparams.dt*(0:size(syllspec,2)-1)) + (specparams.NFFT/2)/(specparams.fs/1000);
            exempedges = (tempedges/specparams.dt) + 0.5;
            exempedges(1) = w(exempedges(1));
            exempedges(2) = w(exempedges(2));
            exempedges(1) = interp1(1:length(exemptimeaxis),exemptimeaxis,exempedges(1));
            exempedges(2) = interp1(1:length(exemptimeaxis),exemptimeaxis,exempedges(2));
            dtwonsets = [dtwonsets; (exempedges(1)+ons(s))];
            dtwoffsets = [dtwoffsets; (exempedges(2)+ons(s))];
%             dtwonsets = [dtwonsets; (exempedges(1) - (specparams.NFFT-specparams.Nadvance)/(specparams.fs/1000) + ons(s) -(pad/(fs/1000)))];
%             dtwoffsets = [dtwoffsets; (exempedges(2)- (specparams.NFFT-specparams.Nadvance)/(specparams.fs/1000) + ons(s)-(pad/(fs/1000)))];
            
            %% matrix and warping
            dtwaxis = axes('position',[.55 .35 .4 .4]);
            hold on
            imagesc(specparams.dt*(.5:size(template,2)),specparams.dt*(.5:size(syllspec,2)),mtrix);
            set(dtwaxis,'ydir','normal')
            axis('tight')
            p = plot(specparams.dt*(r(1)-.5:r(2)),...
                specparams.dt*w(r(1):r(2)));
                set(p,'color','r','linewidth',2);  
                title([fn,' REPEAT #', num2str(i),' NOTE #',num2str(s),' TRIAL #',num2str(n)],'fontsize',12,'interpreter','none');
            set(dtwaxis,'xtick',[],'ytick',[]);
            
            %% plot template and exemplar
            tempaxis = axes('position',[.55 .1 .4 .2]);
            if min(size(template))==1
                plot(specparams.dt*(.5:size(template,2)),template);
            else
                imagesc(specparams.dt*(.5:size(template,2)),specparams.f,template);
            end
            set(tempaxis,'yaxislocation','right')
            set(tempaxis,'ydir','normal','xdir','normal')
            ylabel('kHz','fontsize',12);
            xlabel('Template time (msec)','fontsize',12);

            exempaxis = axes('position',[.3 .35 .2 .4]);
            if min(size(syllspec))==1
                plot(syllspec,specparams.dt*(.5:size(syllspec,2)));
            else
                imagesc(specparams.f,specparams.dt*(.5:size(syllspec,2)),syllspec');
            end
            set(exempaxis,'xaxislocation','top','xdir','reverse')
            xlabel('kHz','fontsize',12);
            set(exempaxis,'ydir','normal')
            ylabel('Exemplar time (msec)','fontsize',12);
            
            %% plot template and exemplar above each other with onset and offset times
            tempaxis2 = axes('position',[0.05 0.5 .2 .4]);
            imagesc(specparams.dt*(.5:size(template,2)),specparams.f,template);
            set(tempaxis2,'ydir','normal');
            xlim = get(tempaxis,'xlim');
            hold on;plot([tempedges(1) tempedges(1)],[0 16],'r','LineWidth',2);
            plot([tempedges(2) tempedges(2)],[0 16],'r','LineWidth',2);
            ylabel('kHz','fontsize',12);
            xlabel('Template time (msec)','fontsize',12);

            exempaxis2 = axes('position',[.05 .05 .2 .4]);
            exempedges = (tempedges/specparams.dt) + 0.5;
            exempedges(1) = w(exempedges(1));
            exempedges(2) = w(exempedges(2));
            exempedges(1) = interp1(1:length(exemptimeaxis),exemptimeaxis,exempedges(1));
            exempedges(2) = interp1(1:length(exemptimeaxis),exemptimeaxis,exempedges(2)); 
            
            imagesc(exemptimeaxis,specparams.f,syllspec);
            set(exempaxis2,'ydir','normal');
            set(exempaxis2,'xlim',xlim);
            hold on;plot([exempedges(1) exempedges(1)],[0 16],'r','LineWidth',2);
            plot([exempedges(2) exempedges(2)],[0 16],'r','LineWidth',2);
            ylabel('kHz','fontsize',12);
            xlabel('Exemplar time (msec)','fontsize',12);          
            %pause;
            saveas(h3,[fn,'_rep',num2str(i),'_note',num2str(s),'_trial',num2str(n),'.fig']);
            clf(h3)  
        end
        
        for k = 1:length(dtwonsets)
            figure(h2);hold on;
            subplot(2,1,1);hold on;plot([dtwonsets(k) dtwonsets(k)],[0 16],'color',cmap(n,:),'linewidth',2);
            subplot(2,1,2);hold on;plot([dtwonsets(k) dtwonsets(k)],[0 ylim(2)],'color',cmap(n,:),'linewidth',2);
            subplot(2,1,1);hold on;plot([dtwoffsets(k) dtwoffsets(k)],[0 16],'color',cmap(n,:),'linewidth',2);
            subplot(2,1,2);hold on;plot([dtwoffsets(k) dtwoffsets(k)],[0 ylim(2)],'color',cmap(n,:),'linewidth',2);
        end
        dtwcomp(i).(['trial',num2str(n)]) = [dtwonsets dtwoffsets];
        saveas(h1,[fn,'_rep',num2str(i),'_ampseg.fig']);
        saveas(h2,[fn,'_rep',num2str(i),'_dtwseg.fig']);
    end
    clf(h1);
    clf(h2);
end

save('dtwtest','segcomp','dtwcomp');



    
   
    
    
