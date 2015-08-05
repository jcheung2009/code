function [] = syll_cv(dayvect,sylvect)
%
%
%
%

% r_vect = (0:1/length(dayvect):1);
% g_vect = (0:1/length(dayvect):1);
% b_vect = (0:1/length(dayvect):1);

dayaxis = zeros(1,length(dayvect));
dayaxis = '';

for index=1:length(sylvect);
    thesyl = [sylvect(index) '_'];
    
    fighandle = figure();set(fighandle,'Color','white');
    cv_vect = zeros(1,length(dayvect));
    
    for dindex=1:length(dayvect);
        
        theday = dayvect(dindex);
        daystr = ['TAF' num2str(theday)];
        
        in_str = [thesyl daystr];
        in_ptr = evalin('base',in_str);

%         r = r_vect(index);
%         g = g_vect(index);
%         b = b_vect(index);
        
        cv_vect(dindex) = cv(in_ptr);
    end
    
    figure(fighandle); title_str = ['Syllable ' thesyl ' CV']; title(title_str);
    barhandle = bar(cv_vect);
    ylabel(title_str);
    set(gca,'XTickLabel',dayvect);
    xlabel('Days Post Deafening');
    set(barhandle,'FaceColor',[.5 .5 .5]);
end