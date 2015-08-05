function [] = PlotOKrankDataSpks(DirectoryName, FileName, f_low, f_high, varargin)

if (nargin > 4)
    ChanNo = varargin{1};
    if (nargin > 5)
        Limits = varargin{2};
    end
end

cd(DirectoryName);

[datafid, message] = fopen(FileName, 'r');

[recfid, message] = fopen([FileName, '.rec'], 'r');

disp(FileName);

if ((recfid) > 0)
    while (~feof(recfid))
        tline = fgetl(recfid);
        if (strfind(tline, 'ai_freq'))
            ColonIndex = find(tline == ':');
            Fs = str2double(tline((ColonIndex + 1):end));
        end

        if (strfind(tline, 'n_ai_chan'))
            ColonIndex = find(tline == ':');
            NoOfChannels = str2double(tline((ColonIndex + 1):end));
        end
        
        if (strfind(tline, 'n_samples'))
            ColonIndex = find(tline == ':');
            NoOfSamples = str2double(tline((ColonIndex + 1):end));
            break;
        end
    end

    fclose(recfid);

    MainFigure = figure;
    set(gcf, 'Color', 'w');
    SubPlotAxes = axes('position',[0.15 0.15 0.75 0.8]);
    hold on;

    DataMax = 0;

    for i = 1:NoOfChannels,
        fseek(datafid, (i - 1) * 2, 'bof');
        [data, num_read] = fread(datafid, inf, 'uint16', (NoOfChannels - 1) * 2);
        data = (data - 32768) * 10/32768;
        if (num_read ~= NoOfSamples)
            disp(['No of samples does not match that of recfile: ',FileName]);
        end
        
        if (exist('Limits', 'var'))
            Begin = floor(Fs * Limits(1));
            if (Begin < 0)
                Begin = 0;
            end
            End = ceil(Fs * Limits(2));
            if (End > length(data))
                End = length(data);
            end
            data = data(Begin:End);
        end
        
        data=bandpass(data,Fs,f_low,f_high);
        
        time = 0:1/Fs:(length(data)/Fs);
        time(end) = [];

        if (i == 1)
%             plot_motif_spectrogram(data,Fs, MainFigure, SubPlotAxes)
            DataMax = 10000;
            data = data * 2000;
            data = data + DataMax + 1000 + abs(min(data));
            DataMax = max(data);
            DataMin=min(data);
            data=data./(DataMax-DataMin);
            data=data-mean(data); %0 center
            figure(MainFigure);
            axes(SubPlotAxes);
            hold on;
            plot(time, data);
        else
%            [b, a] = butter(3, [5/16000 15/16000]);
%            data1 = filtfilt(b, a, data);
%             [b, a] = butter(3, [300/16000 6000/16000]);
%             data = filtfilt(b, a, data);
            if (exist('ChanNo','var'))
                for (j = 1:length(ChanNo)),
                    if (ChanNo(j) == i)
%                          SpectrogramFigure = figure;
%                          set(gcf, 'Color', 'w');
%                          TestAxes = axes('position',[0.15 0.15 0.75 0.8]);
%                          hold on;
 
%                          plot_lfp_spectrogram(data, Fs, SpectrogramFigure, TestAxes);

                        figure(MainFigure);
                        axes(SubPlotAxes);
                        hold on;
                        
                        [Freq ISIs Times]=FindSpikes(data,Fs,0);
                        
                        Freq = Freq * 2000;
 %                       data1 = data1 * 2000;
 %                       data1 = data1 + DataMax + 1000 + abs(min(data));
                        Freq = Freq + max(Freq) + 1000 + abs(min(data));
                        
%                         DataMax = max(data);
%                         plot(time, data);
 %                       plot(time, data1, 'r');
                        plot(Times(1:end-1),Freq);
%                        FiltData = bandpass_fft_filter(data, 40, 10, Fs);
%                        FiltData = FiltData * 2000;
%                        FiltData = FiltData + DataMax + 1000 + abs(min(FiltData));
%                        DataMax = max(FiltData);
%                        plot(time, FiltData);
                        axis tight;
                    end
                end
            else
     
                        [Freq ISIs Times]=FindSpikes(data,Fs,0);
                        range=max(Freq)-min(Freq); 
                        Freq=Freq/range;
                        Freq = Freq + i;
%                         keyboard
 %                       data1 = data1 * 2000;
 %                       data1 = data1 + DataMax + 1000 + abs(min(data));
%                         Freq = Freq + max(Freq) + 1000 + abs(min(data));
                    figure(MainFigure);
                    axes(SubPlotAxes);
                    hold on;
                                  
%                         DataMax = max(data);
%                         plot(time, data);
 %                       plot(time, data1, 'r');
                        plot(Times(1:end-1)/1000,Freq);

                axis tight;
            end
        end
    end
    axis tight;

    figure(MainFigure);
    title(FileName);
    axes(SubPlotAxes);
    axis tight;
end

if ((datafid) > 0)
    fclose(datafid);
end
   


