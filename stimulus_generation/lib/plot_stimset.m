function plot_stimset(stimset)



max_length = max([stimset.stims(:).length])/stimset.samprate;

for kstim = 1:length(stimset.stims);
    fig = figure('color','w');
    t = (1:length(stimset.stims(kstim).signal))/stimset.samprate;
    subplot(3,1,1)
    plot_bird_ossiligram(t,stimset.stims(kstim).signal,'norm_type','none');
    tx = title(stimset.stims(kstim).name);
    set(tx,'interpreter','none')
    xlim([0 max_length])
    ylim([-3e3 3e3])
    subplot(3,1,2:3)
    plot_bird_spectrogram(stimset.stims(kstim).signal,stimset.samprate)
    xlim([0 max_length])
    
end
    