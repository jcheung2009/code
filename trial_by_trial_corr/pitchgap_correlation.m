config;
shufftrials = 1000;
drug = 'naspm';%naspm
baselinecondition = 'saline';%saline in naspm, saline1 in saline
treatmentcondition = 'naspm';%naspm in naspm, saline2 in saline

trials = params.trial(arrayfun(@(x) strcmp(x.condition,drug),params.trial));
gapfordata = cell(1,2,2);
gapbackdata = cell(1,2,2);
for mtf = 1:length(params.findmotif)
    syllables = params.findmotif(mtf).syllables;
    motif = params.findmotif(mtf).motif;
    for i = 1:length(trials)
        load(['analysis/data_structures/',params.findmotif(mtf).motifstruct,trials(i).name]);
        load(['analysis/data_structures/',params.findmotif(mtf).motifstruct,trials(i).baseline]);
        basedata = eval([params.findmotif(mtf).motifstruct,trials(i).baseline]);
        testdata = eval([params.findmotif(mtf).motifstruct,trials(i).name]);
        
        %cut off washin time
        tb_cond = jc_tb([testdata(:).datenm]',7,0);
        tb_base = jc_tb([basedata(:).datenm]',7,0);
        if ~strcmp(drug,'saline') & ~strcmp(params.baseepoch,'morn')
            if ~isempty(trials(i).treattime)
                start_time = time2datenum(trials(i).treattime) + 5400;%1.5 hr buffer
            else
                start_time = tb_cond(1) + 5400; 
            end
            ind = find(tb_cond >= start_time);
            testdata = testdata(ind);
        else
            ind = find(tb_cond >= 5*3600);
            testdata = testdata(ind);
            ind = find(tb_base < 5*3600);
            basedata = basedata(ind);
        end
        
        
        for syllix = 1:length(syllables)
            mtfind = strfind(motif,syllables{syllix});
            for id = 1:length(mtfind)
                pitch = arrayfun(@(x) x.syllpitch(mtfind(id)),basedata,'un',1)';
                volume = log10(arrayfun(@(x) x.syllvol(mtfind(id)),basedata,'un',1)');
                pitch2 = arrayfun(@(x) x.syllpitch(mtfind(id)),testdata,'un',1)';
                volume2 = log10(arrayfun(@(x) x.syllvol(mtfind(id)),testdata,'un',1)');
                
                pitch = jc_removeoutliers(pitch,3);
                pitch2 = jc_removeoutliers(pitch2,3);
                volume = jc_removeoutliers(volume,3);
                volume2 = jc_removeoutliers(volume2,3);
                
                pitch2 = (pitch2-nanmean(pitch))./nanstd(pitch);
                pitch = (pitch-nanmean(pitch))./nanstd(pitch);
                volume2 = (volume2-nanmean(volume))./nanstd(volume);
                volume = (volume-nanmean(volume))./nanstd(volume);
                
                if mtfind(id) ~= length(motif)
                    gapdurfor1 = arrayfun(@(x) x.gaps(mtfind(id)),basedata,'un',1)';
                    gapdurfor2 = arrayfun(@(x) x.gaps(mtfind(id)),testdata,'un',1)';
                    gapdurfor2 = (gapdurfor2-nanmean(gapdurfor1))./nanstd(gapdurfor1);
                    gapdurfor1 = (gapdurfor1-nanmean(gapdurfor1))./nanstd(gapdurfor1);
                    
                    gapdurfor1 = jc_removeoutliers(gapdurfor1,3);
                    gapdurfor2 = jc_removeoutliers(gapdurfor2,3);
                    
                    gapfordata{1,1,1} = [gapfordata{1,1,1};pitch gapdurfor1];
                    gapfordata{1,1,2} = [gapfordata{1,1,1};volume gapdurfor1];
                    gapfordata{1,2,1} = [gapfordata{1,2,1};pitch2 gapdurfor2];
                    gapfordata{1,2,2} = [gapfordata{1,2,1};volume2 gapdurfor2];
                end
                if mtfind(id) ~= 1
                    gapdurback1 = arrayfun(@(x) x.gaps(mtfind(id)-1),basedata,'un',1)';
                    gapdurback2 = arrayfun(@(x) x.gaps(mtfind(id)-1),testdata,'un',1)';
                    gapdurback2 = (gapdurback2-nanmean(gapdurback1))./nanstd(gapdurback1);
                    gapdurback1 = (gapdurback1-nanmean(gapdurback1))./nanstd(gapdurback1);
                    
                    gapdurback1 = jc_removeoutliers(gapdurback1,3);
                    gapdurback2 = jc_removeoutliers(gapdurback2,3);
                    
                    gapbackdata{1,1,1} = [gapbackdata{1,1,1};pitch gapdurback1];
                    gapbackdata{1,1,2} = [gapbackdata{1,1,2};volume gapdurback1];
                    gapbackdata{1,2,1} = [gapbackdata{1,2,1};pitch2 gapdurback2];
                    gapbackdata{1,2,2} = [gapbackdata{1,2,2};volume2 gapdurback2];
                end
                
                %plot pitch vs gap correlations for each trial
                figure;hold on;
                if mtfind(id) ~= length(motif)
                    subplot(2,2,1);hold on;
                    plot(pitch,gapdurfor1,'k.');hold on;
                    plot(pitch2,gapdurfor2,'r.');
                    xlabel('pitch');ylabel('gap dur forward');
                    title(strjoin({num2str(mtfind(id)),trials(i).name}),...
                        'interpreter','none')
                    subplot(2,2,3);hold on;
                    plot(volume,gapdurfor1,'k.');hold on;
                    plot(volume2,gapdurfor2,'r.');hold on;
                    xlabel('volume');ylabel('gap dur forward');
                end
                if mtfind(id) ~= 1
                    subplot(2,2,2);hold on;
                    plot(pitch,gapdurback1,'k.');hold on;
                    plot(pitch2,gapdurback2,'r.');
                    xlabel('pitch');ylabel('gap dur back');
                    title(strjoin({num2str(mtfind(id)),trials(i).name}),...
                        'interpreter','none')
                    subplot(2,2,4);hold on;
                    plot(volume,gapdurback1,'k.');hold on;
                    plot(volume2,gapdurback2,'r.');hold on;
                    xlabel('volume');ylabel('gap dur forward');
                end
            end
        end
    end
end
                  
                   
                
                