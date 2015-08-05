function jc_dtwcompdisplay(template,specparams,filetype)
%compare onset and offset times from amplitude segmentation and with dtw
%map
%onsets/offsets taken from notespecs.mat and dtwspecs.mat 
%filetype: 'b' batch mode, 'fn' file mode
%displays the template, exemplar spectrograms and the exemplar amplitude
%envelop with markers denoting the offsets/onsets 


if strcmp(filetype,'b')
    batch = uigetfile;
else strcmp(filetype,'fn')
    fn = uigetfile;
end

%% set defaults
fontsize = 10;
linewidth = 2;
labelfontsize = 12;
fontsize = 10;
load('specparams.mat');

%determine onset and offset times in template
query = 'n';figure;
while strcmp(query,'n')
    timeaxis = specparams.dt*(0.5:size(template,2));
    subplot(2,1,1);imagesc(timeaxis,specparams.f,template);syn();
    xlimits = get(gca,'xlim');
    xlabel('Template time (msec)','fontsize',labelfontsize);
    ylabel('kHz','fontsize',labelfontsize);
    tempamp = ftr_amp(template,specparams.f,'freqrange',freqrange);
    subplot(2,1,2);plot(timeaxis,tempamp./max(tempamp),'k');set(gca,'xlim',xlimits);
    tempedges = input('Template onset and offset (msec):');
    [c ind] = min(abs(timeaxis-tempedges(1)));
    tempedges(1) = timeaxis(ind);
    [c ind] = min(abs(timeaxis-tempedges(2)));
    tempedges(2) = timeaxis(ind);
    subplot(2,1,1);hold on;plot([tempedges(1) tempedges(1)],[0 16],'g','linewidth',linewidth);
    subplot(2,1,1);hold on;plot([tempedges(2) tempedges(2)],[0 16],'g','linewidth',linewidth);
    subplot(2,1,2);hold on;plot([tempedges(1) tempedges(1)],[0 1],'g','linewidth',linewidth);
    subplot(2,1,2);hold on;plot([tempedges(2) tempedges(2)],[0 1],'g','linewidth',linewidth);
    query = input('Are onsets and offsets good?(y/n):','s');
    clf
end
close;

if strcmp(filetype,'fn')
    load(fn);
    h1 = figure;
    for i = 1:length(notespecs)
        if specparams.tds == 1
            exemplar = notespecs(i).spectds;
        else
             exemplar = notespecs(i).spec;
        end
        %time axis relative to rawsong clip
        exemptimeaxis = (specparams.dt*(0:size(exemplar,2)-1)) + (specparams.NFFT/2)/(specparams.fs/1000);
        %time axis in template relative to time in the spectrogram
        templatetimeaxis = specparams.dt*(0.5:size(template,2));
        exempedges = (tempedges/specparams.dt) + 0.5;
        exempedges(1) = dtwspecs(i).warp(exempedges(1));
        exempedges(2) = dtwspecs(i).warp(exempedges(2));
        exempedges(1) = interp1(1:length(exemptimeaxis),exemptimeaxis,exempedges(1));
        exempedges(2) = interp1(1:length(exemptimeaxis),exemptimeaxis,exempedges(2));
        
        %% template and onset/offset times
        subplot(3,1,1);hold on;
        imagesc(templatetimeaxis,specparams.f,template);syn();hold on;
        plot([tempedges(1) tempedges(1)],[0 16],'g','LineWidth',linewidth);
        plot([tempedges(2) tempedges(2)],[0 16],'g','LineWidth',linewidth);
        ylabel('kHz','fontsize',fontsize);
        xlabel('Template time(msec)','fontsize',labelfontsize);
        axis('tight')
        
        %% exemplar spectrogram and its corresponding onset and offset 
        subplot(3,1,2);hold on;
        ampsegonset = 1000*(notespecs(i).ntonset - notespecs(i).cliponset) + (specparams.NFFT-specparams.Nadvance)/(specparams.fs/1000);
        ampsegoffset = 1000*(notespecs(i).ntoffset - notespecs(i).cliponset)+(specparams.NFFT-specparams.Nadvance)/(specparams.fs/1000);
        imagesc(exemptimeaxis,specparams.f,exemplar);syn();hold on;
        plot([exempedges(1) exempedges(1)],[0 16],'g','LineWidth',linewidth);
        plot([exempedges(2) exempedges(2)],[0 16],'g','LineWidth',linewidth);
        plot([ampsegonset ampsegonset],[0 16],'r','LineWidth',linewidth);
        plot([ampsegoffset ampsegoffset],[0 16],'r','LineWidth',linewidth);
        ylabel('kHz','fontsize',fontsize);
        xlabel('Absolute time in rawsong (msec)','fontsize',labelfontsize);
        title([fn,' NOTE #',num2str(i)],'fontsize',labelfontsize,'interpreter','none');
        axis('tight')
        xlimits = get(gca,'xlim');
        
        
        %% exemplar rawsong clip with corresponding onset and offset from dtw
        subplot(3,1,3);hold on;
        clip = abs(notespecs(i).clip);
        %spectrograms were computed after raw data was padded 
        clip = [NaN(specparams.NFFT-specparams.Nadvance,1); clip; NaN(specparams.NFFT-specparams.Nadvance,1)];  
        plot((0:length(clip)-1)/32,clip./max(clip),'k');hold on;
        plot([exempedges(1) exempedges(1)],[0 1],'g','LineWidth',linewidth);hold on;
        plot([exempedges(2) exempedges(2)],[0 1],'g','LineWidth',linewidth);hold on;
        plot([ampsegonset ampsegonset],[0 1],'r','LineWidth',linewidth);
        plot([ampsegoffset ampsegoffset],[0 1],'r','LineWidth',linewidth);
        ylabel('normalized amp','fontsize',fontsize);
        xlabel('Absolute time in rawsong (msec)','fontsize',labelfontsize);
        set(gca,'xlim',xlimits);
        
        pause;
        clf(h1);
    end
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
            %time axis relative to rawsong clip
            exemptimeaxis = (specparams.dt*(0:size(exemplar,2)-1)) + (specparams.NFFT/2)/(specparams.fs/1000);
            %time axis in template relative to time in the spectrogram
            templatetimeaxis = specparams.dt*(0.5:size(template,2));
            exempedges = (tempedges/specparams.dt) + 0.5;
            exempedges(1) = dtwspecs(i).warp(exempedges(1));
            exempedges(2) = dtwspecs(i).warp(exempedges(2));
            exempedges(1) = interp1(1:size(exemptimeaxis,2),exemptimeaxis,exempedges(1));
            exempedges(2) = interp1(1:size(exemptimeaxis,2),exemptimeaxis,exempedges(2));

            %% template and onset/offset times
            subplot(3,1,1);hold on;
            imagesc(templatetimeaxis,specparams.f,template);syn();
            plot([tempedges(1) tempedges(1)],[0 16],'g','LineWidth',linewidth);
            plot([tempedges(2) tempedges(2)],[0 16],'g','LineWidth',linewidth);
            ylabel('kHz','fontsize',fontsize);
            xlabel('Template time(msec)','fontsize',labelfontsize);
            axis('tight')
            
            %% exemplar spectrogram and its corresponding onset and offset 
            subplot(3,1,2);hold on;
            ampsegonset = 1000*(notespecs(i).ntonset - notespecs(i).cliponset)+(specparams.NFFT-specparams.Nadvance)/(specparams.fs/1000);
            ampsegoffset = 1000*(notespecs(i).ntoffset - notespecs(i).cliponset)+(specparams.NFFT-specparams.Nadvance)/(specparams.fs/1000);
            imagesc(exemptimeaxis,specparams.f,exemplar);syn();
            plot([exempedges(1) exempedges(1)],[0 16],'g','LineWidth',linewidth);
            plot([exempedges(2) exempedges(2)],[0 16],'g','LineWidth',linewidth);
            plot([ampsegonset ampsegonset],[0 16],'r','LineWidth',linewidth);
            plot([ampsegoffset ampsegoffset],[0 16],'r','LineWidth',linewidth);
            ylabel('kHz','fontsize',fontsize);
            xlabel('Absolute time in rawsong (msec)','fontsize',labelfontsize);
            title([fn,' NOTE #',num2str(i)],'fontsize',labelfontsize,'interpreter','none');
            axis('tight')
            xlimits = get(gca,'xlim');
            
            %% exemplar rawsong clip with corresponding onset and offset from dtw
            subplot(3,1,3);hold on;
            clip = abs(notespecs(i).clip);
            %spectrograms were computed after raw data was padded 
            clip = [NaN(specparams.NFFT-specparams.Nadvance,1); clip; NaN(specparams.NFFT-specparams.Nadvance,1)];
            plot((0:length(clip)-1)/32,clip./max(clip),'k');
            plot([exempedges(1) exempedges(1)],[0 1],'g','LineWidth',linewidth);
            plot([exempedges(2) exempedges(2)],[0 1],'g','LineWidth',linewidth);
            plot([ampsegonset ampsegonset],[0 1],'r','LineWidth',linewidth);
            plot([ampsegoffset ampsegoffset],[0 1],'r','LineWidth',linewidth);
            ylabel('normalized amp','fontsize',fontsize);
            xlabel('Absolute time in rawsong (msec)','fontsize',labelfontsize);
            set(gca,'xlim',xlimits);

            pause;
            clf(h1);
        end
    end
end
        
