function stimset = save_krank_stimuli(stimset, direc, basename, varargin)
% save a standardized directory containting krank-format stimuli, an
% auto-generated rc file, and

% set persistant paramteres
zero_pad_length = 4;
fs_out = 40e3;
add_null = false;
for karg = 1:2:length(varargin)
    switch lower(varargin{karg})
        case 'zero_pad_length'
            zero_pad_length = varargin{karg+1};
        case 'fs_out'
            fs_out = varargin{karg+1};
        case 'stim_order'
            stim_order = varargin{karg+1};
        case 'add_null'
            add_null = varargin{karg+1};
    end
end
input_fs = stimset.samprate; % get original samplerate and set new samplerate to 40e3
stimset.samprate = fs_out;
stimcount = length(stimset.stims);
% if specified, add a null trial
if add_null
    stimcount = stimcount+1;
    stimset.stims(stimcount).name = 'null';
    stimset.stims(stimcount).type = 'null';
    stimset.stims(stimcount).tag = 'null';
    stimset.stims(stimcount).signal = zeros(round(1*input_fs),1);
    stimset.stims(stimcount).length = length(stimset.stims(stimcount).signal);
    stimset.stims(stimcount).onset = 0;
    stimset.stims(stimcount).offset = length(stimset.stims(stimcount).signal);
end
stimset.numstims = stimcount;

mkdir([direc, '/', basename])
direc = [direc, '/', basename, '/'];
for kstim = 1:length(stimset.stims)
    % filter wf and set to correct level
    wf = apply_krank_filters(stimset.stims(kstim).signal, input_fs, 'db', 85, 'zero_pad_length', zero_pad_length, 'fs_out', fs_out);
    
    % assmble stim information 
    stimset.stims(kstim).signal = wf;
    stimset.stims(kstim).length = length(wf);
    stimset.stims(kstim).onset = floor(zero_pad_length * stimset.samprate);
    stimset.stims(kstim).offset = length(wf) - ceil(zero_pad_length * stimset.samprate);
    
    % assemble file name
    fname = [basename, '_', stimset.stims(kstim).name];
    if isfield(stimset.stims(kstim),'tag')
        tag = stimset.stims(kstim).tag;
        fname = [fname, '_', tag];
    end
    if isfield(stimset.stims(kstim), 'p_time')
        time_string = strrep(num2str(stimset.stims(kstim).p_time), '.','p');
        fname = [fname, '_time', time_string];
    end
    if isfield(stimset.stims(kstim), 'p_frequency')
        freq_string = strrep(num2str(stimset.stims(kstim).p_frequency), '.','p');
        fname = [fname, '_freq', freq_string];
    end
    if isfield(stimset.stims(kstim), 'p_sweeprate')
        rate_string = strrep(num2str(stimset.stims(kstim).p_sweeprate), '.','p');
        fname = [fname, '_sr', rate_string];
    end
    if isfield(stimset.stims(kstim), 'p_switched')
        s_string = strrep(num2str(stimset.stims(kstim).p_switched), '.','p');
        fname = [fname, '_switch', s_string];
    end
    
    % set data back to stimset
    fname = [fname, '.raw'];
    stimset.stims(kstim).fname = fname;
    
    %
    % generate file name
    write_krank_file(wf, [direc, fname])
end


stimset.total_length_est = 0;
for k=1:length(stimset.stims)
    stimset.total_length_est = stimset.total_length_est + (stimset.stims(kstim).length / stimset.samprate);
end

%  stimset.stims = rmfield(stimset.stims, 'signal'); % remove signals and save
save([direc, basename, '_stimset.mat'], 'stimset');
write_krank_script([direc], basename, stimset)


