function [] = histplotscript(dayvect,sylvect)
%
% day vect is vector of TAF days, i.e. [0 1 3] would plot days 0, 1, and 3.
% sylvect is a vector of syllables: i.e. [a b i e]
%

fig_handle = figure();
set(fig_handle,'Color','white');
r_vect = (0:1/length(dayvect):1);
g_vect = (0:1/length(dayvect):1);
b_vect = (0:1/length(dayvect):1);

for index=1:length(dayvect)

    theday = dayvect(index);
    daystr = ['TAF' num2str(theday)];
    trace_color = 'b'; % need to update this for every new trace
    
    r = r_vect(index);
    g = g_vect(index);
    b = b_vect(index);
    
    for sindex=1:length(sylvect)

        thesyl = [sylvect(sindex) '_'];
        style_str = [trace_color '.-'];
        axis_str = [thesyl daystr 'axis'];
        hist_str = [thesyl daystr 'hist'];
        pdf_str = [thesyl daystr 'cum'];


        in_str = [thesyl daystr];
        in_ptr = evalin('base',in_str);
        [temphist tempcum tempaxis] = cumhist(in_ptr);
        %
        %         axis_ptr = evalin('base',axis_str);
        %         hist_ptr = evalin('base',hist_str);
        %         pdf_ptr = evalin('base',pdf_str);

        
        % plot histograms & cumulative histograms:
        figure(fig_handle);
        subplot(length(sylvect),2,(sindex*2)-1);
        hold all
        linehandle = plot(tempaxis,temphist,style_str);
        set(linehandle,'Color',[r g b]);
        set(linehandle,'LineWidth',1.5);
        set(gca,'LineWidth',1.2);
        hold off

        subplot(length(sylvect),2,(sindex*2));
        hold all
        linehandle = plot(tempaxis,tempcum,style_str);
        set(linehandle,'Color',[r g b]);
        set(linehandle,'LineWidth',1.5);
        set(gca,'LineWidth',1.2);
        hold off
        
        %         subplot(length(sylvect),2,index);
        %         hold on
        %         plot(axis_ptr,hist_ptr,style_str);
        %         hold off
        %
        %         subplot(length(sylvect),2,index+1);
        %         hold on
        %         plot(axis_ptr,pdf_ptr,style_str);
        %         hold off
    end

end