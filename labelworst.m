function labelworst(songs_fid)


% ****msb*** modified bretts labelblanks to label syllables with lowest confidence (requires that confidence vector be saved in .mat file)
% Interface for quickly labeling blank syllables in a batch of songs. The unlabeld syllable appears in 
% the center of the spectrogram (unless it is too near the beginning or end of the sound file) with a 
% few syllables on either side to provide contextual information. Pressing any letter will change the current
% label and pressing return will save the current label and move on to the next blank syllable. Pressing 'q' will 
% quit the program.

if ~nargin
    songs_fid = -1;
    songsfile = 0;
    while songs_fid == -1 | songsfile == 0 | isempty(songsfile)
        disp('Select Batchfile of Songs to be Labeled');
        [songsfile, pathname]=uigetfile('*','Select Batchfile of Songs to be Labeled');
        songs_fid=fopen([pathname, songsfile]);
        if songs_fid == -1 | songsfile == 0
            disp('cannot open file' )
            disp (songsfile)
        end
    end
else
    frewind(songs_fid)
end

quit = 0;

while ~quit
   %get songfile name
     songfile = fscanf(songs_fid,'%s',1);
   %end when there are no more notefiles 
     if isempty(songfile)
        break
     end
     
     filtfile = [songfile, '.filt'];
     notefile = [songfile, '.not.mat'];
     
    if ~(exist(songfile) & exist(notefile))
        disp(['Skipping ' songfile ' (file or notefile does not exist)']);
        continue
    end
    
    load(notefile);   
    [song, fs] = read_filt(filtfile);
    on = fix(onsets.*fs/1000);
    off = fix(offsets.*fs/1000);

    
    for i = 1:size(labels,1)
        if quit
            break
        end
        if labels(i) ~= '-'
            continue
        end
        
        if on(i) - 10000 < 0
            start = 1;
        else
            start = on(i) - 10000;
        end
        if off(i) + 10000 > size(song,1)
            stop = size(song,1);
        else
            stop = off(i) + 10000;
        end
            
        window = song(start:stop);
        
        specgram(window,128)
 
        winLabels = find(on < stop & off > start);
        
        for k = 1:size(winLabels,1)
            if winLabels(k)==i 
                continue 
            end
            xpos = ((on(winLabels(k))+off(winLabels(k))) / 2 - start) / 2;
            text(xpos, .9, labels(winLabels(k)), 'FontSize', 22, 'HorizontalAlignment', 'Center');
        end
        
        xpos = ((on(i)+off(i)) / 2 - start) / 2;
        labeltext = text(xpos, .9, labels(i), 'FontSize', 22, 'color', 'w', 'HorizontalAlignment', 'Center');
        
        while 1
            [x,y,key] = ginput(1);
            if isempty(key) | key == 13
                break
            elseif ~isempty(key) & strcmp(char(key),'q')        
                quit = 1;
                break
            elseif ~isempty(key)
                labels(i) = char(key);
                delete(labeltext);
                labeltext = text(xpos, .9, labels(i), 'FontSize', 22, 'color', 'w', 'HorizontalAlignment', 'Center');
            end
        end
    end

    eval(['save ', notefile,...
       ' Fs',' onsets',' offsets',' labels',...
       ' threshold',' min_int',' min_dur',' sm_win']);


end
 
close;
if quit
    disp('Quit before completion.')
else
    disp('All blank syllables labeled.');
end

if ~nargin 
    fclose(songs_fid);
end
