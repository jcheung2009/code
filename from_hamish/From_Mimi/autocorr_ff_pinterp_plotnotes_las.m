function [outFF]=autocorr_ff_pinterp_plotnotes(batch_in,note, ff_low, ff_hi)

% SK modified autocorr_ff_pinterp to plot syllables in which FF is
% calculated.
% MK modified this code so that the user can choose whether or not to 
%plot the syllables


outFF=[];
% set color axis for spectrogram
 caxis_low = 100;
 caxis_hi = 160; 
plot_fig=0;     %default is not to plot
% set higher limit of FF
%ff_hi = 1000; %Hz
%ff_low = 400

%function autocorr_ff_pinterp pulls out all examples of the sound defined by string 'note' 
%uses a batch file ('batch_in') of notefiles and calculates the ff of a 16ms segment of the
%syllable, which is determined by the user
%the user enters the start of the segment by entering either the ms_from_start of the syllable
%or the % in the syllable

%this function uses parts of pick_notes and get_songs to pull out the relevant 16ms segment of the
%syllable of interest, calculates the auto-covariance of the segment, and then
%looks for the distance, in frequency, between the 0th lag and the first peak (does parabolic
%interpolation of the peak given three points)

%us assumes that the file type is 'filt' b/c it requires that notes are already labeled 
%using uisonganal

%also assumes that you are in the subdirectory w/ the data files and the .filt files


clear ffreq
clear ff

k=1;
freq=cell(200,2);
savedata=0;         %does not save the data unless specified
    
     
%make sure note is a string
note=char(note);
 
%%Do you want to plot the syllables?
plotfigs=input('Do you want to plot each of the syllables?  1) yes  2) no?  (default=2) ','s');

if plotfigs == '1' | plotfigs == 'y'
    plot_fig=1;
end

%align by the start of the note if align_start==1
align_start=1;


%open batch_file
meta_fid=fopen([batch_in]);
if meta_fid==-1|batch_in==0
        disp('cannot open file')
        disp(batch_in)
end

%what part of the syllable to analyze?
syl_segment=input('1) percent from start,  2) ms from start,  or 3) ms from end?  ');


if length(syl_segment)==0
    disp('You must specify what part of the syllable to analyze')
%     break
elseif syl_segment==1
    percent_from_start=input('percent from start?  ');
elseif syl_segment==2
    ms_from_start=input('ms from start?   ');
elseif syl_segment==3
    ms_from_end=input('ms from end?   ');
end    


sample_size=input('Duration of the segment? (ms)  (default=16ms)  ');
if length(sample_size)==0
    sample_size=.016;                   %default is 16ms
else sample_size=sample_size/1000;      %convert to seconds
end

half_sample_size=sample_size/2


disp('Sample centered around the time entered')



%save the calculated ffreq?
savedata=input('Do you want to save the values calculated?  1)yes   2) no   ');
if savedata==1
    temp=input('Save as what?   ','s');
else disp ('Calculated frequencies will not be saved.')
end


while 1
    
       %get notefile namedf
       notefile=fscanf(meta_fid,'%s',1)
       %end when there are no more notefiles
       if isempty(notefile);
           break
       end
       
       %if notefile exists, get it
       if exist([notefile])
           load(notefile);          %Fs, onsets, offsets and labels are defined
       else disp(['cannot find ',notefile])
       end
       
       %count the number of matches in this file
       labels=makerow(labels);
%        matches=findstr(note,labels);   %returns the index for the note in the labels vector
%        keyboard
       [strt ender]=regexp(labels,note); % changed to RegExp, whm, 2013. 
        
%          keyboard
       num_matches=length(strt);

       %get soundfile name 
       end_file=findstr('.not.mat',notefile); 
       rootfile=notefile(1:end_file-1);
       soundfile=[rootfile,'.filt'];

%        keyboard
       %get the sound 
       for i=1:num_matches  %for all occurrencs of the syllable
            labels=makerow(labels);
            start_time=onsets(strt(i));      %syl onset
            start_time=start_time/1000;         
            end_time=offsets(ender(i)); 
            end_time=end_time/1000;             %syl offset
            
            %get raw data
            [rawsong,Fs]=soundin('',soundfile,'filt');
            [Laser,Fs]=ReadEvTAFFile(rootfile,1);
            
            %get the desired note
            syllable=rawsong(round(start_time*Fs):round(end_time*Fs));
%             keyboard;
            % plot the note
            if plot_fig==1
            figure
            specgram(syllable*5000,300,Fs,280,250)
            axis([0 length(syllable)/Fs 250 8000]);   
            colormap(flipud(gray));   
%              caxis([caxis_low caxis_hi])
%             caxis([0 125])
            hold on
            end
        
            %take a slice through the note
            if syl_segment==1
                note_length=end_time-start_time;        %note_length is in seconds
                temp_start_time=start_time+(note_length*(percent_from_start/100));
                seg_start_time=temp_start_time-half_sample_size;
                seg_end_time=temp_start_time+half_sample_size;
            elseif syl_segment==2                       %(ms from the start)
                temp_start_time=start_time+(ms_from_start/1000);     %(in seconds)
                seg_start_time=temp_start_time-half_sample_size;     %sample centered on time entered
                seg_end_time=(temp_start_time+half_sample_size);     %dur of segment determined by user 
             elseif syl_segment==3
                 temp_start_time=end_time-(ms_from_end/1000);     %(in seconds)
                 seg_start_time=temp_start_time-half_sample_size;     %sample centered on time entered
                 seg_end_time=(temp_start_time+half_sample_size);     %dur of segment determined by user 
            end  
            
            newstarttime=seg_start_time*Fs;
            newendtime=seg_end_time*Fs;
            note_segment=rawsong(round(newstarttime):round(newendtime));
            las_seg=Laser(round(newstarttime):round(newendtime));
            las_on=mean(las_seg);
             
            % draw lines for the period of FF calculation
            if plot_fig==1
                FFstart = (seg_start_time-start_time);
                FFend = (seg_end_time-start_time);
                xFFstart = [FFstart, FFstart];
                xFFend = [FFend, FFend];
                y = [250,8000];
                plot(xFFstart, y, '-r')
                plot(xFFend, y, '-r')
                hold on
            end
            
            %analyze the psd of selected song segment
            nfft=8192;
            window=8192;
            [Pxx,freq]=psd(note_segment);
%             Nyq=Fs/2;
            HighIdx=ff_hi/(Fs/2);
            [stop]=find(freq>HighIdx,1)-1;
            LowIdx=ff_low/(Fs/2);
            start=find(freq>LowIdx,1)+1;            
            start=floor(start)
            stop=floor(stop)
            
            [amp loc]=max(Pxx(start:stop));
            loc=loc+start-1;
            InterPolated=pinterp([freq(loc-1);freq(loc);freq(loc+1)],[Pxx(loc-1);Pxx(loc);Pxx(loc+1)]);
            ff=InterPolated*(Fs/2);
            
            %amp=sqrt(Pxx);
            
             
            %calculate the auto-covariance of the song segment
            %window in which it looks for the 1st peak after the 0th lag is 3-100 pts
%             autocorr=xcov(note_segment);
%             %acwin=autocorr(length(note_segment)+3:length(note_segment)+70);  %for ~400-7000 Hz if Fs=32000 Hz
            % if Fs=20000/ use range 3:40  
%              acwin=autocorr(length(note_segment)+3:length(note_segment)+floor(Fs/ff_low)); 
            
%             acwin=autocorr(length((note_segment+3)):length(note_segment+70));
%             stop=floor(Fs/ff_low);
%             start=ceil(Fs/ff_hi);
%             keyboard
%             [max1,loc]=max(acwin);
%             
%             if loc==1 | loc==length(acwin)
%                 peak=loc;   %parabolic interpolation req at least 3 points
%             else
%                 peak=pinterp([loc-1;loc;loc+1],[acwin(loc-1);acwin(loc);acwin(loc+1)]);
%             end     %peak values are real number
%             period=peak+2;   %using window from 3rd-100th point after peak;
%                             %if peak is the 3rd point,peak=1; so period=peak+2                
%             ff=Fs/period;
            %clip=autocorr(length(note_segment):end);        %take half b/c autocorr is 2X
                                                            %the size of the segment
%             OutFF=[OutFF ff]
           
            % SK modefied the follwoing part to limit highest ff value
try            
            if ff > ff_hi
                   while 1
                       q = 2
                       while q < (length(acwin)-1)
                           if acwin(q-1)<acwin(q) & acwin(q) > acwin(q+1) 
                               loc3 = q;
                               break
                           end
                           q = q+1
                       end
                       %[max1,loc2]=max(acwin(loc+5:length(acwin)));
                       %loc3 = loc2+loc+5;
                       peak=pinterp([loc3-1;loc3;loc3+1],[acwin(loc3-1);acwin(loc3);acwin(loc3+1)]);
                       period=peak+2;                               
                       ff=Fs/period;
                       if ff <= ff_hi
                           break
                       end
                       loc = loc3;
                   end
               end
catch
%     keyboard;
end;

            
           % Draw a line indicating the ff value
           if plot_fig==1
               x = linspace(FFstart,FFend,50);
               plot(x, ff, '-y')
          
               % title for the figure
                title( [soundfile,',  #',(int2str(i)), ',  ff = ', (num2str(ff))])
           end
           pause
           
           
            %save values in a cell array w/ 2 elements:  songname and fundfreq
            ffreq{k,1}=soundfile;
            ffreq{k,2}=ff;
            ffreq{k,3}=las_on;
            
            %ffreq{k,3}=peak;
            k=k+1;
         
            if savedata==1                      %save filename, ff, sample duration and place in syllable to mat file
                jj=['',temp];
                if syl_segment==1
                save (jj,'ffreq','percent_from_start','sample_size','note','Fs')    
                elseif syl_segment==2
                save (jj,'ffreq','ms_from_start','sample_size','note','Fs')     
                elseif syl_segment==3
                save (jj,'ffreq','ms_from_end','sample_size','note','Fs')    
                end
            end
                
            end
         
  end     
            
           
%     end %for loop
    

% end     %while loop

fclose(meta_fid);

% end

% display the results
[ffreq{:,2}]'

% plot the results
plot_durs=input('Do you want to plot the durations of the syllables?  1) yes 2) no (default=no)?  ','s')
if plot_durs=='1' | plot_durs=='yes' | plot_durs=='y'
    plot_notes4DS_UDS2(' ', ' ', [ffreq{:,2}]); 
    axis auto
end
