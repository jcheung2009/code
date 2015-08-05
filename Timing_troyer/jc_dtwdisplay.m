function jc_dtwdisplay(template,specparams,filetype)
%displays the diference matrix and warping path for all syllables in each single file or
%each file in a batch list
%filetype = 'b' or 'fn' to be in batch or file mode
%also displays the corresponding onsets and offsets on the template and
%exemplar spectrograms
%

if strcmp(filetype,'b')
    batch = uigetfile
else strcmp(filetype,'fn')
    fn = uigetfile
end

%% set defaults
params.scaled = 1;
%params = parse_pv_pairs(params,varargin);

warpcolor = 'g';
warplinewidth = 2;
fontsize = 10;
labelfontsize = 12;
linewidth = 2;

%% determine onset and offset times in the template
figure;
% this is time base for relative time IN THE SPECTROGRAM
imagesc(specparams.dt*(0.5:size(template,2)),specparams.f,template);syn()
xlabel('Template time (msec)','fontsize',labelfontsize);
ylabel('kHz','fontsize',labelfontsize);
tempedges = input('Template onset and offset (msec):');
timeaxis = specparams.dt*(0.5:size(template,2));
[c ind] = min(abs(timeaxis-tempedges(1)));
tempedges(1) = timeaxis(ind);
[c ind] = min(abs(timeaxis-tempedges(2)));
tempedges(2) = timeaxis(ind);
close;

%% plot matrix and warping
%% file mode
if strcmp(filetype,'fn')
    load(fn);
    h1 = figure;
    for i = 1:length(notespecs)
        if specparams.tds == 1
            exemplar = notespecs(i).spectds;
        else
            exemplar = notespecs(i).spec;
        end
        %% matrix and warping
        dtwaxis = axes('position',[.55 .35 .4 .4]);
        hold on
        imagesc(specparams.dt*(.5:size(template,2)),specparams.dt*(.5:size(exemplar,2)),dtwspecs(i).diffmatrix);
        set(dtwaxis,'ydir','normal')
        axis('tight')
        p = plot(specparams.dt*(dtwspecs(i).range(1)-.5:dtwspecs(i).range(2)),...
            specparams.dt*dtwspecs(i).warp(dtwspecs(i).range(1):dtwspecs(i).range(2)));
            set(p,'color',warpcolor,'linewidth',warplinewidth);
            title([fn,' NOTE #', num2str(i)],'FontSize',12,'interpreter','none');
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
        ylabel('kHz','fontsize',labelfontsize);
        xlabel('Template time (msec)','fontsize',labelfontsize);

        exempaxis = axes('position',[.3 .35 .2 .4]);
        if min(size(exemplar))==1
            plot(exemplar,specparams.dt*(.5:size(exemplar,2)));
        else
            imagesc(specparams.f,specparams.dt*(.5:size(exemplar,2)),exemplar');
        end
        set(exempaxis,'xaxislocation','top','xdir','reverse')
        xlabel('kHz','fontsize',labelfontsize);
        set(exempaxis,'ydir','normal')
        ylabel('Exemplar time (msec)','fontsize',labelfontsize);
       
        
        %% plot template and exemplar above each other with onset and offset times
        tempaxis2 = axes('position',[0.05 0.5 .2 .4]);
        imagesc(specparams.dt*(.5:size(template,2)),specparams.f,template);
        set(tempaxis2,'ydir','normal');
        xlim = get(tempaxis,'xlim');
        hold on;plot([tempedges(1) tempedges(1)],[0 16],'g','LineWidth',linewidth);
        plot([tempedges(2) tempedges(2)],[0 16],'g','LineWidth',linewidth);
        ylabel('kHz','fontsize',labelfontsize);
        xlabel('Template time (msec)','fontsize',labelfontsize);
        
        exempaxis2 = axes('position',[.05 .05 .2 .4]);
        exemptimeaxis = specparams.dt*(.5:size(exemplar,2));
        %exemptimeaxis = (specparams.dt*(0:size(exemplar,2)-1)) + (specparams.NFFT/2)/(specparams.fs/1000);
        exempedges = (tempedges/specparams.dt) + 0.5;%indices of tempedges
        exempedges(1) = dtwspecs(i).warp(exempedges(1));%indices for exemplar
        exempedges(2) = dtwspecs(i).warp(exempedges(2));%indices for exemplar 
        exempedges(1) = interp1(1:length(exemptimeaxis),exemptimeaxis,exempedges(1));
        exempedges(2) = interp1(1:length(exemptimeaxis),exemptimeaxis,exempedges(2)); 


        imagesc(exemptimeaxis,specparams.f,exemplar);
        %imagesc(specparams.dt*(0.5:size(exemplar,2)),specparams.f,exemplar);
        set(exempaxis2,'ydir','normal');
        set(exempaxis2,'xlim',xlim);
        hold on;plot([exempedges(1) exempedges(1)],[0 16],'g','LineWidth',linewidth);
        plot([exempedges(2) exempedges(2)],[0 16],'g','LineWidth',linewidth);
        ylabel('kHz','fontsize',labelfontsize);
        xlabel('Exemplar time (msec)','fontsize',labelfontsize);
        
        pause;
        clf(h1);
    end
%% batch mode
elseif strcmp(filetype,'b')
    ff = load_batchf(batch);
    h1 = figure;
    for fnind = 1:length(ff)
        fn = ff(fnind).name;
        load(fn);
        for i = 1:length(notespecs)
            if specparams.tds == 1
                exemplar = notespecs(i).spectds;
            else
                exemplar = notespecs(i).spec;
            end
            %% matrix and warping
            dtwaxis = axes('position',[.55 .35 .4 .4]);
            hold on
            imagesc(specparams.dt*(.5:size(template,2)),specparams.dt*(.5:size(exemplar,2)),dtwspecs(i).diffmatrix);
            set(dtwaxis,'ydir','normal')
            axis('tight')
            p = plot(specparams.dt*(dtwspecs(i).range(1)-.5:dtwspecs(i).range(2)),...
                specparams.dt*dtwspecs(i).warp(dtwspecs(i).range(1):dtwspecs(i).range(2)));
                set(p,'color',warpcolor,'linewidth',warplinewidth);
                title([fn,' NOTE #', num2str(i)],'FontSize',12,'interpreter','none');
            set(dtwaxis,'xtick',[],'ytick',[])
            %% plot template and exemplar
            tempaxis = axes('position',[.55 .1 .4 .2]);
            if min(size(template))==1
                plot(specparams.dt*(.5:size(template,2)),template);
            else
                imagesc(specparams.dt*(.5:size(template,2)),specparams.f,template);
            end
            set(tempaxis,'yaxislocation','right')
            set(tempaxis,'ydir','normal','xdir','normal')
            ylabel('kHz','fontsize',labelfontsize);
            xlabel('Template time (msec)','fontsize',labelfontsize);

            exempaxis = axes('position',[.3 .35 .2 .4]);
            if min(size(exemplar))==1
                plot(exemplar,specparams.dt*(.5:size(exemplar,2)));
            else
                imagesc(specparams.f,specparams.dt*(.5:size(exemplar,2)),exemplar');
            end
            set(exempaxis,'xaxislocation','top','xdir','reverse')
            xlabel('kHz','fontsize',labelfontsize);
            set(exempaxis,'ydir','normal')
            ylabel('Exemplar time (msec)','fontsize',labelfontsize);


            %% plot template and exemplar above each other with onset and offset times
            tempaxis2 = axes('position',[0.05 0.5 .2 .4]);
            imagesc(specparams.dt*(.5:size(template,2)),specparams.f,template);
            set(tempaxis2,'ydir','normal');
            xlim = get(tempaxis,'xlim');
            hold on;plot([tempedges(1) tempedges(1)],[0 16],'g','LineWidth',linewidth);
            plot([tempedges(2) tempedges(2)],[0 16],'g','LineWidth',linewidth);
            ylabel('kHz','fontsize',labelfontsize);
            xlabel('Template time (msec)','fontsize',labelfontsize);

            exempaxis2 = axes('position',[.05 .05 .2 .4]);
            exempedges = (tempedges/specparams.dt) + 0.5;
            exempedges(1) = specparams.dt*dtwspecs(i).warp(exempedges(1));
            exempedges(2) = specparams.dt*dtwspecs(i).warp(exempedges(2));
            imagesc(specparams.dt*(0.5:size(exemplar,2)),specparams.f,exemplar);
            set(exempaxis2,'ydir','normal');
            set(exempaxis2,'xlim',xlim);
            hold on;plot([exempedges(1) exempedges(1)],[0 16],'g','LineWidth',linewidth);
            plot([exempedges(2) exempedges(2)],[0 16],'g','LineWidth',linewidth);
            ylabel('kHz','fontsize',labelfontsize);
            xlabel('Exemplar time (msec)','fontsize',labelfontsize);

            pause;
            clf(h1);
        end
    end
end
