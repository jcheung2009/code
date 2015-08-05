function [entVar] = entVariance_batch(batchsongs)
% Gets syllables and labels from batchfile
batch_fid = fopen(batchsongs,'r');

global train_path
global filetype
%global do_fltflt

sylls = [];
index =[];
labelIndex = [];
id=[];

numsongs = 1000;
entVar = zeros(1,numsongs);
i = 1;
while 1
    %get soundfile name
    soundfile = fscanf(batch_fid,'%s',1);
    %end when there are no more notefiles
    if isempty(soundfile)
        break
    end

    if (~(soundfile(1)=='/'))&(~strcmp(train_path,pwd))
        soundfile=[train_path,soundfile];
    end
    if (soundfile(end-4:end)=='.filt')   % if the batch file is of .filt files...
        notefile=[soundfile(1:end-5),'.not.mat'];
        filtfile=soundfile;
        if ~strcmp(filetype,'filt')
            disp('Filetype .filt found.')
        end
        filetype='filt';
    else
        if (soundfile(end-4:end)=='.cbin')  % if the batch file is of .cbin files...
            notefile=[soundfile, '.not.mat'];
            filtfile=[soundfile, '.filt'];
            if ~(strcmp(filetype,'obs0r')|strcmp(filetype,'obs1r'))
                disp('Filetype .cbin found.')
            end
            filetype='obs0r';
        else                              % if the files end in neither .cbin nor .filt
            notefile=[soundfile, '.not.mat'];
            filtfile=[soundfile, '.filt'];
            if ~(strcmp(filetype,'w'))
                disp('Assuming wave file format (file does not end in .cbin or .filt)')
            end
            filetype='w';
        end
    end
    % Skip file if it doesn't exist or has no .not.mat file
    if ~((exist(soundfile)|exist(filtfile)) & exist(notefile))
        %disp(['Skipping ', soundfile, ' (file or .not.mat file does not exist)'])
        continue
    end

    % Read filt file if it exists, otherwise read,resample if necessary, and filter raw song, saving a copy
    if exist(filtfile)
        [filtsong, fs]=read_filt(filtfile);
    else
        disp([' Bandpass Filtering' soundfile ': F_low = 750   F_high = 15000'])
        if(strcmp('w',filetype))
            [song,fs] = wavread(soundfile);
            disp('found wav file... using wavread()');
        else
            [song,fs]=soundin('', soundfile, filetype);
        end
        length(song);
        filtsong=bandpass(song,fs,2000,10000,'hanningffir'); %%%%%changed from 8000
        length(filtsong);
        write_filt(filtfile, filtsong, fs);
    end


    load(notefile); % i.e. the .not.mat file

    %     if(size(labels,2)> 1);
    if(length(strmatch('a',labels')) > 1)
        disp(['calculating entropy variance for ' soundfile]);
        [spec t f] = plotspect(filtsong,fs,0);
        entvect = rolling_ent(log(abs(spec)));
      
        %zeroRows = findvals(entvect,0.995);
        %entvect = entvect';
        %zeroRows = zeroRows';
        
        %entvect_nozero = removerows(entvect,zeroRows); % omit silences / gaps
        %entvect = entvect_nozero';
        entVar(i) = var(entvect);
        i = i+1;
    end
    %
    %     %make sure labels is a column vector
    %     [x,y]=size(labels);
    %     if y > x
    %         labels=labels';
    %     end
    %
    %     disp(['Processing ' soundfile ' . . .']);
    %
    %     % convert onsets and offsets from ms to samples
    %     if do_fltflt
    %         on = fix(.008*fs+onsets.*fs/1000);
    %         off = fix(.008*fs+offsets.*fs/1000);
    %     else
    %         on = fix(onsets.*fs/1000);
    %         off = fix(offsets.*fs/1000);
    %     end
    %
    %     % normalize the amplitude of the syllables
    %     %%    filtsong=normalize_sylls(filtsong, on, off);
    %
    %     % For each syllable in the song file
    %     for i = 1:size(labels,1)
    %         % Skip certain labels
    %         if labels(i)=='0'|labels(i)=='-'
    %             continue
    %         end
    %         length(filtsong);
    %         off(i)
    %         if length(filtsong(on(i):off(i)))>750
    %             % Add syll
    %             sylls = [sylls; {filtsong((on(i)):off(i))}];
    %             % Add label to index if it isn't there already
    %             if isempty(labelIndex) | isempty(find(labelIndex == labels(i)))
    %                 labelIndex = [labelIndex; labels(i)];
    %             end
    %             % add label to index of sylls, in numerical form
    %             index = [index; find(labelIndex == labels(i))];
    %             id = [id; {soundfile},{onsets(i)}];
    %
    %         else
    %
    %             tooshort=1;
    %         end
    %     end
end

entVar = entVar(1:i-1);