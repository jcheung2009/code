function dur_strct = plot_notes_KB(notes, elts, dur_data)

%plots up raw durations for the notes listed in the string "notes"
%elts contains the labels for each row of durations in dur_data

%elts and dur_data must have same number of rows
if length(elts) ~= size(dur_data, 1)
   disp('number of note labels must = number of data rows')
   return
end   


%deal with version compatibility issues...
ver_num=version('-release');
ver_num=str2num(ver_num);
if ver_num >= 13
    xticks='xticklabel';
else
    xticks='xticklabel';
end


%open and hold figure
h_durs = figure;
hold on
set(gca,xticks,[])

cnt = 0;
for i = 1:length(notes)
    if isletter(notes(i))
        cnt  = 1+cnt;
       %find row number of data labeled by current note
         note_row = find(elts == notes(i));
       %find durations of current note, number of this note, mean and
       %std
         durs = dur_data(note_row,:);
         durs = nonzeros(durs);
         n = length(durs);
         %if there were no notes, skip data display
         if n ~= 0
            mean_dur = mean(durs);
            std_dur = std(durs);
            dur_strct{cnt}.label = char(notes(i));
            dur_strct{cnt}.mean = mean_dur;
            dur_strct{cnt}.std = std_dur;
           %display data to screen
            disp([notes(i),'   ',num2str(mean_dur),'   ',num2str(std_dur),'   ',num2str(n)]);
           %plot data
            plot(cnt*ones(size(durs)),durs,'+')
            line([cnt-.25,cnt+.25],[mean_dur, mean_dur],'color','m')
            line([cnt-.25,cnt+.25],[mean_dur+3.5*std_dur, mean_dur+3*std_dur],...
                 'color','m',...
                 'linestyle','--')
            line([cnt-.25,cnt+.25],[mean_dur-3.5*std_dur, mean_dur-3*std_dur],...
                 'color','m',...
                 'linestyle','--')
            text(cnt,max(durs)+10,['(', num2str(n), ')'],...
                 'horizontalalignment','center')
            ylim = get(gca,'ylim');
            ylim(2) = max(ylim(2), max(durs)+8); 
            set(gca,'ylim',[0 ylim(2)]);
         end
            
         %set label on x axis
         set(gca,'xtick',[1:cnt])
         old_xticklabel = get(gca,xticks);
         set(gca,xticks,[old_xticklabel; notes(i)])
     end                       
end

hold off

