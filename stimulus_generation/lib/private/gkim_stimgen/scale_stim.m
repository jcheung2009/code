function stim_scaled = scale_stim(stim,MAX_DA,MIN_DA,MAX_GAUSS_WIDTH)

% Rescale filtered stim 
% Saturate data so it will fit into a short int
stim_mean = mean(stim)
stim_rms  = sqrt(var(stim - stim_mean))

gain = MAX_DA/(MAX_GAUSS_WIDTH*stim_rms);


stim_scaled = round(gain*(stim - stim_mean));
pclip_idx = find(stim_scaled>MAX_DA);
npclip = length(pclip_idx)
stim_scaled(pclip_idx) = MAX_DA;
nclip_idx = find(stim_scaled<MIN_DA);
nnclip = length(nclip_idx)
stim_scaled(nclip_idx) = MIN_DA;
nclip = npclip + nnclip

disp(['Number of points clipped: ', int2str(nclip), ', ', ...
      num2str(100*nclip/length(stim)),'%'])

