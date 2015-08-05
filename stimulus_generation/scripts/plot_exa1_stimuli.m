close all; clear all; clc
pathdata = path_localsettings;


stimset = load(fullfile(pathdata.stim_path, 'exa1_physio_v2','exa1_physio_v2_stimset.mat'));
stimset = stimset.stimset;



for kstim = 1:7
    fig = figure('color','w','position',[0 0 1000 300]);
    plot_bird_spectrogram(stimset.stims(kstim).signal,stimset.samprate,'t_offset',-1)
    
    disp(stimset.stims(kstim).name)
    ylim([.5 10])
    xlim(.25 + [0 1.25])
    axis off

%     if ~(kstim==4 || kstim ==24)
%         axis off
%     else
%         set(gca,'ytick',[],'xtick',[])
%         ylabel('')
%         xlabel('')
%     end
    set(findall(fig,'-property','fontsize'),'fontsize',40); set(findall(gcf,'-property','linewidth'),'linewidth',3);
    saveas(fig,fullfile(pathdata.figure_folder,stimset.stims(kstim).name),'png')
end