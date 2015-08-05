function wfout = apply_hop_filters(wf, fs, varargin)
% set default parameters
filter_info = struct;
filter_info.F_low = 200; % set lower cutoff hz
filter_info.F_high = 15e3; % set high cutoff hz
filter_info.type = 'hanningfir';

fs_out = 24414;
plottest = false;

db = 85;
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
            otherwise
                disp(['Warning no argument', varargin{k}])
        end
    end
end
wfout = wf;
% % generate filter params
% filter_params = filter_setup(filter_info, fs);
% 
% % filter song
% wfout = filter_data(wf, filter_params);

% % resample song
% div = gcd(fs, fs_out);
% p = fs/div;
% q = fs_out/div;
% wfout = resample(wfout, p, q);

% set amplitude
wfout = set_rms_for_hop(wfout, db);
% wfout = zero_pad(wfout, fs, 1, 1);
% 
% plot(wfout)
% % add noise
% wfout = wfout + set_rms_for_hop(randn(size(wfout)), 0);
if plottest
    % plot signal
    generate_song_plot(wfout/max(wfout*1.1),fs_out, 'sound',true);
end



