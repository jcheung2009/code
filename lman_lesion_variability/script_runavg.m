batch = 'batchex';
%plot raw data and running average over days
config;
ff = load_batchf(batch);
numepochs = params.numepochs;
if ~isempty(numepochs)
    tbshft = repmat([0:length(ff)/numepochs-1],numepochs,1);
    tbshft = tbshft(:);
end
if isfield(params,'findnote')
    for  n = 1:length(params.findnote)
        fvfig(n)=figure;
    end
end
for i = 1:length(ff)
    if isempty(ff(i).name)
        continue
    end
    disp(ff(i).name);
    
    [mrk color] = markercolor(ff(i).name);
    
    if ~isempty(numepochs)
        tb=tbshft(i);
    else
        tb='';
    end
    
    if isfield(params,'findnote')  
        for n = 1:length(params.findnote)
            if ~exist([params.findnote(n).fvstruct,ff(i).name])
                load(['analysis/data_structures/',params.findnote(n).fvstruct,ff(i).name]);
            end
            fv = eval([params.findnote(n).fvstruct,ff(i).name]);
            pitchdat = [[fv(:).datenm]',[fv(:).mxvals]'];
            pitchdat(:,1) = jc_tb(pitchdat(:,1),7,0)+(tb*24*3600);
            nstd = 4;
            pitchdat = jc_removeoutliers(pitchdat,nstd,1);
            figure(fvfig(n));hold on;
            subtightplot(2,1,1,0.07,0.08,0.15);hold on;
            h = plot(pitchdat(:,1),pitchdat(:,2),mrk);hold on
            xscale_hours_to_days(gca);
            xlabel('Days','fontweight','bold');
            ylabel('Frequency (Hz)','fontweight','bold')
            hrs = [floor(min(pitchdat(:,1))):3600:ceil(max(pitchdat(:,1)))];
            avg = NaN(length(hrs)-1,1);
            for idx = 1:length(hrs)-1
                ix = find(pitchdat(:,1)>=hrs(idx) & pitchdat(:,1)<=hrs(idx+1));
                if length(ix)>=15
                    avg(idx) = nanmean(pitchdat(ix,2));
                else
                    continue
                end
            end
            subtightplot(2,1,2,0.07,0.08,0.15);hold on;
            h2 = plot(hrs(1:end-1),avg,color,'linewidth',2);
            xscale_hours_to_days(gca);
            xlabel('Days','fontweight','bold');
            ylabel('Frequency (Hz)','fontweight','bold')
        end
    end
end