function syllables = extract_syllables_from_song(wf, fs)

% options
plottest = false;
windowsize = 10e-3;
sigma = .3;
min_int = 10e-3;
min_dur = 50e-3;

% extract and filter envelope
envelope = abs(hilbert(wf));
envelope = filtfilt(ones(1,round(windowsize*fs)), 1, envelope);
envelope = envelope / max(envelope);

% calcualte statisics on envelope
threshold = sigma*std(envelope);

% % find syllable components
[onsets offsets] = segment_syllables(envelope(:), fs, min_int, min_dur, threshold);

% extract all syllables
for ksyl = 1:length(onsets)
    syllables(ksyl).wf = cut_segment(wf, fs, onsets(ksyl),offsets(ksyl));
    syllables(ksyl).dur = length(syllables(ksyl).wf)/fs;
    syllables(ksyl).onset = onsets(ksyl);
    syllables(ksyl).offset = offsets(ksyl);
end

if plottest
    t = (1:length(wf))/fs;
    subplot(3,1,1)
    plot(t,wf)
    subplot(3,1,2)
    plot(t,envelope)
    hold on
    plot([0 t(end)], [threshold threshold],'--r')
    for ksyl = 1:length(onsets)
        plot([onsets(ksyl) offsets(ksyl)],[.5,.5], 'g','linewidth',2)
    end
    
    for ksyl = 1:length(syllables)
        fig  = figure('color','w');
        generate_song_plot(syllables(ksyl).wf, fs);
        pause
        close(fig)
    end   
end
