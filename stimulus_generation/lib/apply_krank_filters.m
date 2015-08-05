function wfout = apply_krank_filters(wf, fs, varargin)
% set default parameters
filter_info = struct;
filter_info.F_low = 200; % set lower cutoff hz
filter_info.F_high = 15e3; % set high cutoff hz
filter_info.type = 'hanningfir';

fs_out = 40e3;
plottest = false;
db = 85;
zero_pad_length = 1;
set_amp = 1;
if length(varargin) > 0
    for k=1:2:length(varargin)
        switch lower(varargin{k})
            case 'fs_out'
                fs_out = varargin{k+1};
            case 'high_cutoff'
                filter_info.F_high = varargin{k+1};
            case 'low_cutoff'
                filter_info.F_low = varargin{k+1};
            case 'plot'
                plottest = varargin{k+1};
            case 'db'
                db = varargin{k+1};
            case 'zero_pad_length'
                zero_pad_length = varargin{k+1};
            case 'set_amp'
                set_amp = varargin{k+1};
            otherwise
                disp(['Warning no argument', varargin{k}])
        end
    end
end
% resample song
fs = round(fs);
fs_out = round(fs_out);
div = gcd(fs, fs_out);
p = fs/div;
q = fs_out/div;
wfout = resample(wf, q, p);

% generate filter params
filter_params = filter_setup(filter_info, fs_out);

% filter song
wfout = filter_data(wfout, filter_params);

if set_amp
    % set amplitude
    wfout = set_rms_for_krank(wfout, db);
end

wfout = zero_pad(wfout, fs_out, zero_pad_length, zero_pad_length);

% add noise
wfout = wfout + set_rms_for_krank(randn(size(wfout)), 0);
if plottest
    % plot signal
    generate_song_plot(wfout/max(wfout*1.1),fs_out, 'sound',true);
end



