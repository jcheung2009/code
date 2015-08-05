function [avg_spec] = makeBatchAvg(batchsongs)
%
%
%
%   calculates spectral avg of last 1sec of files in batchsongs
%
%

batch_fid = fopen(batchsongs,'r');

global train_path
global filetype
%global do_fltflt
i = 1;
avg_spec = zeros(129,814); % note hardcoded size 
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
        filtsong=bandpass(song,fs,750,15000,'hanningffir'); %%%%%changed from 8000
        length(filtsong);
        write_filt(filtfile, filtsong, fs);
    end
    
    load(notefile); % i.e. the .not.mat file
    
    if(length(strmatch('a',labels')) > 1)
        %disp(['including ' soundfile ' in avg']);
        endsong = filtsong(length(filtsong)-(1*fs):length(filtsong));
        [spec t f] = plotspect(endsong,fs,0);
        avg_spec = avg_spec + spec;
   
        i = i+1;
    end
end
avg_spec = avg_spec ./ i;