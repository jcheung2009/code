function extract_and_save_syllables(BIRDDIR)

% options
back_window = 25e-3; % set how far to step forward and backward around syllables
for_window = 25e-3;

% extract name of bird
idx = find(BIRDDIR=='/',2,'last');
params.birdname = BIRDDIR(idx(1)+1:idx(2)-1);

% query the directory and loop thru all the bird files
DIR = dir(BIRDDIR);
for kfile = 1:length(DIR)
    
    % if analysis is SAP type
    if (length(DIR(kfile).name)>20 && strcmp(DIR(kfile).name(end-18:end),'SAPFeatures_seg.mat'))
        
        
        disp(DIR(kfile).name)
        sapdata = load(fullfile(BIRDDIR,DIR(kfile).name));
        fs = sapdata.frequency;
        song_fname = fullfile(BIRDDIR,DIR(kfile).name(1:end-20));
        wf = read_raw_file(song_fname,'int16');      
        wf = filter_bandpass(wf,150,10e3,fs);
        
        params.songtype = DIR(kfile).name(1:3);
        params.fs = fs;
        for ksyl = 1:length(sapdata.SAPFeatures_seg.noteonset)
            idxs = [sapdata.SAPFeatures_seg.noteonset(ksyl)-back_window sapdata.SAPFeatures_seg.noteend(ksyl)+for_window];
            idxs = floor(idxs*sapdata.frequency);
            if idxs(1) > 0 && idxs(2) < length(wf)
                syl_wf = wf(idxs(1):idxs(2));
                syl_wf = 0.5*syl_wf / max(abs(syl_wf));
                
                % decide whether to save syllable
                %save_syllable(syl_wf, params);
                fig = generate_song_plot(syl_wf, fs)
                pause
                close(fig)
            end
        end
        
   end
    
    
    
end

end

%% subfunction
function save_syllable(syl_wf, params)
    fs_out = 44100;
    pathdata = path_localsettings;
    syllable_dir = fullfile(pathdata.stim_path, 'source_syllables');
    

    % find number of files (syllables) with birdname
    DIR=dir(fullfile(syllable_dir, [params.birdname, '*']));
    count = length(DIR);
    
    % resample wf
    if params.fs ~= fs_out
        fs = round(params.fs); 
        fs_out = round(fs_out);
        div = gcd(fs, fs_out);
        p = fs/div;
        q = fs_out/div;
        syl_wf = resample(syl_wf, q, p);
    end
    
    syl_name = [params.birdname, '_', num2str(count+1), '.wav'];
    wavwrite(syl_wf, fs_out, fullfile(syllable_dir, syl_name))  
    
end


